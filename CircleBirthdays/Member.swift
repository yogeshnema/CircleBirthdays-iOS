import Foundation

struct Member: Identifiable, Equatable {
    let id: String
    let familyId: String
    let name: String
    let gender: String
    let dateOfBirth: String
    let phoneNumber: String
    let email: String?
    let location: String?
    let spouseName: String?
    let fatherName: String?
    let motherName: String?
    let marriageDate: String?
    let bereavementDate: String?
    let photoURL: String?
    let immediateFamily: String
    let address: String?
    let latitude: Double?
    let longitude: Double?
    let flatNumber: String?
    let floor: String?
    let landmark: String?
    let password: String?
    let isAdmin: Bool
    let isEditor: Bool
    let status: String
    let lastLoggedIn: Int64?
    let relationship: String?
    let fcmToken: String?
    let facebookURL: String?
    let instagramURL: String?
    let youtubeURL: String?
    let manualRelationships: [String: String]
    let requestedBy: String?
    let requestedByName: String?
    let requestedRelationship: String?
    let points: Int
    let level: Int
    let badges: [String]

    init(
        id: String,
        familyId: String,
        name: String,
        gender: String,
        dateOfBirth: String,
        phoneNumber: String,
        email: String?,
        location: String?,
        spouseName: String?,
        fatherName: String?,
        motherName: String?,
        marriageDate: String?,
        bereavementDate: String?,
        photoURL: String?,
        immediateFamily: String,
        address: String?,
        latitude: Double? = nil,
        longitude: Double? = nil,
        flatNumber: String? = nil,
        floor: String? = nil,
        landmark: String? = nil,
        password: String?,
        isAdmin: Bool,
        isEditor: Bool,
        status: String,
        lastLoggedIn: Int64?,
        relationship: String?,
        fcmToken: String?,
        facebookURL: String? = nil,
        instagramURL: String? = nil,
        youtubeURL: String? = nil,
        manualRelationships: [String: String] = [:],
        requestedBy: String? = nil,
        requestedByName: String? = nil,
        requestedRelationship: String? = nil,
        points: Int = 0,
        level: Int = 1,
        badges: [String] = []
    ) {
        self.id = id
        self.familyId = familyId
        self.name = name
        self.gender = gender
        self.dateOfBirth = dateOfBirth
        self.phoneNumber = phoneNumber
        self.email = email
        self.location = location
        self.spouseName = spouseName
        self.fatherName = fatherName
        self.motherName = motherName
        self.marriageDate = marriageDate
        self.bereavementDate = bereavementDate
        self.photoURL = photoURL
        self.immediateFamily = immediateFamily
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.flatNumber = flatNumber
        self.floor = floor
        self.landmark = landmark
        self.password = password
        self.isAdmin = isAdmin
        self.isEditor = isEditor
        self.status = status
        self.lastLoggedIn = lastLoggedIn
        self.relationship = relationship
        self.fcmToken = fcmToken
        self.facebookURL = facebookURL
        self.instagramURL = instagramURL
        self.youtubeURL = youtubeURL
        self.manualRelationships = manualRelationships
        self.requestedBy = requestedBy
        self.requestedByName = requestedByName
        self.requestedRelationship = requestedRelationship
        self.points = points
        self.level = level
        self.badges = badges
    }

    var initials: String {
        let parts = name.split(separator: " ")
        return String(parts.prefix(2).compactMap(\.first))
    }

    var isDeceased: Bool {
        !(bereavementDate?.isEmpty ?? true)
    }

    var birthDateValue: Date? {
        Self.isoDateFormatter.date(from: dateOfBirth)
    }

    var marriageDateValue: Date? {
        guard let marriageDate else { return nil }
        return Self.isoDateFormatter.date(from: marriageDate)
    }

    func matches(searchText: String) -> Bool {
        if searchText.isEmpty {
            return true
        }

        return name.localizedCaseInsensitiveContains(searchText)
            || phoneNumber.localizedCaseInsensitiveContains(searchText)
            || (relationship?.localizedCaseInsensitiveContains(searchText) ?? false)
            || (location?.localizedCaseInsensitiveContains(searchText) ?? false)
    }

    func daysUntilBirthday(referenceDate: Date = .now, calendar: Calendar = .current) -> Int? {
        guard let birthDateValue else { return nil }
        let month = calendar.component(.month, from: birthDateValue)
        let day = calendar.component(.day, from: birthDateValue)
        let year = calendar.component(.year, from: referenceDate)

        var components = DateComponents(year: year, month: month, day: day)
        guard let currentYearBirthday = calendar.date(from: components) else { return nil }
        let today = calendar.startOfDay(for: referenceDate)
        let normalizedBirthday = calendar.startOfDay(for: currentYearBirthday)

        let nextBirthday: Date
        if normalizedBirthday < today {
            components.year = year + 1
            nextBirthday = calendar.date(from: components) ?? currentYearBirthday
        } else {
            nextBirthday = currentYearBirthday
        }

        return calendar.dateComponents([.day], from: today, to: calendar.startOfDay(for: nextBirthday)).day
    }

    func turnsAge(referenceDate: Date = .now, calendar: Calendar = .current) -> Int? {
        guard let birthDateValue else { return nil }
        let birthYear = calendar.component(.year, from: birthDateValue)
        let referenceYear = calendar.component(.year, from: referenceDate)
        let birthdayPassed = (daysUntilBirthday(referenceDate: referenceDate, calendar: calendar) ?? 0) == 0
        return birthdayPassed ? referenceYear - birthYear : referenceYear - birthYear + 1
    }

    static let isoDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static let mediumDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}
struct RelationshipOverride: Identifiable, Equatable {
    let id: String
    let observerId: String
    let observerName: String
    let targetId: String
    let targetName: String
    let relationship: String
    let status: String
}

extension Member {
    func copy(
        spouseName: String? = nil,
        fatherName: String? = nil,
        motherName: String? = nil,
        marriageDate: String? = nil,
        immediateFamily: String? = nil,
        relationship: String? = nil,
        fcmToken: String? = nil,
        password: String? = nil
    ) -> Member {
        Member(
            id: id,
            familyId: familyId,
            name: name,
            gender: gender,
            dateOfBirth: dateOfBirth,
            phoneNumber: phoneNumber,
            email: email,
            location: location,
            spouseName: spouseName ?? self.spouseName,
            fatherName: fatherName ?? self.fatherName,
            motherName: motherName ?? self.motherName,
            marriageDate: marriageDate ?? self.marriageDate,
            bereavementDate: bereavementDate,
            photoURL: photoURL,
            immediateFamily: immediateFamily ?? self.immediateFamily,
            address: address,
            latitude: latitude,
            longitude: longitude,
            flatNumber: flatNumber,
            floor: floor,
            landmark: landmark,
            password: password ?? self.password,
            isAdmin: isAdmin,
            isEditor: isEditor,
            status: status,
            lastLoggedIn: lastLoggedIn,
            relationship: relationship ?? self.relationship,
            fcmToken: fcmToken ?? self.fcmToken,
            facebookURL: facebookURL,
            instagramURL: instagramURL,
            youtubeURL: youtubeURL,
            manualRelationships: manualRelationships,
            requestedBy: requestedBy,
            requestedByName: requestedByName,
            requestedRelationship: requestedRelationship,
            points: points,
            level: level,
            badges: badges
        )
    }
}
