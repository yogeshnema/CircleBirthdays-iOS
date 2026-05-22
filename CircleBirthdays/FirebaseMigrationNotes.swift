import Foundation

enum FirebaseMigrationNotes {
    static let swiftPackages = [
        "FirebaseCore",
        "FirebaseFirestore",
        "FirebaseStorage"
    ]

    static let topLevelCollections = [
        "members",
        "pending_updates",
        "memories",
        "discussions",
        "channels",
        "relationship_overrides",
        "deletion_requests",
        "notifications",
        "memorylane",
        "recipes",
        "traditions"
    ]

    static let memberFields = [
        "familyId: String",
        "name: String",
        "gender: String",
        "dateOfBirth: String",
        "phoneNumber: String",
        "email: String?",
        "location: String?",
        "spouseName: String?",
        "fatherName: String?",
        "motherName: String?",
        "marriageDate: String?",
        "bereavementDate: String?",
        "photoUrl: String?",
        "immediateFamily: String",
        "address: String?",
        "password: String?",
        "isAdmin: Bool",
        "isEditor: Bool",
        "status: String",
        "lastLoggedIn: Int64?",
        "relationship: String?",
        "fcmToken: String?"
    ]

    static let storagePattern = "photos/{uuid}.jpg"
    static let messagesPath = "channels/{channelId}/messages/{messageId}"
}
