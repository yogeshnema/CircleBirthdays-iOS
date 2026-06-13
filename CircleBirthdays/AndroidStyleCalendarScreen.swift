import SwiftUI
import UIKit
import ImageIO

struct PanchangDay: Equatable {
    let tithi: String
    let tithiShort: String
    let nakshatra: String
    let yoga: String
    let karana: String
    let muhurat: String
    let festivals: [String]
    let isPanchak: Bool
    let note: String?
    let sunrise: String
    let sunset: String
}

enum PanchangGenerator {
    static func monthData(for month: Date, calendar: Calendar, language: AppLanguage) -> [Date: PanchangDay] {
        guard let range = calendar.range(of: .day, in: .month, for: month) else { return [:] }

        let isHindi = language == .hindi
        let tithisEn = [
            "Pratipada", "Dwitiya", "Tritiya", "Chaturthi", "Panchami", "Shashti", "Saptami", "Ashtami", "Navami", "Dashami",
            "Ekadashi", "Dwadashi", "Trayodashi", "Chaturdashi", "Purnima",
            "Pratipada", "Dwitiya", "Tritiya", "Chaturthi", "Panchami", "Shashti", "Saptami", "Ashtami", "Navami", "Dashami",
            "Ekadashi", "Dwadashi", "Trayodashi", "Chaturdashi", "Amavasya"
        ]
        let tithisHi = [
            "प्रतिपदा", "द्वितीया", "तृतीया", "चतुर्थी", "पंचमी", "षष्ठी", "सप्तमी", "अष्टमी", "नवमी", "दशमी",
            "एकादशी", "द्वादशी", "त्रयोदशी", "चतुर्दशी", "पूर्णिमा",
            "प्रतिपदा", "द्वितीया", "तृतीया", "चतुर्थी", "पंचमी", "षष्ठी", "सप्तमी", "अष्टमी", "नवमी", "दशमी",
            "एकादशी", "द्वादशी", "त्रयोदशी", "चतुर्दशी", "अमावस्या"
        ]
        let nakshatrasEn = ["Ashwini", "Bharani", "Krittika", "Rohini", "Mrigashirsha", "Ardra", "Punarvasu", "Pushya", "Ashlesha", "Magha", "Purva Phalguni", "Uttara Phalguni", "Hasta", "Chitra", "Swati", "Vishakha", "Anuradha", "Jyeshtha", "Mula", "Purva Ashadha", "Uttara Ashadha", "Shravana", "Dhanishta", "Shatabhisha", "Purva Bhadrapada", "Uttara Bhadrapada", "Revati"]
        let nakshatrasHi = ["अश्विनी", "भरणी", "कृत्तिका", "रोहिणी", "मृगशिरा", "आर्द्रा", "पुनर्वसु", "पुष्य", "अश्लेषा", "मघा", "पूर्वा फाल्गुनी", "उत्तरा फाल्गुनी", "हस्त", "चित्रा", "स्वाती", "विशाखा", "अनुराधा", "ज्येष्ठा", "मूल", "पूर्वाषाढ़ा", "उत्तराषाढ़ा", "श्रवण", "धनिष्ठा", "शतभिषा", "पूर्वाभाद्रपद", "उत्तराभाद्रपद", "रेवती"]
        let yogasEn = ["Vishkumbha", "Priti", "Ayushman", "Saubhagya", "Shobhana", "Atiganda", "Sukarma", "Dhriti", "Shula", "Ganda", "Vriddhi", "Dhruva", "Vyaghata", "Harshana", "Vajra", "Siddhi", "Vyatipata", "Variyan", "Parigha", "Shiva", "Siddha", "Sadhya", "Shubha", "Shukla", "Brahma", "Indra", "Vaidhriti"]
        let yogasHi = ["विष्कुम्भ", "प्रीति", "आयुष्मान्", "सौभाग्य", "शोभन", "अतिगण्ड", "सुकर्मा", "धृति", "शूल", "गण्ड", "वृद्धि", "ध्रुव", "व्याघात", "हर्षण", "वज्र", "सिद्धि", "व्यतीपात", "वरीयान्", "परिघ", "शिव", "सिद्ध", "साध्य", "शुभ", "शुक्ल", "ब्रह्म", "ऐन्द्र", "वैधृति"]
        let karanasEn = ["Bava", "Balava", "Kaulava", "Taitila", "Gara", "Vanija", "Vishti", "Shakuni", "Chatushpada", "Naga", "Kinstughna"]
        let karanasHi = ["बव", "बालव", "कौलव", "तैतिल", "गर", "वणिज", "विष्टि", "शकुनि", "चतुष्पाद", "नाग", "किंस्तुघ्न"]

        let monthNumber = calendar.component(.month, from: month)
        let year = calendar.component(.year, from: month)

        return range.reduce(into: [Date: PanchangDay]()) { result, day in
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: month) else { return }
            let tithiIndex = (day + monthNumber * 2 + year % 30) % 30
            let nakshatraIndex = (day + monthNumber) % 27
            let yogaIndex = (day + monthNumber * 3) % 27
            let karanaIndex = (day * 2) % 11
            let englishTithi = tithisEn[tithiIndex]
            let tithi = isHindi ? tithisHi[tithiIndex] : englishTithi
            let paksha = isHindi
                ? (tithiIndex < 15 ? "शुक्ल पक्ष" : "कृष्ण पक्ष")
                : (tithiIndex < 15 ? "Shukla Paksha" : "Krishna Paksha")
            var festivals = festivals2026(month: monthNumber, day: day)
            var note: String?
            var isPanchak = false

            if year == 2026 {
                panchakRanges2026[monthNumber]?.forEach { range in
                    if range.contains(day) { isPanchak = true }
                }
                let muhurats = muhurats2026[monthNumber]?.compactMap { type, days -> String? in
                    guard days.contains(day) else { return nil }
                    return isHindi ? hindiMuhuratName(type) : type
                } ?? []
                if !muhurats.isEmpty {
                    note = isHindi ? "शुभ: \(muhurats.joined(separator: ", "))" : "Shubh: \(muhurats.joined(separator: ", "))"
                }
            }

            if year != 2026 || monthNumber != 1 {
                if englishTithi == "Ekadashi" { festivals.append(isHindi ? "एकादशी व्रत" : "Ekadashi Vrat") }
                if englishTithi == "Chaturthi" { festivals.append(isHindi ? "संकष्टी चतुर्थी" : "Sankashti Chaturthi") }
                if englishTithi == "Purnima" { festivals.append(isHindi ? "पूर्णिमा व्रत" : "Purnima Vrat") }
            }

            let defaultMuhurat = day.isMultiple(of: 3)
                ? (isHindi ? "शुभ: 09:30-11:00 AM" : "Shubh: 09:30-11:00 AM")
                : (isHindi ? "अभिजीत: 11:45-12:30 PM" : "Abhijit: 11:45-12:30 PM")

            result[calendar.startOfDay(for: date)] = PanchangDay(
                tithi: "\(tithi) (\(paksha))",
                tithiShort: isHindi ? tithi : String(englishTithi.prefix(6)),
                nakshatra: isHindi ? nakshatrasHi[nakshatraIndex] : nakshatrasEn[nakshatraIndex],
                yoga: isHindi ? yogasHi[yogaIndex] : yogasEn[yogaIndex],
                karana: isHindi ? karanasHi[karanaIndex] : karanasEn[karanaIndex],
                muhurat: note ?? defaultMuhurat,
                festivals: Array(Set(festivals)).sorted(),
                isPanchak: isPanchak,
                note: note,
                sunrise: day.isMultiple(of: 2) ? "06:12 AM" : "06:14 AM",
                sunset: day.isMultiple(of: 2) ? "18:48 PM" : "18:47 PM"
            )
        }
    }

    private static func festivals2026(month: Int, day: Int) -> [String] {
        guard let festival = festivalMap2026[month]?[day] else { return [] }
        return [festival]
    }

    private static func hindiMuhuratName(_ type: String) -> String {
        switch type {
        case "Vivah": return "विवाह"
        case "Namkaran": return "नामकरण"
        case "Vyapar Prarambh": return "व्यापार प्रारम्भ"
        case "Annaprashan": return "अन्नप्राशन"
        case "Griharambh": return "गृहआरम्भ"
        default: return type
        }
    }

    private static let panchakRanges2026: [Int: [ClosedRange<Int>]] = [
        1: [3...7, 30...31],
        2: [1...3, 26...28],
        3: [1...2, 25...29],
        4: [22...26],
        5: [12...16, 24...26],
        6: [18...22],
        7: [15...19],
        8: [11...15],
        9: [7...11],
        10: [5...9],
        11: [1...5, 28...30],
        12: [1...2, 25...29]
    ]
    private static let muhurats2026: [Int: [String: [Int]]] = [
        1: [
            "Vivah": [15, 16, 18, 23, 25, 26, 28],
            "Namkaran": [2, 5, 9, 12, 16, 19, 23, 26, 30],
            "Vyapar Prarambh": [5, 8, 12, 19, 23, 28],
            "Annaprashan": [8, 12, 16, 23, 26, 30],
            "Griharambh": [15, 19, 23, 28]
        ],
        2: [
            "Vivah": [2, 4, 6, 12, 13, 17, 20, 25],
            "Namkaran": [3, 6, 10, 13, 17, 20, 24, 27],
            "Vyapar Prarambh": [4, 10, 13, 20, 24],
            "Annaprashan": [3, 6, 13, 17, 24],
            "Griharambh": [4, 12, 20, 25]
        ],
        3: [
            "Vivah": [4, 5, 8, 11, 12],
            "Namkaran": [2, 5, 9, 12, 16, 19, 23, 27, 30],
            "Vyapar Prarambh": [5, 9, 16, 23, 30],
            "Annaprashan": [2, 9, 12, 19, 27],
            "Griharambh": [5, 11, 16, 23]
        ],
        4: [
            "Vivah": [16, 17, 21, 22, 26, 27],
            "Namkaran": [3, 6, 10, 13, 17, 20, 24, 29],
            "Vyapar Prarambh": [3, 10, 17, 24, 29],
            "Annaprashan": [6, 13, 20, 24, 29],
            "Griharambh": [17, 21, 27]
        ],
        5: [
            "Vivah": [1, 3, 8, 12, 13, 14],
            "Namkaran": [4, 11, 13, 14, 18, 20, 21, 25, 27, 28],
            "Vyapar Prarambh": [3, 8, 18, 31],
            "Annaprashan": [8, 14, 20, 21, 28, 29],
            "Griharambh": [1, 4, 6]
        ],
        6: [
            "Vivah": [2, 4, 5, 7, 11, 12],
            "Namkaran": [1, 4, 8, 11, 15, 18, 22, 25, 29],
            "Vyapar Prarambh": [4, 8, 15, 22, 29],
            "Annaprashan": [1, 8, 11, 18, 25],
            "Griharambh": [2, 5, 11]
        ],
        7: [
            "Namkaran": [2, 6, 9, 13, 16, 20, 23, 27, 30],
            "Vyapar Prarambh": [2, 9, 16, 23, 30],
            "Annaprashan": [6, 13, 20, 27],
            "Griharambh": [2, 9, 23]
        ],
        8: [
            "Namkaran": [3, 6, 10, 13, 17, 20, 24, 27, 31],
            "Vyapar Prarambh": [3, 10, 17, 24, 31],
            "Annaprashan": [6, 13, 20, 27],
            "Griharambh": [10, 17, 24]
        ],
        9: [
            "Namkaran": [1, 4, 8, 11, 15, 18, 22, 25, 29],
            "Vyapar Prarambh": [1, 8, 15, 22, 29],
            "Annaprashan": [4, 11, 18, 25],
            "Griharambh": [8, 15, 22]
        ],
        10: [
            "Vivah": [22, 23, 27, 28, 30],
            "Namkaran": [2, 5, 9, 12, 16, 19, 23, 26, 30],
            "Vyapar Prarambh": [2, 9, 16, 23, 30],
            "Annaprashan": [5, 12, 19, 26],
            "Griharambh": [22, 27, 30]
        ],
        11: [
            "Vivah": [2, 3, 6, 10, 11, 16, 20, 25, 26],
            "Namkaran": [3, 6, 10, 13, 17, 20, 24, 27],
            "Vyapar Prarambh": [6, 10, 17, 24, 27],
            "Annaprashan": [3, 10, 17, 24],
            "Griharambh": [6, 16, 20, 26]
        ],
        12: [
            "Vivah": [1, 5, 6, 10, 11, 15],
            "Namkaran": [1, 4, 8, 11, 15, 18, 22, 25, 29],
            "Vyapar Prarambh": [4, 8, 15, 22, 29],
            "Annaprashan": [1, 8, 15, 22],
            "Griharambh": [5, 10, 15]
        ]
    ]

    private static let festivalMap2026: [Int: [Int: String]] = [
        1: [1: "ईस्वी सन् नव वर्ष (New Year)", 2: "व्रत पूर्णिमा", 5: "परमहंस योगानंद जयंती", 10: "सावित्री बा फुले जयंती", 12: "राष्ट्रीय युवा दिवस", 13: "लोहड़ी उत्सव", 14: "मकर संक्रांति", 19: "Bhisma Ekadashi", 23: "बसंत पंचमी", 26: "Republic Day", 29: "जया एकादशी", 31: "गुरु हरराय जयंती"],
        2: [1: "माघ पूर्णिमा", 12: "स्वामी दयानंद सरस्वती जयंती", 15: "महाशिवरात्रि", 17: "फाल्गुन अमावस्या"],
        3: [3: "होली (Dhulandi)", 10: "शीतला अष्टमी", 19: "गुड़ी पड़वा (Gudi Padwa)", 21: "गौरी पूजा (Gangaur)", 27: "राम नवमी (Ram Navami)", 31: "हनुमान जयंती"],
        4: [13: "वैशाखी", 14: "अम्बेडकर जयंती", 20: "अक्षय तृतीया"],
        5: [1: "बुद्ध पूर्णिमा, कूर्म अवतार", 3: "नारद जयंती", 13: "अपरा एकादशी व्रत", 15: "शिव चतुर्दशी व्रत", 16: "वट सावित्री अमावस्या व्रत", 18: "चन्द्रदर्शन", 20: "विनायकी चतुर्थी व्रत", 26: "गंगा दशहारा", 27: "निर्जला/कमला एकादशी", 28: "प्रदोष व्रत", 30: "ज्येष्ठ पूर्णिमा, वट पूर्णिमा"],
        6: [16: "आषाढ़ एकादशी (Devshayani)", 30: "गुरु पूर्णिमा"],
        7: [26: "प्रदोष व्रत"],
        8: [15: "स्वतंत्रता दिवस (Independence Day)", 16: "रक्षा बंधन", 25: "कृष्ण जन्माष्टमी", 28: "भाद्रपद अमावस्या"],
        9: [15: "गणेश चतुर्थी (Ganesh Chaturthi)", 26: "अनंत चतुर्दशी"],
        10: [2: "गांधी जयंती", 11: "दशहरा (Vijayadashami)", 20: "करवा चौथ", 31: "नरक चतुर्दशी"],
        11: [8: "दीपावली (Diwali)", 9: "गोवर्धन पूजा", 10: "भाई दूज", 16: "छठ पूजा", 20: "देवोत्थान एकादशी", 24: "कार्तिक पूर्णिमा"],
        12: [25: "क्रिसमस (Christmas)"]
    ]
}

