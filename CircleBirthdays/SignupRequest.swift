import Foundation

struct SignupRequest: Identifiable, Equatable {
    let id: String
    let name: String
    let parentName: String
    let mobileNumber: String
    let email: String
    let status: String
    let requestedAt: Int64
    let suggestedMemberID: String?
    let suggestedMemberName: String?

    var normalizedStatus: String {
        status.approvalNormalizedStatus
    }
}
