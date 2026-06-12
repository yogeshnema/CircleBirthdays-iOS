import Foundation

extension String {
    var approvalNormalizedStatus: String {
        trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    }

    var isApprovedStatus: Bool {
        approvalNormalizedStatus == "APPROVED"
    }

    var isPendingStatus: Bool {
        approvalNormalizedStatus == "PENDING"
    }
}

struct PostComment: Identifiable, Equatable {
    let id: String
    let userId: String
    let userName: String
    let text: String
    let timestamp: Date
}

struct MemoryPost: Identifiable, Equatable {
    let id: String
    let userId: String
    let userName: String
    let imageURL: String
    let caption: String
    let timestamp: Date
    let status: String
    let reactions: [String: [String]]
    let comments: [PostComment]
}

struct Recipe: Identifiable, Equatable {
    let id: String
    let title: String
    let authorId: String
    let authorName: String
    let category: String
    let description: String
    let ingredients: [String]
    let instructions: String
    let imageURL: String
    let reactions: [String: [String]]
    let comments: [PostComment]
    let status: String
    let timestamp: Date
}

struct Tradition: Identifiable, Equatable {
    let id: String
    let title: String
    let authorId: String
    let authorName: String
    let description: String
    let imageURL: String
    let reactions: [String: [String]]
    let comments: [PostComment]
    let status: String
    let timestamp: Date
}

struct Milestone: Identifiable, Equatable {
    let id: String
    let title: String
    let description: String
    let year: String
    let imageURL: String
    let audioURL: String
    let location: String
    let timestamp: Date
    let authorId: String
    let authorName: String
    let visibilityType: String
    let familyContextId: String
    let reactions: [String: [String]]
    let comments: [PostComment]
    let status: String
}

enum DiscussionKind: String, Equatable, Hashable {
    case text = "TEXT"
    case image = "IMAGE"
    case poll = "POLL"
}

struct PollOption: Identifiable, Equatable {
    let id: String
    let text: String
    let voterIds: [String]
}

struct DiscussionThread: Identifiable, Equatable {
    let id: String
    let userId: String
    let userName: String
    let type: DiscussionKind
    let title: String
    let content: String
    let pollOptions: [PollOption]
    let timestamp: Date
    let status: String
    let comments: [PostComment]
}

struct ChatChannel: Identifiable, Equatable {
    let id: String
    let userIds: [String]
    let lastMessage: String
    let lastTimestamp: Date
    let unreadCount: [String: Int]
}

struct ChatMessage: Identifiable, Equatable {
    let id: String
    let senderId: String
    let senderName: String
    let receiverId: String
    let text: String
    let timestamp: Date
}

struct DeletionRequest: Identifiable, Equatable {
    let id: String
    let collectionName: String
    let docId: String
    let title: String
    let reason: String
    let requestedBy: String
    let requestedByName: String
    let timestamp: Date
    let status: String

    var isPending: Bool {
        status.isPendingStatus
    }
}

struct FamilyBusiness: Identifiable, Equatable {
    let id: String
    let name: String
    let ownerName: String
    let contactNumber: String
    let type: String
    let address: String
    let locationLink: String
    let latitude: Double?
    let longitude: Double?
    let addedBy: String
    let treeId: String
    let timestamp: Int64
}

struct AppNotification: Identifiable, Equatable {
    let id: String
    let type: String
    let title: String
    let body: String
    let timestamp: Date
    let readBy: [String]
    let targetUserId: String?
    let senderId: String?
    let senderName: String?
    let relatedId: String?
    let isAdminOnly: Bool
    let topic: String?
    let metadata: [String: String]

    func isRead(by userID: String) -> Bool {
        readBy.contains(userID)
    }
}

enum FamilyGameType: String, CaseIterable, Identifiable, Equatable {
    case snakesLadders = "SNAKES_LADDERS"
    case chess = "CHESS"
    case chaupad = "CHAUPAD"
    case hangman = "HANGMAN"
    case rummy = "RUMMY"
    case antakshari = "ANTAKSHARI"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .snakesLadders:
            return "Snakes & Ladders"
        case .chess:
            return "Chess"
        case .chaupad:
            return "Chaupad"
        case .hangman:
            return "Hangman"
        case .rummy:
            return "Rummy"
        case .antakshari:
            return "Antakshari"
        }
    }

    var hindiTitle: String {
        switch self {
        case .snakesLadders:
            return "सांप और सीढ़ी"
        case .chess:
            return "शतरंज"
        case .chaupad:
            return "चौपड़"
        case .hangman:
            return "हैंगमैन"
        case .rummy:
            return "रम्मी"
        case .antakshari:
            return "अंताक्षरी"
        }
    }

    var systemImage: String {
        switch self {
        case .snakesLadders:
            return "dice.fill"
        case .chess:
            return "checkerboard.rectangle"
        case .chaupad:
            return "circle.grid.cross.fill"
        case .hangman:
            return "character.cursor.ibeam"
        case .rummy:
            return "suit.club.fill"
        case .antakshari:
            return "music.note"
        }
    }
}

struct GameSession: Identifiable, Equatable {
    let id: String
    let gameType: FamilyGameType
    let players: [String]
    let playerNames: [String: String]
    let status: String
    let currentTurn: String
    let gameState: [String: Any]
    let winnerId: String?
    let lastUpdated: Int64

    var isFull: Bool {
        players.count >= 2
    }

    func isParticipant(_ userID: String?) -> Bool {
        guard let userID else { return false }
        return players.contains(userID)
    }

    func canJoin(_ userID: String?) -> Bool {
        guard let userID else { return false }
        return status == "WAITING" && !isFull && !players.contains(userID)
    }

    static func == (lhs: GameSession, rhs: GameSession) -> Bool {
        lhs.id == rhs.id
            && lhs.gameType == rhs.gameType
            && lhs.players == rhs.players
            && lhs.playerNames == rhs.playerNames
            && lhs.status == rhs.status
            && lhs.currentTurn == rhs.currentTurn
            && lhs.winnerId == rhs.winnerId
            && lhs.lastUpdated == rhs.lastUpdated
    }
}
