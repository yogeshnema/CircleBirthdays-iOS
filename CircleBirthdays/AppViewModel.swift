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
    case aiCardGenerator(memberID: String, eventType: DashboardFamilyEvent.EventType)
    case emergency
    case businessDirectory
    case achievements
    case activityLog
    case loginLog
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

struct CommunityAchievement: Identifiable, Equatable {
    let id: String
    let memberName: String
    let memberId: String?
    let title: String
    let description: String
    let date: String
    let location: String
    let mapsLink: String
    let imageURL: String
    let timestamp: Date
    let addedBy: String
}

@MainActor
@Observable
final class AppViewModel {
    private enum SessionStore {
        static let userIDKey = "CircleBirthdays.session.userID"
        static let timestampKey = "CircleBirthdays.session.timestamp"
        static let duration: TimeInterval = 10 * 24 * 60 * 60
        static let languageKey = "CircleBirthdays.session.language"
        static let treeIDKey = "CircleBirthdays.session.currentTreeID"
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
    var businesses: [FamilyBusiness] = []
    var channels: [ChatChannel] = []
    var messages: [ChatMessage] = []
    var relationshipOverrides: [RelationshipOverride] = []
    var deletionRequests: [DeletionRequest] = []
    var signupRequests: [SignupRequest] = []
    var activeGameSessions: [GameSession] = []
    var currentGameSession: GameSession?
    var notifications: [AppNotification] = []
    var communityAchievements: [CommunityAchievement] = []
    var currentUser: Member?
    var currentScreen: AppScreen = .login
    var isLoading = false
    var errorMessage: String?
    var loginError: String?
    var searchText = ""
    var repositoryStatus = FirebaseBootstrap.statusText
    var lastInboxRefreshAt: Date?
    var lastFullSyncAt: Date?
    var isSyncingAll = false
    var language: AppLanguage = UserDefaults.standard.string(forKey: SessionStore.languageKey).flatMap(AppLanguage.init(rawValue:)) ?? .english
    var currentTreeId: String = UserDefaults.standard.string(forKey: SessionStore.treeIDKey) ?? "primary"
    private var pushTokenObserver: NSObjectProtocol?
    private var inboxRefreshTask: Task<Void, Never>?
    private var autoRefreshTask: Task<Void, Never>?
    private let fullSyncIntervalNanoseconds: UInt64 = 30 * 60 * 1_000_000_000

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
        dashboardActiveMembers.filter { member in
            guard let days = member.daysUntilBirthday() else { return false }
            return days == 0
        }
    }

    var upcomingBirthdays: [Member] {
        dashboardActiveMembers
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
        members.filter { !$0.isDeceased && $0.status.isApprovedStatus }
    }

    var dashboardActiveMembers: [Member] {
        activeMembers.filter { member in
            currentTreeId == "primary"
                ? (member.treeId.isEmpty || member.treeId == "primary" || member.isPrimaryTree)
                : member.treeId == currentTreeId || member.id == currentTreeId
        }
    }

    var canSwitchTreeView: Bool {
        currentUser?.secondaryTreeEnabled == true
    }

    var approvedMembers: [Member] {
        members.filter { $0.status.isApprovedStatus }
    }

    var dashboardApprovedMembers: [Member] {
        approvedMembers.filter { member in
            currentTreeId == "primary"
                ? (member.treeId.isEmpty || member.treeId == "primary" || member.isPrimaryTree)
                : member.treeId == currentTreeId || member.id == currentTreeId
        }
    }

    var dashboardMembersIncludingPending: [Member] {
        (members + pendingMembers).filter { member in
            currentTreeId == "primary"
                ? (member.treeId.isEmpty || member.treeId == "primary" || member.isPrimaryTree)
                : member.treeId == currentTreeId || member.id == currentTreeId
        }
    }

