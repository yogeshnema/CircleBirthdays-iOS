import Foundation

#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif
#if canImport(FirebaseStorage)
import FirebaseStorage
#endif

struct FirebaseSocialRepository: SocialRepository {
    func fetchMemories() async throws -> [MemoryPost] {
        #if canImport(FirebaseFirestore)
        let snapshot = try await firestore.collection("memories").getDocuments()
        return snapshot.documents.compactMap(MemoryPost.init(document:)).sorted { $0.timestamp > $1.timestamp }
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func fetchDiscussions() async throws -> [DiscussionThread] {
        #if canImport(FirebaseFirestore)
        let snapshot = try await firestore.collection("discussions").getDocuments()
        return snapshot.documents.compactMap(DiscussionThread.init(document:)).sorted { $0.timestamp > $1.timestamp }
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func fetchRecipes() async throws -> [Recipe] {
        #if canImport(FirebaseFirestore)
        let snapshot = try await firestore.collection("recipes").getDocuments()
        return snapshot.documents.compactMap(Recipe.init(document:)).sorted { $0.timestamp > $1.timestamp }
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func fetchTraditions() async throws -> [Tradition] {
        #if canImport(FirebaseFirestore)
        let snapshot = try await firestore.collection("traditions").getDocuments()
        return snapshot.documents.compactMap(Tradition.init(document:)).sorted { $0.timestamp > $1.timestamp }
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func fetchMilestones() async throws -> [Milestone] {
        #if canImport(FirebaseFirestore)
        let snapshot = try await firestore.collection("memorylane").getDocuments()
        return snapshot.documents.compactMap(Milestone.init(document:)).sorted {
            let lhsYear = Int($0.year) ?? 0
            let rhsYear = Int($1.year) ?? 0
            if lhsYear == rhsYear {
                return $0.timestamp > $1.timestamp
            }
            return lhsYear < rhsYear
        }
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func fetchDeletionRequests() async throws -> [DeletionRequest] {
        #if canImport(FirebaseFirestore)
        let snapshot = try await firestore.collection("deletion_requests")
            .whereField("status", isEqualTo: "PENDING")
            .getDocuments()
        return snapshot.documents.compactMap(DeletionRequest.init(document:)).sorted { $0.timestamp > $1.timestamp }
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func fetchInbox(for userID: String) async throws -> SocialInbox {
        #if canImport(FirebaseFirestore)
        let snapshot = try await firestore.collection("channels")
            .whereField("userIds", arrayContains: userID)
            .getDocuments()

        var channels = snapshot.documents.compactMap(ChatChannel.init(document:)).sorted { $0.lastTimestamp > $1.lastTimestamp }
        var allMessages: [ChatMessage] = []

        for channel in channels {
            let messagesSnapshot = try await firestore.collection("channels")
                .document(channel.id)
                .collection("messages")
                .order(by: "timestamp")
                .getDocuments()
            allMessages += messagesSnapshot.documents.compactMap(ChatMessage.init(document:))
        }

        if channels.isEmpty {
            let sentSnapshot = try await firestore.collectionGroup("messages")
                .whereField("senderId", isEqualTo: userID)
                .getDocuments()
            let receivedSnapshot = try await firestore.collectionGroup("messages")
                .whereField("receiverId", isEqualTo: userID)
                .getDocuments()

            let fallbackMessages = (sentSnapshot.documents + receivedSnapshot.documents)
                .compactMap(ChatMessage.init(document:))
            allMessages = Array(Dictionary(grouping: fallbackMessages, by: { $0.id }).values.compactMap { $0.first })
                .sorted { $0.timestamp < $1.timestamp }
            channels = synthesizeChannels(from: allMessages, currentUserID: userID)
        }

        return SocialInbox(channels: channels, messages: allMessages.sorted { $0.timestamp < $1.timestamp })
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func sendMessage(_ message: ChatMessage) async throws {
        #if canImport(FirebaseFirestore)
        let channelID = [message.senderId, message.receiverId].sorted().joined(separator: "_")
        let channelRef = firestore.collection("channels").document(channelID)
        let messageRef = channelRef.collection("messages").document(message.id)

        let snapshot = try await channelRef.getDocument()
        var unreadCount = snapshot.data()?["unreadCount"] as? [String: Int] ?? [:]
        unreadCount[message.receiverId] = (unreadCount[message.receiverId] ?? 0) + 1
        unreadCount[message.senderId] = unreadCount[message.senderId] ?? 0

        try await messageRef.setData([
            "id": message.id,
            "senderId": message.senderId,
            "senderName": message.senderName,
            "receiverId": message.receiverId,
            "text": message.text,
            "timestamp": Int64(message.timestamp.timeIntervalSince1970 * 1000),
            "isRead": false
        ])

        try await channelRef.setData([
            "id": channelID,
            "userIds": [message.senderId, message.receiverId],
            "lastMessage": message.text,
            "lastTimestamp": Int64(message.timestamp.timeIntervalSince1970 * 1000),
            "unreadCount": unreadCount
        ], merge: true)
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    private func synthesizeChannels(from messages: [ChatMessage], currentUserID: String) -> [ChatChannel] {
        let grouped = Dictionary(grouping: messages) { message -> String in
            [message.senderId, message.receiverId].sorted().joined(separator: "_")
        }

        return grouped.compactMap { channelID, messages in
            guard let latest = messages.sorted(by: { $0.timestamp > $1.timestamp }).first else { return nil }
            let userIds = Array(Set(messages.flatMap { [$0.senderId, $0.receiverId] })).sorted()
            var unreadCount: [String: Int] = [:]
            let receivedCount = messages.filter { $0.receiverId == currentUserID }.count
            unreadCount[currentUserID] = receivedCount
            for userId in userIds where userId != currentUserID {
                unreadCount[userId] = 0
            }
            return ChatChannel(
                id: channelID,
                userIds: userIds,
                lastMessage: latest.text,
                lastTimestamp: latest.timestamp,
                unreadCount: unreadCount
            )
        }
        .sorted { $0.lastTimestamp > $1.lastTimestamp }
    }

    func markChatRead(channelID: String, userID: String) async throws {
        #if canImport(FirebaseFirestore)
        let channelRef = firestore.collection("channels").document(channelID)
        let snapshot = try await channelRef.getDocument()
        var unreadCount = snapshot.data()?["unreadCount"] as? [String: Int] ?? [:]
        unreadCount[userID] = 0
        try await channelRef.setData(["unreadCount": unreadCount], merge: true)
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func uploadImageData(_ data: Data, folder: String) async throws -> String {
        #if canImport(FirebaseStorage)
        let storage = Storage.storage()
        let fileName = "\(folder)/\(UUID().uuidString).jpg"
        let ref = storage.reference().child(fileName)
        _ = try await ref.putDataAsync(data)
        return try await ref.downloadURL().absoluteString
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func uploadAudioData(_ data: Data, folder: String, fileExtension: String) async throws -> String {
        #if canImport(FirebaseStorage)
        let storage = Storage.storage()
        let safeExtension = fileExtension.trimmingCharacters(in: CharacterSet.alphanumerics.inverted).isEmpty ? "m4a" : fileExtension
        let fileName = "\(folder)/\(UUID().uuidString).\(safeExtension)"
        let ref = storage.reference().child(fileName)
        let metadata = StorageMetadata()
        metadata.contentType = "audio/\(safeExtension == "mp3" ? "mpeg" : safeExtension)"
        _ = try await ref.putDataAsync(data, metadata: metadata)
        return try await ref.downloadURL().absoluteString
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func submitMemory(_ memory: MemoryPost) async throws {
        #if canImport(FirebaseFirestore)
        try await firestore.collection("memories")
            .document(memory.id)
            .setData(memory.firestoreData)
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func deleteMemory(memoryID: String) async throws {
        #if canImport(FirebaseFirestore)
        try await firestore.collection("memories").document(memoryID).delete()
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func toggleMemoryReaction(memoryID: String, emoji: String, userID: String) async throws {
        #if canImport(FirebaseFirestore)
        let docRef = firestore.collection("memories").document(memoryID)
        let snapshot = try await docRef.getDocument()
        let reactions = MemoryPost.parseReactions(snapshot.data()?["reactions"])
        var updated = reactions
        var users = updated[emoji] ?? []
        if let index = users.firstIndex(of: userID) {
            users.remove(at: index)
        } else {
            users.append(userID)
        }
        updated[emoji] = users
        try await docRef.setData(["reactions": updated], merge: true)
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func addMemoryComment(memoryID: String, comment: PostComment) async throws {
        #if canImport(FirebaseFirestore)
        let docRef = firestore.collection("memories").document(memoryID)
        let snapshot = try await docRef.getDocument()
        var comments = MemoryPost.parseComments(snapshot.data()?["comments"])
        comments.append(comment)
        try await docRef.setData(["comments": comments.map { $0.firestoreData }], merge: true)
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func submitRecipe(_ recipe: Recipe) async throws {
        #if canImport(FirebaseFirestore)
        try await firestore.collection("recipes")
            .document(recipe.id)
            .setData(recipe.firestoreData)
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func deleteRecipe(recipeID: String) async throws {
        #if canImport(FirebaseFirestore)
        try await firestore.collection("recipes").document(recipeID).delete()
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func toggleRecipeReaction(recipeID: String, emoji: String, userID: String) async throws {
        #if canImport(FirebaseFirestore)
        let docRef = firestore.collection("recipes").document(recipeID)
        let snapshot = try await docRef.getDocument()
        let reactions = MemoryPost.parseReactions(snapshot.data()?["reactions"])
        var updated = reactions
        var users = updated[emoji] ?? []
        if let index = users.firstIndex(of: userID) {
            users.remove(at: index)
        } else {
            users.append(userID)
        }
        updated[emoji] = users
        try await docRef.setData(["reactions": updated], merge: true)
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func addRecipeComment(recipeID: String, comment: PostComment) async throws {
        #if canImport(FirebaseFirestore)
        let docRef = firestore.collection("recipes").document(recipeID)
        let snapshot = try await docRef.getDocument()
        var comments = MemoryPost.parseComments(snapshot.data()?["comments"])
        comments.append(comment)
        try await docRef.setData(["comments": comments.map { $0.firestoreData }], merge: true)
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func submitTradition(_ tradition: Tradition) async throws {
        #if canImport(FirebaseFirestore)
        try await firestore.collection("traditions")
            .document(tradition.id)
            .setData(tradition.firestoreData)
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func deleteTradition(traditionID: String) async throws {
        #if canImport(FirebaseFirestore)
        try await firestore.collection("traditions").document(traditionID).delete()
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func toggleTraditionReaction(traditionID: String, emoji: String, userID: String) async throws {
        #if canImport(FirebaseFirestore)
        let docRef = firestore.collection("traditions").document(traditionID)
        let snapshot = try await docRef.getDocument()
        let reactions = MemoryPost.parseReactions(snapshot.data()?["reactions"])
        var updated = reactions
        var users = updated[emoji] ?? []
        if let index = users.firstIndex(of: userID) {
            users.remove(at: index)
        } else {
            users.append(userID)
        }
        updated[emoji] = users
        try await docRef.setData(["reactions": updated], merge: true)
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func addTraditionComment(traditionID: String, comment: PostComment) async throws {
        #if canImport(FirebaseFirestore)
        let docRef = firestore.collection("traditions").document(traditionID)
        let snapshot = try await docRef.getDocument()
        var comments = MemoryPost.parseComments(snapshot.data()?["comments"])
        comments.append(comment)
        try await docRef.setData(["comments": comments.map { $0.firestoreData }], merge: true)
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func submitMilestone(_ milestone: Milestone) async throws {
        #if canImport(FirebaseFirestore)
        try await firestore.collection("memorylane")
            .document(milestone.id)
            .setData(milestone.firestoreData)
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func deleteMilestone(milestoneID: String) async throws {
        #if canImport(FirebaseFirestore)
        try await firestore.collection("memorylane").document(milestoneID).delete()
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func toggleMilestoneReaction(milestoneID: String, emoji: String, userID: String) async throws {
        #if canImport(FirebaseFirestore)
        let docRef = firestore.collection("memorylane").document(milestoneID)
        let snapshot = try await docRef.getDocument()
        let reactions = MemoryPost.parseReactions(snapshot.data()?["reactions"])
        var updated = reactions
        var users = updated[emoji] ?? []
        if let index = users.firstIndex(of: userID) {
            users.remove(at: index)
        } else {
            users.append(userID)
        }
        updated[emoji] = users
        try await docRef.setData(["reactions": updated], merge: true)
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func addMilestoneComment(milestoneID: String, comment: PostComment) async throws {
        #if canImport(FirebaseFirestore)
        let docRef = firestore.collection("memorylane").document(milestoneID)
        let snapshot = try await docRef.getDocument()
        var comments = MemoryPost.parseComments(snapshot.data()?["comments"])
        comments.append(comment)
        try await docRef.setData(["comments": comments.map { $0.firestoreData }], merge: true)
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func submitDeletionRequest(_ request: DeletionRequest) async throws {
        #if canImport(FirebaseFirestore)
        try await firestore.collection("deletion_requests")
            .document(request.id)
            .setData(request.firestoreData)
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func resolveDeletionRequest(_ request: DeletionRequest, approved: Bool) async throws {
        #if canImport(FirebaseFirestore)
        let requestRef = firestore.collection("deletion_requests").document(request.id)
        if approved {
            let collectionName = normalizedDeletionCollection(request.collectionName)
            if !collectionName.isEmpty, !request.docId.isEmpty {
                try await firestore.collection(collectionName).document(request.docId).delete()
            }
        }
        try await requestRef.delete()
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func fetchActiveGameSessions() async throws -> [GameSession] {
        #if canImport(FirebaseFirestore)
        let snapshot = try await firestore.collection("game_sessions")
            .whereField("status", isEqualTo: "WAITING")
            .limit(to: 20)
            .getDocuments()
        return snapshot.documents.compactMap(GameSession.init(document:)).sorted { $0.lastUpdated > $1.lastUpdated }
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func fetchGameSession(sessionID: String) async throws -> GameSession? {
        #if canImport(FirebaseFirestore)
        let snapshot = try await firestore.collection("game_sessions").document(sessionID).getDocument()
        return GameSession(document: snapshot)
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func createGameSession(gameType: FamilyGameType, player: Member) async throws -> String {
        #if canImport(FirebaseFirestore)
        let sessionID = UUID().uuidString
        let state = initialGameState(for: gameType)
        try await firestore.collection("game_sessions").document(sessionID).setData([
            "id": sessionID,
            "gameType": gameType.rawValue,
            "players": [player.id],
            "playerNames": [player.id: player.name],
            "status": "WAITING",
            "currentTurn": player.id,
            "gameState": state,
            "lastUpdated": Self.currentMillis()
        ])
        return sessionID
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func joinGameSession(sessionID: String, player: Member) async throws {
        #if canImport(FirebaseFirestore)
        let ref = firestore.collection("game_sessions").document(sessionID)
        let snapshot = try await ref.getDocument()
        guard let session = GameSession(document: snapshot) else { return }

        if session.players.contains(player.id) {
            return
        }
        guard session.players.count < 2 else { return }

        let players = session.players + [player.id]
        var playerNames = session.playerNames
        playerNames[player.id] = player.name

        var state = session.gameState
        if session.gameType == .rummy {
            state = rummyState(firstPlayerID: session.players.first ?? player.id, secondPlayerID: player.id)
        } else if session.gameType == .hangman {
            state = hangmanState()
        } else if session.gameType == .chess, state["board"] == nil {
            state["board"] = Self.initialChessBoard()
        } else if session.gameType == .chaupad, state["p1_pieces"] == nil {
            state["p1_pieces"] = [0, 0, 0, 0]
            state["p2_pieces"] = [0, 0, 0, 0]
        }

        try await ref.updateData([
            "players": players,
            "playerNames": playerNames,
            "status": "ACTIVE",
            "gameState": state,
            "lastUpdated": Self.currentMillis()
        ])
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func updateGameState(sessionID: String, state: [String: Any], nextTurnID: String?, winnerID: String?) async throws {
        #if canImport(FirebaseFirestore)
        var updates: [String: Any] = [
            "gameState": state,
            "lastUpdated": Self.currentMillis()
        ]
        if let nextTurnID {
            updates["currentTurn"] = nextTurnID
        }
        if let winnerID {
            updates["winnerId"] = winnerID
            updates["status"] = "FINISHED"
        } else if nextTurnID == "" {
            updates["status"] = "FINISHED"
        }
        try await firestore.collection("game_sessions").document(sessionID).updateData(updates)
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func fetchNotifications(userID: String, isAdmin: Bool) async throws -> [AppNotification] {
        #if canImport(FirebaseFirestore)
        let snapshot = try await firestore.collection("notifications")
            .order(by: "timestamp", descending: true)
            .limit(to: 50)
            .getDocuments()

        return snapshot.documents
            .compactMap(AppNotification.init(document:))
            .filter { notification in
                let isForUser: Bool
                if notification.isAdminOnly {
                    isForUser = isAdmin
                } else if let targetUserId = notification.targetUserId {
                    isForUser = targetUserId == userID
                } else {
                    switch notification.topic {
                    case "all", "gallery", "recipes", "traditions", "memorylane", "all_discussions", "events":
                        isForUser = true
                    default:
                        isForUser = true
                    }
                }
                return isForUser && notification.senderId != userID
            }
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func markNotificationRead(notificationID: String, userID: String) async throws {
        #if canImport(FirebaseFirestore)
        guard !notificationID.isEmpty else { return }
        try await firestore.collection("notifications")
            .document(notificationID)
            .updateData(["readBy": FieldValue.arrayUnion([userID])])
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    #if canImport(FirebaseFirestore)
    private var firestore: Firestore {
        Firestore.firestore()
    }

    private func initialGameState(for gameType: FamilyGameType) -> [String: Any] {
        switch gameType {
        case .rummy:
            return ["deckCount": 52, "discardPile": []]
        case .antakshari:
            return ["recordings": [], "lastLetter": ""]
        case .chess:
            return ["board": Self.initialChessBoard()]
        case .chaupad:
            return ["p1_pieces": [0, 0, 0, 0], "p2_pieces": [0, 0, 0, 0]]
        case .snakesLadders, .hangman:
            return [:]
        }
    }

    private func rummyState(firstPlayerID: String, secondPlayerID: String) -> [String: Any] {
        var deck = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"].flatMap { rank in
            ["\(rank)♠", "\(rank)♥", "\(rank)♦", "\(rank)♣"]
        }.shuffled()
        var firstHand: [String] = []
        var secondHand: [String] = []
        for _ in 0..<10 {
            if !deck.isEmpty { firstHand.append(deck.removeFirst()) }
            if !deck.isEmpty { secondHand.append(deck.removeFirst()) }
        }
        let discard = deck.isEmpty ? [] : [deck.removeFirst()]
        return [
            "deck": deck,
            "deckCount": deck.count,
            "discardPile": discard,
            "hand_\(firstPlayerID)": firstHand,
            "hand_\(secondPlayerID)": secondHand
        ]
    }

    private func hangmanState() -> [String: Any] {
        let categories = [
            "ANIMALS": ["ELEPHANT", "GIRAFFE", "KANGAROO", "PANDA", "LEOPARD", "TIGER", "CHEETAH", "CHIMPANZEE", "RHINOCEROS", "PLATYPUS", "HAMSTER", "IGUANA"],
            "MOVIES": ["INCEPTION", "AVATAR", "TITANIC", "GLADIATOR", "JOKER", "SHOLAY", "DANGAL", "INTERSTELLAR", "BAHUBALI", "LAGAAN", "PARASITE", "HAMILTON"],
            "COUNTRIES": ["INDIA", "BRAZIL", "CANADA", "GERMANY", "JAPAN", "FRANCE", "AUSTRALIA", "ARGENTINA", "EGYPT", "THAILAND", "NORWAY", "MEXICO"],
            "FRUITS": ["ORANGE", "BANANA", "CHERRY", "MANGO", "PINEAPPLE", "WATERMELON", "POMEGRANATE", "KIWI", "AVOCADO", "STRAWBERRY", "GUAVA"],
            "SPORTS": ["CRICKET", "FOOTBALL", "BASKETBALL", "TENNIS", "HOCKEY", "BADMINTON", "VOLLEYBALL", "KABADDI", "CHESS"]
        ]
        let category = categories.keys.randomElement() ?? "ANIMALS"
        return [
            "word": categories[category]?.randomElement() ?? "FAMILY",
            "category": category,
            "guessedLetters": []
        ]
    }

    private static func currentMillis() -> Int64 {
        Int64(Date().timeIntervalSince1970 * 1000)
    }

    private static func initialChessBoard() -> [String] {
        [
            "BR", "BN", "BB", "BQ", "BK", "BB", "BN", "BR",
            "BP", "BP", "BP", "BP", "BP", "BP", "BP", "BP",
            "", "", "", "", "", "", "", "",
            "", "", "", "", "", "", "", "",
            "", "", "", "", "", "", "", "",
            "", "", "", "", "", "", "", "",
            "WP", "WP", "WP", "WP", "WP", "WP", "WP", "WP",
            "WR", "WN", "WB", "WQ", "WK", "WB", "WN", "WR"
        ]
    }

    private func normalizedDeletionCollection(_ collectionName: String) -> String {
        switch collectionName.lowercased() {
        case "memorylane":
            return "memorylane"
        case "memories":
            return "memories"
        case "discussions":
            return "discussions"
        case "recipes":
            return "recipes"
        case "traditions":
            return "traditions"
        default:
            return collectionName
        }
    }
    #endif
}

#if canImport(FirebaseFirestore)
private extension MemoryPost {
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let userName = data["userName"] as? String else { return nil }
        self.init(
            id: document.documentID,
            userId: data["userId"] as? String ?? "",
            userName: userName,
            imageURL: data["imageUrl"] as? String ?? "",
            caption: data["caption"] as? String ?? "",
            timestamp: Self.dateValue(from: data["timestamp"]),
            status: data["status"] as? String ?? "PENDING",
            reactions: Self.parseReactions(data["reactions"]),
            comments: Self.parseComments(data["comments"])
        )
    }

    var firestoreData: [String: Any] {
        [
            "id": id,
            "userId": userId,
            "userName": userName,
            "imageUrl": imageURL,
            "caption": caption,
            "timestamp": Int64(timestamp.timeIntervalSince1970 * 1000),
            "status": status,
            "reactions": reactions,
            "comments": comments.map { $0.firestoreData }
        ]
    }

    static func parseReactions(_ raw: Any?) -> [String: [String]] {
        guard let map = raw as? [String: Any] else { return [:] }
        return map.reduce(into: [:]) { result, entry in
            result[entry.key] = (entry.value as? [String]) ?? (entry.value as? [Any])?.compactMap { $0 as? String } ?? []
        }
    }

    static func parseComments(_ raw: Any?) -> [PostComment] {
        guard let list = raw as? [[String: Any]] else { return [] }
        return list.map(PostComment.init(dictionary:)).sorted { $0.timestamp < $1.timestamp }
    }
}

private extension DiscussionThread {
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let title = data["title"] as? String else { return nil }
        let type = DiscussionKind(rawValue: data["type"] as? String ?? "TEXT") ?? .text
        let rawOptions = data["pollOptions"] as? [[String: Any]] ?? []
        let options = rawOptions.map {
            PollOption(
                id: $0["id"] as? String ?? UUID().uuidString,
                text: $0["text"] as? String ?? "",
                voterIds: ($0["voterIds"] as? [String]) ?? (($0["voterIds"] as? [Any])?.compactMap { $0 as? String } ?? [])
            )
        }

        self.init(
            id: document.documentID,
            userId: data["userId"] as? String ?? "",
            userName: data["userName"] as? String ?? "",
            type: type,
            title: title,
            content: data["content"] as? String ?? "",
            pollOptions: options,
            timestamp: Self.dateValue(from: data["timestamp"]),
            status: data["status"] as? String ?? "PENDING",
            comments: MemoryPost.parseComments(data["comments"])
        )
    }
}

private extension Recipe {
    static func dateValue(from raw: Any?) -> Date {
        MemoryPost.dateValue(from: raw)
    }

    var firestoreData: [String: Any] {
        [
            "id": id,
            "title": title,
            "authorId": authorId,
            "authorName": authorName,
            "category": category,
            "description": description,
            "ingredients": ingredients,
            "instructions": instructions,
            "imageUrl": imageURL,
            "reactions": reactions,
            "comments": comments.map { $0.firestoreData },
            "timestamp": Int64(timestamp.timeIntervalSince1970 * 1000)
        ]
    }
}

private extension Recipe {
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let title = data["title"] as? String else { return nil }
        let ingredients: [String]
        if let list = data["ingredients"] as? [String] {
            ingredients = list
        } else if let list = data["ingredients"] as? [Any] {
            ingredients = list.compactMap { $0 as? String }
        } else if let string = data["ingredients"] as? String {
            ingredients = string
                .components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        } else {
            ingredients = []
        }

        let reactions = MemoryPost.parseReactions(data["reactions"])
        let comments = MemoryPost.parseComments(data["comments"])

        self.init(
            id: document.documentID,
            title: title,
            authorId: data["authorId"] as? String ?? "",
            authorName: data["authorName"] as? String ?? "",
            category: data["category"] as? String ?? "",
            description: data["description"] as? String ?? "",
            ingredients: ingredients,
            instructions: Self.instructionsValue(from: data["instructions"] ?? data["instruction"] ?? data["steps"] ?? data["method"]),
            imageURL: data["imageUrl"] as? String ?? "",
            reactions: reactions,
            comments: comments,
            timestamp: Self.dateValue(from: data["timestamp"])
        )
    }

    static func instructionsValue(from raw: Any?) -> String {
        if let string = raw as? String {
            return string
        }
        if let list = raw as? [String] {
            return list.joined(separator: "\n")
        }
        if let list = raw as? [Any] {
            return list.compactMap { $0 as? String }.joined(separator: "\n")
        }
        return ""
    }
}

private extension Tradition {
    static func dateValue(from raw: Any?) -> Date {
        MemoryPost.dateValue(from: raw)
    }

    var firestoreData: [String: Any] {
        [
            "id": id,
            "title": title,
            "authorId": authorId,
            "authorName": authorName,
            "description": description,
            "imageUrl": imageURL,
            "reactions": reactions,
            "comments": comments.map { $0.firestoreData },
            "timestamp": Int64(timestamp.timeIntervalSince1970 * 1000)
        ]
    }
}

private extension Tradition {
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let title = data["title"] as? String else { return nil }

        self.init(
            id: document.documentID,
            title: title,
            authorId: data["authorId"] as? String ?? "",
            authorName: data["authorName"] as? String ?? "",
            description: data["description"] as? String ?? "",
            imageURL: data["imageUrl"] as? String ?? "",
            reactions: MemoryPost.parseReactions(data["reactions"]),
            comments: MemoryPost.parseComments(data["comments"]),
            timestamp: Self.dateValue(from: data["timestamp"])
        )
    }
}

private extension Milestone {
    static func dateValue(from raw: Any?) -> Date {
        MemoryPost.dateValue(from: raw)
    }

    var firestoreData: [String: Any] {
        [
            "id": id,
            "title": title,
            "description": description,
            "year": year,
            "imageUrl": imageURL,
            "audioUrl": audioURL,
            "location": location,
            "timestamp": Int64(timestamp.timeIntervalSince1970 * 1000),
            "authorId": authorId,
            "authorName": authorName,
            "visibilityType": visibilityType,
            "familyContextId": familyContextId,
            "reactions": reactions,
            "comments": comments.map { $0.firestoreData }
        ]
    }
}

private extension Milestone {
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let title = data["title"] as? String else { return nil }

        self.init(
            id: document.documentID,
            title: title,
            description: data["description"] as? String ?? "",
            year: data["year"] as? String ?? "",
            imageURL: data["imageUrl"] as? String ?? "",
            audioURL: data["audioUrl"] as? String ?? "",
            location: data["location"] as? String ?? "",
            timestamp: Self.dateValue(from: data["timestamp"]),
            authorId: data["authorId"] as? String ?? "",
            authorName: data["authorName"] as? String ?? "",
            visibilityType: data["visibilityType"] as? String ?? "GLOBAL",
            familyContextId: data["familyContextId"] as? String ?? "",
            reactions: MemoryPost.parseReactions(data["reactions"]),
            comments: MemoryPost.parseComments(data["comments"])
        )
    }
}

private extension ChatChannel {
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let userIds = data["userIds"] as? [String] ?? (data["userIds"] as? [Any])?.compactMap({ $0 as? String }) else {
            return nil
        }
        let rawUnread = data["unreadCount"] as? [String: Any] ?? [:]
        let unread = rawUnread.reduce(into: [String: Int]()) { result, entry in
            if let intValue = entry.value as? Int {
                result[entry.key] = intValue
            } else if let number = entry.value as? NSNumber {
                result[entry.key] = number.intValue
            }
        }

        self.init(
            id: document.documentID,
            userIds: userIds,
            lastMessage: data["lastMessage"] as? String ?? "",
            lastTimestamp: Self.dateValue(from: data["lastTimestamp"]),
            unreadCount: unread
        )
    }
}

private extension ChatMessage {
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let text = data["text"] as? String else { return nil }
        self.init(
            id: data["id"] as? String ?? document.documentID,
            senderId: data["senderId"] as? String ?? "",
            senderName: data["senderName"] as? String ?? "",
            receiverId: data["receiverId"] as? String ?? "",
            text: text,
            timestamp: Self.dateValue(from: data["timestamp"])
        )
    }
}

private extension DeletionRequest {
    static func dateValue(from raw: Any?) -> Date {
        MemoryPost.dateValue(from: raw)
    }

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let title = data["title"] as? String else { return nil }
        self.init(
            id: document.documentID,
            collectionName: data["collectionName"] as? String ?? "",
            docId: data["docId"] as? String ?? "",
            title: title,
            reason: data["reason"] as? String ?? "",
            requestedBy: data["requestedBy"] as? String ?? "",
            requestedByName: data["requestedByName"] as? String ?? "",
            timestamp: Self.dateValue(from: data["timestamp"]),
            status: data["status"] as? String ?? "PENDING"
        )
    }

    var firestoreData: [String: Any] {
        [
            "id": id,
            "collectionName": collectionName,
            "docId": docId,
            "title": title,
            "reason": reason,
            "requestedBy": requestedBy,
            "requestedByName": requestedByName,
            "timestamp": Int64(timestamp.timeIntervalSince1970 * 1000),
            "status": status
        ]
    }
}

private extension PostComment {
    init(dictionary: [String: Any]) {
        self.init(
            id: dictionary["id"] as? String ?? UUID().uuidString,
            userId: dictionary["userId"] as? String ?? "",
            userName: dictionary["userName"] as? String ?? "",
            text: dictionary["text"] as? String ?? "",
            timestamp: Self.dateValue(from: dictionary["timestamp"])
        )
    }

    var firestoreData: [String: Any] {
        [
            "id": id,
            "userId": userId,
            "userName": userName,
            "text": text,
            "timestamp": Int64(timestamp.timeIntervalSince1970 * 1000)
        ]
    }
}

private extension MemoryPost {
    static func dateValue(from raw: Any?) -> Date {
        if let timestamp = raw as? Timestamp {
            return timestamp.dateValue()
        }
        if let intValue = raw as? Int64 {
            return Date(timeIntervalSince1970: TimeInterval(intValue) / 1000)
        }
        if let intValue = raw as? Int {
            return Date(timeIntervalSince1970: TimeInterval(intValue) / 1000)
        }
        if let number = raw as? NSNumber {
            return Date(timeIntervalSince1970: number.doubleValue / 1000)
        }
        return .now
    }
}

private extension DiscussionThread {
    static func dateValue(from raw: Any?) -> Date {
        MemoryPost.dateValue(from: raw)
    }
}

private extension ChatChannel {
    static func dateValue(from raw: Any?) -> Date {
        MemoryPost.dateValue(from: raw)
    }
}

private extension ChatMessage {
    static func dateValue(from raw: Any?) -> Date {
        MemoryPost.dateValue(from: raw)
    }
}

private extension PostComment {
    static func dateValue(from raw: Any?) -> Date {
        MemoryPost.dateValue(from: raw)
    }
}

private extension GameSession {
    init?(document: DocumentSnapshot) {
        guard let data = document.data(),
              let rawType = data["gameType"] as? String,
              let gameType = FamilyGameType(rawValue: rawType) else {
            return nil
        }
        let players = data["players"] as? [String] ?? (data["players"] as? [Any])?.compactMap { $0 as? String } ?? []
        let playerNames = data["playerNames"] as? [String: String]
            ?? (data["playerNames"] as? [String: Any])?.reduce(into: [String: String]()) { result, entry in
                result[entry.key] = entry.value as? String
            }
            ?? [:]
        self.init(
            id: data["id"] as? String ?? document.documentID,
            gameType: gameType,
            players: players,
            playerNames: playerNames,
            status: data["status"] as? String ?? "WAITING",
            currentTurn: data["currentTurn"] as? String ?? "",
            gameState: data["gameState"] as? [String: Any] ?? [:],
            winnerId: data["winnerId"] as? String,
            lastUpdated: Self.millisValue(from: data["lastUpdated"])
        )
    }

    init?(document: QueryDocumentSnapshot) {
        self.init(document: document as DocumentSnapshot)
    }

    static func millisValue(from raw: Any?) -> Int64 {
        if let int64 = raw as? Int64 {
            return int64
        }
        if let int = raw as? Int {
            return Int64(int)
        }
        if let number = raw as? NSNumber {
            return number.int64Value
        }
        if let timestamp = raw as? Timestamp {
            return Int64(timestamp.dateValue().timeIntervalSince1970 * 1000)
        }
        return 0
    }
}

private extension AppNotification {
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        let readBy = data["readBy"] as? [String] ?? (data["readBy"] as? [Any])?.compactMap { $0 as? String } ?? []
        let metadata = data["metadata"] as? [String: String]
            ?? (data["metadata"] as? [String: Any])?.reduce(into: [String: String]()) { result, entry in
                result[entry.key] = entry.value as? String
            }
            ?? [:]

        self.init(
            id: data["id"] as? String ?? document.documentID,
            type: data["type"] as? String ?? "",
            title: data["title"] as? String ?? "",
            body: data["body"] as? String ?? "",
            timestamp: MemoryPost.dateValue(from: data["timestamp"]),
            readBy: readBy,
            targetUserId: data["targetUserId"] as? String,
            senderId: data["senderId"] as? String,
            senderName: data["senderName"] as? String,
            relatedId: data["relatedId"] as? String,
            isAdminOnly: data["isAdminOnly"] as? Bool ?? false,
            topic: data["topic"] as? String,
            metadata: metadata
        )
    }
}
#endif
