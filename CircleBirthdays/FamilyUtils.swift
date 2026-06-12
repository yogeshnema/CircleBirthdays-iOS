import Foundation

enum FamilyUtils {
    static func resolveLinks(member: Member, allMembers: [Member], currentUser: Member? = nil) -> Member {
        let familyId = member.familyId
        let normalizedId = normalizedFamilyId(familyId)
        guard !familyId.isEmpty else { return member }

        var spouseName: String?
        var fatherName: String? = nil
        var motherName: String? = nil
        var children: [String] = []
        var siblings: [String] = []

        var spouseMarriageDate: String?
        if normalizedId.hasSuffix("0") {
            let partnerId = String(normalizedId.dropLast())
            let partner = findMember(withFamilyId: partnerId, in: allMembers)
            spouseName = partner?.name ?? partnerId
            spouseMarriageDate = partner?.marriageDate
        } else {
            let partnerId = normalizedId + "0"
            let partner = findMember(withFamilyId: partnerId, in: allMembers)
            spouseName = partner?.name ?? partnerId
            spouseMarriageDate = partner?.marriageDate
        }

        let effectiveMarriageDate = member.marriageDate ?? spouseMarriageDate

        let isSpouseSuffix = normalizedId.hasSuffix("0")
        let baseId = baseFamilyId(familyId)
        let hierarchy = FamilyHierarchy(members: allMembers)

        if !isSpouseSuffix {
            let parentBaseId = hierarchy.parentBase(for: baseId)
            let parentSpouseId = parentBaseId.isEmpty ? "" : parentBaseId + "0"
            let p1 = findMember(withFamilyId: parentBaseId, in: allMembers)
            let p2 = findMember(withFamilyId: parentSpouseId, in: allMembers)

            if p1 != nil || p2 != nil {
                if isMale(p1?.gender) {
                    fatherName = p1?.name
                    motherName = p2?.name
                } else if isFemale(p1?.gender) {
                    motherName = p1?.name
                    fatherName = p2?.name
                } else if isMale(p2?.gender) {
                    fatherName = p2?.name
                    motherName = p1?.name
                } else {
                    fatherName = p1?.name
                    motherName = p2?.name
                }
            }

            let siblingsFilter: (Member) -> Bool
            if parentBaseId.isEmpty {
                siblingsFilter = { candidate in
                    false
                }
            } else {
                siblingsFilter = { candidate in
                    let candidateBase = baseFamilyId(candidate.familyId)
                    return candidateBase != baseId
                        && !isSpouseFamilyId(candidate.familyId)
                        && hierarchy.parentBase(for: candidateBase) == parentBaseId
                }
            }

            allMembers.filter(siblingsFilter).sorted { $0.name < $1.name }.forEach { siblings.append($0.name) }
        }

        let childrenFilter: (Member) -> Bool
        childrenFilter = { candidate in
            let candidateBase = baseFamilyId(candidate.familyId)
            return !isSpouseFamilyId(candidate.familyId)
                && hierarchy.parentBase(for: candidateBase) == baseId
        }

        allMembers.filter(childrenFilter).sorted { $0.name < $1.name }.forEach { children.append($0.name) }

        let familySummary = [siblings.isEmpty ? nil : "Siblings: \(siblings.joined(separator: ", ")).",
                             children.isEmpty ? nil : "Children: \(children.joined(separator: ", "))."]
            .compactMap { $0 }
            .joined(separator: " ")

        let manualRelationship = currentUser
            .flatMap { member.manualRelationships[$0.id] }
            .flatMap { relationship -> String? in
                let trimmed = relationship.trimmingCharacters(in: .whitespacesAndNewlines)
                return trimmed.isEmpty ? nil : trimmed
            }
        let inferredRelationship = manualRelationship ?? {
            guard let currentUser else { return nil }
            return getRelationship(target: member, observer: currentUser, allMembers: allMembers)
        }()

        return member.copy(
            spouseName: spouseName ?? member.spouseName,
            fatherName: fatherName ?? member.fatherName,
            motherName: motherName ?? member.motherName,
            marriageDate: effectiveMarriageDate,
            immediateFamily: familySummary.isEmpty ? member.immediateFamily : familySummary,
            relationship: inferredRelationship ?? member.relationship
        )
    }

