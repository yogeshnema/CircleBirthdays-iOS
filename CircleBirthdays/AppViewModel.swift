import CryptoKit
import Foundation
import Observation

enum AppScreen: Equatable {
    case login
    case dashboard
    case profiles
    case gallery
    case discussions
    case cookbook
    case traditions
    case memoryLane
    case familyTree
    case calendar
    case messages
    case chat(memberID: String)
    case familyGames
    case gameLobby(gameType: FamilyGameType)
    case gameSession(sessionID: String)
    case notifications
}

enum AppLanguage: String, CaseIterable {
    case english
    case hindi

    var toggleLabel: String {
        switch self {
        case .english:
            return "हिंदी"
        case .hindi:
            return "EN"
        }
    }
}

struct DashboardFamilyEvent: Identifiable, Equatable {
    enum EventType: String {
        case birthday
        case anniversary
        case remembrance
    }

    let id: String
    let member: Member
    let type: EventType
    let date: Date
    let daysUntil: Int
}

@MainActor
@Observable
final class AppViewModel {
    private enum SessionStore {
        static let userIDKey = "CircleBirthdays.session.userID"
        static let timestampKey = "CircleBirthdays.session.timestamp"
        static let duration: TimeInterval = 10 * 24 * 60 * 60
        static let languageKey = "CircleBirthdays.session.language"
    }

    private let memberRepository: MemberRepository
    private let socialRepository: SocialRepository

    var members: [Member] = []
    var pendingMembers: [Member] = []
    var memories: [MemoryPost] = []
    var discussions: [DiscussionThread] = []
    var recipes: [Recipe] = []
    var traditions: [Tradition] = []
    var milestones: [Milestone] = []
    var channels: [ChatChannel] = []
    var messages: [ChatMessage] = []
    var relationshipOverrides: [RelationshipOverride] = []
    var deletionRequests: [DeletionRequest] = []
    var activeGameSessions: [GameSession] = []
    var currentGameSession: GameSession?
    var notifications: [AppNotification] = []
    var currentUser: Member?
    var currentScreen: AppScreen = .login
    var isLoading = false
    var errorMessage: String?
    var loginError: String?
    var searchText = ""
    var repositoryStatus = FirebaseBootstrap.statusText
    var lastInboxRefreshAt: Date?
    var language: AppLanguage = UserDefaults.standard.string(forKey: SessionStore.languageKey).flatMap(AppLanguage.init(rawValue:)) ?? .english
    private var pushTokenObserver: NSObjectProtocol?
    private var inboxRefreshTask: Task<Void, Never>?
    private var autoRefreshTask: Task<Void, Never>?

    init(memberRepository: MemberRepository, socialRepository: SocialRepository) {
        self.memberRepository = memberRepository
        self.socialRepository = socialRepository
        pushTokenObserver = NotificationCenter.default.addObserver(
            forName: .circleBirthdaysPushTokenDidChange,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let token = notification.object as? String else { return }
            Task { @MainActor [weak self] in
                self?.syncCurrentUserPushToken(tokenOverride: token)
            }
        }
    }

    var todayBirthdays: [Member] {
        activeMembers.filter { member in
            guard let days = member.daysUntilBirthday() else { return false }
            return days == 0
        }
    }

    var upcomingBirthdays: [Member] {
        activeMembers
            .filter { member in
                guard let days = member.daysUntilBirthday() else { return false }
                return days <= 30
            }
            .sorted { ($0.daysUntilBirthday() ?? .max) < ($1.daysUntilBirthday() ?? .max) }
    }

    var todayEvents: [DashboardFamilyEvent] {
        familyEvents(withinDays: 0)
    }

    var upcomingEvents: [DashboardFamilyEvent] {
        familyEvents(withinDays: 7).filter { $0.daysUntil > 0 }
    }

    var activeMembers: [Member] {
        members.filter { !$0.isDeceased && $0.status == "APPROVED" }
    }

    var approvedMembers: [Member] {
        members.filter { $0.status == "APPROVED" }
    }

    var visibleMembers: [Member] {
        let resolved = FamilyUtils.populateAllLinks(
            members: approvedMembers,
            allMembers: members + pendingMembers,
            currentUser: currentUser
        )
        let source = searchText.isEmpty ? resolved : resolved.filter { $0.matches(searchText: searchText) }
        return source.sorted { lhs, rhs in
            if lhs.familyId == rhs.familyId {
                return lhs.name < rhs.name
            }
            return lhs.familyId < rhs.familyId
        }
    }

    var pendingCount: Int {
        pendingMembers.count
    }

    var resolvedPendingMembers: [Member] {
        FamilyUtils.populateAllLinks(
            members: pendingMembers,
            allMembers: members + pendingMembers,
            currentUser: currentUser
        )
    }

    var approvedMemories: [MemoryPost] {
        let isAdmin = currentUser?.isAdmin == true
        return memories.filter { isAdmin || $0.status == "APPROVED" }
    }

    var visibleDiscussions: [DiscussionThread] {
        let isAdmin = currentUser?.isAdmin == true
        return discussions.filter { isAdmin || $0.status == "APPROVED" }
    }

    var totalUnreadCount: Int {
        guard let currentUser else { return 0 }
        return channels.reduce(0) { $0 + ($1.unreadCount[currentUser.id] ?? 0) }
    }

    var inboxDebugSummary: String {
        let channelCount = channels.count
        let messageCount = messages.count
        let lastRefresh = lastInboxRefreshAt.map { $0.formatted(date: .omitted, time: .standard) } ?? "never"
        let userID = currentUser?.id ?? "none"
        return "Inbox: \(channelCount) channels, \(messageCount) messages, user \(userID), refreshed \(lastRefresh)"
    }

