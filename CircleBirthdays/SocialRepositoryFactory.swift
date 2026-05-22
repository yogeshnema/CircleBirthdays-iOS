import Foundation

enum SocialRepositoryFactory {
    static func makeRepository() -> SocialRepository {
        if FirebaseBootstrap.isConfigured {
            return FirebaseSocialRepository()
        }

        return MockSocialRepository()
    }
}