    static func getRelationship(target: Member, observer: Member, allMembers: [Member]) -> String? {
        if target.id == observer.id { return nil }

        let targetId = normalizedFamilyId(target.familyId)
        let observerId = normalizedFamilyId(observer.familyId)
        guard !targetId.isEmpty, !observerId.isEmpty else { return nil }

        let manual = target.manualRelationships[observer.id]?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let manual, !manual.isEmpty {
            return manual
        }

        if observerId.hasSuffix("0") {
            let partnerBase = String(observerId.dropLast())
            if let partner = findMember(withFamilyId: partnerBase, in: allMembers),
               let relToPartner = getRelationship(target: target, observer: partner, allMembers: allMembers) {
                if !isFemale(partner.gender) {
                    return switch relToPartner {
                    case "Bhai": "Devar"
                    case "Bhaiya": "Jeth"
                    case "Behan", "Didi": "Nanad"
                    case "Papa": "Sasurji"
                    case "Mummy": "Saasuma"
                    default: relToPartner
                    }
                } else {
                    return switch relToPartner {
                    case "Bhai", "Bhaiya": "Saala"
                    case "Behan", "Didi": "Saali"
                    case "Papa": "Sasurji"
                    case "Mummy": "Saasuma"
                    default: relToPartner
                    }
                }
            }
        }

        let targetBase = baseFamilyId(targetId)
        let observerBase = baseFamilyId(observerId)
        let targetGeneration = relationshipGeneration(for: targetBase)
        let observerGeneration = relationshipGeneration(for: observerBase)
        let diff = observerGeneration - targetGeneration
        let targetIsSpouse = targetId.hasSuffix("0")
        let targetIsFemale = isFemale(target.gender)

        if targetIsSpouse {
            let relToPartner: String?
            if let partner = findMember(withFamilyId: targetBase, in: allMembers), partner.id != observer.id {
                relToPartner = getRelationship(target: partner, observer: observer, allMembers: allMembers)
            } else {
                relToPartner = getRelationship(
                    targetFamilyId: targetBase,
                    targetGender: nil,
                    observerFamilyId: observerId,
                    allMembers: allMembers
                )
            }

            if let relToPartner,
               let spouseRelationship = relationshipForSpouse(of: relToPartner, spouseIsFemale: targetIsFemale) {
                return spouseRelationship
            }
        }

        if diff == 0 {
            if targetBase == observerBase, targetId != observerId {
                return targetIsFemale ? "Wife" : "Husband"
            }

            if targetBase != "P", observerBase != "P" {
                let elder = isOlderBranch(targetBase, observerBase)
                if targetIsSpouse {
                    return targetIsFemale ? "Bhabhi" : "Jijaji"
                }
                return targetIsFemale ? (elder ? "Didi" : "Behan") : (elder ? "Bhaiya" : "Bhai")
            }
        }

        if diff == 1 {
            let observerParentBase = relationshipParentBase(for: observerBase)
            if targetBase == observerParentBase {
                return (targetIsFemale || targetIsSpouse) ? "Mummy" : "Papa"
            }

            let observerParentParentBase = relationshipParentBase(for: observerParentBase)
            let targetParentBase = relationshipParentBase(for: targetBase)
            let areExtendedSiblings = targetParentBase == observerParentParentBase
                || (!targetParentBase.isEmpty
                    && !observerParentParentBase.isEmpty
                    && relationshipParentBase(for: targetParentBase) == relationshipParentBase(for: observerParentParentBase))

            if areExtendedSiblings, targetBase != "P" {
                let elder = isOlderPerson(targetBase, than: observerParentBase, allMembers: allMembers)
                    ?? isOlderBranch(targetBase, observerParentBase)
                let observerParent = findMember(withFamilyId: observerParentBase, in: allMembers)
                let isPaternal = observerParent == nil
                    || isMale(observerParent?.gender)
                    || (isCoreFamilyBranch(targetBase) && isCoreFamilyBranch(observerBase))

                if targetIsSpouse {
                    if targetIsFemale {
                        return isPaternal ? (elder ? "Badi Amma" : "Chachiji") : (elder ? "Badi Mamiji" : "Choti Mamiji")
                    }
                    return isPaternal ? (elder ? "Bade Fufa" : "Chote Fufa") : (elder ? "Bade Mausa" : "Chote Mausa")
                }

                if targetIsFemale {
                    return isPaternal ? (elder ? "Badi Bua" : "Choti Bua") : (elder ? "Badi Mausi" : "Choti Mausi")
                }
                return isPaternal ? (elder ? "Bade Papa" : "Chachaji") : (elder ? "Bade Mamaji" : "Chote Mamaji")
            }
        }

        if diff == 2 {
            let observerParentBase = relationshipParentBase(for: observerBase)
            let observerParent = findMember(withFamilyId: observerParentBase, in: allMembers)
            let isMaternal = observerParent != nil
                && isFemale(observerParent?.gender)
                && !(observerParentBase.count == 1 && observerParentBase != "P")
            let observerGrandParentBase = relationshipParentBase(for: observerParentBase)

            if targetBase == observerGrandParentBase {
                if isMaternal {
                    return targetIsFemale ? "Nani" : "Nana"
                }
                return targetIsFemale ? "Dadi" : "Dadaji"
            }

            if !targetBase.isEmpty, !observerGrandParentBase.isEmpty,
               relationshipParentBase(for: targetBase) == relationshipParentBase(for: observerGrandParentBase) {
                let elder = isOlderPerson(targetBase, than: observerGrandParentBase, allMembers: allMembers)
                    ?? isOlderBranch(targetBase, observerGrandParentBase)
                if isMaternal {
                    return targetIsFemale
                        ? (elder ? "Badi Nani" : "Choti Nani")
                        : (elder ? "Bade Nana" : "Chote Nana")
                } else {
                    return targetIsFemale
                        ? (elder ? "Badi Dadi" : "Choti Dadi")
                        : (elder ? "Bade Dadaji" : "Chote Dadaji")
                }
            }
        }

        if diff == -1 {
            if targetBase.hasPrefix(observerBase) {
                if targetIsSpouse {
                    return targetIsFemale ? "Bahu" : "Damand"
                }
                return targetIsFemale ? "Beti" : "Beta"
            }

            let targetParentId = relationshipParentBase(for: targetBase)
            if let targetParent = findMember(withFamilyId: targetParentId, in: allMembers) {
                let relToParent = getRelationship(target: targetParent, observer: observer, allMembers: allMembers)
                if relToParent == "Bhai" || relToParent == "Bhaiya" || relToParent == "Didi" || relToParent == "Behan" {
                    if targetIsSpouse {
                        return targetIsFemale ? "Bahu" : "Damand"
                    }
                    if isFemale(targetParent.gender) {
                        return targetIsFemale ? "Bhanji" : "Bhanja"
                    } else {
                        return targetIsFemale ? "Bhatiji" : "Bhatija"
                    }
                }
            }
        }

        if diff == -2 {
            let targetParentId = relationshipParentBase(for: targetBase)
            if let targetParent = findMember(withFamilyId: targetParentId, in: allMembers) {
                let targetParentIsDaughter = isFemale(targetParent.gender)

                if targetBase.hasPrefix(observerBase) {
                    if targetIsSpouse {
                        return targetIsFemale ? "Bahu" : "Damand"
                    }
                    return targetParentIsDaughter
                        ? (targetIsFemale ? "Natin" : "Nati")
                        : (targetIsFemale ? "Poti" : "Pota")
                }

                let targetGrandparentId = relationshipParentBase(for: targetParentId)
                if let targetGrandparent = findMember(withFamilyId: targetGrandparentId, in: allMembers) {
                    let relToGrandparent = getRelationship(target: targetGrandparent, observer: observer, allMembers: allMembers)
                    if relToGrandparent == "Bhai" || relToGrandparent == "Bhaiya" || relToGrandparent == "Didi" || relToGrandparent == "Behan" {
                        if targetIsSpouse {
                            return targetIsFemale ? "Bahu" : "Damand"
                        }
                        return targetParentIsDaughter
                            ? (targetIsFemale ? "Natin" : "Nati")
                            : (targetIsFemale ? "Poti" : "Pota")
                    }
                }
            }
        }

        if targetBase.hasPrefix(observerBase), diff < -2 {
            return "Grandchild"
        }

        if observerBase.hasPrefix(targetBase), diff > 2 {
            return "Grandparent"
        }

        return nil
    }