struct TodayPanchangTile: View {
    let language: AppLanguage
    private let deepBrown = Color(red: 0x21 / 255.0, green: 0x13 / 255.0, blue: 0x10 / 255.0)
    private let accentGold = Color(red: 0xF2 / 255.0, green: 0xB7 / 255.0, blue: 0x05 / 255.0)
    private let lightGolden = Color(red: 0xFF / 255.0, green: 0xF0 / 255.0, blue: 0xB8 / 255.0)

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 1
        return calendar
    }

    var body: some View {
        let today = calendar.startOfDay(for: .now)
        let month = monthStart(for: today)
        if let panchang = PanchangGenerator.monthData(for: month, calendar: calendar, language: language)[today] {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "sun.max.fill")
                        .foregroundStyle(Color.yellow, Color.orange)
                    Text(language == .hindi ? "आज का पंचांग" : "Today Panchang")
                        .font(.headline)
                        .foregroundStyle(deepBrown)
                    Spacer()
                }

                HStack(alignment: .top, spacing: 14) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(language == .hindi ? "तिथि" : "Tithi")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(panchang.tithi)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(deepBrown)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(language == .hindi ? "मुहूर्त" : "Muhurat")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(panchang.muhurat.components(separatedBy: ":").last?.trimmingCharacters(in: .whitespaces) ?? panchang.muhurat)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.green)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                if !panchang.festivals.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(language == .hindi ? "त्योहार" : "Festivals")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.red)
                        ForEach(panchang.festivals.prefix(2), id: \.self) { festival in
                            Text("• \(festival)")
                                .font(.caption)
                                .foregroundStyle(deepBrown)
                        }
                    }
                }
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [Color.white.opacity(0.88), lightGolden.opacity(0.48)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(accentGold.opacity(0.85), lineWidth: 1.5)
            )
        }
    }

    private func monthStart(for date: Date) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
    }

}

