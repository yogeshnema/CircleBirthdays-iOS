import Foundation

#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

struct FirebaseMemberRepository: MemberRepository {
    func fetchMembers() async throws -> [Member] {
        try await fetchCollection(named: "members")
    }

    func fetchPendingMembers() async throws -> [Member] {
        #if canImport(FirebaseFirestore)
        guard FirebaseBootstrap.isConfigured else {
            throw FirebaseRepositoryError.notConfigured
        }

        let snapshot = try await Firestore.firestore()
            .collection("pending_updates")
            .getDocuments()

        return snapshot.documents
            .map(Member.init(document:))
            .sorted { lhs, rhs in
                if lhs.familyId == rhs.familyId {
                    return lhs.name < rhs.name
                }
                return lhs.familyId < rhs.familyId
            }
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func saveMember(_ member: Member, toPending: Bool) async throws {
        #if canImport(FirebaseFirestore)
        guard FirebaseBootstrap.isConfigured else {
            throw FirebaseRepositoryError.notConfigured
        }

        let collection = toPending ? "pending_updates" : "members"
        try await Firestore.firestore()
            .collection(collection)
            .document(member.id)
            .setData(member.firestoreData)
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func deletePendingMember(userID: String) async throws {
        #if canImport(FirebaseFirestore)
        guard FirebaseBootstrap.isConfigured else {
            throw FirebaseRepositoryError.notConfigured
        }

        try await Firestore.firestore()
            .collection("pending_updates")
            .document(userID)
            .delete()
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func updatePushToken(userID: String, token: String, toPending: Bool) async throws {
        #if canImport(FirebaseFirestore)
        guard FirebaseBootstrap.isConfigured else {
            throw FirebaseRepositoryError.notConfigured
        }

        let collection = toPending ? "pending_updates" : "members"
        try await Firestore.firestore()
            .collection(collection)
            .document(userID)
            .setData(["fcmToken": token], merge: true)
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func updatePassword(userID: String, passwordHash: String) async throws {
        #if canImport(FirebaseFirestore)
        guard FirebaseBootstrap.isConfigured else {
            throw FirebaseRepositoryError.notConfigured
        }

        try await Firestore.firestore()
            .collection("members")
            .document(userID)
            .updateData(["password": passwordHash])
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func updateLastLoggedIn(userID: String, timestamp: Int64) async throws {
        #if canImport(FirebaseFirestore)
        guard FirebaseBootstrap.isConfigured else {
            throw FirebaseRepositoryError.notConfigured
        }

        try await Firestore.firestore()
            .collection("members")
            .document(userID)
            .setData(["lastLoggedIn": timestamp], merge: true)
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func fetchSignupRequests() async throws -> [SignupRequest] {
        #if canImport(FirebaseFirestore)
        guard FirebaseBootstrap.isConfigured else {
            throw FirebaseRepositoryError.notConfigured
        }

        let snapshot = try await Firestore.firestore()
            .collection("signup_requests")
            .order(by: "requestedAt", descending: true)
            .getDocuments()

        return snapshot.documents
            .map(SignupRequest.init(document:))
            .filter { $0.normalizedStatus.isPendingStatus }
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func submitSignupRequest(_ request: SignupRequest) async throws {
        #if canImport(FirebaseFirestore)
        guard FirebaseBootstrap.isConfigured else {
            throw FirebaseRepositoryError.notConfigured
        }

        try await Firestore.firestore()
            .collection("signup_requests")
            .document(request.id)
            .setData(request.firestoreData)
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func updateSignupRequest(_ request: SignupRequest) async throws {
        try await submitSignupRequest(request)
    }

    func deleteSignupRequest(requestID: String) async throws {
        #if canImport(FirebaseFirestore)
        guard FirebaseBootstrap.isConfigured else {
            throw FirebaseRepositoryError.notConfigured
        }

        try await Firestore.firestore()
            .collection("signup_requests")
            .document(requestID)
            .delete()
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func fetchRelationshipOverrides() async throws -> [RelationshipOverride] {
        #if canImport(FirebaseFirestore)
        guard FirebaseBootstrap.isConfigured else {
            throw FirebaseRepositoryError.notConfigured
        }

        let snapshot = try await Firestore.firestore()
            .collection("relationship_overrides")
            .getDocuments()

        return snapshot.documents
            .compactMap(RelationshipOverride.init(document:))
            .filter { $0.status.uppercased() == "PENDING" }
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func submitRelationshipOverride(_ override: RelationshipOverride) async throws {
        #if canImport(FirebaseFirestore)
        guard FirebaseBootstrap.isConfigured else {
            throw FirebaseRepositoryError.notConfigured
        }

        try await Firestore.firestore()
            .collection("relationship_overrides")
            .document(override.id)
            .setData(override.firestoreData)
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    func approveRelationshipOverride(_ override: RelationshipOverride) async throws {
        #if canImport(FirebaseFirestore)
        guard FirebaseBootstrap.isConfigured else {
            throw FirebaseRepositoryError.notConfigured
        }

        let db = Firestore.firestore()
        let memberRef = db.collection("members").document(override.targetId)
        let overrideRef = db.collection("relationship_overrides").document(override.id)
        let snapshot = try await memberRef.getDocument()
        let data = snapshot.data() ?? [:]
        let manual = data["manualRelationships"] as? [String: String] ?? [:]
        var updatedManual = manual
        updatedManual[override.observerId] = override.relationship

        try await memberRef.setData(["manualRelationships": updatedManual], merge: true)
        try await overrideRef.delete()
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }

    private func fetchCollection(named collectionName: String) async throws -> [Member] {
        #if canImport(FirebaseFirestore)
        guard FirebaseBootstrap.isConfigured else {
            throw FirebaseRepositoryError.notConfigured
        }

        let snapshot = try await Firestore.firestore()
            .collection(collectionName)
            .order(by: "familyId")
            .getDocuments()

        return snapshot.documents.map(Member.init(document:))
        #else
        throw FirebaseRepositoryError.sdkMissing
        #endif
    }
}

enum FirebaseRepositoryError: LocalizedError {
    case sdkMissing
    case notConfigured

    var errorDescription: String? {
        switch self {
        case .sdkMissing:
            return "Firebase SDK is not installed in the Xcode project."
        case .notConfigured:
            return "Firebase is not configured. Add GoogleService-Info.plist to the app target."
        }
    }
}

#if canImport(FirebaseFirestore)
private extension Member {
    init(document: QueryDocumentSnapshot) {
        let data = document.data()
        let badgesRaw = data["badges"] as? [Any] ?? []
        let badges = badgesRaw.compactMap { $0 as? String }

        self.init(
            id: document.documentID,
            familyId: data["familyId"] as? String ?? document.documentID,
            name: data["name"] as? String ?? "",
            gender: data["gender"] as? String ?? "",
            dateOfBirth: Self.dateString(from: data["dateOfBirth"]) ?? "",
            phoneNumber: data["phoneNumber"] as? String ?? "",
            email: data["email"] as? String,
            location: data["location"] as? String,
            spouseName: data["spouseName"] as? String,
            fatherName: data["fatherName"] as? String,
            motherName: data["motherName"] as? String,
            marriageDate: Self.dateString(from: data["marriageDate"]),
            bereavementDate: Self.dateString(from: data["bereavementDate"]),
            photoURL: data["photoUrl"] as? String,
            immediateFamily: data["immediateFamily"] as? String ?? "",
            address: data["address"] as? String,
            latitude: data["latitude"] as? Double ?? (data["latitude"] as? NSNumber)?.doubleValue,
            longitude: data["longitude"] as? Double ?? (data["longitude"] as? NSNumber)?.doubleValue,
            flatNumber: data["flatNumber"] as? String,
            floor: data["floor"] as? String,
            landmark: data["landmark"] as? String,
            password: data["password"] as? String,
            isAdmin: data["isAdmin"] as? Bool ?? false,
            isEditor: data["isEditor"] as? Bool ?? false,
            isPrimaryTree: data["isPrimaryTree"] as? Bool ?? true,
            secondaryTreeEnabled: data["secondaryTreeEnabled"] as? Bool ?? false,
            treeId: data["treeId"] as? String ?? "primary",
            status: (data["status"] as? String ?? "APPROVED").approvalNormalizedStatus,
            lastLoggedIn: data["lastLoggedIn"] as? Int64 ?? (data["lastLoggedIn"] as? NSNumber)?.int64Value,
            relationship: data["relationship"] as? String,
            fcmToken: data["fcmToken"] as? String,
            facebookURL: data["facebookUrl"] as? String,
            instagramURL: data["instagramUrl"] as? String,
            youtubeURL: data["youtubeUrl"] as? String,
            manualRelationships: data["manualRelationships"] as? [String: String] ?? [:],
            requestedBy: data["requestedBy"] as? String,
            requestedByName: data["requestedByName"] as? String,
            requestedRelationship: data["requestedRelationship"] as? String,
            points: data["points"] as? Int ?? (data["points"] as? NSNumber)?.intValue ?? 0,
            level: data["level"] as? Int ?? (data["level"] as? NSNumber)?.intValue ?? 1,
            badges: badges
        )
    }

    private static func dateString(from value: Any?) -> String? {
        if let string = value as? String {
            return string
        }
        if let timestamp = value as? Timestamp {
            return Member.isoDateFormatter.string(from: timestamp.dateValue())
        }
        return nil
    }

    var firestoreData: [String: Any] {
        var data: [String: Any] = [
            "familyId": familyId,
            "name": name,
            "gender": gender,
            "dateOfBirth": dateOfBirth,
            "phoneNumber": phoneNumber,
            "immediateFamily": immediateFamily,
            "isAdmin": isAdmin,
            "isEditor": isEditor,
            "isPrimaryTree": isPrimaryTree,
            "secondaryTreeEnabled": secondaryTreeEnabled,
            "treeId": treeId,
            "status": status.approvalNormalizedStatus,
            "points": points,
            "level": level,
            "badges": badges
        ]

        data["email"] = email
        data["location"] = location
        data["spouseName"] = spouseName
        data["fatherName"] = fatherName
        data["motherName"] = motherName
        data["marriageDate"] = marriageDate
        data["bereavementDate"] = bereavementDate
        data["photoUrl"] = photoURL
        data["address"] = address
        data["latitude"] = latitude
        data["longitude"] = longitude
        data["flatNumber"] = flatNumber
        data["floor"] = floor
        data["landmark"] = landmark
        data["password"] = password
        data["lastLoggedIn"] = lastLoggedIn
        data["relationship"] = relationship
        data["fcmToken"] = fcmToken
        data["facebookUrl"] = facebookURL
        data["instagramUrl"] = instagramURL
        data["youtubeUrl"] = youtubeURL
        data["manualRelationships"] = manualRelationships
        data["requestedBy"] = requestedBy
        data["requestedByName"] = requestedByName
        data["requestedRelationship"] = requestedRelationship
        return data
    }
}

#if canImport(FirebaseFirestore)
private extension SignupRequest {
    init(document: QueryDocumentSnapshot) {
        let data = document.data()
        self.init(
            id: document.documentID,
            name: data["name"] as? String ?? "",
            parentName: data["parentName"] as? String ?? "",
            mobileNumber: data["mobileNumber"] as? String ?? "",
            email: data["email"] as? String ?? "",
            status: (data["status"] as? String ?? "PENDING").approvalNormalizedStatus,
            requestedAt: data["requestedAt"] as? Int64 ?? (data["requestedAt"] as? NSNumber)?.int64Value ?? 0,
            suggestedMemberID: data["suggestedMemberID"] as? String,
            suggestedMemberName: data["suggestedMemberName"] as? String
        )
    }

    var firestoreData: [String: Any] {
        var data: [String: Any] = [
            "name": name,
            "parentName": parentName,
            "mobileNumber": mobileNumber,
            "email": email,
            "status": normalizedStatus,
            "requestedAt": requestedAt
        ]

        data["suggestedMemberID"] = suggestedMemberID
        data["suggestedMemberName"] = suggestedMemberName
        return data
    }
}

private extension RelationshipOverride {
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()

        self.init(
            id: document.documentID,
            observerId: data["observerId"] as? String ?? "",
            observerName: data["observerName"] as? String ?? "",
            targetId: data["targetId"] as? String ?? "",
            targetName: data["targetName"] as? String ?? "",
            relationship: data["relationship"] as? String ?? "",
            status: (data["status"] as? String ?? "PENDING").approvalNormalizedStatus
        )
    }

    var firestoreData: [String: Any] {
        [
            "id": id,
            "observerId": observerId,
            "observerName": observerName,
            "targetId": targetId,
            "targetName": targetName,
            "relationship": relationship,
            "status": status.approvalNormalizedStatus
        ]
    }
}
#endif
#endif