    static func populateAllLinks(members: [Member], allMembers: [Member]? = nil, currentUser: Member? = nil) -> [Member] {
        let source = allMembers ?? members
        return members.map { resolveLinks(member: $0, allMembers: source, currentUser: currentUser) }
    }

    private static func getRelationship(targetFamilyId: String, targetGender: String?, observerFamilyId: String, allMembers: [Member]) -> String? {
        let targetId = normalizedFamilyId(targetFamilyId)
        let observerId = normalizedFamilyId(observerFamilyId)
        guard !targetId.isEmpty, !observerId.isEmpty else { return nil }

        let target = findMember(withFamilyId: targetId, in: allMembers) ?? placeholderMember(
            id: "target-\(targetId)",
            familyId: targetId,
            gender: targetGender ?? ""
        )
        let observer = findMember(withFamilyId: observerId, in: allMembers) ?? placeholderMember(
            id: "observer-\(observerId)",
            familyId: observerId,
            gender: ""
        )
        return getRelationship(target: target, observer: observer, allMembers: allMembers)
    }

    private static func placeholderMember(id: String, familyId: String, gender: String) -> Member {
        Member(
            id: id,
            familyId: familyId,
            name: familyId,
            gender: gender,
            dateOfBirth: "",
            phoneNumber: "",
            email: nil,
            location: nil,
            spouseName: nil,
            fatherName: nil,
            motherName: nil,
            marriageDate: nil,
            bereavementDate: nil,
            photoURL: nil,
            immediateFamily: "",
            address: nil,
            password: nil,
            isAdmin: false,
            isEditor: false,
            status: "approved",
            lastLoggedIn: nil,
            relationship: nil,
            fcmToken: nil
        )
    }

