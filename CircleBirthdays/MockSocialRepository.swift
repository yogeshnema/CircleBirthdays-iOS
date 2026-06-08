import Foundation

struct MockSocialRepository: SocialRepository {
    func fetchMemories() async throws -> [MemoryPost] {
        MockSocialData.memories()
    }

    func fetchDiscussions() async throws -> [DiscussionThread] {
        MockSocialData.discussions()
    }

    func fetchRecipes() async throws -> [Recipe] {
        MockSocialData.recipes()
    }

    func fetchTraditions() async throws -> [Tradition] {
        MockSocialData.traditions()
    }

    func fetchMilestones() async throws -> [Milestone] {
        MockSocialData.milestones()
    }

    func fetchDeletionRequests() async throws -> [DeletionRequest] {
        [
            DeletionRequest(
                id: "delete-1",
                collectionName: "memorylane",
                docId: "memory-2",
                title: "Wedding invitation cards are finally printed.",
                reason: "Duplicate upload",
                requestedBy: "A111",
                requestedByName: "Prachi Vijay Gulab Chand",
                timestamp: .now.addingTimeInterval(-18_000),
                status: "PENDING"
            )
        ]
    }

    func fetchInbox(for userID: String) async throws -> SocialInbox {
        SocialInbox(
            channels: MockSocialData.channels().filter { $0.userIds.contains(userID) },
            messages: MockSocialData.messages().filter { $0.senderId == userID || $0.receiverId == userID }
        )
    }

    func sendMessage(_ message: ChatMessage) async throws {}

    func markChatRead(channelID: String, userID: String) async throws {}

    func uploadImageData(_ data: Data, folder: String) async throws -> String {
        ""
    }

    func uploadAudioData(_ data: Data, folder: String, fileExtension: String) async throws -> String {
        ""
    }

    func submitDiscussion(_ discussion: DiscussionThread) async throws {}

    func submitMemory(_ memory: MemoryPost) async throws {}

    func deleteMemory(memoryID: String) async throws {}

    func toggleMemoryReaction(memoryID: String, emoji: String, userID: String) async throws {}

    func addMemoryComment(memoryID: String, comment: PostComment) async throws {}

    func submitRecipe(_ recipe: Recipe) async throws {}

    func deleteRecipe(recipeID: String) async throws {}

    func toggleRecipeReaction(recipeID: String, emoji: String, userID: String) async throws {}

    func addRecipeComment(recipeID: String, comment: PostComment) async throws {}

    func submitTradition(_ tradition: Tradition) async throws {}

    func deleteTradition(traditionID: String) async throws {}

    func toggleTraditionReaction(traditionID: String, emoji: String, userID: String) async throws {}

    func addTraditionComment(traditionID: String, comment: PostComment) async throws {}

    func submitMilestone(_ milestone: Milestone) async throws {}

    func deleteMilestone(milestoneID: String) async throws {}

    func toggleMilestoneReaction(milestoneID: String, emoji: String, userID: String) async throws {}

    func addMilestoneComment(milestoneID: String, comment: PostComment) async throws {}

    func submitDeletionRequest(_ request: DeletionRequest) async throws {}

    func resolveDeletionRequest(_ request: DeletionRequest, approved: Bool) async throws {}

    func fetchActiveGameSessions() async throws -> [GameSession] {
        []
    }

    func fetchGameSession(sessionID: String) async throws -> GameSession? {
        nil
    }

    func createGameSession(gameType: FamilyGameType, player: Member) async throws -> String {
        UUID().uuidString
    }

    func joinGameSession(sessionID: String, player: Member) async throws {}

    func updateGameState(sessionID: String, state: [String: Any], nextTurnID: String?, winnerID: String?) async throws {}

    func fetchNotifications(userID: String, isAdmin: Bool) async throws -> [AppNotification] {
        [
            AppNotification(
                id: "mock-notification-1",
                type: "EVENTS",
                title: "Today’s Family Events",
                body: "There are family events to celebrate today.",
                timestamp: .now.addingTimeInterval(-1800),
                readBy: [],
                targetUserId: nil,
                senderId: "system",
                senderName: "Purawale",
                relatedId: nil,
                isAdminOnly: false,
                topic: "events",
                metadata: [:]
            )
        ]
    }

    func markNotificationRead(notificationID: String, userID: String) async throws {}
}