    var visibleChannels: [ChatChannel] {
        guard let currentUser else { return [] }
        return channels
            .filter { $0.userIds.contains(currentUser.id) }
            .sorted { $0.lastTimestamp > $1.lastTimestamp }
    }

    var pendingOverrideCount: Int {
        relationshipOverrides.count
    }

    var pendingDeletionCount: Int {
        deletionRequests.count
    }

    var visibleRecipes: [Recipe] {
        recipes.sorted { $0.timestamp > $1.timestamp }
    }

    var visibleTraditions: [Tradition] {
        traditions.sorted { $0.timestamp > $1.timestamp }
    }

    var visibleMilestones: [Milestone] {
        milestones.sorted {
            let lhsYear = Int($0.year) ?? 0
            let rhsYear = Int($1.year) ?? 0
            if lhsYear == rhsYear {
                return $0.timestamp > $1.timestamp
            }
            return lhsYear < rhsYear
        }
    }

    var visibleGameSessions: [GameSession] {
        activeGameSessions.sorted { $0.lastUpdated > $1.lastUpdated }
    }

    var unreadNotificationCount: Int {
        guard let currentUser else { return 0 }
        return notifications.filter { !$0.isRead(by: currentUser.id) }.count
    }

    var allResolvedMembers: [Member] {
        FamilyUtils.populateAllLinks(
            members: members + pendingMembers,
            allMembers: members + pendingMembers,
            currentUser: currentUser
        )
    }

    private var canRestoreSession: Bool {
        let defaults = UserDefaults.standard
        guard let timestamp = defaults.object(forKey: SessionStore.timestampKey) as? Date else {
            return false
        }
        return Date().timeIntervalSince(timestamp) <= SessionStore.duration
    }