    private static func isFemale(_ gender: String?) -> Bool {
        let value = gender?.lowercased() ?? ""
        return value == "female" || value == "f" || value == "woman"
    }

    private static func isMale(_ gender: String?) -> Bool {
        let value = gender?.lowercased() ?? ""
        return value == "male" || value == "m" || value == "man"
    }

    private static func relationshipGeneration(for baseId: String) -> Int {
        let normalizedBase = normalizedFamilyId(baseId)
        if normalizedBase == "P" || normalizedBase.isEmpty { return 0 }
        return normalizedBase.count
    }

    private static func relationshipParentBase(for baseId: String) -> String {
        let normalizedBase = normalizedFamilyId(baseId)
        if normalizedBase == "P" || normalizedBase.isEmpty { return "" }
        return normalizedBase.count == 1 ? "P" : String(normalizedBase.dropLast())
    }

    private static func isCoreFamilyBranch(_ baseId: String) -> Bool {
        guard let first = normalizedFamilyId(baseId).first else { return false }
        return first >= "A" && first <= "G"
    }

    private static func normalizedFamilyId(_ familyId: String) -> String {
        familyId.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    }

    private static func isSpouseFamilyId(_ familyId: String) -> Bool {
        normalizedFamilyId(familyId).hasSuffix("0")
    }

    private static func baseFamilyId(_ familyId: String) -> String {
        let normalizedId = normalizedFamilyId(familyId)
        return normalizedId.hasSuffix("0") ? String(normalizedId.dropLast()) : normalizedId
    }

    private static func findMember(withFamilyId familyId: String, in members: [Member]) -> Member? {
        let normalizedId = normalizedFamilyId(familyId)
        return members.first { normalizedFamilyId($0.familyId) == normalizedId }
    }

