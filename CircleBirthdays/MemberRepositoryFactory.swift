import Foundation

enum MemberRepositoryFactory {
    static func makeRepository() -> MemberRepository {
        if FirebaseBootstrap.isConfigured {
            return FirebaseMemberRepository()
        }

        return MockMemberRepository()
    }
}
