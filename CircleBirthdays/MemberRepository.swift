import Foundation

protocol MemberRepository {
    func fetchMembers() async throws -> [Member]
    func fetchPendingMembers() async throws -> [Member]
    func saveMember(_ member: Member, toPending: Bool) async throws
    func updatePushToken(userID: String, token: String, toPending: Bool) async throws
    func updatePassword(userID: String, passwordHash: String) async throws
    func fetchRelationshipOverrides() async throws -> [RelationshipOverride]
    func submitRelationshipOverride(_ override: RelationshipOverride) async throws
    func approveRelationshipOverride(_ override: RelationshipOverride) async throws
}