struct AndroidStyleCalendarScreen: View {
    @Bindable var viewModel: AppViewModel
    @State private var selectedDate = Calendar.current.startOfDay(for: .now)
    @State private var isPanchangImagePresented = false
    private let calendarInk = Color(red: 0x21 / 255.0, green: 0x13 / 255.0, blue: 0x10 / 255.0)
    private let calendarMutedInk = Color(red: 0x64 / 255.0, green: 0x46 / 255.0, blue: 0x3A / 255.0)
    private let calendarGold = Color(red: 0xF2 / 255.0, green: 0xB7 / 255.0, blue: 0x05 / 255.0)

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 1
        return calendar
    }

    var body: some View {
        let month = monthStart(for: selectedDate)
        let panchangMap = PanchangGenerator.monthData(for: month, calendar: calendar, language: viewModel.language)
        let selectedPanchang = panchangMap[calendar.startOfDay(for: selectedDate)]

        CalendarBackground {
            NavigationStack {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        daySelector(selectedDate)
                        weekStrip(centeredOn: selectedDate)
                        dailyPanchangCard(date: selectedDate, panchang: selectedPanchang)
                        monthlyPanchangImageCard(month: month)
                        monthOverview(month: month, panchangMap: panchangMap)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .frame(maxWidth: 620, alignment: .top)
                    .frame(maxWidth: .infinity)
                }
                .background(Color.clear)
                .scrollContentBackground(.hidden)
                .navigationTitle(viewModel.language == .hindi ? "कैलेंडर" : "Calendar")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color(red: 0x08 / 255.0, green: 0x0B / 255.0, blue: 0x14 / 255.0), for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            viewModel.showDashboard()
                        } label: {
                            Label(viewModel.language == .hindi ? "होम" : "Home", systemImage: "house")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            selectedDate = calendar.startOfDay(for: .now)
                        } label: {
                            Image(systemName: "calendar.badge.clock")
                        }
                    }
                }
                .fullScreenCover(isPresented: $isPanchangImagePresented) {
                    FullScreenPanchangImage(
                        url: panchangImageURL(for: month),
                        title: month.formatted(.dateTime.month(.wide).year()),
                        onClose: {
                            isPanchangImagePresented = false
                        }
                    )
                }
            }
        }
    }

    private func dailyPanchangCard(date: Date, panchang: PanchangDay?) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "sun.max.fill")
                    .foregroundStyle(Color.yellow)
                Text(viewModel.language == .hindi ? "दैनिक पंचांग" : "Daily Panchang")
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(calendarInk)
                Spacer()
                Text(date.formatted(.dateTime.day().month(.abbreviated)))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(calendarMutedInk)
            }

            if let panchang {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    PanchangDetailLine(label: viewModel.language == .hindi ? "तिथि" : "Tithi", value: panchang.tithi, systemImage: "moon.stars")
                    PanchangDetailLine(label: viewModel.language == .hindi ? "नक्षत्र" : "Nakshatra", value: panchang.nakshatra, systemImage: "star")
                    PanchangDetailLine(label: viewModel.language == .hindi ? "योग" : "Yoga", value: panchang.yoga, systemImage: "arrow.triangle.2.circlepath")
                    PanchangDetailLine(label: viewModel.language == .hindi ? "करण" : "Karana", value: panchang.karana, systemImage: "info.circle")
                    PanchangDetailLine(label: viewModel.language == .hindi ? "मुहूर्त" : "Muhurat", value: panchang.muhurat, systemImage: "clock")
                    PanchangDetailLine(label: viewModel.language == .hindi ? "सूर्योदय/सूर्यास्त" : "Sun", value: "\(panchang.sunrise) / \(panchang.sunset)", systemImage: "sunrise")
                }

                if panchang.isPanchak || panchang.note != nil {
                    Text(panchang.note ?? (viewModel.language == .hindi ? "पञ्चक काल" : "Panchak period"))
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.red)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.red.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                }

                if !panchang.festivals.isEmpty {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(viewModel.language == .hindi ? "त्योहार और व्रत" : "Festivals and Vrat")
                            .font(.caption.weight(.heavy))
                            .foregroundStyle(Color.red.opacity(0.82))
                        ForEach(panchang.festivals, id: \.self) { festival in
                            Text("• \(festival)")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(calendarInk)
                        }
                    }
                }
            }
        }
        .padding(14)
        .calendarGlassCard()
    }

    private func daySelector(_ date: Date) -> some View {
        VStack(spacing: 12) {
            HStack {
                Button {
                    moveSelectedDate(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                }
                .frame(width: 38, height: 38)

                Spacer()

                VStack(spacing: 4) {
                    Text(date.formatted(.dateTime.weekday(.wide)))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(calendarMutedInk)
                    Text(date.formatted(.dateTime.day().month(.wide).year()))
                        .font(.title3.weight(.bold))
                        .foregroundStyle(calendarInk)
                }

                Spacer()

                Button {
                    moveSelectedDate(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                }
                .frame(width: 38, height: 38)
            }

            HStack(spacing: 10) {
                Button(viewModel.language == .hindi ? "बीता कल" : "Yesterday") {
                    moveSelectedDate(by: -1)
                }
                Button(viewModel.language == .hindi ? "आज" : "Today") {
                    selectedDate = calendar.startOfDay(for: .now)
                }
                Button(viewModel.language == .hindi ? "आने वाला कल" : "Tomorrow") {
                    moveSelectedDate(by: 1)
                }
            }
            .font(.caption.weight(.semibold))
            .buttonStyle(.bordered)
        }
        .padding(14)
        .foregroundStyle(calendarInk)
        .background(Color.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(calendarGold.opacity(0.36), lineWidth: 1)
        )
    }

    private func weekStrip(centeredOn date: Date) -> some View {
        let dates = (-3...3).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: calendar.startOfDay(for: date))
        }

        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(dates, id: \.self) { date in
                    dayPill(date)
                }
            }
            .padding(.horizontal, 2)
        }
    }

    private func dayPill(_ date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)

        return Button {
            selectedDate = calendar.startOfDay(for: date)
        } label: {
            VStack(spacing: 5) {
                Text(date.formatted(.dateTime.weekday(.abbreviated)))
                    .font(.caption2.weight(.bold))
                Text("\(calendar.component(.day, from: date))")
                    .font(.headline.weight(.heavy))
                Circle()
                    .fill(Color.clear)
                    .frame(width: 6, height: 6)
            }
            .frame(width: 58, height: 72)
            .foregroundStyle(isSelected ? .black : calendarInk)
            .background(
                isSelected ? calendarGold.opacity(0.86) : (isToday ? Color.white.opacity(0.92) : Color.white.opacity(0.82)),
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isToday || isSelected ? calendarGold.opacity(0.85) : calendarGold.opacity(0.22), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func moveSelectedDate(by days: Int) {
        selectedDate = calendar.startOfDay(for: calendar.date(byAdding: .day, value: days, to: selectedDate) ?? selectedDate)
    }

    private func monthOverview(month: Date, panchangMap: [Date: PanchangDay]) -> some View {
        VStack(spacing: 10) {
            HStack {
                Button {
                    moveMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                }
                .frame(width: 34, height: 34)

                Spacer()

                Text(month.formatted(.dateTime.month(.wide).year()))
                    .font(.headline.weight(.bold))
                    .foregroundStyle(calendarInk)

                Spacer()

                Button {
                    moveMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                }
                .frame(width: 34, height: 34)
            }

            weekdayHeader
            monthGrid(month: month, panchangMap: panchangMap)
        }
        .padding(12)
        .foregroundStyle(calendarInk)
        .background(Color.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(calendarGold.opacity(0.36), lineWidth: 1)
        )
    }

    private func moveMonth(by months: Int) {
        selectedDate = calendar.startOfDay(for: calendar.date(byAdding: .month, value: months, to: selectedDate) ?? selectedDate)
    }

    private var weekdayHeader: some View {
        HStack {
            ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { symbol in
                Text(symbol)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(calendarMutedInk)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func monthGrid(month: Date, panchangMap: [Date: PanchangDay]) -> some View {
        let days = stableCalendarDays(for: month)
        let columns = Array(repeating: GridItem(.flexible(minimum: 0), spacing: 3), count: 7)
        return LazyVGrid(columns: columns, spacing: 3) {
            ForEach(days.indices, id: \.self) { index in
                if let date = days[index] {
                    dayCell(date: date, month: month, panchang: panchangMap[calendar.startOfDay(for: date)])
                        .aspectRatio(0.92, contentMode: .fit)
                } else {
                    Color.clear
                        .aspectRatio(0.92, contentMode: .fit)
                }
            }
        }
    }

    private func dayCell(date: Date, month: Date, panchang: PanchangDay?) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        let isPanchak = panchang?.isPanchak == true
        let cellFill: Color = if isSelected {
            calendarGold.opacity(0.72)
        } else if isPanchak {
            Color(red: 1.0, green: 0.87, blue: 0.87).opacity(0.94)
        } else if isToday {
            Color.white.opacity(0.98)
        } else {
            Color.white.opacity(0.86)
        }
        let cellStroke = isToday ? calendarGold.opacity(0.82) : calendarGold.opacity(0.18)
        let dayForeground: Color = isSelected ? .black : (isPanchak ? .red : calendarInk)

        return Button {
            selectedDate = calendar.startOfDay(for: date)
        } label: {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(cellFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .stroke(cellStroke, lineWidth: 1)
                    )

                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(dayForeground)
                    .padding(4)

                if panchang?.festivals.isEmpty == false {
                    Circle()
                        .fill(isSelected ? .white : .red)
                        .frame(width: 5, height: 5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .padding(5)
                }

                if let panchang {
                    Text(panchang.tithiShort)
                        .font(.system(size: 7, weight: .bold))
                        .foregroundStyle(isSelected ? .black.opacity(0.78) : (panchang.isPanchak ? .red : calendarMutedInk))
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .padding(.horizontal, 3)
                        .padding(.bottom, 3)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(.plain)
    }

    private func selectedDetails(date: Date, panchang: PanchangDay?, events: [CalendarFamilyEvent]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if !events.isEmpty {
                VStack(alignment: .leading, spacing: 7) {
                    Text(viewModel.language == .hindi ? "पारिवारिक कार्यक्रम" : "Family Events")
                        .font(.caption.bold())
                        .foregroundStyle(.orange)
                    ForEach(events) { event in
                        HStack(spacing: 6) {
                            Image(systemName: event.iconName)
                                .font(.caption)
                                .foregroundStyle(.orange)
                            Text(event.member.name)
                                .font(.caption.weight(.bold))
                            Text("(\(event.label(language: viewModel.language)))")
                                .font(.caption2)
                                .foregroundStyle(Color.white.opacity(0.86))
                        }
                    }
                }
                .padding(10)
                .foregroundStyle(.white)
                .background(Color.white.opacity(0.22), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            }

            if let panchang {
                VStack(alignment: .leading, spacing: 8) {
                    Text(date.formatted(.dateTime.day().month(.abbreviated)))
                        .font(.headline)
                        .foregroundStyle(.white)
                    Divider()
                    PanchangDetailLine(label: viewModel.language == .hindi ? "तिथि" : "Tithi", value: panchang.tithi, systemImage: "sun.max")
                    PanchangDetailLine(label: viewModel.language == .hindi ? "नक्षत्र" : "Nakshatra", value: panchang.nakshatra, systemImage: "star")
                    PanchangDetailLine(label: viewModel.language == .hindi ? "योग" : "Yoga", value: panchang.yoga, systemImage: "arrow.triangle.2.circlepath")
                    PanchangDetailLine(label: viewModel.language == .hindi ? "करण" : "Karana", value: panchang.karana, systemImage: "info.circle")
                    PanchangDetailLine(label: viewModel.language == .hindi ? "मुहूर्त" : "Muhurat", value: panchang.muhurat, systemImage: "clock")
                    PanchangDetailLine(label: viewModel.language == .hindi ? "सूर्योदय" : "Sunrise", value: panchang.sunrise, systemImage: "sunrise")
                    PanchangDetailLine(label: viewModel.language == .hindi ? "सूर्यास्त" : "Sunset", value: panchang.sunset, systemImage: "sunset")

                    if panchang.isPanchak || panchang.note != nil {
                        Text(panchang.note ?? (viewModel.language == .hindi ? "पञ्चक" : "Panchak"))
                            .font(.caption.bold())
                            .foregroundStyle(.red)
                            .padding(7)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.red.opacity(0.10), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }

                    if !panchang.festivals.isEmpty {
                        Text(viewModel.language == .hindi ? "त्योहार" : "Festivals")
                            .font(.caption.bold())
                            .foregroundStyle(.red)
                            .padding(.top, 4)
                        ForEach(panchang.festivals, id: \.self) { festival in
                            Text("• \(festival)")
                                .font(.caption)
                                .foregroundStyle(.white)
                        }
                    }
                }
                .padding(12)
                .foregroundStyle(.white)
                .background(Color.white.opacity(0.22), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.white.opacity(0.32), lineWidth: 1)
                )
            }
        }
    }

    private func panchangImage(month: Date) -> some View {
        CompactRemotePanchangImage(url: panchangImageURL(for: month))
        .padding(6)
        .background(Color.white.opacity(0.22), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func panchangImageURL(for month: Date) -> URL? {
        let monthNumber = calendar.component(.month, from: month)
        return URL(string: "https://circlebirthdays.web.app/calendar/\(monthNumber).jpg")
    }

    private func monthlyPanchangImageCard(month: Date) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "photo.on.rectangle.angled")
                    .foregroundStyle(Color.yellow)
                Text(viewModel.language == .hindi ? "मासिक पंचांग चित्र" : "Monthly Panchang Pic")
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(calendarInk)
            }

            Button {
                isPanchangImagePresented = true
            } label: {
                panchangImage(month: month)
                    .frame(height: 150)
                    .overlay(alignment: .bottomTrailing) {
                        Label(viewModel.language == .hindi ? "पूरा देखें" : "Open", systemImage: "arrow.up.left.and.arrow.down.right")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(Color.yellow.opacity(0.92), in: Capsule())
                            .padding(8)
                    }
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .calendarGlassCard()
    }

    private func stableCalendarDays(for month: Date) -> [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: month) else { return Array(repeating: nil, count: 42) }
        let firstWeekday = calendar.component(.weekday, from: month) - 1
        var days = Array(repeating: nil as Date?, count: firstWeekday)
        days += range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: month) }
        if days.count < 42 {
            days += Array(repeating: nil, count: 42 - days.count)
        }
        return Array(days.prefix(42))
    }

    private func monthStart(for date: Date) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
    }

    private func calendarEventSnapshot(selectedDate: Date, upcomingDays: Int) -> CalendarEventSnapshot {
        let allMembers = viewModel.allResolvedMembers
        let visible = visibleMembers(from: allMembers)
        let memberByFamilyId = allMembers.reduce(into: [String: Member]()) { result, member in
            result[member.familyId] = result[member.familyId] ?? member
        }
        let today = calendar.startOfDay(for: .now)
        let selected = calendar.startOfDay(for: selectedDate)
        var dates = Set<Date>()
        dates.insert(selected)

        for offset in -3...3 {
            if let date = calendar.date(byAdding: .day, value: offset, to: selected) {
                dates.insert(calendar.startOfDay(for: date))
            }
        }

        for offset in 0...upcomingDays {
            if let date = calendar.date(byAdding: .day, value: offset, to: today) {
                dates.insert(calendar.startOfDay(for: date))
            }
        }

        let eventMap = Dictionary(uniqueKeysWithValues: dates.map { date in
            (date, familyEvents(on: date, members: visible, memberByFamilyId: memberByFamilyId))
        })
        let upcomingEvents = (1...upcomingDays).flatMap { offset -> [UpcomingCalendarEvent] in
            guard let date = calendar.date(byAdding: .day, value: offset, to: today) else { return [] }
            let day = calendar.startOfDay(for: date)
            return (eventMap[day] ?? []).map { UpcomingCalendarEvent(date: day, event: $0) }
        }

        return CalendarEventSnapshot(eventMap: eventMap, upcomingEvents: upcomingEvents)
    }

    private func familyEvents(on date: Date, members: [Member], memberByFamilyId: [String: Member]) -> [CalendarFamilyEvent] {
        members.reduce(into: [CalendarFamilyEvent]()) { events, member in
            if !member.isDeceased, matchesMonthDay(member.dateOfBirth, date: date) {
                events.append(CalendarFamilyEvent(member: member, kind: .birthday))
            }

            if let marriageDate = member.marriageDate,
               isActiveAnniversaryMember(member, memberByFamilyId: memberByFamilyId),
               matchesMonthDay(marriageDate, date: date) {
                events.append(CalendarFamilyEvent(member: member, kind: .anniversary))
            }

            if let bereavementDate = member.bereavementDate,
               matchesMonthDay(bereavementDate, date: date) || matchesMonthDay(member.dateOfBirth, date: date) {
                events.append(CalendarFamilyEvent(member: member, kind: .punyaTithi))
            }
        }
    }

    private func birthdayMembers(on date: Date) -> [Member] {
        visibleMembers.filter { !$0.isDeceased && matchesMonthDay($0.dateOfBirth, date: date) }
    }

    private func anniversaryMembers(on date: Date) -> [Member] {
        visibleMembers.filter { member in
            guard let marriageDate = member.marriageDate, isActiveAnniversaryMember(member) else { return false }
            return matchesMonthDay(marriageDate, date: date)
        }
    }

    private func punyaTithiMembers(on date: Date) -> [Member] {
        visibleMembers.filter { member in
            guard let bereavementDate = member.bereavementDate else { return false }
            return matchesMonthDay(bereavementDate, date: date) || matchesMonthDay(member.dateOfBirth, date: date)
        }
    }

    private func familyEvents(on date: Date) -> [CalendarFamilyEvent] {
        birthdayMembers(on: date).map { CalendarFamilyEvent(member: $0, kind: .birthday) }
            + anniversaryMembers(on: date).map { CalendarFamilyEvent(member: $0, kind: .anniversary) }
            + punyaTithiMembers(on: date).map { CalendarFamilyEvent(member: $0, kind: .punyaTithi) }
    }

    private func upcomingCalendarEvents(days: Int) -> [UpcomingCalendarEvent] {
        let today = calendar.startOfDay(for: .now)
        return (0...days).flatMap { offset -> [UpcomingCalendarEvent] in
            guard let date = calendar.date(byAdding: .day, value: offset, to: today) else { return [] }
            return familyEvents(on: date).map { UpcomingCalendarEvent(date: date, event: $0) }
        }
    }

    private func familyEventIcon(birthdays: [Member], anniversaries: [Member], punyaTithis: [Member]) -> String {
        if !birthdays.isEmpty {
            return "birthday.cake.fill"
        }
        if !anniversaries.isEmpty {
            return "heart.fill"
        }
        return "leaf.fill"
    }

    private var visibleMembers: [Member] {
        visibleMembers(from: viewModel.allResolvedMembers)
    }

    private func visibleMembers(from allMembers: [Member]) -> [Member] {
        guard !viewModel.hasAdminPrivileges else { return allMembers }
        return allMembers.filter { !$0.isAdmin || $0.id == viewModel.currentUser?.id }
    }

    private func isActiveAnniversaryMember(_ member: Member, memberByFamilyId: [String: Member]) -> Bool {
        guard !member.isDeceased else { return false }
        guard let partner = memberByFamilyId[partnerFamilyId(for: member.familyId)] else { return true }
        return !partner.isDeceased
    }

    private func isActiveAnniversaryMember(_ member: Member) -> Bool {
        guard !member.isDeceased else { return false }
        guard let partner = anniversaryPartner(for: member) else { return true }
        return !partner.isDeceased
    }

    private func anniversaryPartner(for member: Member) -> Member? {
        let partnerId = partnerFamilyId(for: member.familyId)
        return viewModel.allResolvedMembers.first { $0.familyId == partnerId }
    }

    private func partnerFamilyId(for familyId: String) -> String {
        familyId.hasSuffix("0") ? String(familyId.dropLast()) : familyId + "0"
    }

    private func matchesMonthDay(_ string: String?, date: Date) -> Bool {
        guard let parsed = flexibleDate(from: string) else { return false }
        return calendar.component(.month, from: parsed) == calendar.component(.month, from: date)
            && calendar.component(.day, from: parsed) == calendar.component(.day, from: date)
    }

    private func flexibleDate(from string: String?) -> Date? {
        guard let string, !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        if let date = Member.isoDateFormatter.date(from: string) { return date }
        let parts = string.components(separatedBy: CharacterSet(charactersIn: "-/")).compactMap(Int.init)
        guard parts.count >= 2 else { return nil }
        if parts[0] > 31, parts.count >= 3 {
            return calendar.date(from: DateComponents(year: parts[0], month: parts[1], day: parts[2]))
        }
        return calendar.date(from: DateComponents(year: parts.count > 2 ? parts[2] : calendar.component(.year, from: .now), month: parts[1], day: parts[0]))
    }
}

private struct UpcomingCalendarEvent: Identifiable {
    let date: Date
    let event: CalendarFamilyEvent

    var id: String {
        "\(date.timeIntervalSince1970)-\(event.id)"
    }
}

private struct CalendarEventSnapshot {
    let eventMap: [Date: [CalendarFamilyEvent]]
    let upcomingEvents: [UpcomingCalendarEvent]

    func events(on date: Date) -> [CalendarFamilyEvent] {
        eventMap[Calendar.current.startOfDay(for: date)] ?? []
    }

    func hasEvents(on date: Date) -> Bool {
        !events(on: date).isEmpty
    }
}

private struct CalendarAvatar: View {
    let member: Member

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.30))

            Text(member.initials)
                .font(.caption.weight(.heavy))
                .foregroundStyle(.white)
        }
        .frame(width: 42, height: 42)
        .overlay(
            Circle()
                .stroke(Color.white.opacity(0.30), lineWidth: 1)
        )
    }
}

