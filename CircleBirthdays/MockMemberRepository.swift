import CryptoKit
import Foundation

struct MockMemberRepository: MemberRepository {
    func fetchMembers() async throws -> [Member] {
        [
            Member(
                id: "admin",
                familyId: "admin",
                name: "Admin",
                gender: "Male",
                dateOfBirth: "1970-01-01",
                phoneNumber: "9999999999",
                email: "family-admin@example.com",
                location: "Indore",
                spouseName: nil,
                fatherName: nil,
                motherName: nil,
                marriageDate: nil,
                bereavementDate: nil,
                photoURL: nil,
                immediateFamily: "",
                address: nil,
                password: Self.sha256("1234"),
                isAdmin: true,
                isEditor: true,
                status: "APPROVED",
                lastLoggedIn: 1_714_930_400_000,
                relationship: "Admin",
                fcmToken: nil
            ),
            Member(
                id: "A11",
                familyId: "A11",
                name: "Vijay Gulab Chand",
                gender: "Male",
                dateOfBirth: "1958-11-28",
                phoneNumber: "9876543210",
                email: "vijay@example.com",
                location: "Ujjain",
                spouseName: "Manjula Vijay Gulab Chand",
                fatherName: "Gulab Chand",
                motherName: "Savitri Gulab Chand",
                marriageDate: "1989-12-02",
                bereavementDate: nil,
                photoURL: nil,
                immediateFamily: "Children: Prachi Vijay Gulab Chand, Varun Vijay Gulab Chand.",
                address: "Madhav Nagar",
                password: nil,
                isAdmin: false,
                isEditor: false,
                status: "APPROVED",
                lastLoggedIn: 1_714_844_000_000,
                relationship: "Bade Papa",
                fcmToken: nil
            ),
            Member(
                id: "A111",
                familyId: "A111",
                name: "Prachi Vijay Gulab Chand",
                gender: "Female",
                dateOfBirth: "1995-06-21",
                phoneNumber: "9898989898",
                email: "prachi@example.com",
                location: "Pune",
                spouseName: "Rishav Prachi Vijay Gulab Chand",
                fatherName: "Vijay Gulab Chand",
                motherName: "Manjula Vijay Gulab Chand",
                marriageDate: nil,
                bereavementDate: nil,
                photoURL: nil,
                immediateFamily: "Siblings: Varun Vijay Gulab Chand.",
                address: "Baner",
                password: Self.sha256("family123"),
                isAdmin: false,
                isEditor: false,
                status: "APPROVED",
                lastLoggedIn: 1_714_757_600_000,
                relationship: "Didi",
                fcmToken: nil
            ),
            Member(
                id: "A112",
                familyId: "A112",
                name: "Varun Vijay Gulab Chand",
                gender: "Male",
                dateOfBirth: "1997-03-13",
                phoneNumber: "9123456789",
                email: "varun@example.com",
                location: "Bhopal",
                spouseName: nil,
                fatherName: "Vijay Gulab Chand",
                motherName: "Manjula Vijay Gulab Chand",
                marriageDate: nil,
                bereavementDate: nil,
                photoURL: nil,
                immediateFamily: "Siblings: Prachi Vijay Gulab Chand.",
                address: "Arera Colony",
                password: Self.sha256("circle123"),
                isAdmin: false,
                isEditor: false,
                status: "APPROVED",
                lastLoggedIn: nil,
                relationship: "Bhai",
                fcmToken: nil
            ),
            Member(
                id: "A61",
                familyId: "A61",
                name: "Pratish Kanti",
                gender: "Male",
                dateOfBirth: "1989-11-16",
                phoneNumber: "9011112222",
                email: nil,
                location: "Mumbai",
                spouseName: nil,
                fatherName: "Yogesh Kanti",
                motherName: "Kanti",
                marriageDate: "2025-11-04",
                bereavementDate: nil,
                photoURL: nil,
                immediateFamily: "",
                address: nil,
                password: nil,
                isAdmin: false,
                isEditor: false,
                status: "APPROVED",
                lastLoggedIn: nil,
                relationship: "Bhaiya",
                fcmToken: nil
            )
        ]
    }

    func fetchPendingMembers() async throws -> [Member] {
        [
            Member(
                id: "A431",
                familyId: "A431",
                name: "Parv (Naman) Manoj Purushottam",
                gender: "Male",
                dateOfBirth: "2007-04-07",
                phoneNumber: "",
                email: nil,
                location: "Indore",
                spouseName: nil,
                fatherName: "Manoj Purushottam",
                motherName: "Amita Manoj Purushottam",
                marriageDate: nil,
                bereavementDate: nil,
                photoURL: nil,
                immediateFamily: "",
                address: nil,
                password: nil,
                isAdmin: false,
                isEditor: false,
                status: "PENDING",
                lastLoggedIn: nil,
                relationship: "Bhatija",
                fcmToken: nil
            )
        ]
    }

    func saveMember(_ member: Member, toPending: Bool) async throws {}

    func deletePendingMember(userID: String) async throws {}

    func updatePushToken(userID: String, token: String, toPending: Bool) async throws {}

    func updatePassword(userID: String, passwordHash: String) async throws {}

    func updateLastLoggedIn(userID: String, timestamp: Int64) async throws {}

    func fetchSignupRequests() async throws -> [SignupRequest] {
        [
            SignupRequest(
                id: "signup-A431",
                name: "Parv Naman",
                parentName: "Manoj Purushottam",
                mobileNumber: "9000012345",
                email: "parv@example.com",
                status: "PENDING",
                requestedAt: Int64(Date().timeIntervalSince1970 * 1000),
                suggestedMemberID: "A431",
                suggestedMemberName: "Parv (Naman) Manoj Purushottam"
            )
        ]
    }

    func submitSignupRequest(_ request: SignupRequest) async throws {}

    func updateSignupRequest(_ request: SignupRequest) async throws {}

    func deleteSignupRequest(requestID: String) async throws {}

    func fetchRelationshipOverrides() async throws -> [RelationshipOverride] {
        [
            RelationshipOverride(
                id: "A111_A112",
                observerId: "A111",
                observerName: "Prachi Vijay Gulab Chand",
                targetId: "A112",
                targetName: "Varun Vijay Gulab Chand",
                relationship: "Didi",
                status: "PENDING"
            )
        ]
    }

    func submitRelationshipOverride(_ override: RelationshipOverride) async throws {}

    func approveRelationshipOverride(_ override: RelationshipOverride) async throws {}

    private static func sha256(_ value: String) -> String {
        let digest = SHA256.hash(data: Data(value.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
