import Foundation

struct SocialInbox {
    let channels: [ChatChannel]
    let messages: [ChatMessage]
}

protocol SocialRepository {
    func fetchMemories() async throws -> [MemoryPost]
    func fetchDiscussions() async throws -> [DiscussionThread]
    func fetchRecipes() async throws -> [Recipe]
    func fetchTraditions() async throws -> [Tradition]
    func fetchMilestones() async throws -> [Milestone]
    func fetchBusinesses() async throws -> [FamilyBusiness]
    func fetchDeletionRequests() async throws -> [DeletionRequest]
    func fetchInbox(for userID: String) async throws -> SocialInbox
    func sendMessage(_ message: ChatMessage) async throws
    func markChatRead(channelID: String, userID: String) async throws
    func uploadImageData(_ data: Data, folder: String) async throws -> String
    func uploadAudioData(_ data: Data, folder: String, fileExtension: String) async throws -> String
    func submitDiscussion(_ discussion: DiscussionThread) async throws
    func deleteDiscussion(discussionID: String) async throws
    func submitMemory(_ memory: MemoryPost) async throws
    func deleteMemory(memoryID: String) async throws
    func updateMemoryCaption(memoryID: String, caption: String) async throws
    func toggleMemoryReaction(memoryID: String, emoji: String, userID: String) async throws
    func addMemoryComment(memoryID: String, comment: PostComment) async throws
    func submitRecipe(_ recipe: Recipe) async throws
    func deleteRecipe(recipeID: String) async throws
    func toggleRecipeReaction(recipeID: String, emoji: String, userID: String) async throws
    func addRecipeComment(recipeID: String, comment: PostComment) async throws
    func submitTradition(_ tradition: Tradition) async throws
    func deleteTradition(traditionID: String) async throws
    func toggleTraditionReaction(traditionID: String, emoji: String, userID: String) async throws
    func addTraditionComment(traditionID: String, comment: PostComment) async throws
    func submitMilestone(_ milestone: Milestone) async throws
    func deleteMilestone(milestoneID: String) async throws
    func toggleMilestoneReaction(milestoneID: String, emoji: String, userID: String) async throws
    func addMilestoneComment(milestoneID: String, comment: PostComment) async throws
    func submitBusiness(_ business: FamilyBusiness, treeId: String) async throws
    func deleteBusiness(businessID: String) async throws
    func submitDeletionRequest(_ request: DeletionRequest) async throws
    func resolveDeletionRequest(_ request: DeletionRequest, approved: Bool) async throws
    func fetchActiveGameSessions() async throws -> [GameSession]
    func fetchGameSession(sessionID: String) async throws -> GameSession?
    func createGameSession(gameType: FamilyGameType, player: Member) async throws -> String
    func joinGameSession(sessionID: String, player: Member) async throws
    func updateGameState(sessionID: String, state: [String: Any], nextTurnID: String?, winnerID: String?) async throws
    func fetchNotifications(userID: String, isAdmin: Bool) async throws -> [AppNotification]
    func markNotificationRead(notificationID: String, userID: String) async throws
}