private struct CompactRemotePanchangImage: View {
    let url: URL?
    @State private var thumbnail: UIImage?
    @State private var didFail = false

    var body: some View {
        ZStack {
            if let thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if didFail {
                Label("Panchang image unavailable", systemImage: "photo")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.white.opacity(0.86))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ProgressView()
                    .tint(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task(id: url?.absoluteString ?? "nil") {
            await loadThumbnail()
        }
    }

    private func loadThumbnail() async {
        guard let url else { return }
        do {
            var request = URLRequest(url: url)
            request.cachePolicy = .returnCacheDataElseLoad
            request.timeoutInterval = 20
            let (data, _) = try await URLSession.shared.data(for: request)
            guard let rendered = Self.thumbnail(from: data, maxPixelWidth: 620) else {
                throw URLError(.cannotDecodeContentData)
            }
            await MainActor.run {
                thumbnail = rendered
                didFail = false
            }
        } catch {
            await MainActor.run {
                didFail = true
            }
        }
    }

    private static func thumbnail(from data: Data, maxPixelWidth: CGFloat) -> UIImage? {
        let options = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let source = CGImageSourceCreateWithData(data as CFData, options) else { return nil }
        let thumbnailOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: Int(maxPixelWidth),
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: false
        ] as CFDictionary
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, thumbnailOptions) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

private struct FullScreenPanchangImage: View {
    let url: URL?
    let title: String
    let onClose: () -> Void
    @State private var image: UIImage?
    @State private var didFail = false
    @State private var zoom: CGFloat = 1

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let image {
                ScrollView([.horizontal, .vertical], showsIndicators: true) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(zoom)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(14)
                }
            } else if didFail {
                ContentUnavailableView("Panchang image unavailable", systemImage: "photo")
                    .foregroundStyle(.white)
            } else {
                ProgressView()
                    .tint(.white)
            }

            VStack {
                HStack(spacing: 10) {
                    Text(title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                    Spacer()
                    Button {
                        zoom = zoom == 1 ? 1.8 : 1
                    } label: {
                        Image(systemName: "plus.magnifyingglass")
                            .frame(width: 40, height: 40)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.white)

                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.headline.weight(.bold))
                            .frame(width: 40, height: 40)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.black.opacity(0.62))

                Spacer()
            }
        }
        .task(id: url?.absoluteString ?? "nil") {
            await loadImage()
        }
    }

    private func loadImage() async {
        guard let url else { return }
        do {
            let loaded = try await RemoteMediaCache.shared.image(for: url)
            await MainActor.run {
                image = loaded
                didFail = false
            }
        } catch {
            await MainActor.run {
                didFail = true
            }
        }
    }
}