    private static func relationshipForSpouse(of partnerRelationship: String, spouseIsFemale: Bool) -> String? {
        switch partnerRelationship {
        case "Papa", "Mummy":
            return spouseIsFemale ? "Mummy" : "Papa"
        case "Bhai", "Bhaiya", "Behan", "Didi":
            return spouseIsFemale ? "Bhabhi" : "Jijaji"
        case "Beta", "Beti", "Pota", "Poti", "Nati", "Natin", "Bhatija", "Bhatiji", "Bhanja", "Bhanji":
            return spouseIsFemale ? "Bahu" : "Damand"
        case "Chachaji":
            return spouseIsFemale ? "Chachiji" : "Chachaji"
        case "Bade Papa":
            return spouseIsFemale ? "Badi Amma" : "Bade Papa"
        case "Bade Mamaji":
            return spouseIsFemale ? "Badi Mamiji" : "Bade Mamaji"
        case "Chote Mamaji":
            return spouseIsFemale ? "Choti Mamiji" : "Chote Mamaji"
        case "Badi Bua":
            return spouseIsFemale ? "Badi Bua" : "Bade Fufa"
        case "Choti Bua":
            return spouseIsFemale ? "Choti Bua" : "Chote Fufa"
        case "Badi Mausi":
            return spouseIsFemale ? "Badi Mausi" : "Bade Mausa"
        case "Choti Mausi":
            return spouseIsFemale ? "Choti Mausi" : "Chote Mausa"
        case "Dadaji", "Dadi":
            return spouseIsFemale ? "Dadi" : "Dadaji"
        case "Nana", "Nani":
            return spouseIsFemale ? "Nani" : "Nana"
        default:
            return nil
        }
    }

    private static func isOlderBranch(_ id1: String, _ id2: String) -> Bool {
        var index = 0
        while index < id1.count && index < id2.count {
            let c1 = id1[id1.index(id1.startIndex, offsetBy: index)]
            let c2 = id2[id2.index(id2.startIndex, offsetBy: index)]
            if c1 != c2 {
                if c1.isNumber && c2.isNumber {
                    let n1 = Int(id1[id1.index(id1.startIndex, offsetBy: index)...].prefix { $0.isNumber }) ?? 0
                    let n2 = Int(id2[id2.index(id2.startIndex, offsetBy: index)...].prefix { $0.isNumber }) ?? 0
                    if n1 != n2 { return n1 < n2 }
                }
                return c1 < c2
            }
            index += 1
        }
        return id1.count < id2.count
    }

    private static func isOlderPerson(_ baseId: String, than referenceBaseId: String, allMembers: [Member]) -> Bool? {
        guard let date = findMember(withFamilyId: baseId, in: allMembers)?.birthDateValue,
              let referenceDate = findMember(withFamilyId: referenceBaseId, in: allMembers)?.birthDateValue else {
            return nil
        }
        return date < referenceDate
    }

    private struct FamilyHierarchy {
        private let presentBases: Set<String>

        init(members: [Member]) {
            presentBases = Set(members.compactMap { member -> String? in
                let base = Self.baseId(member.familyId)
                guard !base.isEmpty else { return nil }
                return base
            })
        }

        func generation(for baseId: String) -> Int {
            let normalizedBase = Self.normalizedFamilyId(baseId)
            guard !normalizedBase.isEmpty else { return 0 }
            let parent = parentBase(for: normalizedBase)
            if parent.isEmpty { return 0 }
            return generation(for: parent) + 1
        }

        func parentBase(for baseId: String) -> String {
            let normalizedBase = Self.normalizedFamilyId(baseId)
            guard !normalizedBase.isEmpty, normalizedBase != "P" else { return "" }
            if normalizedBase.count == 1 {
                return presentBases.contains("P") ? "P" : ""
            }

            var candidate = String(normalizedBase.dropLast())
            while !candidate.isEmpty {
                if presentBases.contains(candidate) {
                    return candidate
                }
                candidate = candidate.count > 1 ? String(candidate.dropLast()) : ""
            }
            return presentBases.contains("P") ? "P" : ""
        }

        func areTopLevelSiblings(_ lhs: String, _ rhs: String) -> Bool {
            let normalizedLhs = Self.normalizedFamilyId(lhs)
            let normalizedRhs = Self.normalizedFamilyId(rhs)
            let lhsParent = parentBase(for: normalizedLhs)
            let rhsParent = parentBase(for: normalizedRhs)
            return !normalizedLhs.isEmpty
                && !normalizedRhs.isEmpty
                && normalizedLhs != normalizedRhs
                && !lhsParent.isEmpty
                && lhsParent == rhsParent
        }

        private static func baseId(_ familyId: String) -> String {
            let normalizedId = normalizedFamilyId(familyId)
            return normalizedId.hasSuffix("0") ? String(normalizedId.dropLast()) : normalizedId
        }

        private static func normalizedFamilyId(_ familyId: String) -> String {
            familyId.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        }
    }
}
