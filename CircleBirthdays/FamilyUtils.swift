import Foundation

enum FamilyUtils {
    static func resolveLinks(member: Member, allMembers: [Member], currentUser: Member? = nil) -> Member {
        let familyId = member.familyId
        guard !familyId.isEmpty else { return member }

        var spouseName: String?
        var fatherName: String? = nil
        var motherName: String? = nil
        var children: [String] = []
        var siblings: [String] = []

        var spouseMarriageDate: String?
        if familyId.hasSuffix("0") {
            let partnerId = String(familyId.dropLast())
            let partner = allMembers.first { $0.familyId == partnerId }
            spouseName = partner?.name
            spouseMarriageDate = partner?.marriageDate
        } else {
            let partnerId = familyId + "0"
            let partner = allMembers.first { $0.familyId == partnerId }
            spouseName = partner?.name
            spouseMarriageDate = partner?.marriageDate
        }

        let effectiveMarriageDate = member.marriageDate ?? spouseMarriageDate

        let isSpouseSuffix = familyId.hasSuffix("0")
        let baseId = isSpouseSuffix ? String(familyId.dropLast()) : familyId

        if !isSpouseSuffix, (baseId.count > 1 || (baseId.count == 1 && baseId != "P")) {
            let parentBaseId = baseId.count > 1 ? String(baseId.dropLast()) : "P"
            let parentSpouseId = parentBaseId == "P" ? "P0" : parentBaseId + "0"
            let p1 = allMembers.first { $0.familyId == parentBaseId }
            let p2 = allMembers.first { $0.familyId == parentSpouseId }

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
            if parentBaseId == "P" {
                siblingsFilter = { candidate in
                    candidate.familyId.count == 1
                        && candidate.familyId != "P"
                        && !candidate.familyId.hasSuffix("0")
                        && candidate.familyId != baseId
                }
            } else {
                siblingsFilter = { candidate in
                    candidate.familyId.count == baseId.count
                        && candidate.familyId.hasPrefix(parentBaseId)
                        && !candidate.familyId.hasSuffix("0")
                        && candidate.familyId != baseId
                }
            }

            allMembers.filter(siblingsFilter).sorted { $0.name < $1.name }.forEach { siblings.append($0.name) }
        }

        let childrenFilter: (Member) -> Bool
        if baseId == "P" {
            childrenFilter = { candidate in
                candidate.familyId.count == 1
                    && candidate.familyId != "P"
                    && !candidate.familyId.hasSuffix("0")
            }
        } else {
            childrenFilter = { candidate in
                candidate.familyId.count == baseId.count + 1
                    && candidate.familyId.hasPrefix(baseId)
                    && !candidate.familyId.hasSuffix("0")
            }
        }

        allMembers.filter(childrenFilter).sorted { $0.name < $1.name }.forEach { children.append($0.name) }

        let familySummary = [siblings.isEmpty ? nil : "Siblings: \(siblings.joined(separator: ", ")).",
                             children.isEmpty ? nil : "Children: \(children.joined(separator: ", "))."]
            .compactMap { $0 }
            .joined(separator: " ")

        let inferredRelationship = currentUser.flatMap { member.manualRelationships[$0.id] } ?? {
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

        let targetId = target.familyId
        let observerId = observer.familyId
        guard !targetId.isEmpty, !observerId.isEmpty else { return nil }

        if observerId.hasSuffix("0") {
            let partnerBase = String(observerId.dropLast())
            if let partner = allMembers.first(where: { $0.familyId == partnerBase }),
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

        let targetBase = targetId.hasSuffix("0") ? String(targetId.dropLast()) : targetId
        let observerBase = observerId.hasSuffix("0") ? String(observerId.dropLast()) : observerId
        let targetGeneration = targetBase == "P" ? 0 : targetBase.count
        let observerGeneration = observerBase == "P" ? 0 : observerBase.count
        let diff = observerGeneration - targetGeneration
        let targetIsSpouse = targetId.hasSuffix("0")
        let targetIsFemale = isFemale(target.gender)

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
            let observerParentBase = getParentBase(observerBase)
            if targetBase == observerParentBase {
                return (targetIsFemale || targetIsSpouse) ? "Mummy" : "Papa"
            }

            let observerParentParentBase = getParentBase(observerParentBase)
            let targetParentBase = getParentBase(targetBase)
            let areExtendedSiblings = targetParentBase == observerParentParentBase
                || (!targetParentBase.isEmpty
                    && !observerParentParentBase.isEmpty
                    && getParentBase(targetParentBase) == getParentBase(observerParentParentBase))

            if areExtendedSiblings, targetBase != "P" {
                let elder = isOlderBranch(targetBase, observerParentBase)
                let observerParent = allMembers.first { $0.familyId == observerParentBase }
                let coreBranches = Set(["A", "B", "C", "D", "E", "F", "G"])
                let observerBranch = observerBase.first.map { String($0) }
                let targetBranch = targetBase.first.map { String($0) }
                let isPaternal = observerParent == nil
                    || isMale(observerParent?.gender)
                    || (observerBranch.map { coreBranches.contains($0) } ?? false
                        && targetBranch.map { coreBranches.contains($0) } ?? false)

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
            let observerParentBase = getParentBase(observerBase)
            let observerParent = allMembers.first { $0.familyId == observerParentBase }
            let isMaternal = observerParent != nil
                && isFemale(observerParent?.gender)
                && !(observerParentBase.count == 1 && observerParentBase != "P")
            let observerGrandParentBase = getParentBase(observerParentBase)

            if targetBase == observerGrandParentBase {
                if isMaternal {
                    return targetIsFemale ? "Nani" : "Nana"
                }
                return targetIsFemale ? "Dadi" : "Dadaji"
            }

            if !targetBase.isEmpty, !observerGrandParentBase.isEmpty,
               getParentBase(targetBase) == getParentBase(observerGrandParentBase) {
                let elder = isOlderBranch(targetBase, observerGrandParentBase)
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

            let targetParentId = getParentBase(targetBase)
            if let targetParent = allMembers.first(where: { $0.familyId == targetParentId }) {
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
            let targetParentId = getParentBase(targetBase)
            if let targetParent = allMembers.first(where: { $0.familyId == targetParentId }) {
                let targetParentIsDaughter = isFemale(targetParent.gender)

                if targetBase.hasPrefix(observerBase) {
                    if targetIsSpouse {
                        return targetIsFemale ? "Bahu" : "Damand"
                    }
                    return targetParentIsDaughter
                        ? (targetIsFemale ? "Natin" : "Nati")
                        : (targetIsFemale ? "Poti" : "Pota")
                }

                let targetGrandparentId = getParentBase(targetParentId)
                if let targetGrandparent = allMembers.first(where: { $0.familyId == targetGrandparentId }) {
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

    private static func isFemale(_ gender: String?) -> Bool {
        let value = gender?.lowercased() ?? ""
        return value == "female" || value == "f" || value == "woman"
    }

    private static func isMale(_ gender: String?) -> Bool {
        let value = gender?.lowercased() ?? ""
        return value == "male" || value == "m" || value == "man"
    }

    private static func getParentBase(_ baseId: String) -> String {
        if baseId == "P" || baseId.isEmpty { return "" }
        return baseId.count == 1 ? "P" : String(baseId.dropLast())
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
}