private extension View {
    func calendarGlassCard() -> some View {
        self
            .background(Color.white.opacity(0.90), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color(red: 0xF2 / 255.0, green: 0xB7 / 255.0, blue: 0x05 / 255.0).opacity(0.32), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.16), radius: 10, x: 0, y: 4)
    }
}

private struct CalendarBackground<Content: View>: View {
    @ViewBuilder let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            Color(red: 0x08 / 255.0, green: 0x0B / 255.0, blue: 0x14 / 255.0)
                .ignoresSafeArea()

            Image("Background")
                .resizable()
                .scaledToFill()
                .opacity(0.38)
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color(red: 0x08 / 255.0, green: 0x0B / 255.0, blue: 0x14 / 255.0).opacity(0.62),
                    Color(red: 0x12 / 255.0, green: 0x18 / 255.0, blue: 0x27 / 255.0).opacity(0.48),
                    Color(red: 0x24 / 255.0, green: 0x16 / 255.0, blue: 0x26 / 255.0).opacity(0.58)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            content
        }
    }
}

private struct CalendarFamilyEvent: Identifiable {
    enum Kind {
        case birthday
        case anniversary
        case punyaTithi
    }

    let member: Member
    let kind: Kind

    var id: String { "\(member.id)-\(kind)" }

    func label(language: AppLanguage) -> String {
        switch kind {
        case .birthday:
            return language == .hindi ? "जनमदिन" : "Birthday"
        case .anniversary:
            return language == .hindi ? "वर्षगांठ" : "Anniversary"
        case .punyaTithi:
            return language == .hindi ? "पुण्यतिथि" : "Punya Tithi"
        }
    }

    var iconName: String {
        switch kind {
        case .birthday:
            return "birthday.cake.fill"
        case .anniversary:
            return "heart.fill"
        case .punyaTithi:
            return "leaf.fill"
        }
    }
}

private struct PanchangDetailLine: View {
    let label: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: systemImage)
                .font(.caption2)
                .foregroundStyle(Color(red: 0xF2 / 255.0, green: 0xB7 / 255.0, blue: 0x05 / 255.0))
                .frame(width: 14)
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.system(size: 9))
                    .foregroundStyle(Color(red: 0x64 / 255.0, green: 0x46 / 255.0, blue: 0x3A / 255.0))
                Text(value)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color(red: 0x21 / 255.0, green: 0x13 / 255.0, blue: 0x10 / 255.0))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