    var visibleMembers: [Member] {
        let resolved = FamilyUtils.populateAllLinks(
            members: dashboardApprovedMembers,
            allMembers: dashboardMembersIncludingPending,
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
        dashboardPendingMembers.count
    }

    var approvalPendingCount: Int {
        pendingCount + pendingSignupRequestCount + pendingContentApprovalCount + pendingOverrideCount + pendingDeletionCount
    }

    var pendingSignupRequestCount: Int {
        signupRequests.filter { $0.normalizedStatus.isPendingStatus }.count
    }

    var pendingContentApprovalCount: Int {
        pendingMemories.count
            + pendingDiscussions.count
            + pendingRecipes.count
            + pendingTraditions.count
            + pendingMilestones.count
    }

    var dashboardPendingMembers: [Member] {
        if hasAdminPrivileges {
            return pendingMembers
        }
        return pendingMembers.filter { member in
            currentTreeId == "primary"
                ? (member.treeId.isEmpty || member.treeId == "primary" || member.isPrimaryTree)
                : member.treeId == currentTreeId || member.id == currentTreeId
        }
    }

    var resolvedPendingMembers: [Member] {
        FamilyUtils.populateAllLinks(
            members: dashboardPendingMembers,
            allMembers: dashboardMembersIncludingPending,
            currentUser: currentUser
        )
    }

    var approvedMemories: [MemoryPost] {
        let isAdmin = hasAdminPrivileges
        return memories.filter { isAdmin || $0.status.isApprovedStatus }
    }

    var pendingMemories: [MemoryPost] {
        memories.filter { $0.status.isPendingStatus }.sorted { $0.timestamp > $1.timestamp }
    }

    var visibleDiscussions: [DiscussionThread] {
        let isAdmin = hasAdminPrivileges
        return discussions.filter { isAdmin || $0.status.isApprovedStatus }
    }

    var pendingDiscussions: [DiscussionThread] {
        discussions.filter { $0.status.isPendingStatus }.sorted { $0.timestamp > $1.timestamp }
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
        let isAdmin = hasAdminPrivileges
        return recipes
            .filter { isAdmin || $0.status.isApprovedStatus }
            .sorted { $0.timestamp > $1.timestamp }
    }

    var pendingRecipes: [Recipe] {
        recipes.filter { $0.status.isPendingStatus }.sorted { $0.timestamp > $1.timestamp }
    }

    var hasAdminPrivileges: Bool {
        currentUser?.isAdmin == true
    }

    var isPrimaryAdminLogin: Bool {
        hasAdminPrivileges
    }

    var visibleTraditions: [Tradition] {
        let isAdmin = hasAdminPrivileges
        return traditions
            .filter { isAdmin || $0.status.isApprovedStatus }
            .sorted { $0.timestamp > $1.timestamp }
    }

    var pendingTraditions: [Tradition] {
        traditions.filter { $0.status.isPendingStatus }.sorted { $0.timestamp > $1.timestamp }
    }

    var visibleMilestones: [Milestone] {
        let isAdmin = hasAdminPrivileges
        return milestones.filter { isAdmin || $0.status.isApprovedStatus }.sorted {
            let lhsYear = Int($0.year) ?? 0
            let rhsYear = Int($1.year) ?? 0
            if lhsYear == rhsYear {
                return $0.timestamp > $1.timestamp
            }
            return lhsYear < rhsYear
        }
    }

    var pendingMilestones: [Milestone] {
        milestones.filter { $0.status.isPendingStatus }.sorted { $0.timestamp > $1.timestamp }
    }

    var visibleBusinesses: [FamilyBusiness] {
        businesses
            .filter { belongsToCurrentTree($0.treeId) }
            .sorted { $0.timestamp > $1.timestamp }
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
        let remembranceMembers = hasAdminPrivileges ? dashboardMembersIncludingPending : dashboardApprovedMembers
        var events: [DashboardFamilyEvent] = []
        var anniversaryKeys = Set<String>()

        for member in dashboardActiveMembers {
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
               isActiveAnniversaryMember(member),
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

    private func isActiveAnniversaryMember(_ member: Member) -> Bool {
        guard !member.isDeceased else { return false }
        guard let partner = anniversaryPartner(for: member) else { return true }
        return !partner.isDeceased
    }

    private func anniversaryPartner(for member: Member) -> Member? {
        let partnerId = partnerFamilyId(for: member.familyId)
        return dashboardMembersIncludingPending.first { $0.familyId == partnerId }
    }

    private func partnerFamilyId(for familyId: String) -> String {
        familyId.hasSuffix("0") ? String(familyId.dropLast()) : familyId + "0"
    }

    private func normalizedTreeId(_ treeId: String?) -> String {
        guard let treeId, !treeId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return "primary"
        }
        return treeId
    }

    private func belongsToCurrentTree(_ treeId: String?) -> Bool {
        normalizedTreeId(treeId) == normalizedTreeId(currentTreeId)
    }

    private func upsertBusiness(_ business: FamilyBusiness) {
        if let index = businesses.firstIndex(where: { $0.id == business.id }) {
            businesses[index] = business
        } else {
            businesses.insert(business, at: 0)
        }
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
            try await loadSignupRequests()
            try await loadRelationshipOverrides()
            try await loadDeletionRequests()
            lastFullSyncAt = .now
            preloadRemoteMedia()
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
                    signupRequests = (try? await fallback.fetchSignupRequests()) ?? []
                    relationshipOverrides = try await memberRepository.fetchRelationshipOverrides()
                    deletionRequests = try await socialRepository.fetchDeletionRequests()
                    lastFullSyncAt = .now
                    preloadRemoteMedia()
                    restoreSessionIfPossible()
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        }

        isLoading = false
    }

    func refreshAllData() async {
        guard !isSyncingAll else { return }
        isSyncingAll = true
        defer { isSyncingAll = false }

        await load()

        if let currentUserID = currentUser?.id,
           let latestUser = members.first(where: { $0.id == currentUserID }) {
            currentUser = latestUser
        }
        lastFullSyncAt = .now

        let mediaURLStrings = remoteMediaURLStrings
        let fileURLStrings = remoteFileURLStrings
        Task {
            await Self.refreshRemoteMediaCache(
                mediaURLStrings: mediaURLStrings,
                fileURLStrings: fileURLStrings,
                forceRefresh: true
            )
        }
    }

    func refreshAllDataSilently() async {
        guard let currentUserID = currentUser?.id else { return }
        do {
            async let membersTask = memberRepository.fetchMembers()
            async let pendingTask = memberRepository.fetchPendingMembers()
            async let signupRequestsTask = memberRepository.fetchSignupRequests()
            let fetchedMembers = try await membersTask
            let fetchedPending = try await pendingTask
            let fetchedSignupRequests = try await signupRequestsTask

            members = fetchedMembers
            pendingMembers = fetchedPending
            signupRequests = fetchedSignupRequests
            repositoryStatus = FirebaseBootstrap.statusText

            try await loadSocialState(showErrors: false)
            try await loadRelationshipOverrides()
            try await loadDeletionRequests()

            if let latestUser = members.first(where: { $0.id == currentUserID }) {
                currentUser = latestUser
            }
            await refreshNotifications(showErrors: false)
            preloadRemoteMedia()
            lastFullSyncAt = .now
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

        let loginTimestamp = Int64(Date().timeIntervalSince1970 * 1000)
        let loggedInUser = memberWithUpdatedLogin(user, timestamp: loginTimestamp)
        currentUser = loggedInUser
        if !user.secondaryTreeEnabled, currentTreeId != "primary" {
            switchTree("primary")
        }
        currentScreen = .dashboard
        replaceLocalMember(loggedInUser)
        saveSession(for: loggedInUser)
        syncCurrentUserPushToken()
        startInboxRefreshLoop()
        startAutoRefreshLoop()
        Task {
            try? await memberRepository.updateLastLoggedIn(userID: user.id, timestamp: loginTimestamp)
            await refreshInbox()
            await refreshNotifications()
        }
    }

    func submitSignupRequest(name: String, parentName: String, mobileNumber: String, email: String) async -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedParent = parentName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMobile = mobileNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty, !trimmedParent.isEmpty, !Self.normalizePhoneNumber(trimmedMobile).isEmpty else {
            loginError = "Enter name, parent name, and mobile number."
            return false
        }

        let normalizedMobile = Self.normalizePhoneNumber(trimmedMobile)
        if members.contains(where: { Self.normalizePhoneNumber($0.phoneNumber) == normalizedMobile }) {
            loginError = "This mobile number already exists. Please login with this number."
            return false
        }

        let suggestion = suggestedMember(forName: trimmedName, parentName: trimmedParent)
        let request = SignupRequest(
            id: "signup-\(UUID().uuidString)",
            name: trimmedName,
            parentName: trimmedParent,
            mobileNumber: trimmedMobile,
            email: trimmedEmail,
            status: "PENDING",
            requestedAt: Int64(Date().timeIntervalSince1970 * 1000),
            suggestedMemberID: suggestion?.id,
            suggestedMemberName: suggestion?.name
        )

        do {
            try await memberRepository.submitSignupRequest(request)
            signupRequests.insert(request, at: 0)
            loginError = nil
            return true
        } catch {
            loginError = error.localizedDescription
            return false
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

    func switchTree(_ treeId: String) {
        currentTreeId = treeId.isEmpty ? "primary" : treeId
        UserDefaults.standard.set(currentTreeId, forKey: SessionStore.treeIDKey)
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

    func showAICardGenerator(for member: Member, eventType: DashboardFamilyEvent.EventType) {
        currentScreen = .aiCardGenerator(memberID: member.id, eventType: eventType)
    }

    func showNearestAICardGenerator() {
        let eligible = (todayEvents + upcomingEvents)
            .filter { $0.type == .birthday || $0.type == .anniversary }
            .sorted { $0.daysUntil < $1.daysUntil }

        guard let event = eligible.first else {
            errorMessage = "No birthday or anniversary is coming up this week."
            return
        }

        showAICardGenerator(for: event.member, eventType: event.type)
    }

    func showBusinessDirectory() {
        currentScreen = .businessDirectory
    }

    func addBusiness(_ business: FamilyBusiness) async {
        guard let currentUser else { return }
        let timestamp = business.timestamp == 0 ? Int64(Date().timeIntervalSince1970 * 1000) : business.timestamp
        let finalBusiness = FamilyBusiness(
            id: business.id,
            name: business.name,
            ownerName: business.ownerName,
            contactNumber: business.contactNumber,
            type: business.type,
            address: business.address,
            locationLink: business.locationLink,
            latitude: business.latitude,
            longitude: business.longitude,
            addedBy: currentUser.id,
            treeId: currentTreeId,
            timestamp: timestamp
        )

        do {
            try await socialRepository.submitBusiness(finalBusiness, treeId: currentTreeId)
            let savedBusiness: FamilyBusiness?
            if finalBusiness.id.isEmpty {
                let fetchedBusinesses = try await socialRepository.fetchBusinesses()
                businesses = fetchedBusinesses
                savedBusiness = fetchedBusinesses.first { $0.timestamp == timestamp && $0.addedBy == currentUser.id }
            } else {
                savedBusiness = finalBusiness
            }
            if let savedBusiness {
                upsertBusiness(savedBusiness)
            } else {
                businesses = try await socialRepository.fetchBusinesses()
            }
            await PushNotificationCoordinator.shared.queueNotification(
                title: "New Business Added",
                body: "\(finalBusiness.ownerName) added their business: \(finalBusiness.name)",
                recipientIDs: activeMembers.map(\.id).filter { $0 != currentUser.id },
                category: "business",
                referenceID: finalBusiness.id
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteBusiness(_ business: FamilyBusiness) async {
        guard hasAdminPrivileges || business.addedBy == currentUser?.id else { return }
        do {
            try await socialRepository.deleteBusiness(businessID: business.id)
            businesses.removeAll { $0.id == business.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func showEmergency() {
        currentScreen = .emergency
    }

    func showAchievements() {
        currentScreen = .achievements
    }

    func saveAchievement(_ achievement: CommunityAchievement) {
        let finalAchievement = CommunityAchievement(
            id: achievement.id.isEmpty ? UUID().uuidString : achievement.id,
            memberName: achievement.memberName,
            memberId: achievement.memberId,
            title: achievement.title,
            description: achievement.description,
            date: achievement.date,
            location: achievement.location,
            mapsLink: achievement.mapsLink,
            imageURL: achievement.imageURL,
            timestamp: achievement.timestamp,
            addedBy: currentUser?.id ?? achievement.addedBy
        )

        if let index = communityAchievements.firstIndex(where: { $0.id == finalAchievement.id }) {
            communityAchievements[index] = finalAchievement
        } else {
            communityAchievements.insert(finalAchievement, at: 0)
        }
    }

    func deleteAchievement(_ achievement: CommunityAchievement) {
        guard hasAdminPrivileges || achievement.addedBy == currentUser?.id else { return }
        communityAchievements.removeAll { $0.id == achievement.id }
    }

    func showActivityLog() {
        guard isPrimaryAdminLogin else { return }
        currentScreen = .activityLog
    }

    func showLoginLog() {
        guard isPrimaryAdminLogin else { return }
        currentScreen = .loginLog
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
        return isPrimaryAdminLogin
            || currentUser.isEditor
            || currentUser.id == member.id
    }

    func canManageContent(authorId: String) -> Bool {
        hasAdminPrivileges
    }

    func canRequestContentDeletion(authorId: String) -> Bool {
        hasAdminPrivileges || currentUser?.id == authorId
    }

    var newContentStatus: String {
        hasAdminPrivileges ? "APPROVED" : "PENDING"
    }

    func savesMemberEditsDirectly(_ member: Member) -> Bool {
        guard let currentUser else { return false }
        return isPrimaryAdminLogin || currentUser.isEditor
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
            preloadRemoteMedia(for: [recipe.imageURL])
            if recipe.status.isApprovedStatus {
                let recipients = activeMembers.map(\.id).filter { $0 != recipe.authorId }
                await PushNotificationCoordinator.shared.queueNotification(
                    title: "New recipe shared",
                    body: recipe.title,
                    recipientIDs: recipients,
                    category: "recipe",
                    referenceID: recipe.id
                )
            }
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
            preloadRemoteMedia(for: [memory.imageURL])

            if memory.status.isApprovedStatus {
                let recipients = activeMembers.map(\.id).filter { $0 != memory.userId }
                await PushNotificationCoordinator.shared.queueNotification(
                    title: "New photo shared",
                    body: memory.caption.isEmpty ? memory.userName : memory.caption,
                    recipientIDs: recipients,
                    category: "gallery",
                    referenceID: memory.id
                )
            }
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

    func updateMemoryCaption(_ memory: MemoryPost, caption: String) async {
        guard currentUser?.id == memory.userId || hasAdminPrivileges else { return }
        let trimmed = caption.trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            try await socialRepository.updateMemoryCaption(memoryID: memory.id, caption: trimmed)
            if let index = memories.firstIndex(where: { $0.id == memory.id }) {
                let updated = memories[index]
                memories[index] = MemoryPost(
                    id: updated.id,
                    userId: updated.userId,
                    userName: updated.userName,
                    imageURL: updated.imageURL,
                    caption: trimmed,
                    timestamp: updated.timestamp,
                    status: updated.status,
                    reactions: updated.reactions,
                    comments: updated.comments
                )
            }
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
                let reactions = Self.toggledSingleReaction(updated.reactions, emoji: emoji, userID: currentUser.id)
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
                let reactions = Self.toggledSingleReaction(updated.reactions, emoji: emoji, userID: currentUser.id)
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
                    status: updated.status,
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
                    status: updated.status,
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
            preloadRemoteMedia(for: [tradition.imageURL])
            if tradition.status.isApprovedStatus {
                let recipients = activeMembers.map(\.id).filter { $0 != tradition.authorId }
                await PushNotificationCoordinator.shared.queueNotification(
                    title: "New tradition shared",
                    body: tradition.title,
                    recipientIDs: recipients,
                    category: "tradition",
                    referenceID: tradition.id
                )
            }
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
                let reactions = Self.toggledSingleReaction(updated.reactions, emoji: emoji, userID: currentUser.id)
                updated = Tradition(
                    id: updated.id,
                    title: updated.title,
                    authorId: updated.authorId,
                    authorName: updated.authorName,
                    description: updated.description,
                    imageURL: updated.imageURL,
                    reactions: reactions,
                    comments: updated.comments,
                    status: updated.status,
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
                    status: updated.status,
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

    func saveDiscussion(_ discussion: DiscussionThread) async {
        do {
            try await socialRepository.submitDiscussion(discussion)
            if let index = discussions.firstIndex(where: { $0.id == discussion.id }) {
                discussions[index] = discussion
            } else {
                discussions.append(discussion)
            }
            if discussion.status.isApprovedStatus {
                let recipients = activeMembers.map(\.id).filter { $0 != discussion.userId }
                await PushNotificationCoordinator.shared.queueNotification(
                    title: "New discussion",
                    body: discussion.title,
                    recipientIDs: recipients,
                    category: "discussion",
                    referenceID: discussion.id
                )
            }
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
            preloadRemoteMedia(for: [milestone.imageURL])
            preloadRemoteFiles(for: [milestone.audioURL])
            if milestone.status.isApprovedStatus {
                let recipients = activeMembers.map(\.id).filter { $0 != milestone.authorId }
                await PushNotificationCoordinator.shared.queueNotification(
                    title: "New milestone shared",
                    body: milestone.title,
                    recipientIDs: recipients,
                    category: "milestone",
                    referenceID: milestone.id
                )
            }
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

    func approveMemory(_ memory: MemoryPost) async {
        guard hasAdminPrivileges else { return }
        await saveMemory(
            MemoryPost(
                id: memory.id,
                userId: memory.userId,
                userName: memory.userName,
                imageURL: memory.imageURL,
                caption: memory.caption,
                timestamp: memory.timestamp,
                status: "APPROVED",
                reactions: memory.reactions,
                comments: memory.comments
            )
        )
    }

    func approveDiscussion(_ discussion: DiscussionThread) async {
        guard hasAdminPrivileges else { return }
        await saveDiscussion(
            DiscussionThread(
                id: discussion.id,
                userId: discussion.userId,
                userName: discussion.userName,
                type: discussion.type,
                title: discussion.title,
                content: discussion.content,
                pollOptions: discussion.pollOptions,
                timestamp: discussion.timestamp,
                status: "APPROVED",
                comments: discussion.comments
            )
        )
    }

    func rejectDiscussion(_ discussion: DiscussionThread) async {
        guard hasAdminPrivileges else { return }
        do {
            try await socialRepository.deleteDiscussion(discussionID: discussion.id)
            discussions.removeAll { $0.id == discussion.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func approveRecipe(_ recipe: Recipe) async {
        guard hasAdminPrivileges else { return }
        await saveRecipe(
            Recipe(
                id: recipe.id,
                title: recipe.title,
                authorId: recipe.authorId,
                authorName: recipe.authorName,
                category: recipe.category,
                description: recipe.description,
                ingredients: recipe.ingredients,
                instructions: recipe.instructions,
                imageURL: recipe.imageURL,
                reactions: recipe.reactions,
                comments: recipe.comments,
                status: "APPROVED",
                timestamp: recipe.timestamp
            )
        )
    }

    func approveTradition(_ tradition: Tradition) async {
        guard hasAdminPrivileges else { return }
        await saveTradition(
            Tradition(
                id: tradition.id,
                title: tradition.title,
                authorId: tradition.authorId,
                authorName: tradition.authorName,
                description: tradition.description,
                imageURL: tradition.imageURL,
                reactions: tradition.reactions,
                comments: tradition.comments,
                status: "APPROVED",
                timestamp: tradition.timestamp
            )
        )
    }

    func approveMilestone(_ milestone: Milestone) async {
        guard hasAdminPrivileges else { return }
        await saveMilestone(
            Milestone(
                id: milestone.id,
                title: milestone.title,
                description: milestone.description,
                year: milestone.year,
                imageURL: milestone.imageURL,
                audioURL: milestone.audioURL,
                location: milestone.location,
                timestamp: milestone.timestamp,
                authorId: milestone.authorId,
                authorName: milestone.authorName,
                visibilityType: milestone.visibilityType,
                familyContextId: milestone.familyContextId,
                reactions: milestone.reactions,
                comments: milestone.comments,
                status: "APPROVED"
            )
        )
    }

    func toggleMilestoneReaction(_ milestone: Milestone, emoji: String) async {
        guard let currentUser else { return }
        do {
            try await socialRepository.toggleMilestoneReaction(milestoneID: milestone.id, emoji: emoji, userID: currentUser.id)
            if let index = milestones.firstIndex(where: { $0.id == milestone.id }) {
                var updated = milestones[index]
                let reactions = Self.toggledSingleReaction(updated.reactions, emoji: emoji, userID: currentUser.id)
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
                    comments: updated.comments,
                    status: updated.status
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
                    comments: updated.comments + [comment],
                    status: updated.status
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

    func saveMemberEdits(_ member: Member) async -> Bool {
        guard let currentUser else { return false }

        guard canEdit(member) else { return false }
        if let validationError = validateMemberEdit(member) {
            errorMessage = validationError
            return false
        }

        let savesDirectly = savesMemberEditsDirectly(member)
        let existingMember = (members + pendingMembers).first { $0.id == member.id }
        let wasPendingApproval = pendingMembers.contains { $0.id == member.id }
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
            latitude: member.latitude,
            longitude: member.longitude,
            flatNumber: member.flatNumber,
            floor: member.floor,
            landmark: member.landmark,
            password: member.password,
            isAdmin: member.isAdmin,
            isEditor: member.isEditor,
            isPrimaryTree: member.isPrimaryTree,
            secondaryTreeEnabled: member.secondaryTreeEnabled,
            treeId: member.treeId,
            status: savesDirectly ? "APPROVED" : "PENDING",
            lastLoggedIn: member.lastLoggedIn,
            relationship: member.relationship,
            fcmToken: member.fcmToken,
            facebookURL: member.facebookURL,
            instagramURL: member.instagramURL,
            youtubeURL: member.youtubeURL,
            manualRelationships: member.manualRelationships,
            requestedBy: savesDirectly ? nil : currentUser.id,
            requestedByName: savesDirectly ? nil : currentUser.name,
            requestedRelationship: relationshipRequested ? member.relationship : member.requestedRelationship,
            points: member.points,
            level: member.level,
            badges: member.badges
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
                latitude: finalMember.latitude,
                longitude: finalMember.longitude,
                flatNumber: finalMember.flatNumber,
                floor: finalMember.floor,
                landmark: finalMember.landmark,
                password: finalMember.password,
                isAdmin: finalMember.isAdmin,
                isEditor: finalMember.isEditor,
                isPrimaryTree: finalMember.isPrimaryTree,
                secondaryTreeEnabled: finalMember.secondaryTreeEnabled,
                treeId: finalMember.treeId,
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
                requestedRelationship: member.relationship,
                points: finalMember.points,
                level: finalMember.level,
                badges: finalMember.badges
            )
            : finalMember

        do {
            try await memberRepository.saveMember(finalWithRequester, toPending: !savesDirectly)
            if savesDirectly && wasPendingApproval {
                try await memberRepository.deletePendingMember(userID: finalMember.id)
            }

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

            if savesDirectly && currentUser.id == finalMember.id {
                self.currentUser = finalWithRequester
            }
            preloadRemoteMedia(for: [finalWithRequester.photoURL])
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func approvePendingMember(_ member: Member) async {
        guard hasAdminPrivileges else { return }
        let approvedMember = member.withApprovalStatus("APPROVED")

        do {
            try await memberRepository.saveMember(approvedMember, toPending: false)
            try await memberRepository.deletePendingMember(userID: member.id)

            if let index = members.firstIndex(where: { $0.id == approvedMember.id }) {
                members[index] = approvedMember
            } else {
                members.append(approvedMember)
            }
            pendingMembers.removeAll { $0.id == member.id }
            preloadRemoteMedia(for: [approvedMember.photoURL])
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func suggestedMember(for request: SignupRequest) -> Member? {
        if let suggestedMemberID = request.suggestedMemberID,
           let member = (members + pendingMembers).first(where: { $0.id == suggestedMemberID }) {
            return member
        }
        return suggestedMember(forName: request.name, parentName: request.parentName)
    }

    func approveSignupRequest(_ request: SignupRequest, assigningTo member: Member) async {
        guard hasAdminPrivileges else { return }
        let updatedMember = memberWithSignupContact(member, request: request)
        let wasPendingMember = pendingMembers.contains { $0.id == member.id }

        do {
            try await memberRepository.saveMember(updatedMember, toPending: false)
            if wasPendingMember {
                try await memberRepository.deletePendingMember(userID: member.id)
            }
            try await memberRepository.deleteSignupRequest(requestID: request.id)
            replaceLocalMember(updatedMember)
            pendingMembers.removeAll { $0.id == updatedMember.id }
            signupRequests.removeAll { $0.id == request.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func rejectSignupRequest(_ request: SignupRequest) async {
        guard hasAdminPrivileges else { return }

        do {
            try await memberRepository.deleteSignupRequest(requestID: request.id)
            signupRequests.removeAll { $0.id == request.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func rejectPendingMember(_ member: Member) async {
        guard hasAdminPrivileges else { return }

        do {
            try await memberRepository.deletePendingMember(userID: member.id)
            pendingMembers.removeAll { $0.id == member.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadSignupRequests() async throws {
        signupRequests = try await memberRepository.fetchSignupRequests()
    }

    private func loadSocialState(showErrors: Bool = true) async throws {
        do {
            async let memoriesTask = socialRepository.fetchMemories()
            async let discussionsTask = socialRepository.fetchDiscussions()
            async let recipesTask = socialRepository.fetchRecipes()
            async let traditionsTask = socialRepository.fetchTraditions()
            async let milestonesTask = socialRepository.fetchMilestones()
            async let businessesTask = socialRepository.fetchBusinesses()
            memories = try await memoriesTask
            discussions = try await discussionsTask
            recipes = try await recipesTask
            traditions = try await traditionsTask
            milestones = try await milestonesTask
            businesses = try await businessesTask
            activeGameSessions = (try? await socialRepository.fetchActiveGameSessions()) ?? []
            if let currentUser {
                notifications = (try? await socialRepository.fetchNotifications(userID: currentUser.id, isAdmin: isPrimaryAdminLogin)) ?? []
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
            businesses = (try? await MockSocialRepository().fetchBusinesses()) ?? []
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
            notifications = try await socialRepository.fetchNotifications(userID: currentUser.id, isAdmin: isPrimaryAdminLogin)
        } catch {
            if FirebaseBootstrap.isConfigured && showErrors {
                errorMessage = error.localizedDescription
            } else {
                notifications = (try? await MockSocialRepository().fetchNotifications(userID: currentUser.id, isAdmin: isPrimaryAdminLogin)) ?? []
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
            if let index = members.firstIndex(where: { $0.id == currentUser.id }) {
                members[index] = members[index].copy(password: hashed)
            }
            logout()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func resetPassword(for member: Member, to newPassword: String = "1234") async {
        guard hasAdminPrivileges else { return }
        let trimmed = newPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        do {
            let hashed = Self.sha256(trimmed)
            try await memberRepository.updatePassword(userID: member.id, passwordHash: hashed)
            replaceLocalMember(adminUpdatedMember(member, password: hashed))
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func removePhoto(for member: Member) async {
        guard hasAdminPrivileges else { return }
        let updated = adminUpdatedMember(member, photoURL: nil, clearsPhoto: true)

        do {
            try await memberRepository.saveMember(updated, toPending: false)
            replaceLocalMember(updated)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func removeMember(_ member: Member) async {
        guard hasAdminPrivileges, member.id != currentUser?.id else { return }
        let updated = adminUpdatedMember(member, status: "REMOVED")

        do {
            try await memberRepository.saveMember(updated, toPending: false)
            replaceLocalMember(updated)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func replaceLocalMember(_ member: Member) {
        if let index = members.firstIndex(where: { $0.id == member.id }) {
            members[index] = member
        }
        if let index = pendingMembers.firstIndex(where: { $0.id == member.id }) {
            pendingMembers[index] = member
        }
        if currentUser?.id == member.id {
            currentUser = member
        }
    }

    private func memberWithUpdatedLogin(_ member: Member, timestamp: Int64) -> Member {
        Member(
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
            latitude: member.latitude,
            longitude: member.longitude,
            flatNumber: member.flatNumber,
            floor: member.floor,
            landmark: member.landmark,
            password: member.password,
            isAdmin: member.isAdmin,
            isEditor: member.isEditor,
            isPrimaryTree: member.isPrimaryTree,
            secondaryTreeEnabled: member.secondaryTreeEnabled,
            treeId: member.treeId,
            status: member.status,
            lastLoggedIn: timestamp,
            relationship: member.relationship,
            fcmToken: member.fcmToken,
            facebookURL: member.facebookURL,
            instagramURL: member.instagramURL,
            youtubeURL: member.youtubeURL,
            manualRelationships: member.manualRelationships,
            requestedBy: member.requestedBy,
            requestedByName: member.requestedByName,
            requestedRelationship: member.requestedRelationship,
            points: member.points,
            level: member.level,
            badges: member.badges
        )
    }

    private func adminUpdatedMember(
        _ member: Member,
        photoURL: String? = nil,
        clearsPhoto: Bool = false,
        status: String? = nil,
        password: String? = nil
    ) -> Member {
        Member(
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
            photoURL: clearsPhoto ? nil : (photoURL ?? member.photoURL),
            immediateFamily: member.immediateFamily,
            address: member.address,
            latitude: member.latitude,
            longitude: member.longitude,
            flatNumber: member.flatNumber,
            floor: member.floor,
            landmark: member.landmark,
            password: password ?? member.password,
            isAdmin: member.isAdmin,
            isEditor: member.isEditor,
            isPrimaryTree: member.isPrimaryTree,
            secondaryTreeEnabled: member.secondaryTreeEnabled,
            treeId: member.treeId,
            status: status ?? member.status,
            lastLoggedIn: member.lastLoggedIn,
            relationship: member.relationship,
            fcmToken: member.fcmToken,
            facebookURL: member.facebookURL,
            instagramURL: member.instagramURL,
            youtubeURL: member.youtubeURL,
            manualRelationships: member.manualRelationships,
            requestedBy: member.requestedBy,
            requestedByName: member.requestedByName,
            requestedRelationship: member.requestedRelationship,
            points: member.points,
            level: member.level,
            badges: member.badges
        )
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
            if session.canJoin(currentUser.id) {
                try await socialRepository.joinGameSession(sessionID: session.id, player: currentUser)
            }
            await refreshGameSessions()
            openGame(sessionID: session.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func openGameSession(_ session: GameSession) {
        openGame(sessionID: session.id)
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
        let token = tokenOverride ?? PushNotificationCoordinator.shared.fcmToken
        guard let token, !token.isEmpty else { return }
        guard currentUser.fcmToken != token else { return }

        let updatedUser = currentUser.copy(fcmToken: token)
        self.currentUser = updatedUser

        Task {
            do {
                try await memberRepository.updatePushToken(
                    userID: updatedUser.id,
                    token: token,
                    toPending: updatedUser.status.isPendingStatus
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
                try? await Task.sleep(nanoseconds: self?.fullSyncIntervalNanoseconds ?? 1_800_000_000_000)
                if Task.isCancelled { break }
                await self?.refreshAllDataSilently()
            }
        }
    }

    private func stopAutoRefreshLoop() {
        autoRefreshTask?.cancel()
        autoRefreshTask = nil
    }

    private func suggestedMember(forName name: String, parentName: String) -> Member? {
        let requestedNameTokens = Self.matchTokens(from: name)
        let requestedParentTokens = Self.matchTokens(from: parentName)
        guard !requestedNameTokens.isEmpty else { return nil }

        return (members + pendingMembers)
            .map { member -> (member: Member, score: Int) in
                let memberNameTokens = Self.matchTokens(from: member.name)
                let parentTokens = Self.matchTokens(from: [member.fatherName, member.motherName].compactMap { $0 }.joined(separator: " "))
                let nameOverlap = requestedNameTokens.intersection(memberNameTokens).count
                let parentOverlap = requestedParentTokens.intersection(parentTokens).count
                let exactNameBonus = Self.normalizedWords(name) == Self.normalizedWords(member.name) ? 4 : 0
                return (member, nameOverlap * 3 + parentOverlap * 4 + exactNameBonus)
            }
            .filter { $0.score >= 5 }
            .sorted { lhs, rhs in
                if lhs.score == rhs.score {
                    return lhs.member.familyId < rhs.member.familyId
                }
                return lhs.score > rhs.score
            }
            .first?
            .member
    }

    private func memberWithSignupContact(_ member: Member, request: SignupRequest) -> Member {
        let email = request.email.trimmingCharacters(in: .whitespacesAndNewlines)
        return Member(
            id: member.id,
            familyId: member.familyId,
            name: member.name,
            gender: member.gender,
            dateOfBirth: member.dateOfBirth,
            phoneNumber: request.mobileNumber.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.isEmpty ? member.email : email,
            location: member.location,
            spouseName: member.spouseName,
            fatherName: member.fatherName,
            motherName: member.motherName,
            marriageDate: member.marriageDate,
            bereavementDate: member.bereavementDate,
            photoURL: member.photoURL,
            immediateFamily: member.immediateFamily,
            address: member.address,
            latitude: member.latitude,
            longitude: member.longitude,
            flatNumber: member.flatNumber,
            floor: member.floor,
            landmark: member.landmark,
            password: member.password,
            isAdmin: member.isAdmin,
            isEditor: member.isEditor,
            isPrimaryTree: member.isPrimaryTree,
            secondaryTreeEnabled: member.secondaryTreeEnabled,
            treeId: member.treeId,
            status: "APPROVED",
            lastLoggedIn: member.lastLoggedIn,
            relationship: member.relationship,
            fcmToken: member.fcmToken,
            facebookURL: member.facebookURL,
            instagramURL: member.instagramURL,
            youtubeURL: member.youtubeURL,
            manualRelationships: member.manualRelationships,
            requestedBy: nil,
            requestedByName: nil,
            requestedRelationship: nil,
            points: member.points,
            level: member.level,
            badges: member.badges
        )
    }

    private func preloadRemoteMedia() {
        preloadRemoteMedia(for: remoteMediaURLStrings)
        preloadRemoteFiles(for: remoteFileURLStrings)
    }

    private func preloadRemoteMedia(for urlStrings: [String?]) {
        let urls = urlStrings.compactMap(Self.remoteMediaURL)
        guard !urls.isEmpty else { return }
        Task {
            await RemoteMediaCache.shared.preload(urls: urls)
        }
    }

    private nonisolated static func refreshRemoteMediaCache(
        mediaURLStrings: [String?],
        fileURLStrings: [String?],
        forceRefresh: Bool
    ) async {
        let urls = mediaURLStrings.compactMap(Self.remoteMediaURL)
        if !urls.isEmpty {
            if forceRefresh {
                await RemoteMediaCache.shared.refresh(urls: urls)
            } else {
                await RemoteMediaCache.shared.preload(urls: urls)
            }
        }

        let fileURLs = fileURLStrings.compactMap(Self.remoteMediaURL)
        for url in fileURLs {
            _ = try? await RemoteMediaCache.shared.cachedFileURL(for: url, forceRefresh: forceRefresh)
        }
    }

    private var remoteMediaURLStrings: [String?] {
        members.map(\.photoURL)
            + pendingMembers.map(\.photoURL)
            + memories.map { Optional($0.imageURL) }
            + recipes.map { Optional($0.imageURL) }
            + traditions.map { Optional($0.imageURL) }
            + milestones.map { Optional($0.imageURL) }
            + communityAchievements.map { Optional($0.imageURL) }
            + (1...12).map { Optional("https://circlebirthdays.web.app/calendar/\($0).jpg") }
    }

    private var remoteFileURLStrings: [String?] {
        milestones.map { Optional($0.audioURL) }
    }

    private func preloadRemoteFiles(for urlStrings: [String?]) {
        let urls = urlStrings.compactMap(Self.remoteMediaURL)
        guard !urls.isEmpty else { return }
        Task {
            for url in urls {
                _ = try? await RemoteMediaCache.shared.cachedFileURL(for: url)
            }
        }
    }

    private static func remoteMediaURL(from value: String?) -> URL? {
        guard let value,
              !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !value.hasPrefix("data:image") else { return nil }
        return URL(string: value)
    }

    private static func sha256(_ value: String) -> String {
        let digest = SHA256.hash(data: Data(value.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private static func matchTokens(from value: String) -> Set<String> {
        Set(normalizedWords(value).split(separator: " ").map(String.init).filter { $0.count > 1 })
    }

    private func validateMemberEdit(_ member: Member) -> String? {
        let normalizedPhone = Self.normalizePhoneNumber(member.phoneNumber)
        guard !normalizedPhone.isEmpty else {
            return "Phone number is required because it is used for login."
        }

        let duplicatePhone = (members + pendingMembers).contains { existing in
            existing.id != member.id && Self.normalizePhoneNumber(existing.phoneNumber) == normalizedPhone
        }
        if duplicatePhone {
            return "Phone number must be unique. Another profile already uses this login number."
        }

        for field in editableNameFields(for: member) {
            if let error = Self.nameValidationError(field.value, fieldName: field.name) {
                return error
            }
        }

        let today = Calendar.current.startOfDay(for: Date())
        for field in editableDateFields(for: member) {
            if let error = Self.dateValidationError(field.value, fieldName: field.name, today: today) {
                return error
            }
        }

        return nil
    }

    private func editableNameFields(for member: Member) -> [(name: String, value: String?)] {
        [
            ("Name", member.name),
            ("Spouse", member.spouseName),
            ("Father", member.fatherName),
            ("Mother", member.motherName)
        ]
    }

    private func editableDateFields(for member: Member) -> [(name: String, value: String?)] {
        [
            ("Date of Birth", member.dateOfBirth),
            ("Marriage Date", member.marriageDate),
            ("Bereavement Date", member.bereavementDate)
        ]
    }

    private static func nameValidationError(_ value: String?, fieldName: String) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if fieldName == "Name", trimmed.isEmpty {
            return "Name is required."
        }
        guard !trimmed.isEmpty else { return nil }

        let allowedPunctuation = CharacterSet(charactersIn: "()")
        let allowed = CharacterSet.letters.union(.whitespaces).union(allowedPunctuation)
        if trimmed.unicodeScalars.contains(where: { !allowed.contains($0) }) {
            return "\(fieldName) can contain only letters, spaces, and parentheses."
        }
        return nil
    }

    private static func dateValidationError(_ value: String?, fieldName: String, today: Date) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !trimmed.isEmpty else { return nil }

        guard let date = Member.isoDateFormatter.date(from: trimmed) else {
            return "\(fieldName) must use YYYY-MM-DD format."
        }

        if Calendar.current.startOfDay(for: date) > today {
            return "\(fieldName) cannot be in the future."
        }
        return nil
    }

    private static func toggledSingleReaction(_ reactions: [String: [String]], emoji: String, userID: String) -> [String: [String]] {
        let alreadySelected = reactions[emoji]?.contains(userID) == true
        var updated = reactions.reduce(into: [String: [String]]()) { result, entry in
            let users = entry.value.filter { $0 != userID }
            if !users.isEmpty {
                result[entry.key] = users
            }
        }
        if !alreadySelected {
            var users = updated[emoji] ?? []
            users.append(userID)
            updated[emoji] = users
        }
        return updated
    }

    private static func normalizedWords(_ value: String) -> String {
        value
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    private static func normalizePhoneNumber(_ value: String) -> String {
        let digits = value.filter(\.isNumber)

        if digits.count > 10 {
            return String(digits.suffix(10))
        }

        return digits
    }
}