    private func familyEvents(withinDays limit: Int, referenceDate: Date = .now) -> [DashboardFamilyEvent] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: referenceDate)
        let remembranceMembers = currentUser?.isAdmin == true ? members + pendingMembers : approvedMembers
        var events: [DashboardFamilyEvent] = []
        var anniversaryKeys = Set<String>()

        for member in activeMembers {
            if let event = recurringEvent(
                for: member,
                sourceDate: member.dateOfBirth,
                type: .birthday,
                idSuffix: "birthday",
                today: today,
                calendar: calendar
            ), event.daysUntil <= limit {
                events.append(event)
            }

            if let marriageDate = member.marriageDate,
               let event = recurringEvent(
                    for: member,
                    sourceDate: marriageDate,
                    type: .anniversary,
                    idSuffix: "anniversary",
                    today: today,
                    calendar: calendar
               ),
               event.daysUntil <= limit {
                let key = anniversaryKey(for: member)
                if !anniversaryKeys.contains(key) {
                    anniversaryKeys.insert(key)
                    events.append(event)
                }
            }
        }

        for member in remembranceMembers {
            if let bereavementDate = member.bereavementDate,
               let event = recurringEvent(
                    for: member,
                    sourceDate: bereavementDate,
                    type: .remembrance,
                    idSuffix: "remembrance",
                    today: today,
                    calendar: calendar
               ),
               event.daysUntil <= limit {
                events.append(event)
            }
        }

        return events.sorted {
            if $0.daysUntil == $1.daysUntil {
                return $0.member.name < $1.member.name
            }
            return $0.daysUntil < $1.daysUntil
        }
    }

    private func recurringEvent(
        for member: Member,
        sourceDate: String,
        type: DashboardFamilyEvent.EventType,
        idSuffix: String,
        today: Date,
        calendar: Calendar
    ) -> DashboardFamilyEvent? {
        guard let parsed = parseFlexibleDate(sourceDate, calendar: calendar) else { return nil }
        let month = calendar.component(.month, from: parsed)
        let day = calendar.component(.day, from: parsed)
        let year = calendar.component(.year, from: today)
        guard var eventDate = calendar.date(from: DateComponents(year: year, month: month, day: day)) else { return nil }
        if eventDate < today {
            guard let nextYear = calendar.date(byAdding: .year, value: 1, to: eventDate) else { return nil }
            eventDate = nextYear
        }
        let days = calendar.dateComponents([.day], from: today, to: calendar.startOfDay(for: eventDate)).day ?? .max
        return DashboardFamilyEvent(
            id: "\(member.id)-\(idSuffix)-\(calendar.component(.year, from: eventDate))",
            member: member,
            type: type,
            date: eventDate,
            daysUntil: days
        )
    }

    private func anniversaryKey(for member: Member) -> String {
        let familyId = member.familyId
        if familyId.hasSuffix("0") {
            return String(familyId.dropLast())
        }
        return familyId
    }

    private func parseFlexibleDate(_ string: String, calendar: Calendar) -> Date? {
        if let date = Member.isoDateFormatter.date(from: string) {
            return date
        }
        let separators = CharacterSet(charactersIn: "-/")
        let parts = string.components(separatedBy: separators).compactMap(Int.init)
        guard parts.count >= 2 else { return nil }
        let day = parts[0]
        let month = parts[1]
        let year = parts.count > 2 ? parts[2] : calendar.component(.year, from: .now)
        return calendar.date(from: DateComponents(year: year, month: month, day: day))
    }

    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            async let membersTask = memberRepository.fetchMembers()
            async let pendingTask = memberRepository.fetchPendingMembers()
            members = try await membersTask
            pendingMembers = try await pendingTask
            repositoryStatus = FirebaseBootstrap.statusText
            try await loadSocialState()
            try await loadRelationshipOverrides()
            try await loadDeletionRequests()
            restoreSessionIfPossible()
        } catch {
            if FirebaseBootstrap.isConfigured {
                errorMessage = error.localizedDescription
            } else {
                do {
                    let fallback = MockMemberRepository()
                    members = try await fallback.fetchMembers()
                    pendingMembers = try await fallback.fetchPendingMembers()
                    repositoryStatus = "Using bundled mock data"
                    memories = MockSocialData.memories()
                    discussions = MockSocialData.discussions()
                    recipes = MockSocialData.recipes()
                    traditions = MockSocialData.traditions()
                    milestones = MockSocialData.milestones()
                    channels = []
                    messages = []
                    relationshipOverrides = try await memberRepository.fetchRelationshipOverrides()
                    deletionRequests = try await socialRepository.fetchDeletionRequests()
                    restoreSessionIfPossible()
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        }

        isLoading = false
    }

    func refreshAllData() async {
        await load()

        if let currentUserID = currentUser?.id,
           let latestUser = members.first(where: { $0.id == currentUserID }) {
            currentUser = latestUser
        }
    }

    func refreshAllDataSilently() async {
        guard let currentUserID = currentUser?.id else { return }
        do {
            async let membersTask = memberRepository.fetchMembers()
            async let pendingTask = memberRepository.fetchPendingMembers()
            let fetchedMembers = try await membersTask
            let fetchedPending = try await pendingTask

            members = fetchedMembers
            pendingMembers = fetchedPending
            repositoryStatus = FirebaseBootstrap.statusText

            try await loadSocialState(showErrors: false)
            try await loadRelationshipOverrides()
            try await loadDeletionRequests()

            if let latestUser = members.first(where: { $0.id == currentUserID }) {
                currentUser = latestUser
            }
            await refreshNotifications(showErrors: false)
        } catch {
            // Automatic refresh should stay quiet; the foreground load and explicit actions still surface errors.
        }
    }

    func login(phoneNumber: String, password: String) {
        loginError = nil
        let normalizedInput = Self.normalizePhoneNumber(phoneNumber)

        guard !normalizedInput.isEmpty else {
            loginError = "Enter phone number."
            return
        }

        guard let user = members.first(where: {
            Self.normalizePhoneNumber($0.phoneNumber) == normalizedInput
        }) else {
            loginError = "Access denied: phone number not found."
            return
        }

        let isValid: Bool
        if let storedPassword = user.password, !storedPassword.isEmpty {
            isValid = Self.sha256(password) == storedPassword
        } else {
            isValid = password == "1234"
        }

        guard isValid else {
            loginError = "Incorrect password."
            return
        }

        currentUser = user
        currentScreen = .dashboard
        saveSession(for: user)
        syncCurrentUserPushToken()
        startInboxRefreshLoop()
        startAutoRefreshLoop()
        Task {
            await refreshInbox()
            await refreshNotifications()
        }
    }

    func logout() {
        stopInboxRefreshLoop()
        stopAutoRefreshLoop()
        currentUser = nil
        currentScreen = .login
        searchText = ""
        loginError = nil
        clearSession()
    }

    func toggleLanguage() {
        language = language == .english ? .hindi : .english
        UserDefaults.standard.set(language.rawValue, forKey: SessionStore.languageKey)
    }

    func showDashboard() {
        currentScreen = .dashboard
    }

    func showProfiles() {
        currentScreen = .profiles
    }

    func showGallery() {
        currentScreen = .gallery
    }

    func showDiscussions() {
        currentScreen = .discussions
    }

    func showCookbook() {
        currentScreen = .cookbook
    }

    func showTraditions() {
        currentScreen = .traditions
    }

    func showMemoryLane() {
        currentScreen = .memoryLane
    }

    func showFamilyTree() {
        currentScreen = .familyTree
    }

    func showCalendar() {
        currentScreen = .calendar
    }

    func showMessages() {
        currentScreen = .messages
        Task {
            await refreshInbox()
        }
    }

    func showNotifications() {
        currentScreen = .notifications
        Task {
            await refreshNotifications()
        }
    }

    func showFamilyGames() {
        currentScreen = .familyGames
        Task {
            await refreshGameSessions()
        }
    }

    func showGameLobby(gameType: FamilyGameType) {
        currentScreen = .gameLobby(gameType: gameType)
        Task {
            await refreshGameSessions()
        }
    }

    func openGame(sessionID: String) {
        currentScreen = .gameSession(sessionID: sessionID)
        Task {
            await refreshGameSession(sessionID: sessionID)
        }
    }

    func startChat(with member: Member) {
        currentScreen = .chat(memberID: member.id)
    }

    func member(for id: String) -> Member? {
        let source = members + pendingMembers
        guard let member = source.first(where: { $0.id == id }) else { return nil }
        return FamilyUtils.resolveLinks(member: member, allMembers: source, currentUser: currentUser)
    }

    func canEdit(_ member: Member) -> Bool {
        guard let currentUser else { return false }
        return currentUser.isAdmin
            || currentUser.isEditor
            || currentUser.id == member.id
            || isFamilyProfileBelow(member, currentUser: currentUser)
    }

    private func isFamilyProfileBelow(_ member: Member, currentUser: Member) -> Bool {
        let currentBaseId = normalizedFamilyBaseId(currentUser.familyId)
        let memberBaseId = normalizedFamilyBaseId(member.familyId)
        guard !currentBaseId.isEmpty, memberBaseId.count > currentBaseId.count else {
            return false
        }
        return memberBaseId.hasPrefix(currentBaseId)
    }

    private func normalizedFamilyBaseId(_ familyId: String) -> String {
        familyId.hasSuffix("0") ? String(familyId.dropLast()) : familyId
    }

    func otherMember(for channel: ChatChannel) -> Member? {
        guard let currentUser else { return nil }
        guard let otherID = channel.userIds.first(where: { $0 != currentUser.id }) else { return nil }
        return member(for: otherID)
    }

    func messages(for memberID: String) -> [ChatMessage] {
        guard let currentUser else { return [] }
        return messages
            .filter {
                ($0.senderId == currentUser.id && $0.receiverId == memberID)
                    || ($0.senderId == memberID && $0.receiverId == currentUser.id)
            }
            .sorted { $0.timestamp < $1.timestamp }
    }

    func sendMessage(_ text: String, to memberID: String) {
        guard let currentUser else { return }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let message = ChatMessage(
            id: UUID().uuidString,
            senderId: currentUser.id,
            senderName: currentUser.name,
            receiverId: memberID,
            text: trimmed,
            timestamp: .now
        )
        messages.append(message)

        let channelID = [currentUser.id, memberID].sorted().joined(separator: "_")
        if let index = channels.firstIndex(where: { $0.id == channelID }) {
            var unread = channels[index].unreadCount
            unread[memberID] = (unread[memberID] ?? 0) + 1
            channels[index] = ChatChannel(
                id: channelID,
                userIds: channels[index].userIds,
                lastMessage: trimmed,
                lastTimestamp: .now,
                unreadCount: unread
            )
        } else {
            channels.append(
                ChatChannel(
                    id: channelID,
                    userIds: [currentUser.id, memberID].sorted(),
                    lastMessage: trimmed,
                    lastTimestamp: .now,
                    unreadCount: [currentUser.id: 0, memberID: 1]
                )
            )
        }

        Task {
            do {
                try await socialRepository.sendMessage(message)
                await refreshInbox()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func saveRecipe(_ recipe: Recipe) async {
        do {
            try await socialRepository.submitRecipe(recipe)
            if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
                recipes[index] = recipe
            } else {
                recipes.append(recipe)
            }
            let recipients = activeMembers.map(\.id).filter { $0 != recipe.authorId }
            await PushNotificationCoordinator.shared.queueNotification(
                title: "New recipe shared",
                body: recipe.title,
                recipientIDs: recipients,
                category: "recipe",
                referenceID: recipe.id
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func uploadImageData(_ data: Data, folder: String) async -> String? {
        do {
            let url = try await socialRepository.uploadImageData(data, folder: folder)
            return url.isEmpty ? nil : url
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    func uploadAudioData(_ data: Data, folder: String, fileExtension: String) async -> String? {
        do {
            let url = try await socialRepository.uploadAudioData(data, folder: folder, fileExtension: fileExtension)
            return url.isEmpty ? nil : url
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    func saveMemory(_ memory: MemoryPost) async {
        do {
            try await socialRepository.submitMemory(memory)
            if let index = memories.firstIndex(where: { $0.id == memory.id }) {
                memories[index] = memory
            } else {
                memories.append(memory)
            }

            let recipients = activeMembers.map(\.id).filter { $0 != memory.userId }
            await PushNotificationCoordinator.shared.queueNotification(
                title: "New photo shared",
                body: memory.caption.isEmpty ? memory.userName : memory.caption,
                recipientIDs: recipients,
                category: "gallery",
                referenceID: memory.id
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteMemory(_ memory: MemoryPost) async {
        do {
            try await socialRepository.deleteMemory(memoryID: memory.id)
            memories.removeAll { $0.id == memory.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleMemoryReaction(_ memory: MemoryPost, emoji: String) async {
        guard let currentUser else { return }
        do {
            try await socialRepository.toggleMemoryReaction(memoryID: memory.id, emoji: emoji, userID: currentUser.id)
            if let index = memories.firstIndex(where: { $0.id == memory.id }) {
                var updated = memories[index]
                var reactions = updated.reactions
                var users = reactions[emoji] ?? []
                if let userIndex = users.firstIndex(of: currentUser.id) {
                    users.remove(at: userIndex)
                } else {
                    users.append(currentUser.id)
                }
                reactions[emoji] = users
                updated = MemoryPost(
                    id: updated.id,
                    userId: updated.userId,
                    userName: updated.userName,
                    imageURL: updated.imageURL,
                    caption: updated.caption,
                    timestamp: updated.timestamp,
                    status: updated.status,
                    reactions: reactions,
                    comments: updated.comments
                )
                memories[index] = updated
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addMemoryComment(_ memory: MemoryPost, text: String) async {
        guard let currentUser else { return }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let comment = PostComment(
            id: UUID().uuidString,
            userId: currentUser.id,
            userName: currentUser.name,
            text: trimmed,
            timestamp: .now
        )

        do {
            try await socialRepository.addMemoryComment(memoryID: memory.id, comment: comment)
            if let index = memories.firstIndex(where: { $0.id == memory.id }) {
                let updated = memories[index]
                memories[index] = MemoryPost(
                    id: updated.id,
                    userId: updated.userId,
                    userName: updated.userName,
                    imageURL: updated.imageURL,
                    caption: updated.caption,
                    timestamp: updated.timestamp,
                    status: updated.status,
                    reactions: updated.reactions,
                    comments: updated.comments + [comment]
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteRecipe(_ recipe: Recipe) async {
        do {
            try await socialRepository.deleteRecipe(recipeID: recipe.id)
            recipes.removeAll { $0.id == recipe.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleRecipeReaction(_ recipe: Recipe, emoji: String) async {
        guard let currentUser else { return }
        do {
            try await socialRepository.toggleRecipeReaction(recipeID: recipe.id, emoji: emoji, userID: currentUser.id)
            if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
                var updated = recipes[index]
                var reactions = updated.reactions
                var users = reactions[emoji] ?? []
                if let userIndex = users.firstIndex(of: currentUser.id) {
                    users.remove(at: userIndex)
                } else {
                    users.append(currentUser.id)
                }
                reactions[emoji] = users
                updated = Recipe(
                    id: updated.id,
                    title: updated.title,
                    authorId: updated.authorId,
                    authorName: updated.authorName,
                    category: updated.category,
                    description: updated.description,
                    ingredients: updated.ingredients,
                    instructions: updated.instructions,
                    imageURL: updated.imageURL,
                    reactions: reactions,
                    comments: updated.comments,
                    timestamp: updated.timestamp
                )
                recipes[index] = updated
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addRecipeComment(_ recipe: Recipe, text: String) async {
        guard let currentUser else { return }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let comment = PostComment(
            id: UUID().uuidString,
            userId: currentUser.id,
            userName: currentUser.name,
            text: trimmed,
            timestamp: .now
        )

        do {
            try await socialRepository.addRecipeComment(recipeID: recipe.id, comment: comment)
            if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
                var updated = recipes[index]
                updated = Recipe(
                    id: updated.id,
                    title: updated.title,
                    authorId: updated.authorId,
                    authorName: updated.authorName,
                    category: updated.category,
                    description: updated.description,
                    ingredients: updated.ingredients,
                    instructions: updated.instructions,
                    imageURL: updated.imageURL,
                    reactions: updated.reactions,
                    comments: updated.comments + [comment],
                    timestamp: updated.timestamp
                )
                recipes[index] = updated
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func saveTradition(_ tradition: Tradition) async {
        do {
            try await socialRepository.submitTradition(tradition)
            if let index = traditions.firstIndex(where: { $0.id == tradition.id }) {
                traditions[index] = tradition
            } else {
                traditions.append(tradition)
            }
            let recipients = activeMembers.map(\.id).filter { $0 != tradition.authorId }
            await PushNotificationCoordinator.shared.queueNotification(
                title: "New tradition shared",
                body: tradition.title,
                recipientIDs: recipients,
                category: "tradition",
                referenceID: tradition.id
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleTraditionReaction(_ tradition: Tradition, emoji: String) async {
        guard let currentUser else { return }
        do {
            try await socialRepository.toggleTraditionReaction(traditionID: tradition.id, emoji: emoji, userID: currentUser.id)
            if let index = traditions.firstIndex(where: { $0.id == tradition.id }) {
                var updated = traditions[index]
                var reactions = updated.reactions
                var users = reactions[emoji] ?? []
                if let userIndex = users.firstIndex(of: currentUser.id) {
                    users.remove(at: userIndex)
                } else {
                    users.append(currentUser.id)
                }
                reactions[emoji] = users
                updated = Tradition(
                    id: updated.id,
                    title: updated.title,
                    authorId: updated.authorId,
                    authorName: updated.authorName,
                    description: updated.description,
                    imageURL: updated.imageURL,
                    reactions: reactions,
                    comments: updated.comments,
                    timestamp: updated.timestamp
                )
                traditions[index] = updated
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addTraditionComment(_ tradition: Tradition, text: String) async {
        guard let currentUser else { return }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let comment = PostComment(
            id: UUID().uuidString,
            userId: currentUser.id,
            userName: currentUser.name,
            text: trimmed,
            timestamp: .now
        )

        do {
            try await socialRepository.addTraditionComment(traditionID: tradition.id, comment: comment)
            if let index = traditions.firstIndex(where: { $0.id == tradition.id }) {
                let updated = traditions[index]
                traditions[index] = Tradition(
                    id: updated.id,
                    title: updated.title,
                    authorId: updated.authorId,
                    authorName: updated.authorName,
                    description: updated.description,
                    imageURL: updated.imageURL,
                    reactions: updated.reactions,
                    comments: updated.comments + [comment],
                    timestamp: updated.timestamp
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteTradition(_ tradition: Tradition) async {
        do {
            try await socialRepository.deleteTradition(traditionID: tradition.id)
            traditions.removeAll { $0.id == tradition.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func saveMilestone(_ milestone: Milestone) async {
        do {
            try await socialRepository.submitMilestone(milestone)
            if let index = milestones.firstIndex(where: { $0.id == milestone.id }) {
                milestones[index] = milestone
            } else {
                milestones.append(milestone)
            }
            let recipients = activeMembers.map(\.id).filter { $0 != milestone.authorId }
            await PushNotificationCoordinator.shared.queueNotification(
                title: "New milestone shared",
                body: milestone.title,
                recipientIDs: recipients,
                category: "milestone",
                referenceID: milestone.id
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteMilestone(_ milestone: Milestone) async {
        do {
            try await socialRepository.deleteMilestone(milestoneID: milestone.id)
            milestones.removeAll { $0.id == milestone.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleMilestoneReaction(_ milestone: Milestone, emoji: String) async {
        guard let currentUser else { return }
        do {
            try await socialRepository.toggleMilestoneReaction(milestoneID: milestone.id, emoji: emoji, userID: currentUser.id)
            if let index = milestones.firstIndex(where: { $0.id == milestone.id }) {
                var updated = milestones[index]
                var reactions = updated.reactions
                var users = reactions[emoji] ?? []
                if let userIndex = users.firstIndex(of: currentUser.id) {
                    users.remove(at: userIndex)
                } else {
                    users.append(currentUser.id)
                }
                reactions[emoji] = users
                updated = Milestone(
                    id: updated.id,
                    title: updated.title,
                    description: updated.description,
                    year: updated.year,
                    imageURL: updated.imageURL,
                    audioURL: updated.audioURL,
                    location: updated.location,
                    timestamp: updated.timestamp,
                    authorId: updated.authorId,
                    authorName: updated.authorName,
                    visibilityType: updated.visibilityType,
                    familyContextId: updated.familyContextId,
                    reactions: reactions,
                    comments: updated.comments
                )
                milestones[index] = updated
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addMilestoneComment(_ milestone: Milestone, text: String) async {
        guard let currentUser else { return }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let comment = PostComment(
            id: UUID().uuidString,
            userId: currentUser.id,
            userName: currentUser.name,
            text: trimmed,
            timestamp: .now
        )

        do {
            try await socialRepository.addMilestoneComment(milestoneID: milestone.id, comment: comment)
            if let index = milestones.firstIndex(where: { $0.id == milestone.id }) {
                let updated = milestones[index]
                milestones[index] = Milestone(
                    id: updated.id,
                    title: updated.title,
                    description: updated.description,
                    year: updated.year,
                    imageURL: updated.imageURL,
                    audioURL: updated.audioURL,
                    location: updated.location,
                    timestamp: updated.timestamp,
                    authorId: updated.authorId,
                    authorName: updated.authorName,
                    visibilityType: updated.visibilityType,
                    familyContextId: updated.familyContextId,
                    reactions: updated.reactions,
                    comments: updated.comments + [comment]
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func markChatRead(with memberID: String) {
        guard let currentUser else { return }
        let channelID = [currentUser.id, memberID].sorted().joined(separator: "_")
        guard let index = channels.firstIndex(where: { $0.id == channelID }) else { return }

        var unread = channels[index].unreadCount
        unread[currentUser.id] = 0
        channels[index] = ChatChannel(
            id: channels[index].id,
            userIds: channels[index].userIds,
            lastMessage: channels[index].lastMessage,
            lastTimestamp: channels[index].lastTimestamp,
            unreadCount: unread
        )

        Task {
            do {
                try await socialRepository.markChatRead(channelID: channelID, userID: currentUser.id)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func saveMemberEdits(_ member: Member) async {
        guard let currentUser else { return }

        let savesDirectly = currentUser.isAdmin || currentUser.isEditor
        let existingMember = (members + pendingMembers).first { $0.id == member.id }
        let relationshipRequested = !savesDirectly && member.relationship != existingMember?.relationship
        let finalMember = Member(
            id: member.id,
            familyId: member.familyId,
            name: member.name,
            gender: member.gender,
            dateOfBirth: member.dateOfBirth,
            phoneNumber: member.phoneNumber,
            email: member.email,
            location: member.location,
            spouseName: member.spouseName,
            fatherName: member.fatherName,
            motherName: member.motherName,
            marriageDate: member.marriageDate,
            bereavementDate: member.bereavementDate,
            photoURL: member.photoURL,
            immediateFamily: member.immediateFamily,
            address: member.address,
            password: member.password,
            isAdmin: member.isAdmin,
            isEditor: member.isEditor,
            status: savesDirectly ? "APPROVED" : "PENDING",
            lastLoggedIn: member.lastLoggedIn,
            relationship: member.relationship,
            fcmToken: member.fcmToken,
            facebookURL: member.facebookURL,
            instagramURL: member.instagramURL,
            youtubeURL: member.youtubeURL
        )

        let finalWithRequester = relationshipRequested
            ? Member(
                id: finalMember.id,
                familyId: finalMember.familyId,
                name: finalMember.name,
                gender: finalMember.gender,
                dateOfBirth: finalMember.dateOfBirth,
                phoneNumber: finalMember.phoneNumber,
                email: finalMember.email,
                location: finalMember.location,
                spouseName: finalMember.spouseName,
                fatherName: finalMember.fatherName,
                motherName: finalMember.motherName,
                marriageDate: finalMember.marriageDate,
                bereavementDate: finalMember.bereavementDate,
                photoURL: finalMember.photoURL,
                immediateFamily: finalMember.immediateFamily,
                address: finalMember.address,
                password: finalMember.password,
                isAdmin: finalMember.isAdmin,
                isEditor: finalMember.isEditor,
                status: finalMember.status,
                lastLoggedIn: finalMember.lastLoggedIn,
                relationship: finalMember.relationship,
                fcmToken: finalMember.fcmToken,
                facebookURL: finalMember.facebookURL,
                instagramURL: finalMember.instagramURL,
                youtubeURL: finalMember.youtubeURL,
                manualRelationships: finalMember.manualRelationships,
                requestedBy: currentUser.id,
                requestedByName: currentUser.name,
                requestedRelationship: member.relationship
            )
            : finalMember

        do {
            try await memberRepository.saveMember(finalWithRequester, toPending: !savesDirectly)

            if savesDirectly {
                if let index = members.firstIndex(where: { $0.id == finalMember.id }) {
                    members[index] = finalMember
                } else {
                    members.append(finalMember)
                }
                pendingMembers.removeAll { $0.id == finalMember.id }
            } else {
                if let index = pendingMembers.firstIndex(where: { $0.id == finalMember.id }) {
                    pendingMembers[index] = finalWithRequester
                } else {
                    pendingMembers.append(finalWithRequester)
                }
            }

            if currentUser.id == finalMember.id {
                self.currentUser = finalWithRequester
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadSocialState(showErrors: Bool = true) async throws {
        do {
            async let memoriesTask = socialRepository.fetchMemories()
            async let discussionsTask = socialRepository.fetchDiscussions()
            async let recipesTask = socialRepository.fetchRecipes()
            async let traditionsTask = socialRepository.fetchTraditions()
            async let milestonesTask = socialRepository.fetchMilestones()
            memories = try await memoriesTask
            discussions = try await discussionsTask
            recipes = try await recipesTask
            traditions = try await traditionsTask
            milestones = try await milestonesTask
            activeGameSessions = (try? await socialRepository.fetchActiveGameSessions()) ?? []
            if let currentUser {
                notifications = (try? await socialRepository.fetchNotifications(userID: currentUser.id, isAdmin: currentUser.isAdmin)) ?? []
            }
            await refreshInbox(showErrors: showErrors)

            if memories.isEmpty {
                memories = MockSocialData.memories()
            }
            if discussions.isEmpty {
                discussions = MockSocialData.discussions()
            }
            if recipes.isEmpty {
                recipes = MockSocialData.recipes()
            }
            if traditions.isEmpty {
                traditions = MockSocialData.traditions()
            }
            if milestones.isEmpty {
                milestones = MockSocialData.milestones()
            }
        } catch {
            if FirebaseBootstrap.isConfigured {
                throw error
            }

            memories = MockSocialData.memories()
            discussions = MockSocialData.discussions()
            recipes = MockSocialData.recipes()
            traditions = MockSocialData.traditions()
            milestones = MockSocialData.milestones()
            channels = []
            messages = []
            activeGameSessions = []
            notifications = []
        }
    }

    func refreshNotifications(showErrors: Bool = true) async {
        guard let currentUser else {
            notifications = []
            return
        }

        do {
            notifications = try await socialRepository.fetchNotifications(userID: currentUser.id, isAdmin: currentUser.isAdmin)
        } catch {
            if FirebaseBootstrap.isConfigured && showErrors {
                errorMessage = error.localizedDescription
            } else {
                notifications = (try? await MockSocialRepository().fetchNotifications(userID: currentUser.id, isAdmin: currentUser.isAdmin)) ?? []
            }
        }
    }

    func markNotificationRead(_ notification: AppNotification) async {
        guard let currentUser else { return }
        do {
            try await socialRepository.markNotificationRead(notificationID: notification.id, userID: currentUser.id)
            notifications = notifications.map { existing in
                guard existing.id == notification.id, !existing.readBy.contains(currentUser.id) else { return existing }
                return AppNotification(
                    id: existing.id,
                    type: existing.type,
                    title: existing.title,
                    body: existing.body,
                    timestamp: existing.timestamp,
                    readBy: existing.readBy + [currentUser.id],
                    targetUserId: existing.targetUserId,
                    senderId: existing.senderId,
                    senderName: existing.senderName,
                    relatedId: existing.relatedId,
                    isAdminOnly: existing.isAdminOnly,
                    topic: existing.topic,
                    metadata: existing.metadata
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func markAllNotificationsRead() async {
        guard let currentUser else { return }
        let unread = notifications.filter { !$0.isRead(by: currentUser.id) }
        for notification in unread {
            try? await socialRepository.markNotificationRead(notificationID: notification.id, userID: currentUser.id)
        }
        await refreshNotifications()
    }

    func changePassword(_ newPassword: String) async {
        let trimmed = newPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let currentUser, !trimmed.isEmpty else { return }

        do {
            let hashed = Self.sha256(trimmed)
            try await memberRepository.updatePassword(userID: currentUser.id, passwordHash: hashed)
            self.currentUser = currentUser.copy(password: hashed)
            if let index = members.firstIndex(where: { $0.id == currentUser.id }) {
                members[index] = members[index].copy(password: hashed)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshGameSessions() async {
        do {
            activeGameSessions = try await socialRepository.fetchActiveGameSessions()
        } catch {
            if FirebaseBootstrap.isConfigured {
                errorMessage = error.localizedDescription
            } else {
                activeGameSessions = []
            }
        }
    }

    func refreshGameSession(sessionID: String) async {
        do {
            currentGameSession = try await socialRepository.fetchGameSession(sessionID: sessionID)
        } catch {
            if FirebaseBootstrap.isConfigured {
                errorMessage = error.localizedDescription
            }
        }
    }

    func createGameSession(gameType: FamilyGameType) async {
        guard let currentUser else { return }
        do {
            let sessionID = try await socialRepository.createGameSession(gameType: gameType, player: currentUser)
            await refreshGameSessions()
            openGame(sessionID: sessionID)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func joinGameSession(_ session: GameSession) async {
        guard let currentUser else { return }
        do {
            try await socialRepository.joinGameSession(sessionID: session.id, player: currentUser)
            await refreshGameSessions()
            openGame(sessionID: session.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateGameState(sessionID: String, state: [String: Any], nextTurnID: String?, winnerID: String? = nil) async {
        do {
            try await socialRepository.updateGameState(sessionID: sessionID, state: state, nextTurnID: nextTurnID, winnerID: winnerID)
            await refreshGameSession(sessionID: sessionID)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func refreshInbox(showErrors: Bool = true) async {
        guard let currentUser else {
            channels = []
            messages = []
            return
        }

        do {
            let inbox = try await socialRepository.fetchInbox(for: currentUser.id)
            channels = inbox.channels.isEmpty ? MockSocialData.channels().filter { $0.userIds.contains(currentUser.id) } : inbox.channels
            messages = inbox.messages.isEmpty ? MockSocialData.messages().filter { $0.senderId == currentUser.id || $0.receiverId == currentUser.id } : inbox.messages
            lastInboxRefreshAt = .now
        } catch {
            if FirebaseBootstrap.isConfigured && showErrors {
                errorMessage = error.localizedDescription
            } else {
                channels = MockSocialData.channels().filter { $0.userIds.contains(currentUser.id) }
                messages = MockSocialData.messages().filter { $0.senderId == currentUser.id || $0.receiverId == currentUser.id }
                lastInboxRefreshAt = .now
            }
        }
    }

    func submitRelationshipOverride(for target: Member, relationship: String) async {
        guard let currentUser else { return }
        let override = RelationshipOverride(
            id: "\(currentUser.id)_\(target.id)",
            observerId: currentUser.id,
            observerName: currentUser.name,
            targetId: target.id,
            targetName: target.name,
            relationship: relationship,
            status: "PENDING"
        )

        do {
            try await memberRepository.submitRelationshipOverride(override)
            relationshipOverrides.append(override)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func approveRelationshipOverride(_ override: RelationshipOverride) async {
        do {
            try await memberRepository.approveRelationshipOverride(override)
            relationshipOverrides.removeAll { $0.id == override.id }

            if let index = members.firstIndex(where: { $0.id == override.targetId }) {
                let member = members[index]
                var manual = member.manualRelationships
                manual[override.observerId] = override.relationship
                members[index] = Member(
                    id: member.id,
                    familyId: member.familyId,
                    name: member.name,
                    gender: member.gender,
                    dateOfBirth: member.dateOfBirth,
                    phoneNumber: member.phoneNumber,
                    email: member.email,
                    location: member.location,
                    spouseName: member.spouseName,
                    fatherName: member.fatherName,
                    motherName: member.motherName,
                    marriageDate: member.marriageDate,
                    bereavementDate: member.bereavementDate,
                    photoURL: member.photoURL,
                    immediateFamily: member.immediateFamily,
                    address: member.address,
                    password: member.password,
                    isAdmin: member.isAdmin,
                    isEditor: member.isEditor,
                    status: member.status,
                    lastLoggedIn: member.lastLoggedIn,
                    relationship: member.relationship,
                    fcmToken: member.fcmToken,
                    facebookURL: member.facebookURL,
                    instagramURL: member.instagramURL,
                    youtubeURL: member.youtubeURL,
                    manualRelationships: manual,
                    requestedBy: nil,
                    requestedByName: nil,
                    requestedRelationship: nil
                )
            }

            await PushNotificationCoordinator.shared.queueNotification(
                title: "Relationship approved",
                body: "\(override.targetName) approved \(override.relationship) for \(override.observerName).",
                recipientIDs: [override.observerId],
                category: "relationship-approval",
                referenceID: override.id
            )
            await PushNotificationCoordinator.shared.scheduleLocalNotification(
                title: "Relationship approved",
                body: "\(override.targetName) approved \(override.relationship) for \(override.observerName)."
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func requestDeletion(collectionName: String, docId: String, title: String, reason: String = "Requested from iOS") async {
        guard let currentUser else { return }
        let request = DeletionRequest(
            id: "\(currentUser.id)_\(collectionName)_\(docId)",
            collectionName: collectionName,
            docId: docId,
            title: title,
            reason: reason,
            requestedBy: currentUser.id,
            requestedByName: currentUser.name,
            timestamp: .now,
            status: "PENDING"
        )

        do {
            try await socialRepository.submitDeletionRequest(request)
            deletionRequests.append(request)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func approveDeletionRequest(_ request: DeletionRequest) async {
        do {
            try await socialRepository.resolveDeletionRequest(request, approved: true)
            deletionRequests.removeAll { $0.id == request.id }
            try await loadSocialState()
            await PushNotificationCoordinator.shared.queueNotification(
                title: "Deletion approved",
                body: "\(request.title) was approved for removal.",
                recipientIDs: [request.requestedBy],
                category: "deletion-approval",
                referenceID: request.id
            )
            await PushNotificationCoordinator.shared.scheduleLocalNotification(
                title: "Deletion approved",
                body: "\(request.title) was approved for removal."
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func rejectDeletionRequest(_ request: DeletionRequest) async {
        do {
            try await socialRepository.resolveDeletionRequest(request, approved: false)
            deletionRequests.removeAll { $0.id == request.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadRelationshipOverrides() async throws {
        relationshipOverrides = try await memberRepository.fetchRelationshipOverrides()
    }

    private func loadDeletionRequests() async throws {
        deletionRequests = try await socialRepository.fetchDeletionRequests()
    }

    private func restoreSessionIfPossible() {
        guard currentUser == nil, canRestoreSession else { return }
        let defaults = UserDefaults.standard
        guard let userID = defaults.string(forKey: SessionStore.userIDKey) else { return }
        guard let user = members.first(where: { $0.id == userID }) else { return }
        currentUser = user
        currentScreen = .dashboard
        syncCurrentUserPushToken()
        startInboxRefreshLoop()
        startAutoRefreshLoop()
        Task {
            await refreshInbox()
            await refreshNotifications()
        }
    }

    private func saveSession(for user: Member) {
        let defaults = UserDefaults.standard
        defaults.set(user.id, forKey: SessionStore.userIDKey)
        defaults.set(Date(), forKey: SessionStore.timestampKey)
    }

    private func syncCurrentUserPushToken(tokenOverride: String? = nil) {
        guard let currentUser = currentUser else { return }
        let token = tokenOverride ?? PushNotificationCoordinator.shared.fcmToken ?? PushNotificationCoordinator.shared.deviceToken
        guard let token, !token.isEmpty else { return }
        guard currentUser.fcmToken != token else { return }

        let updatedUser = currentUser.copy(fcmToken: token)
        self.currentUser = updatedUser

        Task {
            do {
                try await memberRepository.updatePushToken(
                    userID: updatedUser.id,
                    token: token,
                    toPending: updatedUser.status == "PENDING"
                )
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func clearSession() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: SessionStore.userIDKey)
        defaults.removeObject(forKey: SessionStore.timestampKey)
    }

    private func startInboxRefreshLoop() {
        inboxRefreshTask?.cancel()
        guard currentUser != nil else { return }

        inboxRefreshTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 5_000_000_000)
                if Task.isCancelled { break }
                await self?.refreshInbox(showErrors: false)
            }
        }
    }

    private func stopInboxRefreshLoop() {
        inboxRefreshTask?.cancel()
        inboxRefreshTask = nil
    }

    private func startAutoRefreshLoop() {
        autoRefreshTask?.cancel()
        guard currentUser != nil else { return }

        autoRefreshTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 30_000_000_000)
                if Task.isCancelled { break }
                await self?.refreshAllDataSilently()
            }
        }
    }

    private func stopAutoRefreshLoop() {
        autoRefreshTask?.cancel()
        autoRefreshTask = nil
    }

    private static func sha256(_ value: String) -> String {
        let digest = SHA256.hash(data: Data(value.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private static func normalizePhoneNumber(_ value: String) -> String {
        let digits = value.filter(\.isNumber)

        if digits.count > 10 {
            return String(digits.suffix(10))
        }

        return digits
    }
}
