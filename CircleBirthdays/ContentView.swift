//
//  ContentView.swift
//  CircleBirthdays
//
//  Created by Ambika Nema on 04/05/26.
//

import SwiftUI
import Combine
import PhotosUI
import CoreLocation
import UIKit
import AVKit
import UniformTypeIdentifiers
import CoreImage
import CoreImage.CIFilterBuiltins
import os
#if canImport(WeatherKit)
import WeatherKit
#endif

private func localized(_ english: String, language: AppLanguage) -> String {
    guard language == .hindi else { return english }

    let hindiMap: [String: String] = [
        "Sign in": "साइन इन करें",
        "Use your family phone number to continue.": "जारी रखने के लिए अपना पारिवारिक फ़ोन नंबर उपयोग करें।",
        "Phone Number": "फ़ोन नंबर",
        "Password": "पासवर्ड",
        "Login": "लॉगिन",
        "Sign Up": "साइन अप",
        "New user request": "नया यूज़र अनुरोध",
        "Name": "नाम",
        "Father/Mother Name": "पिता/माता का नाम",
        "Mobile Number": "मोबाइल नंबर",
        "Email ID": "ईमेल आईडी",
        "Submit": "जमा करें",
        "Request submitted for admin approval.": "अनुरोध एडमिन अनुमोदन के लिए भेज दिया गया है।",
        "Family circle, memories, conversations, and traditions.": "परिवार, यादें, बातचीत और परंपराएँ।",
        "Dashboard": "डैशबोर्ड",
        "Logout": "लॉग आउट",
        "Home": "होम",
        "Upcoming Birthdays": "आने वाले जनमदिन",
        "Quick Actions": "त्वरित विकल्प",
        "Members": "सदस्य",
        "Today": "आज",
        "Pending": "लंबित",
        "Open Family Tree": "परिवार वृक्ष खोलें",
        "Browse the family hierarchy for the selected member.": "चयनित सदस्य के लिए परिवार संरचना देखें।",
        "Pending Approvals": "लंबित अनुमोदन",
        "Relationship Requests": "रिश्ता अनुरोध",
        "Deletion Requests": "हटाने के अनुरोध",
        "Approved Members": "स्वीकृत सदस्य",
        "Search by name, phone, or relationship": "नाम, फ़ोन या रिश्ते से खोजें",
        "Profiles": "प्रोफाइल",
        "Gallery": "गैलरी",
        "Discussions": "चर्चाएँ",
        "Cookbook": "पाक-पुस्तक",
        "Traditions": "परंपराएँ",
        "Memory Lane": "यादों की गली",
        "Family Tree": "वंश वृक्ष",
        "Calendar": "कैलेंडर",
        "Hindu Calendar": "हिंदू कैलेंडर",
        "Events Today": "आज के कार्यक्रम",
        "Upcoming Events (7 Days)": "आगामी कार्यक्रम (7 दिन)",
        "Birthday": "जनमदिन",
        "Anniversary": "वर्षगांठ",
        "Birth Anniversary": "जयंती",
        "Punya Tithi": "पुण्यतिथि",
        "Remembrance Day": "पुण्यतिथि",
        "Messages": "संदेश",
        "Notifications": "सूचनाएं",
        "Mark all read": "सभी पढ़े गए",
        "No notifications": "कोई सूचना नहीं",
        "Change Password": "पासवर्ड बदलें",
        "New Password": "नया पासवर्ड",
        "Save": "सेव",
        "Cancel": "रद्द करें",
        "Family Games": "फैमिली गेम्स",
        "Play together": "साथ खेलें",
        "Members + search": "सदस्य + खोज",
        "Memories": "यादें",
        "Threads + polls": "थ्रेड + पोल",
        "Recipes": "पकवान",
        "Family rituals": "पारिवारिक रस्में",
        "Milestones": "मील के पत्थर",
        "Direct chat": "सीधा चैट",
        "Memory Gallery": "स्मृति गैलरी",
        "Recent Chats": "हाल की चैट",
        "Start New Chat": "नई चैट शुरू करें",
        "Chat": "चैट",
        "Ingredients": "सामग्री",
        "Loading family circle...": "परिवार वृत्त लोड हो रहा है...",
        "Edit Profile": "प्रोफाइल संपादित करें",
        "Recipe": "रेसिपी",
        "Tradition": "परंपरा",
        "Milestone": "मील का पत्थर",
        "Add Recipe": "रेसिपी जोड़ें",
        "Edit Recipe": "रेसिपी संपादित करें",
        "Share Tradition": "परंपरा साझा करें",
        "Edit Tradition": "परंपरा संपादित करें",
        "Add Milestone": "मील का पत्थर जोड़ें",
        "Edit Milestone": "मील का पत्थर संपादित करें",
        "Basic": "मूल",
        "Family": "परिवार",
        "Media & Social": "मीडिया और सोशल",
        "Profile": "प्रोफाइल",
        "Request Delete": "हटाने का अनुरोध",
        "Request": "अनुरोध",
        "Reason": "कारण",
        "No pending": "कोई लंबित नहीं",
        "pending": "लंबित",
        "unread": "अपठित",
        "Turns": "उम्र होगी",
        "Tomorrow": "कल",
        "days": "दिन",
        "No device photo selected": "कोई फ़ोन फोटो नहीं चुनी गई",
        "Choose from Photos": "फ़ोटो से चुनें",
        "Image URL": "छवि URL",
        "Write the steps": "चरण लिखें",
        "One ingredient per line": "प्रत्येक सामग्री अलग लाइन में",
        "Description": "विवरण",
        "Title": "शीर्षक",
        "Category": "श्रेणी",
        "Instructions": "निर्देश",
        "Photo": "फ़ोटो",
        "Audio": "ऑडियो",
        "Audio URL": "ऑडियो URL",
        "Choose Audio": "ऑडियो चुनें",
        "No audio selected": "कोई ऑडियो नहीं चुना गया",
        "Audio selected": "ऑडियो चुना गया",
        "Voice Memory": "वॉइस मेमोरी",
        "Playing voice memory...": "वॉइस मेमोरी चल रही है...",
        "AI Assistant": "AI सहायक",
        "Family AI Assistant": "फैमिली AI सहायक",
        "Ask a question...": "सवाल पूछें...",
        "AI Photo Studio": "AI फोटो स्टूडियो",
        "Generate Card": "स्टिकर बनाएं",
        "Photo Studio": "फोटो स्टूडियो",
        "Prompt stickers + GIFs": "प्रॉम्प्ट स्टिकर + GIF",
        "Business": "व्यवसाय",
        "Business Directory": "व्यवसाय निर्देशिका",
        "Local services": "स्थानीय सेवाएं",
        "Achievements": "उपलब्धियां",
        "Family wins": "परिवार की उपलब्धियां",
        "Activity Log": "गतिविधि लॉग",
        "Recent activity": "हाल की गतिविधि",
        "Login Log": "लॉगिन लॉग",
        "Sign-in history": "साइन-इन इतिहास",
        "Explore": "एक्सप्लोर करें",
        "Emergency": "आपातकाल",
        "Primary": "प्राथमिक",
        "My Branch": "मेरी शाखा"
    ]

    return hindiMap[english] ?? english
}

private func openWhatsAppInvite(for member: Member, language: AppLanguage) {
    let message: String
    if language == .hindi {
        message = """
        पुरावले - हम और हमारे

        नमस्ते \(member.name)! आपको हमारे विशेष समुदाय ऐप में शामिल होने के लिए आमंत्रित किया गया है।

        Android App: https://play.google.com/store/apps/details?id=com.purawale.app
        Web Access: https://circlebirthdays.web.app/

        कृपया अपनी Email ID या Phone Number के साथ उत्तर दें ताकि हम आपका लॉगिन बना सकें और आपको एक्सेस दे सकें!
        """
    } else {
        message = """
        Purawale - Hum aur Humare

        Hello \(member.name)! You're invited to join our exclusive community app.

        Android App: https://play.google.com/store/apps/details?id=com.purawale.app
        Web Access: https://circlebirthdays.web.app/

        Please reply with your Email ID or Phone Number so we can create your login and give you access!
        """
    }

    let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    let digits = member.phoneNumber.filter(\.isNumber)
    let phone = digits.count == 10 ? "91\(digits)" : digits
    let urlString = phone.isEmpty
        ? "https://wa.me/?text=\(encodedMessage)"
        : "https://wa.me/\(phone)?text=\(encodedMessage)"

    guard let url = URL(string: urlString) else { return }
    UIApplication.shared.open(url)
}

private func profileDisplayCase(_ value: String?) -> String? {
    guard let value else { return nil }
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return nil }

    return trimmed
        .split(separator: " ", omittingEmptySubsequences: false)
        .map { word in
            word
                .split(separator: "-", omittingEmptySubsequences: false)
                .map { part in
                    guard let first = part.first else { return "" }
                    return first.uppercased() + part.dropFirst().lowercased()
                }
                .joined(separator: "-")
        }
        .joined(separator: " ")
}

private func adaptiveHorizontalPadding(for width: CGFloat) -> CGFloat {
    max(16.0, min(32.0, width * 0.05))
}

private func cardInnerWidth(for contentWidth: CGFloat) -> CGFloat {
    max(0.0, contentWidth - 28.0)
}

private enum AndroidLook {
    static let deepBrown = Color(red: 0x21 / 255.0, green: 0x13 / 255.0, blue: 0x10 / 255.0)
    static let softBrown = Color(red: 0x3F / 255.0, green: 0x28 / 255.0, blue: 0x20 / 255.0)
    static let mutedBrown = Color(red: 0x64 / 255.0, green: 0x46 / 255.0, blue: 0x3A / 255.0)
    static let cream = Color(red: 0xFF / 255.0, green: 0xF8 / 255.0, blue: 0xEA / 255.0)
    static let lightGolden = Color(red: 0xFF / 255.0, green: 0xF0 / 255.0, blue: 0xB8 / 255.0)
    static let accentGold = Color(red: 0xF2 / 255.0, green: 0xB7 / 255.0, blue: 0x05 / 255.0)
    static let darkBackground = Color(red: 0x08 / 255.0, green: 0x0B / 255.0, blue: 0x14 / 255.0)
    static let darkSurface = Color(red: 0x12 / 255.0, green: 0x18 / 255.0, blue: 0x27 / 255.0)
    static let darkPlum = Color(red: 0x24 / 255.0, green: 0x16 / 255.0, blue: 0x26 / 255.0)

    static var glassFill: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.94),
                cream.opacity(0.88),
                lightGolden.opacity(0.72)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

private func shortDisplayDate(_ value: String?) -> String? {
    guard let value, !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
    guard let parsed = Member.isoDateFormatter.date(from: value) else { return value }
    let formatter = DateFormatter()
    formatter.dateFormat = "dd MMM"
    return formatter.string(from: parsed)
}

private func completedYears(since value: String?) -> Int? {
    guard let value, let date = Member.isoDateFormatter.date(from: value) else { return nil }
    return Calendar.current.dateComponents([.year], from: date, to: .now).year
}

private func ordinalSuffix(_ value: Int) -> String {
    let mod100 = value % 100
    if (11...13).contains(mod100) {
        return "th"
    }

    switch value % 10 {
    case 1:
        return "st"
    case 2:
        return "nd"
    case 3:
        return "rd"
    default:
        return "th"
    }
}

private func loginDisplayDate(_ millis: Int64?) -> String? {
    guard let millis else { return nil }
    let formatter = DateFormatter()
    formatter.dateFormat = "dd MMM, hh:mm a"
    return formatter.string(from: Date(timeIntervalSince1970: TimeInterval(millis) / 1000.0))
}

private func imageData(fromStoredPhoto value: String?) -> Data? {
    guard let value, value.hasPrefix("data:image") else { return nil }
    let parts = value.components(separatedBy: "base64,")
    guard parts.count == 2 else { return nil }
    return Data(base64Encoded: parts[1])
}

private func imageURL(fromStoredPhoto value: String?) -> URL? {
    guard let value, !value.hasPrefix("data:image") else { return nil }
    return URL(string: value)
}

private func storedPhotoString(from imageData: Data) -> String {
    "data:image/jpeg;base64,\(imageData.base64EncodedString())"
}

private final class KeyboardState: ObservableObject {
    @Published var bottomInset: CGFloat = 0

    private var cancellables = Set<AnyCancellable>()

    init() {
        let willChange = NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)

        willChange
            .merge(with: willHide)
            .receive(on: RunLoop.main)
            .sink { [weak self] notification in
                self?.handle(notification)
            }
            .store(in: &cancellables)
    }

    private func handle(_ notification: Notification) {
        guard notification.name != UIResponder.keyboardWillHideNotification,
              let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            animate(to: 0, notification: notification)
            return
        }

        let screenHeight = UIScreen.main.bounds.height
        animate(to: max(0, screenHeight - frame.minY), notification: notification)
    }

    private func animate(to inset: CGFloat, notification: Notification) {
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
        withAnimation(.easeOut(duration: duration)) {
            bottomInset = inset
        }
    }
}

struct ContentView: View {
    @State private var viewModel = AppViewModel(
        memberRepository: MemberRepositoryFactory.makeRepository(),
        socialRepository: SocialRepositoryFactory.makeRepository()
    )
    @StateObject private var keyboard = KeyboardState()

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if viewModel.isLoading {
                    ProgressView(localized("Loading family circle...", language: viewModel.language))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    switch viewModel.currentScreen {
                    case .login:
                        LoginScreen(viewModel: viewModel)
                    case .dashboard:
                        DashboardScreen(viewModel: viewModel)
                    case .profiles:
                        ProfilesScreen(viewModel: viewModel)
                    case .gallery:
                        GalleryScreen(viewModel: viewModel)
                    case .discussions:
                        DiscussionsScreen(viewModel: viewModel)
                    case .cookbook:
                        CookbookScreen(viewModel: viewModel)
                    case .traditions:
                        TraditionsScreen(viewModel: viewModel)
                    case .memoryLane:
                        MemoryLaneScreen(viewModel: viewModel)
                    case .familyTree:
                        WholeFamilyTreeScreen(viewModel: viewModel)
                    case .calendar:
                        AndroidStyleCalendarScreen(viewModel: viewModel)
                    case .messages:
                        MessagesScreen(viewModel: viewModel)
                    case let .chat(memberID):
                        ChatScreen(viewModel: viewModel, memberID: memberID)
                    case .familyGames:
                        FamilyGamesScreen(viewModel: viewModel)
                    case let .gameLobby(gameType):
                        GameLobbyScreen(viewModel: viewModel, gameType: gameType)
                    case let .gameSession(sessionID):
                        FamilyGameSessionScreen(viewModel: viewModel, sessionID: sessionID)
                    case .notifications:
                        NotificationCenterScreen(viewModel: viewModel)
                    case let .aiCardGenerator(memberID, eventType):
                        if let member = viewModel.member(for: memberID) {
                            AICardGeneratorScreen(viewModel: viewModel, member: member, eventType: eventType)
                        } else {
                            PlaceholderFeatureScreen(
                                viewModel: viewModel,
                                title: localized("AI Photo Studio", language: viewModel.language),
                                systemImage: "sparkles.rectangle.stack.fill",
                                message: "Member profile could not be found."
                            )
                        }
                    case .businessDirectory:
                        BusinessDirectoryScreen(viewModel: viewModel)
                    case .emergency:
                        EmergencyScreen(viewModel: viewModel)
                    case .achievements:
                        AchievementsScreen(viewModel: viewModel)
                    case .activityLog:
                        ActivityLogScreen(viewModel: viewModel)
                    case .loginLog:
                        LoginLogScreen(viewModel: viewModel)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

            if viewModel.currentUser != nil, viewModel.currentScreen != .login, !viewModel.currentScreen.isGameScreen {
                FamilyAIAssistant(viewModel: viewModel, keyboardBottomInset: keyboard.bottomInset)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .padding(.leading, 14)
                    .padding(.bottom, 14 + keyboard.bottomInset)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .task {
            await viewModel.load()
        }
        .alert("Couldn’t load data", isPresented: errorBinding) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.errorMessage = nil
                }
            }
        )
    }
}

private extension AppScreen {
    var isGameScreen: Bool {
        switch self {
        case .familyGames, .gameLobby, .gameSession:
            return true
        default:
            return false
        }
    }
}

private enum AppBackgroundTreatment {
    case light
    case androidTint
    case flatDashboard
}

private struct AppBackgroundLayer: View {
    let treatment: AppBackgroundTreatment

    var body: some View {
        ZStack {
            baseColor
                .ignoresSafeArea()

            Image("Background")
                .resizable()
                .scaledToFill()
                .opacity(backgroundImageOpacity)
                .ignoresSafeArea()

            switch treatment {
            case .light:
                LinearGradient(
                    colors: [
                        AndroidLook.lightGolden.opacity(0.16),
                        AndroidLook.cream.opacity(0.08),
                        AndroidLook.lightGolden.opacity(0.12)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            case .androidTint:
                LinearGradient(
                    colors: [
                        AndroidLook.darkBackground.opacity(0.72),
                        AndroidLook.darkSurface.opacity(0.62),
                        AndroidLook.darkPlum.opacity(0.70)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            case .flatDashboard:
                LinearGradient(
                    colors: [
                        AndroidLook.darkBackground.opacity(0.62),
                        AndroidLook.darkSurface.opacity(0.48),
                        AndroidLook.darkPlum.opacity(0.58)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
        }
    }

    private var baseColor: Color {
        switch treatment {
        case .light:
            return Color.black
        case .androidTint, .flatDashboard:
            return AndroidLook.darkBackground
        }
    }

    private var backgroundImageOpacity: Double {
        switch treatment {
        case .light:
            return 0.88
        case .androidTint:
            return 0.38
        case .flatDashboard:
            return 0.44
        }
    }
}

private struct AppBackground<Content: View>: View {
    let treatment: AppBackgroundTreatment
    @ViewBuilder let content: Content

    init(treatment: AppBackgroundTreatment = .androidTint, @ViewBuilder content: () -> Content) {
        self.treatment = treatment
        self.content = content()
    }

    var body: some View {
        ZStack {
            AppBackgroundLayer(treatment: treatment)

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .background(Color.clear)
        }
    }
}

private struct LoginScreen: View {
    @Bindable var viewModel: AppViewModel
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var isSignupPresented = false
    @State private var signupMessage: String?
    private let loginTextColor = Color(red: 0x24 / 255.0, green: 0x18 / 255.0, blue: 0x14 / 255.0)
    private let loginSecondaryTextColor = Color(red: 0x5C / 255.0, green: 0x40 / 255.0, blue: 0x33 / 255.0)
    private let loginHeroTextColor = Color.white
    private let loginHeroSecondaryTextColor = Color.white.opacity(0.92)

    private var appVersionText: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Version \(version) (\(build))"
    }

    var body: some View {
        AppBackground(treatment: .light) {
            GeometryReader { proxy in
                let horizontalInset = max(16.0, proxy.size.width * 0.06)
                let cardWidth = min(proxy.size.width - horizontalInset * 2, 300)
                let heroDiameter = max(90.0, min(118.0, proxy.size.width * 0.26))
                let logoDiameter = max(66.0, min(88.0, proxy.size.width * 0.19))
                let titleSize = max(22.0, min(28.0, proxy.size.width * 0.066))
                let subtitleSize = max(11.0, min(13.0, proxy.size.width * 0.032))
                let topSpacer = max(proxy.size.height * 0.09, 18)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        Spacer(minLength: topSpacer)

                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: heroDiameter, height: heroDiameter)
                                    .overlay(
                                        Circle()
                                            .strokeBorder(
                                                LinearGradient(
                                                    colors: [Color.white.opacity(0.58), Color.orange.opacity(0.20)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1.2
                                            )
                                    )
                                    .shadow(color: .black.opacity(0.10), radius: 14, x: 0, y: 8)

                                Image("Logo")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: logoDiameter, height: logoDiameter)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                                    )
                            }

                            VStack(spacing: 4) {
                                Text("Purawale")
                                    .font(.system(size: titleSize, weight: .bold, design: .serif))
                                    .foregroundStyle(loginHeroTextColor)
                                    .shadow(color: .black.opacity(0.62), radius: 3, x: 0, y: 1)
                                Text("Hum aur Humare")
                                    .font(.system(size: subtitleSize, weight: .semibold))
                                    .foregroundStyle(loginHeroSecondaryTextColor)
                                    .shadow(color: .black.opacity(0.62), radius: 3, x: 0, y: 1)
                            }
                        }
                        .frame(maxWidth: .infinity)

                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .firstTextBaseline, spacing: 10) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(localized("Sign in", language: viewModel.language))
                                        .font(.headline)
                                        .foregroundStyle(loginTextColor)
                                    Text(localized("Use your family phone number to continue.", language: viewModel.language))
                                        .font(.caption.weight(.medium))
                                        .foregroundStyle(loginSecondaryTextColor)
                                }

                                Spacer(minLength: 8)

                                languageToggle
                            }

                            TextField(localized("Phone Number", language: viewModel.language), text: $phoneNumber)
                                .textFieldStyle(.roundedBorder)
                                .textContentType(.telephoneNumber)
                                .submitLabel(.next)
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)

                            SecureField(localized("Password", language: viewModel.language), text: $password)
                                .textFieldStyle(.roundedBorder)
                                .submitLabel(.go)
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)

                            if let loginError = viewModel.loginError {
                                Text(loginError)
                                    .font(.footnote.weight(.medium))
                                    .foregroundStyle(.red)
                            }

                            if let signupMessage {
                                Text(signupMessage)
                                    .font(.footnote.weight(.medium))
                                    .foregroundStyle(.green)
                            }

                            HStack(spacing: 10) {
                                Button {
                                    signupMessage = nil
                                    viewModel.login(phoneNumber: phoneNumber, password: password)
                                } label: {
                                    HStack {
                                        Spacer()
                                        Text(localized("Login", language: viewModel.language))
                                            .fontWeight(.semibold)
                                        Spacer()
                                    }
                                    .padding(.vertical, 13)
                                }
                                .buttonStyle(.plain)
                                .background(
                                    LinearGradient(
                                        colors: [Color.orange, Color.orange.opacity(0.76)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                                )
                                .foregroundStyle(.white)
                                .shadow(color: .orange.opacity(0.20), radius: 10, x: 0, y: 6)

                                Button {
                                    signupMessage = nil
                                    isSignupPresented = true
                                } label: {
                                    HStack {
                                        Spacer()
                                        Text(localized("Sign Up", language: viewModel.language))
                                            .fontWeight(.semibold)
                                        Spacer()
                                    }
                                    .padding(.vertical, 13)
                                }
                                .buttonStyle(.plain)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .strokeBorder(Color.orange.opacity(0.45), lineWidth: 1)
                                )
                                .foregroundStyle(Color.orange)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(10)
                        .frame(width: cardWidth)
                        .background(
                            RoundedRectangle(cornerRadius: 26, style: .continuous)
                                .fill(Color.white.opacity(0.88))
                        )
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 26, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.72), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.08), radius: 14, x: 0, y: 8)

                        Text(localized("Family circle, memories, conversations, and traditions.", language: viewModel.language))
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(loginTextColor)
                            .multilineTextAlignment(.center)

                        Text(appVersionText)
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(loginHeroSecondaryTextColor)
                            .shadow(color: .black.opacity(0.62), radius: 3, x: 0, y: 1)

                        Spacer(minLength: max(proxy.size.height * 0.06, 12))
                    }
                .frame(maxWidth: .infinity, alignment: .center)
                .frame(minHeight: proxy.size.height)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button(localized("Login", language: viewModel.language)) {
                            viewModel.login(phoneNumber: phoneNumber, password: password)
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
        }
        }
        .sheet(isPresented: $isSignupPresented) {
            SignupRequestSheet(
                language: viewModel.language,
                onCancel: {
                    isSignupPresented = false
                },
                onSubmit: { name, parentName, mobileNumber, email in
                    let didSubmit = await viewModel.submitSignupRequest(
                        name: name,
                        parentName: parentName,
                        mobileNumber: mobileNumber,
                        email: email
                    )
                    if didSubmit {
                        signupMessage = localized("Request submitted for admin approval.", language: viewModel.language)
                        isSignupPresented = false
                        return nil
                    }
                    return viewModel.loginError ?? "Could not submit request. Please check the details and try again."
                }
            )
            .presentationDetents([.medium])
        }
    }

    private var languageToggle: some View {
        Button {
            viewModel.toggleLanguage()
        } label: {
            Text(viewModel.language.toggleLabel)
                .font(.caption.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .foregroundStyle(.white)
                .background(Color.orange, in: Capsule())
                .overlay(
                    Capsule()
                        .strokeBorder(Color.white.opacity(0.88), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(viewModel.language == .english ? "Switch to Hindi" : "Switch to English")
    }
}

private struct SignupRequestSheet: View {
    let language: AppLanguage
    let onCancel: () -> Void
    let onSubmit: (String, String, String, String) async -> String?
    @State private var name = ""
    @State private var parentName = ""
    @State private var mobileNumber = ""
    @State private var email = ""
    @State private var errorMessage: String?
    @State private var isSubmitting = false

    private var canSubmit: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !parentName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !mobileNumber.filter(\.isNumber).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField(localized("Name", language: language), text: $name)
                    .textContentType(.name)
                TextField(localized("Father/Mother Name", language: language), text: $parentName)
                    .textContentType(.name)
                TextField(localized("Mobile Number", language: language), text: $mobileNumber)
                    .textContentType(.telephoneNumber)
                    .keyboardType(.phonePad)
                TextField(localized("Email ID", language: language), text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle(localized("New user request", language: language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(localized("Cancel", language: language), action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isSubmitting ? "..." : localized("Submit", language: language)) {
                        Task {
                            isSubmitting = true
                            errorMessage = nil
                            errorMessage = await onSubmit(name, parentName, mobileNumber, email)
                            isSubmitting = false
                        }
                    }
                    .disabled(!canSubmit || isSubmitting)
                }
            }
        }
    }
}

private struct DashboardScreen: View {
    @Bindable var viewModel: AppViewModel
    @State private var isPasswordDialogPresented = false
    @State private var viewingSelf: Member?
    @State private var editingSelf: Member?

    var body: some View {
        if let user = viewModel.currentUser {
            AppBackground(treatment: .flatDashboard) {
                ZStack {
                    GeometryReader { proxy in
                    let safeHorizontalInset = proxy.safeAreaInsets.leading + proxy.safeAreaInsets.trailing
                    let horizontalInset = adaptiveHorizontalPadding(for: proxy.size.width)
                    let contentWidth = max(0.0, proxy.size.width - safeHorizontalInset - horizontalInset * 2.0)
                    let cardSpacing = max(10.0, min(14.0, proxy.size.width * 0.03))
                    let layoutScale = max(0.88, min(1.08, proxy.size.width / 390.0))
                    let statMinWidth = max(88.0, min(128.0, floor((contentWidth - (cardSpacing * 2.0)) / 3.0)))
                    let actionTileWidth = max(132.0, floor((contentWidth - cardSpacing) / 2.0))

                    NavigationStack {
                        ZStack {
                            AppBackgroundLayer(treatment: .flatDashboard)

                            ScrollView {
                                VStack(alignment: .leading, spacing: max(16.0, 18.0 * layoutScale)) {
                                    dashboardAndroidTopBar(
                                    viewModel: viewModel,
                                    layoutScale: layoutScale,
                                    onSyncAll: {
                                        Task {
                                            await viewModel.refreshAllData()
                                        }
                                    },
                                    onChangePassword: {
                                        isPasswordDialogPresented = true
                                    }
                                )

                                dashboardHeroCard(
                                    for: user,
                                    language: viewModel.language,
                                    contentWidth: contentWidth,
                                    layoutScale: layoutScale,
                                    onViewProfile: { viewingSelf = user },
                                    onEditProfile: { editingSelf = user }
                                )

                                LazyVGrid(columns: [
                                    GridItem(.adaptive(minimum: statMinWidth), spacing: cardSpacing)
                                ], spacing: cardSpacing) {
                                    Button {
                                        viewModel.showProfiles()
                                    } label: {
                                        StatTile(title: localized("Members", language: viewModel.language), value: "\(viewModel.dashboardActiveMembers.count)", layoutScale: layoutScale)
                                    }
                                    .buttonStyle(.plain)
                                    StatTile(title: localized("Today", language: viewModel.language), value: "\(viewModel.todayEvents.count)", layoutScale: layoutScale)
                                    if viewModel.hasAdminPrivileges {
                                        Button {
                                            viewModel.showProfiles()
                                        } label: {
                                            StatTile(title: localized("Pending", language: viewModel.language), value: "\(viewModel.approvalPendingCount)", layoutScale: layoutScale)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    DashboardWeatherTile(layoutScale: layoutScale)
                                }

                                dashboardQuickActions(
                                    viewModel: viewModel,
                                    contentWidth: contentWidth,
                                    cardSpacing: cardSpacing,
                                    actionTileWidth: actionTileWidth,
                                    layoutScale: layoutScale
                                )

                                if !viewModel.todayEvents.isEmpty {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text(localized("Events Today", language: viewModel.language))
                                            .font(.headline)
                                            .foregroundStyle(AndroidLook.lightGolden)

                                        ForEach(viewModel.todayEvents.prefix(5)) { event in
                                            FamilyEventRow(
                                                event: event,
                                                language: viewModel.language,
                                                onGenerateCard: {
                                                    viewModel.showAICardGenerator(for: event.member, eventType: event.type)
                                                }
                                            )
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }
                                }

                                if !viewModel.upcomingEvents.isEmpty {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text(localized("Upcoming Events (7 Days)", language: viewModel.language))
                                            .font(.headline)
                                            .foregroundStyle(AndroidLook.lightGolden)

                                        ForEach(viewModel.upcomingEvents.prefix(5)) { event in
                                            FamilyEventRow(
                                                event: event,
                                                language: viewModel.language,
                                                onGenerateCard: {
                                                    viewModel.showAICardGenerator(for: event.member, eventType: event.type)
                                                }
                                            )
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }
                                }
                            }
                            .frame(width: contentWidth, alignment: .leading)
                            .padding(.horizontal, horizontalInset)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                    }
                    .toolbar(.hidden, for: .navigationBar)
                        .sheet(isPresented: $isPasswordDialogPresented) {
                            ChangePasswordSheet(
                                language: viewModel.language,
                                onCancel: { isPasswordDialogPresented = false },
                                onSave: { newPassword in
                                    Task {
                                        await viewModel.changePassword(newPassword)
                                        isPasswordDialogPresented = false
                                    }
                                }
                            )
                            .presentationDetents([.height(230)])
                        }
                        .sheet(item: $viewingSelf) { member in
                            MemberDetailScreen(
                                member: member,
                                canEdit: viewModel.canEdit(member),
                                language: viewModel.language,
                                onEdit: {
                                    viewingSelf = nil
                                    editingSelf = member
                                },
                                onClose: {
                                    viewingSelf = nil
                                }
                            )
                        }
                        .sheet(item: $editingSelf) { member in
                            MemberEditScreen(
                                originalMember: member,
                                canSaveDirectly: viewModel.savesMemberEditsDirectly(member),
                                showsFamilyId: viewModel.currentUser?.isEditor == true,
                                language: viewModel.language,
                                onSave: { updatedMember in
                                    Task {
                                        if await viewModel.saveMemberEdits(updatedMember) {
                                            editingSelf = nil
                                        }
                                    }
                                },
                                onRequestOverride: { relationship in
                                    Task {
                                        await viewModel.submitRelationshipOverride(for: member, relationship: relationship)
                                    }
                                    editingSelf = nil
                                },
                                onCancel: {
                                    editingSelf = nil
                                }
                            )
                        }
                    }
                    }
                }
            }
        }
    }
}

private struct ProfilesScreen: View {
    @Bindable var viewModel: AppViewModel
    @State private var editingMember: Member?
    @State private var viewingMember: Member?

    var body: some View {
        AppBackground {
            NavigationStack {
                List {
                if viewModel.hasAdminPrivileges && !viewModel.pendingMembers.isEmpty {
                    Section(localized("Pending Approvals", language: viewModel.language)) {
                        ForEach(viewModel.resolvedPendingMembers) { member in
                            HStack(alignment: .center, spacing: 10) {
                                MemberListRow(
                                    member: member,
                                    showsPendingBadge: true,
                                    canEdit: viewModel.canEdit(member),
                                    canChat: false,
                                    canAdminManage: false,
                                    onEdit: { editingMember = member },
                                    onView: { viewingMember = member },
                                    onChat: {},
                                    onResetPassword: {},
                                    onRemovePhoto: {},
                                    onRemoveMember: {},
                                    onInviteWhatsApp: {}
                                )
                                Spacer(minLength: 4)
                                ApprovalIconButton(systemImage: "xmark", title: "Reject", role: .destructive) {
                                    Task {
                                        await viewModel.rejectPendingMember(member)
                                    }
                                }
                                ApprovalIconButton(systemImage: "checkmark", title: "Approve", tint: .green) {
                                    Task {
                                        await viewModel.approvePendingMember(member)
                                    }
                                }
                            }
                        }
                    }
                }

                if viewModel.hasAdminPrivileges && !viewModel.signupRequests.isEmpty {
                    Section("Signup Requests") {
                        ForEach(viewModel.signupRequests) { request in
                            SignupApprovalRow(
                                request: request,
                                suggestedMember: viewModel.suggestedMember(for: request),
                                assignableMembers: (viewModel.approvedMembers + viewModel.pendingMembers)
                                    .sorted { $0.name < $1.name },
                                onApprove: { member in
                                    Task {
                                        await viewModel.approveSignupRequest(request, assigningTo: member)
                                    }
                                },
                                onReject: {
                                    Task {
                                        await viewModel.rejectSignupRequest(request)
                                    }
                                }
                            )
                        }
                    }
                }

                if viewModel.hasAdminPrivileges && !viewModel.pendingMemories.isEmpty {
                    Section("Pending Gallery Uploads") {
                        ForEach(viewModel.pendingMemories) { memory in
                            ContentApprovalRow(
                                title: memory.caption.isEmpty ? "Photo from \(memory.userName)" : memory.caption,
                                detail: "Gallery • \(memory.userName)",
                                onApprove: {
                                    Task {
                                        await viewModel.approveMemory(memory)
                                    }
                                },
                                onReject: {
                                    Task {
                                        await viewModel.deleteMemory(memory)
                                    }
                                }
                            )
                        }
                    }
                }

                if viewModel.hasAdminPrivileges && !viewModel.pendingDiscussions.isEmpty {
                    Section("Pending Discussions") {
                        ForEach(viewModel.pendingDiscussions) { discussion in
                            ContentApprovalRow(
                                title: discussion.title,
                                detail: "Discussion • \(discussion.userName)",
                                onApprove: {
                                    Task {
                                        await viewModel.approveDiscussion(discussion)
                                    }
                                },
                                onReject: {
                                    Task {
                                        await viewModel.rejectDiscussion(discussion)
                                    }
                                }
                            )
                        }
                    }
                }

                if viewModel.hasAdminPrivileges && !viewModel.pendingRecipes.isEmpty {
                    Section("Pending Recipes") {
                        ForEach(viewModel.pendingRecipes) { recipe in
                            ContentApprovalRow(
                                title: recipe.title,
                                detail: "Recipe • \(recipe.authorName)",
                                onApprove: {
                                    Task {
                                        await viewModel.approveRecipe(recipe)
                                    }
                                },
                                onReject: {
                                    Task {
                                        await viewModel.deleteRecipe(recipe)
                                    }
                                }
                            )
                        }
                    }
                }

                if viewModel.hasAdminPrivileges && !viewModel.pendingTraditions.isEmpty {
                    Section("Pending Traditions") {
                        ForEach(viewModel.pendingTraditions) { tradition in
                            ContentApprovalRow(
                                title: tradition.title,
                                detail: "Tradition • \(tradition.authorName)",
                                onApprove: {
                                    Task {
                                        await viewModel.approveTradition(tradition)
                                    }
                                },
                                onReject: {
                                    Task {
                                        await viewModel.deleteTradition(tradition)
                                    }
                                }
                            )
                        }
                    }
                }

                if viewModel.hasAdminPrivileges && !viewModel.pendingMilestones.isEmpty {
                    Section("Pending Milestones") {
                        ForEach(viewModel.pendingMilestones) { milestone in
                            ContentApprovalRow(
                                title: milestone.title,
                                detail: "Milestone • \(milestone.authorName)",
                                onApprove: {
                                    Task {
                                        await viewModel.approveMilestone(milestone)
                                    }
                                },
                                onReject: {
                                    Task {
                                        await viewModel.deleteMilestone(milestone)
                                    }
                                }
                            )
                        }
                    }
                }

                if viewModel.hasAdminPrivileges && !viewModel.relationshipOverrides.isEmpty {
                    Section(localized("Relationship Requests", language: viewModel.language)) {
                        ForEach(viewModel.relationshipOverrides) { override in
                            RelationshipOverrideRow(
                                override: override,
                                onApprove: {
                                    Task {
                                        await viewModel.approveRelationshipOverride(override)
                                    }
                                }
                            )
                        }
                    }
                }

                if viewModel.hasAdminPrivileges && !viewModel.deletionRequests.isEmpty {
                    Section(localized("Deletion Requests", language: viewModel.language)) {
                        ForEach(viewModel.deletionRequests) { request in
                            DeletionRequestRow(
                                request: request,
                                onApprove: {
                                    Task {
                                        await viewModel.approveDeletionRequest(request)
                                    }
                                },
                                onReject: {
                                    Task {
                                        await viewModel.rejectDeletionRequest(request)
                                    }
                                }
                            )
                        }
                    }
                }

                Section(localized("Approved Members", language: viewModel.language)) {
                    ForEach(viewModel.visibleMembers) { member in
                        MemberListRow(
                            member: member,
                            showsPendingBadge: false,
                            canEdit: viewModel.canEdit(member),
                            canChat: viewModel.currentUser?.id != member.id,
                            canAdminManage: viewModel.hasAdminPrivileges,
                            onEdit: { editingMember = member },
                            onView: { viewingMember = member },
                            onChat: { viewModel.startChat(with: member) },
                            onResetPassword: {
                                Task { await viewModel.resetPassword(for: member) }
                            },
                            onRemovePhoto: {
                                Task { await viewModel.removePhoto(for: member) }
                            },
                            onRemoveMember: {
                                Task { await viewModel.removeMember(member) }
                            },
                            onInviteWhatsApp: {
                                openWhatsAppInvite(for: member, language: viewModel.language)
                            }
                        )
                    }
                }
                }
                .listStyle(.plain)
                .listSectionSpacing(.compact)
                .scrollContentBackground(.hidden)
                .searchable(text: $viewModel.searchText, prompt: localized("Search by name, phone, or relationship", language: viewModel.language))
                .navigationTitle(localized("Profiles", language: viewModel.language))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            viewModel.showDashboard()
                        } label: {
                            Label(localized("Home", language: viewModel.language), systemImage: "house")
                        }
                    }
                }
                .sheet(item: $editingMember) { member in
                    MemberEditScreen(
                        originalMember: member,
                        canSaveDirectly: viewModel.savesMemberEditsDirectly(member),
                        showsFamilyId: viewModel.currentUser?.isEditor == true,
                        language: viewModel.language,
                        onSave: { updatedMember in
                            Task {
                                if await viewModel.saveMemberEdits(updatedMember) {
                                    editingMember = nil
                                }
                            }
                        },
                        onRequestOverride: { relationship in
                            Task {
                                await viewModel.submitRelationshipOverride(for: member, relationship: relationship)
                            }
                            editingMember = nil
                        },
                        onCancel: {
                            editingMember = nil
                        }
                    )
                }
                .sheet(item: $viewingMember) { member in
                    MemberDetailScreen(
                        member: member,
                        canEdit: viewModel.canEdit(member),
                        language: viewModel.language,
                        onEdit: {
                            viewingMember = nil
                            editingMember = member
                        },
                        onClose: {
                            viewingMember = nil
                        }
                    )
                }
            }
        }
    }
}

private struct ChangePasswordSheet: View {
    let language: AppLanguage
    let onCancel: () -> Void
    let onSave: (String) -> Void
    @State private var newPassword = ""

    var body: some View {
        NavigationStack {
            Form {
                SecureField(localized("New Password", language: language), text: $newPassword)
                    .textContentType(.newPassword)
            }
            .navigationTitle(localized("Change Password", language: language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(localized("Cancel", language: language), action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(localized("Save", language: language)) {
                        onSave(newPassword)
                    }
                    .disabled(newPassword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

private struct NotificationCenterScreen: View {
    @Bindable var viewModel: AppViewModel

    var body: some View {
        AppBackground {
            NavigationStack {
                Group {
                    if viewModel.notifications.isEmpty {
                        ContentUnavailableView(
                            localized("No notifications", language: viewModel.language),
                            systemImage: "bell.slash"
                        )
                    } else {
                        List {
                            ForEach(viewModel.notifications) { notification in
                                NotificationRow(
                                    notification: notification,
                                    isRead: notification.isRead(by: viewModel.currentUser?.id ?? "")
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    Task {
                                        await viewModel.markNotificationRead(notification)
                                    }
                                }
                            }
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
                .navigationTitle(localized("Notifications", language: viewModel.language))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            viewModel.showDashboard()
                        } label: {
                            Label(localized("Home", language: viewModel.language), systemImage: "chevron.left")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(localized("Mark all read", language: viewModel.language)) {
                            Task {
                                await viewModel.markAllNotificationsRead()
                            }
                        }
                        .disabled(viewModel.unreadNotificationCount == 0)
                    }
                }
                .task {
                    await viewModel.refreshNotifications()
                }
            }
        }
    }
}

private struct NotificationRow: View {
    let notification: AppNotification
    let isRead: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.yellow.opacity(0.32))
                    .frame(width: 42, height: 42)
                Image(systemName: iconName)
                    .foregroundStyle(Color.brown)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(notification.title.isEmpty ? "Notification" : notification.title)
                    .font(.subheadline.weight(isRead ? .regular : .bold))
                    .foregroundStyle(.primary)

                Text(notification.body)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(notification.timestamp.formatted(.dateTime.month(.abbreviated).day().hour().minute()))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if !isRead {
                Circle()
                    .fill(.red)
                    .frame(width: 8, height: 8)
                    .padding(.top, 7)
            }
        }
        .padding(.vertical, 8)
        .listRowBackground(isRead ? Color.white.opacity(0.85) : Color.yellow.opacity(0.14))
    }

    private var iconName: String {
        switch notification.type.uppercased() {
        case "DM":
            return "envelope.fill"
        case "GAME_CHALLENGE":
            return "gamecontroller.fill"
        case "PROFILE_CHANGE", "NEW_PROFILE", "APPROVAL_REQUIRED":
            return "person.crop.circle.badge.exclamationmark"
        case "GALLERY", "TAGGED_MEMORY":
            return "photo.fill"
        case "COOKBOOK":
            return "book.closed.fill"
        case "TRADITION":
            return "heart.text.square.fill"
        case "MILESTONE", "TAGGED_MILESTONE":
            return "clock.arrow.circlepath"
        default:
            return "bell.fill"
        }
    }
}

private struct GalleryScreen: View {
    @Bindable var viewModel: AppViewModel
    @State private var pendingDeletionRequest: PendingDeletionRequest?
    @State private var showEditor = false
    @State private var selectedMemory: MemoryPost?

    var body: some View {
        AppBackground {
            NavigationStack {
                GeometryReader { proxy in
                    let safeHorizontalInset = proxy.safeAreaInsets.leading + proxy.safeAreaInsets.trailing
                    let horizontalInset = adaptiveHorizontalPadding(for: proxy.size.width)
                    let contentWidth = max(0.0, proxy.size.width - safeHorizontalInset - horizontalInset * 2.0)

                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(viewModel.approvedMemories.sorted { $0.timestamp > $1.timestamp }) { memory in
                                MemoryCard(
                                    memory: memory,
                                    contentWidth: contentWidth,
                                    canRequestDelete: viewModel.canRequestContentDeletion(authorId: memory.userId),
                                    canApprove: viewModel.hasAdminPrivileges && memory.status.isPendingStatus,
                                    onRequestDelete: {
                                        pendingDeletionRequest = PendingDeletionRequest(
                                            collectionName: "memories",
                                            docId: memory.id,
                                            title: memory.caption
                                        )
                                    },
                                    onApprove: {
                                        Task {
                                            await viewModel.approveMemory(memory)
                                        }
                                    },
                                    onOpen: {
                                        selectedMemory = memory
                                    }
                                )
                                .frame(width: contentWidth, alignment: .leading)
                            }
                        }
                        .frame(width: contentWidth, alignment: .leading)
                        .padding(.horizontal, horizontalInset)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .navigationTitle(localized("Memory Gallery", language: viewModel.language))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            viewModel.showDashboard()
                        } label: {
                            Image(systemName: "house.fill")
                                .frame(width: 40, height: 40)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showEditor = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.headline.weight(.bold))
                                .frame(width: 40, height: 40)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                    }
                }
                .sheet(isPresented: $showEditor) {
                    MemoryEditorSheet(viewModel: viewModel, onClose: { showEditor = false })
                }
                .sheet(item: $selectedMemory) { memory in
                    MemoryDetailSheet(viewModel: viewModel, memory: memory, onClose: { selectedMemory = nil })
                }
                .sheet(item: $pendingDeletionRequest) { request in
                    DeletionRequestSheet(
                        language: viewModel.language,
                        requestTitle: request.title,
                        onSubmit: { reason in
                            Task {
                                await viewModel.requestDeletion(
                                    collectionName: request.collectionName,
                                    docId: request.docId,
                                    title: request.title,
                                    reason: reason
                                )
                            }
                            pendingDeletionRequest = nil
                        },
                        onCancel: {
                            pendingDeletionRequest = nil
                        }
                    )
                }
            }
        }
    }
}

private struct DiscussionsScreen: View {
    @Bindable var viewModel: AppViewModel
    @State private var showEditor = false
    @State private var pendingDeletionRequest: PendingDeletionRequest?

    var body: some View {
        AppBackground {
            NavigationStack {
                GeometryReader { proxy in
                    let safeHorizontalInset = proxy.safeAreaInsets.leading + proxy.safeAreaInsets.trailing
                    let horizontalInset = adaptiveHorizontalPadding(for: proxy.size.width)
                    let contentWidth = max(0.0, proxy.size.width - safeHorizontalInset - horizontalInset * 2.0)

                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(viewModel.visibleDiscussions.sorted { $0.timestamp > $1.timestamp }) { discussion in
                                DiscussionCard(
                                    discussion: discussion,
                                    canRequestDelete: viewModel.canRequestContentDeletion(authorId: discussion.userId),
                                    canApprove: viewModel.hasAdminPrivileges && discussion.status.isPendingStatus,
                                    onRequestDelete: {
                                        pendingDeletionRequest = PendingDeletionRequest(
                                            collectionName: "discussions",
                                            docId: discussion.id,
                                            title: discussion.title
                                        )
                                    },
                                    onApprove: {
                                        Task {
                                            await viewModel.approveDiscussion(discussion)
                                        }
                                    }
                                )
                                .frame(width: contentWidth, alignment: .leading)
                            }
                        }
                        .frame(width: contentWidth, alignment: .leading)
                        .padding(.horizontal, horizontalInset)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .navigationTitle(localized("Discussions", language: viewModel.language))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            viewModel.showDashboard()
                        } label: {
                            Label(localized("Home", language: viewModel.language), systemImage: "house")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showEditor = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        .accessibilityLabel("New")
                    }
                }
                .sheet(isPresented: $showEditor) {
                    DiscussionEditorSheet(
                        viewModel: viewModel,
                        authorId: viewModel.currentUser?.id ?? "",
                        authorName: viewModel.currentUser?.name ?? "",
                        onSave: { discussion in
                            Task {
                                await viewModel.saveDiscussion(discussion)
                            }
                            showEditor = false
                        },
                        onCancel: {
                            showEditor = false
                        }
                    )
                }
                .sheet(item: $pendingDeletionRequest) { request in
                    DeletionRequestSheet(
                        language: viewModel.language,
                        requestTitle: request.title,
                        onSubmit: { reason in
                            Task {
                                await viewModel.requestDeletion(
                                    collectionName: request.collectionName,
                                    docId: request.docId,
                                    title: request.title,
                                    reason: reason
                                )
                            }
                            pendingDeletionRequest = nil
                        },
                        onCancel: {
                            pendingDeletionRequest = nil
                        }
                    )
                }
            }
        }
    }
}

private struct CookbookScreen: View {
    @Bindable var viewModel: AppViewModel
    @State private var showEditor = false
    @State private var editingRecipe: Recipe?
    @State private var selectedRecipe: Recipe?
    @State private var pendingDeletionRequest: PendingDeletionRequest?

    var body: some View {
        AppBackground {
            NavigationStack {
                GeometryReader { proxy in
                    let safeHorizontalInset = proxy.safeAreaInsets.leading + proxy.safeAreaInsets.trailing
                    let horizontalInset = adaptiveHorizontalPadding(for: proxy.size.width)
                    let contentWidth = max(0.0, proxy.size.width - safeHorizontalInset - horizontalInset * 2.0)

                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(viewModel.visibleRecipes) { recipe in
                                RecipeCard(
                                    recipe: recipe,
                                    contentWidth: contentWidth,
                                    canEdit: viewModel.canManageContent(authorId: recipe.authorId),
                                    canRequestDelete: viewModel.canRequestContentDeletion(authorId: recipe.authorId),
                                    canApprove: viewModel.hasAdminPrivileges && recipe.status.isPendingStatus,
                                    onEdit: {
                                        editingRecipe = recipe
                                        showEditor = true
                                    },
                                    onDelete: {
                                        if viewModel.hasAdminPrivileges {
                                            Task {
                                                await viewModel.deleteRecipe(recipe)
                                            }
                                        } else {
                                            pendingDeletionRequest = PendingDeletionRequest(
                                                collectionName: "recipes",
                                                docId: recipe.id,
                                                title: recipe.title
                                            )
                                        }
                                    },
                                    onApprove: {
                                        Task {
                                            await viewModel.approveRecipe(recipe)
                                        }
                                    }
                                )
                                .frame(width: contentWidth, alignment: .leading)
                                .onTapGesture {
                                    selectedRecipe = recipe
                                }
                            }
                        }
                        .frame(width: contentWidth, alignment: .leading)
                        .padding(.horizontal, horizontalInset)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .navigationTitle(localized("Cookbook", language: viewModel.language))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            viewModel.showDashboard()
                        } label: {
                            Label(localized("Home", language: viewModel.language), systemImage: "house")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            editingRecipe = nil
                            showEditor = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        .accessibilityLabel("Add")
                    }
                }
                .sheet(isPresented: $showEditor) {
                    RecipeEditorSheet(
                        viewModel: viewModel,
                        existingRecipe: editingRecipe,
                        authorId: viewModel.currentUser?.id ?? "",
                        authorName: viewModel.currentUser?.name ?? "",
                        onSave: { recipe in
                            Task {
                                await viewModel.saveRecipe(recipe)
                            }
                            showEditor = false
                        },
                        onCancel: {
                            showEditor = false
                        }
                    )
                }
                .sheet(item: $selectedRecipe) { recipe in
                    RecipeDetailSheet(viewModel: viewModel, recipe: recipe, onClose: { selectedRecipe = nil })
                }
                .sheet(item: $pendingDeletionRequest) { request in
                    DeletionRequestSheet(
                        language: viewModel.language,
                        requestTitle: request.title,
                        onSubmit: { reason in
                            Task {
                                await viewModel.requestDeletion(
                                    collectionName: request.collectionName,
                                    docId: request.docId,
                                    title: request.title,
                                    reason: reason
                                )
                            }
                            pendingDeletionRequest = nil
                        },
                        onCancel: {
                            pendingDeletionRequest = nil
                        }
                    )
                }
            }
        }
    }
}

private struct TraditionsScreen: View {
    @Bindable var viewModel: AppViewModel
    @State private var showEditor = false
    @State private var editingTradition: Tradition?
    @State private var selectedTradition: Tradition?
    @State private var pendingDeletionRequest: PendingDeletionRequest?

    var body: some View {
        AppBackground {
            NavigationStack {
                GeometryReader { proxy in
                    let safeHorizontalInset = proxy.safeAreaInsets.leading + proxy.safeAreaInsets.trailing
                    let horizontalInset = adaptiveHorizontalPadding(for: proxy.size.width)
                    let contentWidth = max(0.0, proxy.size.width - safeHorizontalInset - horizontalInset * 2.0)

                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(viewModel.visibleTraditions) { tradition in
                                TraditionCard(
                                    tradition: tradition,
                                    contentWidth: contentWidth,
                                    canEdit: viewModel.canManageContent(authorId: tradition.authorId),
                                    canRequestDelete: viewModel.canRequestContentDeletion(authorId: tradition.authorId),
                                    canApprove: viewModel.hasAdminPrivileges && tradition.status.isPendingStatus,
                                    onEdit: {
                                        editingTradition = tradition
                                        showEditor = true
                                    },
                                    onDelete: {
                                        if viewModel.hasAdminPrivileges {
                                            Task {
                                                await viewModel.deleteTradition(tradition)
                                            }
                                        } else {
                                            pendingDeletionRequest = PendingDeletionRequest(
                                                collectionName: "traditions",
                                                docId: tradition.id,
                                                title: tradition.title
                                            )
                                        }
                                    },
                                    onApprove: {
                                        Task {
                                            await viewModel.approveTradition(tradition)
                                        }
                                    }
                                )
                                .frame(width: contentWidth, alignment: .leading)
                                .onTapGesture {
                                    selectedTradition = tradition
                                }
                            }
                        }
                        .frame(width: contentWidth, alignment: .leading)
                        .padding(.horizontal, horizontalInset)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .navigationTitle(localized("Traditions", language: viewModel.language))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            viewModel.showDashboard()
                        } label: {
                            Label(localized("Home", language: viewModel.language), systemImage: "house")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            editingTradition = nil
                            showEditor = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        .accessibilityLabel("Add")
                    }
                }
                .sheet(isPresented: $showEditor) {
                    TraditionEditorSheet(
                        viewModel: viewModel,
                        existingTradition: editingTradition,
                        authorId: viewModel.currentUser?.id ?? "",
                        authorName: viewModel.currentUser?.name ?? "",
                        onSave: { tradition in
                            Task {
                                await viewModel.saveTradition(tradition)
                            }
                            showEditor = false
                        },
                        onCancel: {
                            showEditor = false
                        }
                    )
                }
                .sheet(item: $selectedTradition) { tradition in
                    TraditionDetailSheet(viewModel: viewModel, tradition: tradition, onClose: { selectedTradition = nil })
                }
                .sheet(item: $pendingDeletionRequest) { request in
                    DeletionRequestSheet(
                        language: viewModel.language,
                        requestTitle: request.title,
                        onSubmit: { reason in
                            Task {
                                await viewModel.requestDeletion(
                                    collectionName: request.collectionName,
                                    docId: request.docId,
                                    title: request.title,
                                    reason: reason
                                )
                            }
                            pendingDeletionRequest = nil
                        },
                        onCancel: {
                            pendingDeletionRequest = nil
                        }
                    )
                }
            }
        }
    }
}

private enum MemoryLaneTrack: String, CaseIterable, Identifiable {
    case family = "GLOBAL"
    case privateFamily = "PRIVATE_FAMILY"
    case oldIsGold = "OLD_IS_GOLD"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .family:
            return "Family Track"
        case .privateFamily:
            return "Private Family"
        case .oldIsGold:
            return "Old Is Gold"
        }
    }

    var subtitle: String {
        switch self {
        case .family:
            return "Shared with the full community"
        case .privateFamily:
            return "Shared inside a selected family context"
        case .oldIsGold:
            return "Legacy memories and archival stories"
        }
    }

    var icon: String {
        switch self {
        case .family:
            return "person.3.fill"
        case .privateFamily:
            return "lock.shield.fill"
        case .oldIsGold:
            return "sparkles"
        }
    }

    var tint: Color {
        switch self {
        case .family:
            return .teal
        case .privateFamily:
            return .indigo
        case .oldIsGold:
            return .orange
        }
    }

    func contains(_ milestone: Milestone) -> Bool {
        let normalized = milestone.visibilityType.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        switch self {
        case .family:
            return normalized.isEmpty || normalized == rawValue
        case .privateFamily, .oldIsGold:
            return normalized == rawValue
        }
    }
}

private struct MemoryLaneTrackSection: View {
    let track: MemoryLaneTrack
    let milestones: [Milestone]
    let language: AppLanguage
    let contentWidth: CGFloat
    let canManage: (Milestone) -> Bool
    let canRequestDelete: (Milestone) -> Bool
    let canApprove: (Milestone) -> Bool
    let onEdit: (Milestone) -> Void
    let onDelete: (Milestone) -> Void
    let onApprove: (Milestone) -> Void
    let onSelect: (Milestone) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: track.icon)
                    .font(.headline)
                    .foregroundStyle(track.tint)
                    .frame(width: 34, height: 34)
                    .background(track.tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(track.title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.primary)
                    Text(track.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(milestones.count)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(track.tint)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(track.tint.opacity(0.12), in: Capsule())
            }

            if milestones.isEmpty {
                Text("No memories in this track yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 10)
            } else {
                ForEach(milestones) { milestone in
                    MilestoneCard(
                        milestone: milestone,
                        language: language,
                        contentWidth: max(0.0, contentWidth - 24),
                        canEdit: canManage(milestone),
                        canRequestDelete: canRequestDelete(milestone),
                        canApprove: canApprove(milestone),
                        onEdit: {
                            onEdit(milestone)
                        },
                        onDelete: {
                            onDelete(milestone)
                        },
                        onApprove: {
                            onApprove(milestone)
                        }
                    )
                    .overlay(alignment: .topTrailing) {
                        MemoryLaneSharingBadge(milestone: milestone, track: track)
                            .padding(10)
                    }
                    .onTapGesture {
                        onSelect(milestone)
                    }
                }
            }
        }
        .padding(12)
        .frame(width: contentWidth, alignment: .leading)
        .background(Color.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(track.tint.opacity(0.20), lineWidth: 1)
        )
    }
}

private struct MemoryLaneSharingBadge: View {
    let milestone: Milestone
    let track: MemoryLaneTrack

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: track.icon)
            Text(label)
        }
        .font(.caption2.weight(.bold))
        .foregroundStyle(track.tint)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(Color.white.opacity(0.90), in: Capsule())
    }

    private var label: String {
        let familyContext = milestone.familyContextId.trimmingCharacters(in: .whitespacesAndNewlines)
        if !familyContext.isEmpty {
            return familyContext
        }
        return track.rawValue.replacingOccurrences(of: "_", with: " ")
    }
}

private struct MemoryLaneScreen: View {
    @Bindable var viewModel: AppViewModel
    @State private var showEditor = false
    @State private var editingMilestone: Milestone?
    @State private var selectedMilestone: Milestone?
    @State private var pendingDeletionRequest: PendingDeletionRequest?

    var body: some View {
        AppBackground {
            NavigationStack {
                GeometryReader { proxy in
                    let safeHorizontalInset = proxy.safeAreaInsets.leading + proxy.safeAreaInsets.trailing
                    let horizontalInset = adaptiveHorizontalPadding(for: proxy.size.width)
                    let contentWidth = max(0.0, proxy.size.width - safeHorizontalInset - horizontalInset * 2.0)

                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(MemoryLaneTrack.allCases) { track in
                                MemoryLaneTrackSection(
                                    track: track,
                                    milestones: viewModel.visibleMilestones.filter { track.contains($0) },
                                    language: viewModel.language,
                                    contentWidth: contentWidth,
                                    canManage: { milestone in
                                        viewModel.canManageContent(authorId: milestone.authorId)
                                    },
                                    canRequestDelete: { milestone in
                                        viewModel.canRequestContentDeletion(authorId: milestone.authorId)
                                    },
                                    canApprove: { milestone in
                                        viewModel.hasAdminPrivileges && milestone.status.isPendingStatus
                                    },
                                    onEdit: { milestone in
                                        editingMilestone = milestone
                                        showEditor = true
                                    },
                                    onDelete: { milestone in
                                        if viewModel.hasAdminPrivileges {
                                            Task {
                                                await viewModel.deleteMilestone(milestone)
                                            }
                                        } else {
                                            pendingDeletionRequest = PendingDeletionRequest(
                                                collectionName: "memorylane",
                                                docId: milestone.id,
                                                title: milestone.title
                                            )
                                        }
                                    },
                                    onApprove: { milestone in
                                        Task {
                                            await viewModel.approveMilestone(milestone)
                                        }
                                    },
                                    onSelect: { milestone in
                                        selectedMilestone = milestone
                                    }
                                )
                            }
                        }
                        .frame(width: contentWidth, alignment: .leading)
                        .padding(.horizontal, horizontalInset)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .navigationTitle(localized("Memory Lane", language: viewModel.language))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            viewModel.showDashboard()
                        } label: {
                            Label(localized("Home", language: viewModel.language), systemImage: "house")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            editingMilestone = nil
                            showEditor = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        .accessibilityLabel("Add")
                    }
                }
                .sheet(isPresented: $showEditor) {
                    MilestoneEditorSheet(
                        viewModel: viewModel,
                        existingMilestone: editingMilestone,
                        authorId: viewModel.currentUser?.id ?? "",
                        authorName: viewModel.currentUser?.name ?? "",
                        onSave: { milestone in
                            Task {
                                await viewModel.saveMilestone(milestone)
                            }
                            showEditor = false
                        },
                        onCancel: {
                            showEditor = false
                        }
                    )
                }
                .sheet(item: $selectedMilestone) { milestone in
                    MilestoneDetailSheet(viewModel: viewModel, milestone: milestone, onClose: { selectedMilestone = nil })
                }
                .sheet(item: $pendingDeletionRequest) { request in
                    DeletionRequestSheet(
                        language: viewModel.language,
                        requestTitle: request.title,
                        onSubmit: { reason in
                            Task {
                                await viewModel.requestDeletion(
                                    collectionName: request.collectionName,
                                    docId: request.docId,
                                    title: request.title,
                                    reason: reason
                                )
                            }
                            pendingDeletionRequest = nil
                        },
                        onCancel: {
                            pendingDeletionRequest = nil
                        }
                    )
                }
            }
        }
    }
}
private struct MessagesScreen: View {
    @Bindable var viewModel: AppViewModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text(viewModel.inboxDebugSummary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }

                Section(localized("Recent Chats", language: viewModel.language)) {
                    ForEach(viewModel.visibleChannels) { channel in
                        if let otherMember = viewModel.otherMember(for: channel) {
                            Button {
                                viewModel.startChat(with: otherMember)
                            } label: {
                                ChannelRow(
                                    channel: channel,
                                    otherMember: otherMember,
                                    unreadCount: channel.unreadCount[viewModel.currentUser?.id ?? ""] ?? 0
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Section(localized("Start New Chat", language: viewModel.language)) {
                    ForEach(viewModel.activeMembers.filter { $0.id != viewModel.currentUser?.id }) { member in
                        Button {
                            viewModel.startChat(with: member)
                        } label: {
                            HStack {
                                AvatarView(member: member, size: 36)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(member.name)
                                        .foregroundStyle(.primary)
                                    Text(member.relationship ?? member.phoneNumber)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle(localized("Messages", language: viewModel.language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        viewModel.showDashboard()
                    } label: {
                        Label(localized("Home", language: viewModel.language), systemImage: "house")
                    }
                }
            }
        }
    }
}

@ViewBuilder
private func dashboardAndroidTopBar(
    viewModel: AppViewModel,
    layoutScale: CGFloat,
    onSyncAll: @escaping () -> Void,
    onChangePassword: @escaping () -> Void
) -> some View {
    HStack(alignment: .center, spacing: 10) {
        VStack(alignment: .leading, spacing: 2) {
            Text("Purawale Hum aur Humare")
                .font(.system(size: max(19.0, 22.0 * layoutScale), weight: .bold))
                .foregroundStyle(AndroidLook.deepBrown)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text("Nema Sub- Community")
                .font(.caption.weight(.semibold))
                .foregroundStyle(AndroidLook.accentGold)
        }
        .layoutPriority(1)

        Spacer(minLength: 4)

        if viewModel.canSwitchTreeView {
            BranchSwitch(
                isBranchView: viewModel.currentTreeId != "primary",
                language: viewModel.language,
                onToggle: { useBranch in
                    viewModel.switchTree(useBranch ? (viewModel.currentUser?.id ?? "primary") : "primary")
                }
            )
        }

        DashboardTopIconButton(
            systemImage: "bell.fill",
            badge: viewModel.unreadNotificationCount,
            action: viewModel.showNotifications
        )

        DashboardTopIconButton(
            systemImage: "arrow.triangle.2.circlepath",
            isBusy: viewModel.isSyncingAll,
            action: onSyncAll
        )

        DashboardTopIconButton(
            systemImage: "key.fill",
            action: onChangePassword
        )

        DashboardTopIconButton(
            systemImage: "rectangle.portrait.and.arrow.right",
            action: viewModel.logout
        )
    }
    .padding(.horizontal, 14)
    .padding(.vertical, 14)
    .background(Color.white.opacity(0.84), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    .overlay(
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .stroke(Color.black.opacity(0.08), lineWidth: 1)
    )
}

private struct BranchSwitch: View {
    let isBranchView: Bool
    let language: AppLanguage
    let onToggle: (Bool) -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text("P")
                .fontWeight(isBranchView ? .bold : .heavy)
                .foregroundStyle(isBranchView ? AndroidLook.mutedBrown : AndroidLook.deepBrown)

            Toggle("", isOn: Binding(get: { isBranchView }, set: onToggle))
                .labelsHidden()
                .toggleStyle(.switch)
                .scaleEffect(0.72)
                .tint(AndroidLook.accentGold)
                .frame(width: 42)

            Text("B")
                .fontWeight(isBranchView ? .heavy : .bold)
                .foregroundStyle(isBranchView ? AndroidLook.deepBrown : AndroidLook.mutedBrown)
        }
        .font(.caption2)
        .padding(.leading, 9)
        .padding(.trailing, 7)
        .padding(.vertical, 5)
        .background(AndroidLook.lightGolden.opacity(0.30), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .accessibilityLabel(isBranchView ? localized("My Branch", language: language) : localized("Primary", language: language))
    }
}

private struct DashboardTopIconButton: View {
    let systemImage: String
    var badge: Int = 0
    var isBusy: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                if isBusy {
                    ProgressView()
                        .controlSize(.mini)
                        .tint(AndroidLook.deepBrown)
                        .frame(width: 30, height: 30)
                } else {
                    Image(systemName: systemImage)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AndroidLook.deepBrown)
                        .frame(width: 30, height: 30)
                }

                if badge > 0 {
                    Text("\(min(badge, 99))")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(.red, in: Capsule())
                        .offset(x: 7, y: -4)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(isBusy)
    }
}

private struct AndroidDashboardSectionHeader: View {
    let title: String

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(AndroidLook.accentGold)
                .frame(width: 10, height: 10)
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(AndroidLook.lightGolden)
                .shadow(color: Color.black.opacity(0.26), radius: 2, x: 0, y: 1)
        }
    }
}

@ViewBuilder
private func dashboardHeroCard(
    for user: Member,
    language: AppLanguage,
    contentWidth: CGFloat,
    layoutScale: CGFloat,
    onViewProfile: @escaping () -> Void,
    onEditProfile: @escaping () -> Void
) -> some View {
        let avatarSize = max(70.0, min(82.0, contentWidth * 0.22))
        let titleFontSize = max(18.0, min(23.0, 21.0 * layoutScale))
        let subtitleFontSize = max(12.0, min(15.0, 14.0 * layoutScale))
        let birthday = shortDisplayDate(user.dateOfBirth)
        let birthdayAge = completedYears(since: user.dateOfBirth)
        let marriage = shortDisplayDate(user.marriageDate)

        VStack(alignment: .leading, spacing: max(12.0, 14.0 * layoutScale)) {
            HStack(alignment: .center, spacing: max(16.0, 20.0 * layoutScale)) {
                AvatarView(member: user, size: avatarSize)
                    .overlay(Circle().stroke(AndroidLook.softBrown, lineWidth: 2))

                VStack(alignment: .leading, spacing: 4) {
                    Text(user.name)
                        .font(.system(size: titleFontSize, weight: .heavy, design: .default))
                        .foregroundStyle(AndroidLook.deepBrown)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                    Text(user.phoneNumber)
                        .font(.system(size: subtitleFontSize, weight: .bold, design: .default))
                        .foregroundStyle(AndroidLook.mutedBrown)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                    if user.isAdmin, let lastLogin = loginDisplayDate(user.lastLoggedIn) {
                        Text("Last Login: \(lastLogin)")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(AndroidLook.accentGold.opacity(0.86))
                    }
                    if let location = user.location?.trimmingCharacters(in: .whitespacesAndNewlines), !location.isEmpty {
                        Label(location, systemImage: "location.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(AndroidLook.mutedBrown)
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(AndroidLook.accentGold)
                        Text("Lvl \(user.level) • \(user.points) pts")
                            .foregroundStyle(AndroidLook.deepBrown)
                    }
                    .font(.caption.weight(.bold))
                    if let relationship = user.relationship {
                        Text(relationship)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AndroidLook.deepBrown)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(AndroidLook.accentGold.opacity(0.22), in: Capsule())
                    }
                }

                Spacer()

                VStack(spacing: 8) {
                    Button(action: onViewProfile) {
                        Image(systemName: "eye.fill")
                            .frame(width: 34, height: 34)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(AndroidLook.deepBrown)

                    Button(action: onEditProfile) {
                        Image(systemName: "square.and.pencil")
                            .frame(width: 34, height: 34)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(AndroidLook.deepBrown)
                }
            }

            Divider()
                .background(Color.black.opacity(0.10))

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(localized("Birthday", language: language))
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AndroidLook.mutedBrown)
                    Text("\(birthday ?? user.dateOfBirth)\(birthdayAge.map { " (Age \($0))" } ?? "")")
                        .font(.subheadline.weight(.heavy))
                        .foregroundStyle(AndroidLook.deepBrown)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if let marriage {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(localized("Anniversary", language: language))
                            .font(.caption.weight(.bold))
                            .foregroundStyle(AndroidLook.mutedBrown)
                        Text(marriage)
                            .font(.subheadline.weight(.heavy))
                            .foregroundStyle(AndroidLook.deepBrown)
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
        .padding(max(18.0, 20.0 * layoutScale))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.86), in: RoundedRectangle(cornerRadius: max(18.0, 20.0 * layoutScale), style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: max(18.0, 20.0 * layoutScale), style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }

@ViewBuilder
private func dashboardAccountActions(
    viewModel: AppViewModel,
    layoutScale: CGFloat,
    onChangePassword: @escaping () -> Void
) -> some View {
    HStack(spacing: max(8.0, 10.0 * layoutScale)) {
        Button {
            viewModel.showNotifications()
        } label: {
            HStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell.fill")
                    if viewModel.unreadNotificationCount > 0 {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                            .offset(x: 5, y: -5)
                    }
                }

                Text(localized("Notifications", language: viewModel.language))
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)

                if viewModel.unreadNotificationCount > 0 {
                    Text("\(min(viewModel.unreadNotificationCount, 99))")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.red, in: Capsule())
                }
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(AndroidLook.softBrown)
            .frame(maxWidth: .infinity, minHeight: max(42.0, 44.0 * layoutScale))
            .padding(.horizontal, 12)
            .background(AndroidLook.glassFill, in: Capsule())
            .overlay(
                Capsule()
                    .stroke(AndroidLook.accentGold.opacity(0.72), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)

        Button {
            onChangePassword()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "key.fill")
                Text(localized("Change Password", language: viewModel.language))
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(AndroidLook.softBrown)
            .frame(maxWidth: .infinity, minHeight: max(42.0, 44.0 * layoutScale))
            .padding(.horizontal, 12)
            .background(AndroidLook.glassFill, in: Capsule())
            .overlay(
                Capsule()
                    .stroke(AndroidLook.accentGold.opacity(0.72), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    .frame(maxWidth: .infinity)
}

@ViewBuilder
private func dashboardQuickActions(
    viewModel: AppViewModel,
    contentWidth: CGFloat,
    cardSpacing: CGFloat,
    actionTileWidth: CGFloat,
    layoutScale: CGFloat
) -> some View {
        let tilePadding = max(10.0, 12.0 * layoutScale)
        let columns = Array(repeating: GridItem(.flexible(minimum: 0, maximum: actionTileWidth), spacing: cardSpacing), count: 2)

        VStack(alignment: .leading, spacing: max(10.0, 12.0 * layoutScale)) {
            AndroidDashboardSectionHeader(title: localized("Explore", language: viewModel.language))

            LazyVGrid(columns: columns, spacing: cardSpacing) {
                Button {
                    viewModel.showProfiles()
                } label: {
                    DashboardActionLabel(
                        title: localized("Profiles", language: viewModel.language),
                        subtitle: localized("Members + search", language: viewModel.language),
                        systemImage: "person.3.fill",
                        tint: AndroidLook.softBrown,
                        background: LinearGradient(colors: [Color.blue.opacity(0.26), Color.cyan.opacity(0.18)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        layoutScale: layoutScale,
                        tilePadding: tilePadding
                    )
                }
                .buttonStyle(.plain)

                if viewModel.hasAdminPrivileges {
                    Button {
                        viewModel.showProfiles()
                    } label: {
                        DashboardActionLabel(
                            title: localized("Approvals", language: viewModel.language),
                            subtitle: viewModel.approvalPendingCount > 0 ? "\(viewModel.approvalPendingCount) \(localized("pending", language: viewModel.language))" : localized("No pending", language: viewModel.language),
                            systemImage: "checkmark.seal.fill",
                            tint: AndroidLook.softBrown,
                            background: LinearGradient(colors: [Color.green.opacity(0.24), Color.mint.opacity(0.16)], startPoint: .topLeading, endPoint: .bottomTrailing),
                            layoutScale: layoutScale,
                            tilePadding: tilePadding
                        )
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    viewModel.showGallery()
                } label: {
                    DashboardActionLabel(
                        title: localized("Gallery", language: viewModel.language),
                        subtitle: localized("Memories", language: viewModel.language),
                        systemImage: "photo.on.rectangle",
                        tint: AndroidLook.softBrown,
                        background: LinearGradient(colors: [Color.pink.opacity(0.25), Color.orange.opacity(0.16)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        layoutScale: layoutScale,
                        tilePadding: tilePadding
                    )
                }
                .buttonStyle(.plain)

                Button {
                    viewModel.showDiscussions()
                } label: {
                    DashboardActionLabel(
                        title: localized("Discussions", language: viewModel.language),
                        subtitle: localized("Threads + polls", language: viewModel.language),
                        systemImage: "bubble.left.and.bubble.right.fill",
                        tint: AndroidLook.softBrown,
                        background: LinearGradient(colors: [Color.purple.opacity(0.24), Color.indigo.opacity(0.16)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        layoutScale: layoutScale,
                        tilePadding: tilePadding
                    )
                }
                .buttonStyle(.plain)

                Button {
                    viewModel.showCookbook()
                } label: {
                    DashboardActionLabel(
                        title: localized("Cookbook", language: viewModel.language),
                        subtitle: localized("Recipes", language: viewModel.language),
                        systemImage: "book.closed.fill",
                        tint: AndroidLook.softBrown,
                        background: LinearGradient(colors: [Color.orange.opacity(0.26), Color.yellow.opacity(0.18)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        layoutScale: layoutScale,
                        tilePadding: tilePadding
                    )
                }
                .buttonStyle(.plain)

                Button {
                    viewModel.showTraditions()
                } label: {
                    DashboardActionLabel(
                        title: localized("Traditions", language: viewModel.language),
                        subtitle: localized("Family rituals", language: viewModel.language),
                        systemImage: "heart.text.square.fill",
                        tint: AndroidLook.softBrown,
                        background: LinearGradient(colors: [Color.red.opacity(0.24), Color.pink.opacity(0.16)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        layoutScale: layoutScale,
                        tilePadding: tilePadding
                    )
                }
                .buttonStyle(.plain)

                Button {
                    viewModel.showMemoryLane()
                } label: {
                    DashboardActionLabel(
                        title: localized("Memory Lane", language: viewModel.language),
                        subtitle: localized("Milestones", language: viewModel.language),
                        systemImage: "clock.arrow.circlepath",
                        tint: AndroidLook.softBrown,
                        background: LinearGradient(colors: [Color.teal.opacity(0.24), Color.green.opacity(0.16)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        layoutScale: layoutScale,
                        tilePadding: tilePadding
                    )
                }
                .buttonStyle(.plain)

                Button {
                    viewModel.showFamilyTree()
                } label: {
                    DashboardActionLabel(
                        title: localized("Family Tree", language: viewModel.language),
                        subtitle: localized("Family hierarchy", language: viewModel.language),
                        systemImage: "point.3.connected.trianglepath.dotted",
                        tint: AndroidLook.softBrown,
                        background: LinearGradient(colors: [Color.brown.opacity(0.24), Color.orange.opacity(0.16)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        layoutScale: layoutScale,
                        tilePadding: tilePadding
                    )
                }
                .buttonStyle(.plain)

                Button {
                    viewModel.showMessages()
                } label: {
                    DashboardActionLabel(
                        title: localized("Messages", language: viewModel.language),
                        subtitle: viewModel.totalUnreadCount > 0 ? "\(viewModel.totalUnreadCount) \(localized("unread", language: viewModel.language))" : localized("Direct chat", language: viewModel.language),
                        systemImage: "envelope.badge",
                        tint: AndroidLook.softBrown,
                        background: LinearGradient(colors: [Color.indigo.opacity(0.26), Color.blue.opacity(0.18)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        layoutScale: layoutScale,
                        tilePadding: tilePadding
                    )
                }
                .buttonStyle(.plain)

                Button {
                    viewModel.showEmergency()
                } label: {
                    DashboardActionLabel(
                        title: localized("Emergency", language: viewModel.language),
                        subtitle: "Numbers + nearby",
                        systemImage: "cross.case.fill",
                        tint: Color(red: 0.90, green: 0.10, blue: 0.12),
                        background: LinearGradient(colors: [Color.red.opacity(0.28), Color.orange.opacity(0.16)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        layoutScale: layoutScale,
                        tilePadding: tilePadding
                    )
                }
                .buttonStyle(.plain)

                Button {
                    viewModel.showNearestAICardGenerator()
                } label: {
                    DashboardActionLabel(
                        title: localized("Photo Studio", language: viewModel.language),
                        subtitle: localized("Prompt stickers + GIFs", language: viewModel.language),
                        systemImage: "wand.and.stars.inverse",
                        tint: AndroidLook.softBrown,
                        background: LinearGradient(colors: [Color.yellow.opacity(0.28), Color.pink.opacity(0.18)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        layoutScale: layoutScale,
                        tilePadding: tilePadding
                    )
                }
                .buttonStyle(.plain)

                Button {
                    viewModel.showAchievements()
                } label: {
                    DashboardActionLabel(
                        title: localized("Achievements", language: viewModel.language),
                        subtitle: localized("Family wins", language: viewModel.language),
                        systemImage: "trophy.fill",
                        tint: AndroidLook.softBrown,
                        background: LinearGradient(colors: [Color.yellow.opacity(0.24), Color.orange.opacity(0.18)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        layoutScale: layoutScale,
                        tilePadding: tilePadding
                    )
                }
                .buttonStyle(.plain)

                Button {
                    viewModel.showBusinessDirectory()
                } label: {
                    DashboardActionLabel(
                        title: localized("Business", language: viewModel.language),
                        subtitle: localized("Local services", language: viewModel.language),
                        systemImage: "building.2.fill",
                        tint: AndroidLook.softBrown,
                        background: LinearGradient(colors: [Color.gray.opacity(0.22), Color.blue.opacity(0.16)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        layoutScale: layoutScale,
                        tilePadding: tilePadding
                    )
                }
                .buttonStyle(.plain)

                Button {
                    viewModel.showFamilyGames()
                } label: {
                    DashboardActionLabel(
                        title: localized("Family Games", language: viewModel.language),
                        subtitle: localized("Play together", language: viewModel.language),
                        systemImage: "gamecontroller.fill",
                        tint: AndroidLook.softBrown,
                        background: LinearGradient(colors: [Color.orange.opacity(0.26), Color.green.opacity(0.16)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        layoutScale: layoutScale,
                        tilePadding: tilePadding
                    )
                }
                .buttonStyle(.plain)

                Button {
                    viewModel.showCalendar()
                } label: {
                    DashboardActionLabel(
                        title: localized("Calendar", language: viewModel.language),
                        subtitle: localized("Events + panchang", language: viewModel.language),
                        systemImage: "calendar",
                        tint: AndroidLook.softBrown,
                        background: LinearGradient(colors: [Color.purple.opacity(0.24), Color.blue.opacity(0.14)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        layoutScale: layoutScale,
                        tilePadding: tilePadding
                    )
                }
                .buttonStyle(.plain)

                if viewModel.isPrimaryAdminLogin {
                    Button {
                        viewModel.showActivityLog()
                    } label: {
                        DashboardActionLabel(
                            title: localized("Activity Log", language: viewModel.language),
                            subtitle: localized("Recent activity", language: viewModel.language),
                            systemImage: "clock.badge.checkmark.fill",
                            tint: AndroidLook.softBrown,
                            background: LinearGradient(colors: [Color.teal.opacity(0.24), Color.cyan.opacity(0.16)], startPoint: .topLeading, endPoint: .bottomTrailing),
                            layoutScale: layoutScale,
                            tilePadding: tilePadding
                        )
                    }
                    .buttonStyle(.plain)

                    Button {
                        viewModel.showLoginLog()
                    } label: {
                        DashboardActionLabel(
                            title: localized("Login Log", language: viewModel.language),
                            subtitle: localized("Sign-in history", language: viewModel.language),
                            systemImage: "person.badge.clock.fill",
                            tint: AndroidLook.softBrown,
                            background: LinearGradient(colors: [Color.indigo.opacity(0.22), Color.mint.opacity(0.16)], startPoint: .topLeading, endPoint: .bottomTrailing),
                            layoutScale: layoutScale,
                            tilePadding: tilePadding
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: contentWidth, alignment: .center)
        }
}

private struct CalendarScreen: View {
    @Bindable var viewModel: AppViewModel
    @State private var monthOffset = 0
    @State private var selectedDate = Foundation.Calendar.current.startOfDay(for: .now)

    private var calendar: Foundation.Calendar {
        var calendar = Foundation.Calendar(identifier: .gregorian)
        calendar.firstWeekday = 1
        return calendar
    }

    var body: some View {
        let month = calendar.date(byAdding: .month, value: monthOffset, to: monthStart(for: .now)) ?? monthStart(for: .now)
        let days = calendarDays(for: month)
        let panchang = generatePanchang(for: month, members: viewModel.allResolvedMembers)
        let selectedPanchang = panchang[calendar.startOfDay(for: selectedDate)]

        AppBackground {
            NavigationStack {
                GeometryReader { proxy in
                    let horizontalInset = adaptiveHorizontalPadding(for: proxy.size.width)

                    VStack(spacing: 0) {
                        monthSelector(month)
                            .padding(.horizontal, horizontalInset)
                            .padding(.top, 12)

                        weekdayHeader
                            .padding(.horizontal, horizontalInset)
                            .padding(.top, 8)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 6) {
                            ForEach(days.indices, id: \.self) { index in
                                if let date = days[index] {
                                    calendarDayCell(date: date, month: month, panchang: panchang[calendar.startOfDay(for: date)])
                                } else {
                                    Color.clear
                                        .aspectRatio(0.82, contentMode: .fit)
                                }
                            }
                        }
                        .padding(.horizontal, horizontalInset)
                        .padding(.top, 8)

                        ScrollView {
                            if let selectedPanchang {
                                dayDetail(date: selectedDate, panchang: selectedPanchang)
                                    .padding(.horizontal, horizontalInset)
                                    .padding(.vertical, 14)
                            } else {
                                Text("Tap on a date to view Panchang details")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(32)
                            }
                        }
                    }
                }
                .navigationTitle(localized("Hindu Calendar", language: viewModel.language))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            viewModel.showDashboard()
                        } label: {
                            Label(localized("Home", language: viewModel.language), systemImage: "house")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            monthOffset = 0
                            selectedDate = calendar.startOfDay(for: .now)
                        } label: {
                            Image(systemName: "calendar.badge.clock")
                        }
                    }
                }
            }
        }
    }

    private func monthSelector(_ month: Date) -> some View {
        HStack {
            Button {
                monthOffset -= 1
                selectedDate = monthStart(for: calendar.date(byAdding: .month, value: monthOffset, to: .now) ?? .now)
            } label: {
                Image(systemName: "chevron.left")
            }

            Spacer()

            Text(month.formatted(.dateTime.month(.wide).year()))
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.brown)

            Spacer()

            Button {
                monthOffset += 1
                selectedDate = monthStart(for: calendar.date(byAdding: .month, value: monthOffset, to: .now) ?? .now)
            } label: {
                Image(systemName: "chevron.right")
            }
        }
        .buttonStyle(.bordered)
        .padding(8)
        .background(Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        )
    }

    private var weekdayHeader: some View {
        let symbols = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        return HStack {
            ForEach(symbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.brown)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func calendarDayCell(date: Date, month: Date, panchang: DayPanchang?) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        let isCurrentMonth = calendar.component(.month, from: date) == calendar.component(.month, from: month)
        let hasEvents = !(panchang?.festivals.isEmpty ?? true)

        return Button {
            selectedDate = calendar.startOfDay(for: date)
        } label: {
            VStack(spacing: 3) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.subheadline.weight(isSelected || isToday ? .bold : .regular))
                if let panchang {
                    Text(panchang.tithiShort)
                        .font(.system(size: 8, weight: .semibold))
                        .lineLimit(1)
                    HStack(spacing: 3) {
                        if hasEvents {
                            Circle()
                                .fill(isSelected ? .white : .red)
                                .frame(width: 5, height: 5)
                        }
                        if !panchang.muhurat.isEmpty {
                            Text("M")
                                .font(.system(size: 7, weight: .bold))
                                .foregroundStyle(isSelected ? .white.opacity(0.75) : .green)
                        }
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(.top, 6)
            .frame(maxWidth: .infinity)
            .aspectRatio(0.82, contentMode: .fit)
            .foregroundStyle(isSelected ? .white : Color.white.opacity(isCurrentMonth ? 0.95 : 0.42))
            .background(
                isSelected ? AndroidLook.accentGold.opacity(0.82) : (isToday ? Color.white.opacity(0.20) : Color.white.opacity(isCurrentMonth ? 0.12 : 0.06)),
                in: RoundedRectangle(cornerRadius: 8, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(isToday ? AndroidLook.accentGold.opacity(0.85) : Color.white.opacity(0.12), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func dayDetail(date: Date, panchang: DayPanchang) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(Color.brown)
                Text(date.formatted(.dateTime.day().month(.wide).year()))
                    .font(.headline)
                Spacer()
            }

            Divider()

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                CalendarDetailItem(label: "Tithi", value: panchang.tithi, systemImage: "sun.max")
                CalendarDetailItem(label: "Nakshatra", value: panchang.nakshatra, systemImage: "star")
                CalendarDetailItem(label: "Yoga", value: panchang.yoga, systemImage: "arrow.triangle.2.circlepath")
                CalendarDetailItem(label: "Karana", value: panchang.karana, systemImage: "info.circle")
            }

            CalendarDetailItem(label: "Muhurat", value: panchang.muhurat, systemImage: "clock")

            if !panchang.festivals.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(localized("Festivals & Events", language: viewModel.language))
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.red)

                    ForEach(panchang.festivals, id: \.self) { festival in
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Circle()
                                .fill(.red)
                                .frame(width: 6, height: 6)
                            Text(festival)
                                .font(.subheadline)
                        }
                    }
                }
            }
        }
        .padding(16)
        .foregroundStyle(.white)
        .background(Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.14), radius: 8, x: 0, y: 4)
    }

    private func monthStart(for date: Date) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components) ?? date
    }

    private func calendarDays(for month: Date) -> [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: month) else { return [] }
        let firstWeekday = calendar.component(.weekday, from: month) - 1
        let dates = range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: month)
        }
        return Array(repeating: nil, count: firstWeekday) + dates
    }

    private func generatePanchang(for month: Date, members: [Member]) -> [Date: DayPanchang] {
        guard let range = calendar.range(of: .day, in: .month, for: month) else { return [:] }
        let tithis = [
            "Pratipada", "Dwitiya", "Tritiya", "Chaturthi", "Panchami", "Shashti", "Saptami", "Ashtami", "Navami", "Dashami",
            "Ekadashi", "Dwadashi", "Trayodashi", "Chaturdashi", "Purnima",
            "Pratipada", "Dwitiya", "Tritiya", "Chaturthi", "Panchami", "Shashti", "Saptami", "Ashtami", "Navami", "Dashami",
            "Ekadashi", "Dwadashi", "Trayodashi", "Chaturdashi", "Amavasya"
        ]
        let nakshatras = ["Ashwini", "Bharani", "Krittika", "Rohini", "Mrigashirsha", "Ardra", "Punarvasu", "Pushya", "Ashlesha", "Magha", "Purva Phalguni", "Uttara Phalguni", "Hasta", "Chitra", "Swati", "Vishakha", "Anuradha", "Jyeshtha", "Mula", "Purva Ashadha", "Uttara Ashadha", "Shravana", "Dhanishta", "Shatabhisha", "Purva Bhadrapada", "Uttara Bhadrapada", "Revati"]
        let monthNumber = calendar.component(.month, from: month)
        let year = calendar.component(.year, from: month)

        return range.reduce(into: [Date: DayPanchang]()) { result, day in
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: month) else { return }
            let tithiIndex = (day + monthNumber * 2 + year % 30) % 30
            let tithiName = tithis[tithiIndex]
            let paksha = tithiIndex < 15 ? "Shukla Paksha" : "Krishna Paksha"
            var festivals = familyEvents(on: date, members: members)
            festivals += fixedFestivals(day: day, month: monthNumber, tithiName: tithiName, paksha: paksha)

            result[calendar.startOfDay(for: date)] = DayPanchang(
                tithi: "\(tithiName) (\(paksha))",
                tithiShort: String(tithiName.prefix(4)),
                nakshatra: nakshatras[(day + monthNumber) % nakshatras.count],
                yoga: "Siddha",
                karana: "Bava",
                muhurat: day % 3 == 0 ? "Shubh Muhurat: 09:30 AM - 11:00 AM" : "Abhijit: 11:45 AM - 12:30 PM",
                festivals: festivals
            )
        }
    }

    private func familyEvents(on date: Date, members: [Member]) -> [String] {
        members.reduce(into: [String]()) { events, member in
            if matchesMonthDay(member.dateOfBirth, date: date) {
                events.append("Birthday: \(member.name)")
            }
            if let marriageDate = member.marriageDate, matchesMonthDay(marriageDate, date: date), !member.isDeceased {
                events.append("Anniversary: \(member.name)")
            }
            if let bereavementDate = member.bereavementDate, matchesMonthDay(bereavementDate, date: date) {
                events.append("Punya Tithi: \(member.name)")
            }
        }
    }

    private func fixedFestivals(day: Int, month: Int, tithiName: String, paksha: String) -> [String] {
        var festivals: [String] = []
        switch month {
        case 1:
            if day == 1 { festivals.append("New Year's Day") }
            if day == 14 || day == 15 { festivals.append("Makar Sankranti / Pongal") }
            if day == 26 { festivals.append("Republic Day") }
        case 2:
            if day == 14 { festivals.append("Vasant Panchami") }
        case 3:
            if tithiName == "Pratipada" && paksha == "Shukla Paksha" { festivals.append("Gudi Padwa / Ugadi") }
            if day == 25 { festivals.append("Holi") }
        case 4:
            if day == 14 { festivals.append("Ambedkar Jayanti") }
            if day == 17 { festivals.append("Ram Navami") }
        case 8:
            if day == 15 { festivals.append("Independence Day") }
            if day == 19 { festivals.append("Raksha Bandhan") }
            if day == 26 { festivals.append("Janmashtami") }
        case 9:
            if day == 7 { festivals.append("Ganesh Chaturthi") }
        case 10:
            if day == 2 { festivals.append("Gandhi Jayanti") }
            if tithiName == "Dashami" && paksha == "Shukla Paksha" { festivals.append("Dussehra") }
            if tithiName == "Amavasya" { festivals.append("Deepavali") }
        case 11:
            if tithiName == "Ekadashi" { festivals.append("Dev Deepavali") }
            if day == 1 { festivals.append("Bhai Dooj") }
        case 12:
            if day == 25 { festivals.append("Christmas") }
        default:
            break
        }

        if tithiName == "Ekadashi" { festivals.append("Ekadashi Vrat") }
        if tithiName == "Chaturthi" { festivals.append("Sankashti Chaturthi") }
        if tithiName == "Purnima" { festivals.append("Purnima Vrat") }
        return festivals
    }

    private func matchesMonthDay(_ dateString: String?, date: Date) -> Bool {
        guard let parsed = flexibleDate(from: dateString) else { return false }
        return calendar.component(.month, from: parsed) == calendar.component(.month, from: date)
            && calendar.component(.day, from: parsed) == calendar.component(.day, from: date)
    }

    private func flexibleDate(from string: String?) -> Date? {
        guard let string, !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        if let date = Member.isoDateFormatter.date(from: string) {
            return date
        }

        let separators = CharacterSet(charactersIn: "-/")
        let parts = string.components(separatedBy: separators).compactMap(Int.init)
        guard parts.count >= 2 else { return nil }
        let day = parts[0]
        let month = parts[1]
        let year = parts.count > 2 ? parts[2] : calendar.component(.year, from: .now)
        return calendar.date(from: DateComponents(year: year, month: month, day: day))
    }
}

private struct DayPanchang: Equatable {
    let tithi: String
    let tithiShort: String
    let nakshatra: String
    let yoga: String
    let karana: String
    let muhurat: String
    let festivals: [String]
}

private struct CalendarDetailItem: View {
    let label: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: systemImage)
                .font(.caption)
                .foregroundStyle(Color.brown.opacity(0.72))
                .frame(width: 16)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.brown)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}


private struct ChatScreen: View {
    @Bindable var viewModel: AppViewModel
    let memberID: String
    @State private var draft = ""

    var body: some View {
        let otherMember = viewModel.member(for: memberID)

        NavigationStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages(for: memberID)) { message in
                                MessageBubble(message: message, isCurrentUser: message.senderId == viewModel.currentUser?.id)
                                    .id(message.id)
                            }
                        }
                        .padding(.horizontal, 16)
                .padding(.vertical, 14)
                    }
                    .onAppear {
                        viewModel.markChatRead(with: memberID)
                        if let last = viewModel.messages(for: memberID).last {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                    .onChange(of: viewModel.messages.count) { _, _ in
                        if let last = viewModel.messages(for: memberID).last {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                messageComposer
            }
            .navigationTitle(otherMember?.name ?? localized("Chat", language: viewModel.language))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        viewModel.showDashboard()
                    } label: {
                        Label(localized("Home", language: viewModel.language), systemImage: "house")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Back") {
                        viewModel.showMessages()
                    }
                }
            }
        }
    }

    private var messageComposer: some View {
        HStack(spacing: 10) {
            TextField("Type a message...", text: $draft, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...4)

            Button {
                viewModel.sendMessage(draft, to: memberID)
                draft = ""
            } label: {
                Image(systemName: "paperplane.fill")
                    .frame(width: 34, height: 34)
            }
            .buttonStyle(.borderedProminent)
            .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(.thinMaterial)
    }
}

private struct MemberListRow: View {
    let member: Member
    let showsPendingBadge: Bool
    let canEdit: Bool
    let canChat: Bool
    let canAdminManage: Bool
    let onEdit: () -> Void
    let onView: () -> Void
    let onChat: () -> Void
    let onResetPassword: () -> Void
    let onRemovePhoto: () -> Void
    let onRemoveMember: () -> Void
    let onInviteWhatsApp: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            AvatarView(member: member, size: 42)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(profileDisplayCase(member.name) ?? member.name)
                        .font(.subheadline.weight(.heavy))
                        .foregroundStyle(AndroidLook.deepBrown)
                        .lineLimit(1)
                        .truncationMode(.tail)

                    if showsPendingBadge {
                        Text("Pending")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.red)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Color.red.opacity(0.10), in: Capsule())
                    }
                }

                Text(relationText)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AndroidLook.mutedBrown)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if canChat {
                compactIconButton(systemImage: "message.fill", action: onChat, label: "Chat")
            }

            compactIconButton(systemImage: "eye.fill", action: onView, label: "View")

            if canAdminManage {
                Menu {
                    Button {
                        onResetPassword()
                    } label: {
                        Label("Reset Password", systemImage: "key.fill")
                    }

                    if member.photoURL?.isEmpty == false {
                        Button(role: .destructive) {
                            onRemovePhoto()
                        } label: {
                            Label("Remove Photo", systemImage: "photo")
                        }
                    }

                    if canEdit {
                        Button {
                            onEdit()
                        } label: {
                            Label("Edit", systemImage: "square.and.pencil")
                        }
                    }

                    Button {
                        onInviteWhatsApp()
                    } label: {
                        Label("Invite via WhatsApp", systemImage: "paperplane.fill")
                    }

                    Button(role: .destructive) {
                        onRemoveMember()
                    } label: {
                        Label("Remove Member", systemImage: "person.crop.circle.badge.minus")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.title3)
                        .frame(width: 34, height: 34)
                }
                .buttonStyle(.plain)
                .foregroundStyle(AndroidLook.deepBrown)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 62, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(Color.white.opacity(0.84), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }

    private func compactIconButton(systemImage: String, action: @escaping () -> Void, label: String) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.subheadline.weight(.bold))
                .frame(width: 34, height: 34)
                .background(AndroidLook.lightGolden.opacity(0.44), in: Circle())
                .overlay(
                    Circle()
                        .stroke(AndroidLook.accentGold.opacity(0.28), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .foregroundStyle(AndroidLook.deepBrown)
        .accessibilityLabel(label)
    }

    private var relationText: String {
        let relationship = member.relationship?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !relationship.isEmpty {
            return profileDisplayCase(relationship) ?? relationship
        }
        return member.isAdmin ? "Admin" : "Relationship not set"
    }
}

private struct MemoryCard: View {
    let memory: MemoryPost
    let contentWidth: CGFloat
    let canRequestDelete: Bool
    let canApprove: Bool
    let onRequestDelete: () -> Void
    let onApprove: () -> Void
    let onOpen: () -> Void

    var body: some View {
        let imageHeight = max(200.0, min(280.0, contentWidth * 0.72))
        let imageWidth = cardInnerWidth(for: contentWidth)
        let reactionCount = memory.reactions.values.reduce(0) { $0 + $1.count }

        VStack(alignment: .leading, spacing: 12) {
            Button(action: onOpen) {
                Group {
                    if let imageURL = URL(string: memory.imageURL), !memory.imageURL.isEmpty {
                        CachedRemoteImage(url: imageURL) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            ZStack {
                                galleryPlaceholder
                                ProgressView()
                            }
                        }
                    } else {
                        galleryPlaceholder
                    }
                }
                .frame(width: imageWidth, height: imageHeight)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .buttonStyle(.plain)

            HStack {
                Text(memory.timestamp.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(reactionCount) reactions")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(memory.comments.count) comments")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if memory.status.isPendingStatus {
                    Text("Pending")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.14), in: Capsule())
                }
                if canApprove {
                    Button("Approve", action: onApprove)
                        .font(.caption.weight(.bold))
                        .buttonStyle(.borderedProminent)
                }
                if canRequestDelete {
                    Button(action: onRequestDelete) {
                        Image(systemName: "trash")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.borderless)
                }
            }

            if !memory.caption.isEmpty {
                Text(memory.caption)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            } else if let firstComment = memory.comments.first {
                Text("“\(firstComment.text)”")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(width: contentWidth, alignment: .leading)
        .background(Color.black.opacity(0.035), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var galleryPlaceholder: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [Color.orange.opacity(0.18), Color.yellow.opacity(0.14)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(memory.userName)
                        .font(.headline)
                    Text(memory.caption)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
            }
    }
}

private struct FullScreenMemoryPhotoView: View {
    let memory: MemoryPost
    let onClose: () -> Void
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            if let url = URL(string: memory.imageURL), !memory.imageURL.isEmpty {
                CachedRemoteImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(zoomGesture.simultaneously(with: dragGesture))
                        .onTapGesture(count: 2) {
                            resetZoom()
                        }
                } placeholder: {
                    ProgressView()
                        .tint(.white)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ContentUnavailableView("Photo", systemImage: "photo", description: Text("No image available."))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(width: 42, height: 42)
                            .background(.black.opacity(0.55), in: Circle())
                    }
                }

                Spacer()

                if !memory.caption.isEmpty {
                    Text(memory.caption)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.black.opacity(0.45), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
            .padding(16)
        }
    }

    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scale = min(max(lastScale * value, 1), 5)
            }
            .onEnded { _ in
                lastScale = scale
                if scale == 1 {
                    offset = .zero
                    lastOffset = .zero
                }
            }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard scale > 1 else { return }
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }

    private func resetZoom() {
        scale = 1
        lastScale = 1
        offset = .zero
        lastOffset = .zero
    }
}

private struct DiscussionCard: View {
    let discussion: DiscussionThread
    let canRequestDelete: Bool
    let canApprove: Bool
    let onRequestDelete: () -> Void
    let onApprove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(discussion.title)
                    .font(.headline)
                Spacer()
                Text(discussion.type.rawValue)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.12), in: Capsule())
                if discussion.status.isPendingStatus {
                    Text("Pending")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.12), in: Capsule())
                }
                if canApprove {
                    Button("Approve", action: onApprove)
                        .font(.caption.weight(.bold))
                        .buttonStyle(.borderedProminent)
                }
                if canRequestDelete {
                    Button(action: onRequestDelete) {
                        Image(systemName: "trash")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.borderless)
                }
            }

            Text("By \(discussion.userName)")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(discussion.content)
                .font(.subheadline)

            if discussion.type == .poll && !discussion.pollOptions.isEmpty {
                VStack(spacing: 8) {
                    ForEach(discussion.pollOptions) { option in
                        HStack {
                            Text(option.text)
                            Spacer()
                            Text("\(option.voterIds.count) votes")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Text("\(discussion.comments.count) comments")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.035), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct RecipeCard: View {
    let recipe: Recipe
    let contentWidth: CGFloat
    let canEdit: Bool
    let canRequestDelete: Bool
    let canApprove: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onApprove: () -> Void

    var body: some View {
        let imageWidth = cardInnerWidth(for: contentWidth)

        VStack(alignment: .leading, spacing: 12) {
            if let url = URL(string: recipe.imageURL), !recipe.imageURL.isEmpty {
                CachedRemoteImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    recipePlaceholder
                }
                .frame(width: imageWidth, height: 190)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            } else {
                recipePlaceholder
                    .frame(width: imageWidth, height: 190)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.title).font(.headline)
                    Text(recipe.category.isEmpty ? "Family Recipe" : recipe.category)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if recipe.status.isPendingStatus {
                    Text("Pending")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.12), in: Capsule())
                }
                if canApprove {
                    Button("Approve", action: onApprove)
                        .font(.caption.weight(.bold))
                        .buttonStyle(.borderedProminent)
                }
                if canEdit {
                    Button(action: onEdit) {
                        Image(systemName: "square.and.pencil")
                    }
                    .buttonStyle(.borderless)
                }
                if canRequestDelete {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.borderless)
                }
            }

            Text(recipe.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            Text("\(recipe.ingredients.count) ingredients • \(recipe.comments.count) comments")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(width: contentWidth, alignment: .leading)
        .background(Color.black.opacity(0.035), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var recipePlaceholder: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [Color.orange.opacity(0.20), Color.yellow.opacity(0.12)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.title)
                        .font(.headline)
                    Text(recipe.category)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 14)
        .padding(.vertical, 12)
            }
    }
}

private struct TraditionCard: View {
    let tradition: Tradition
    let contentWidth: CGFloat
    let canEdit: Bool
    let canRequestDelete: Bool
    let canApprove: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onApprove: () -> Void

    var body: some View {
        let imageWidth = cardInnerWidth(for: contentWidth)

        VStack(alignment: .leading, spacing: 12) {
            if let url = URL(string: tradition.imageURL), !tradition.imageURL.isEmpty {
                CachedRemoteImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    traditionPlaceholder
                }
                .frame(width: imageWidth, height: 180)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            } else {
                traditionPlaceholder
                    .frame(width: imageWidth, height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(tradition.title).font(.headline)
                    Text("Family Tradition")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if tradition.status.isPendingStatus {
                    Text("Pending")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.12), in: Capsule())
                }
                if canApprove {
                    Button("Approve", action: onApprove)
                        .font(.caption.weight(.bold))
                        .buttonStyle(.borderedProminent)
                }
                if canEdit {
                    Button(action: onEdit) {
                        Image(systemName: "square.and.pencil")
                    }
                    .buttonStyle(.borderless)
                }
                if canRequestDelete {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.borderless)
                }
            }

            Text(tradition.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            Text("\(tradition.comments.count) comments")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(width: contentWidth, alignment: .leading)
        .background(Color.black.opacity(0.035), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var traditionPlaceholder: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [Color.pink.opacity(0.20), Color.orange.opacity(0.12)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(alignment: .bottomLeading) {
                Text(tradition.title)
                    .font(.headline)
                    .padding(.horizontal, 14)
        .padding(.vertical, 12)
            }
    }
}

private struct MilestoneCard: View {
    let milestone: Milestone
    let language: AppLanguage
    let contentWidth: CGFloat
    let canEdit: Bool
    let canRequestDelete: Bool
    let canApprove: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onApprove: () -> Void

    var body: some View {
        let imageWidth = cardInnerWidth(for: contentWidth)

        VStack(alignment: .leading, spacing: 12) {
            if let url = URL(string: milestone.imageURL), !milestone.imageURL.isEmpty {
                CachedRemoteImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    milestonePlaceholder
                }
                .frame(width: imageWidth, height: 170)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            } else {
                milestonePlaceholder
                    .frame(width: imageWidth, height: 170)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }

            if !milestone.audioURL.isEmpty {
                AudioPlayerWidget(urlString: milestone.audioURL, language: language)
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(milestone.title).font(.headline)
                    Text(milestone.year.isEmpty ? "Milestone" : milestone.year)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if !milestone.location.isEmpty {
                        Label(milestone.location, systemImage: "mappin.and.ellipse")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                if milestone.status.isPendingStatus {
                    Text("Pending")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.12), in: Capsule())
                }
                if canApprove {
                    Button("Approve", action: onApprove)
                        .font(.caption.weight(.bold))
                        .buttonStyle(.borderedProminent)
                }
                if canEdit {
                    Button(action: onEdit) {
                        Image(systemName: "square.and.pencil")
                    }
                    .buttonStyle(.borderless)
                }
                if canRequestDelete {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.borderless)
                }
            }

            Text(milestone.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(width: contentWidth, alignment: .leading)
        .background(Color.black.opacity(0.035), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var milestonePlaceholder: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [Color.blue.opacity(0.20), Color.orange.opacity(0.12)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(milestone.title)
                        .font(.headline)
                    Text(milestone.year)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if !milestone.location.isEmpty {
                        Text(milestone.location)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 14)
        .padding(.vertical, 12)
            }
    }
}

private struct RecipeDetailSheet: View {
    @Bindable var viewModel: AppViewModel
    @State private var recipe: Recipe
    let onClose: () -> Void
    @State private var commentText = ""

    init(viewModel: AppViewModel, recipe: Recipe, onClose: @escaping () -> Void) {
        self.viewModel = viewModel
        self._recipe = State(initialValue: recipe)
        self.onClose = onClose
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(recipe.title)
                        .font(.title2.weight(.bold))
                    Text(recipe.category)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(recipe.description)
                        .font(.subheadline)
                    detailImage(urlString: recipe.imageURL)

                    reactionBar

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Comments").font(.headline)
                        ForEach(recipe.comments.sorted { $0.timestamp < $1.timestamp }) { comment in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(comment.userName)
                                    .font(.caption.weight(.semibold))
                                Text(comment.text)
                                    .font(.subheadline)
                            }
                            .padding(.vertical, 4)
                        }

                        HStack(spacing: 8) {
                            TextField("Add a comment", text: $commentText, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                            Button("Send") {
                                let text = commentText
                                commentText = ""
                                Task {
                                    await viewModel.addRecipeComment(recipe, text: text)
                                    if let latest = viewModel.visibleRecipes.first(where: { $0.id == recipe.id }) {
                                        recipe = latest
                                    }
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ingredients").font(.headline)
                        ForEach(recipe.ingredients, id: \.self) { ingredient in
                            Text("• \(ingredient)")
                                .font(.subheadline)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Instructions").font(.headline)
                        Text(recipe.instructions)
                            .font(.subheadline)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .navigationTitle(localized("Recipe", language: viewModel.language))
            .toolbar { Button("Close", action: onClose) }
        }
    }

    private var reactionBar: some View {
        ReactionBarView(
            reactions: recipe.reactions,
            currentUserId: viewModel.currentUser?.id,
            members: viewModel.allResolvedMembers
        ) { emoji in
            Task {
                await viewModel.toggleRecipeReaction(recipe, emoji: emoji)
                if let latest = viewModel.visibleRecipes.first(where: { $0.id == recipe.id }) {
                    recipe = latest
                }
            }
        }
    }
}

private struct ReactionBarView: View {
    private let emojis = ["❤️", "🙏", "👍", "🔥"]
    let reactions: [String: [String]]
    let currentUserId: String?
    let members: [Member]
    let onToggle: (String) -> Void
    @State private var hoveredEmoji: String?
    @State private var selectedContributors: ReactionContributorSelection?

    var body: some View {
        HStack(spacing: 10) {
            ForEach(emojis, id: \.self) { emoji in
                let users = reactions[emoji] ?? []
                let isSelected = currentUserId.map { users.contains($0) } ?? false
                ReactionPillView(
                    emoji: emoji,
                    count: users.count,
                    isSelected: isSelected,
                    onToggle: {
                        onToggle(emoji)
                    },
                    onLongPress: {
                        guard !users.isEmpty else { return }
                        selectedContributors = ReactionContributorSelection(
                            emoji: emoji,
                            count: users.count,
                            names: contributorNames(for: emoji)
                        )
                    }
                )
                .help(contributorText(for: emoji))
                .onHover { isHovering in
                    hoveredEmoji = isHovering ? emoji : (hoveredEmoji == emoji ? nil : hoveredEmoji)
                }
                .popover(isPresented: Binding(
                    get: { hoveredEmoji == emoji && !users.isEmpty },
                    set: { if !$0, hoveredEmoji == emoji { hoveredEmoji = nil } }
                )) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(emoji) \(users.count)")
                            .font(.headline)
                        Text(contributorNames(for: emoji).joined(separator: "\n"))
                            .font(.subheadline)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(12)
                    .frame(minWidth: 180, alignment: .leading)
                }
            }
        }
        .sheet(item: $selectedContributors) { selection in
            ReactionContributorsSheet(selection: selection)
        }
    }

    private func contributorText(for emoji: String) -> String {
        let names = contributorNames(for: emoji)
        guard !names.isEmpty else { return "No reactions yet" }
        return names.joined(separator: ", ")
    }

    private func contributorNames(for emoji: String) -> [String] {
        (reactions[emoji] ?? []).map { userId in
            if let member = members.first(where: { $0.id == userId }) {
                return member.name
            }
            if userId == currentUserId {
                return "You"
            }
            return userId
        }
    }
}

private struct ReactionPillView: View {
    let emoji: String
    let count: Int
    let isSelected: Bool
    let onToggle: () -> Void
    let onLongPress: () -> Void

    var body: some View {
        Button(action: onToggle) {
            Text("\(emoji) \(count)")
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .background(isSelected ? Color.orange.opacity(0.20) : Color.black.opacity(0.06), in: Capsule())
        .overlay(
            Capsule()
                .strokeBorder(isSelected ? Color.orange.opacity(0.65) : Color.clear, lineWidth: 1)
        )
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.45)
                .onEnded { _ in
                    onLongPress()
                }
        )
    }
}

private struct ReactionContributorSelection: Identifiable {
    let id = UUID()
    let emoji: String
    let count: Int
    let names: [String]
}

private struct ReactionContributorsSheet: View {
    let selection: ReactionContributorSelection
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("\(selection.emoji) \(selection.count)") {
                    ForEach(selection.names, id: \.self) { name in
                        Label(name, systemImage: "person.crop.circle")
                    }
                }
            }
            .navigationTitle("Reactions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Close") {
                    dismiss()
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

private struct TraditionDetailSheet: View {
    @Bindable var viewModel: AppViewModel
    @State private var tradition: Tradition
    let onClose: () -> Void
    @State private var commentText = ""

    init(viewModel: AppViewModel, tradition: Tradition, onClose: @escaping () -> Void) {
        self.viewModel = viewModel
        self._tradition = State(initialValue: tradition)
        self.onClose = onClose
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(tradition.title)
                        .font(.title2.weight(.bold))
                    Text(tradition.description)
                        .font(.subheadline)
                    detailImage(urlString: tradition.imageURL)

                    reactionBar

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Comments").font(.headline)
                        ForEach(tradition.comments.sorted { $0.timestamp < $1.timestamp }) { comment in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(comment.userName)
                                    .font(.caption.weight(.semibold))
                                Text(comment.text)
                                    .font(.subheadline)
                            }
                            .padding(.vertical, 4)
                        }

                        HStack(spacing: 8) {
                            TextField("Add a comment", text: $commentText, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                            Button("Send") {
                                let text = commentText
                                commentText = ""
                                Task {
                                    await viewModel.addTraditionComment(tradition, text: text)
                                    if let latest = viewModel.visibleTraditions.first(where: { $0.id == tradition.id }) {
                                        tradition = latest
                                    }
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .navigationTitle(localized("Tradition", language: viewModel.language))
            .toolbar { Button("Close", action: onClose) }
        }
    }

    private var reactionBar: some View {
        ReactionBarView(
            reactions: tradition.reactions,
            currentUserId: viewModel.currentUser?.id,
            members: viewModel.allResolvedMembers
        ) { emoji in
            Task {
                await viewModel.toggleTraditionReaction(tradition, emoji: emoji)
                if let latest = viewModel.visibleTraditions.first(where: { $0.id == tradition.id }) {
                    tradition = latest
                }
            }
        }
    }
}

private struct MilestoneDetailSheet: View {
    @Bindable var viewModel: AppViewModel
    @State private var milestone: Milestone
    let onClose: () -> Void
    @State private var commentText = ""

    init(viewModel: AppViewModel, milestone: Milestone, onClose: @escaping () -> Void) {
        self.viewModel = viewModel
        self._milestone = State(initialValue: milestone)
        self.onClose = onClose
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(milestone.title)
                        .font(.title2.weight(.bold))
                    Text(milestone.year)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    if !milestone.location.isEmpty {
                        Label(milestone.location, systemImage: "mappin.and.ellipse")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text(milestone.description)
                        .font(.subheadline)
                    if !milestone.audioURL.isEmpty {
                        AudioPlayerWidget(urlString: milestone.audioURL, language: viewModel.language)
                    }
                    detailImage(urlString: milestone.imageURL)

                    reactionBar

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Comments").font(.headline)
                        ForEach(milestone.comments.sorted { $0.timestamp < $1.timestamp }) { comment in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(comment.userName)
                                    .font(.caption.weight(.semibold))
                                Text(comment.text)
                                    .font(.subheadline)
                            }
                            .padding(.vertical, 4)
                        }

                        HStack(spacing: 8) {
                            TextField("Add a comment", text: $commentText, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                            Button("Send") {
                                let text = commentText
                                commentText = ""
                                Task {
                                    await viewModel.addMilestoneComment(milestone, text: text)
                                    if let latest = viewModel.visibleMilestones.first(where: { $0.id == milestone.id }) {
                                        milestone = latest
                                    }
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .navigationTitle(localized("Milestone", language: viewModel.language))
            .toolbar { Button("Close", action: onClose) }
        }
    }

    private var reactionBar: some View {
        ReactionBarView(
            reactions: milestone.reactions,
            currentUserId: viewModel.currentUser?.id,
            members: viewModel.allResolvedMembers
        ) { emoji in
            Task {
                await viewModel.toggleMilestoneReaction(milestone, emoji: emoji)
                if let latest = viewModel.visibleMilestones.first(where: { $0.id == milestone.id }) {
                    milestone = latest
                }
            }
        }
    }
}

private struct MemoryDetailSheet: View {
    @Bindable var viewModel: AppViewModel
    @State private var memory: MemoryPost
    let onClose: () -> Void
    @State private var commentText = ""
    @State private var captionText = ""
    @State private var isEditingCaption = false

    init(viewModel: AppViewModel, memory: MemoryPost, onClose: @escaping () -> Void) {
        self.viewModel = viewModel
        self._memory = State(initialValue: memory)
        self._captionText = State(initialValue: memory.caption)
        self.onClose = onClose
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(memory.userName)
                        .font(.title3.weight(.bold))
                    Text(memory.timestamp.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    detailImage(urlString: memory.imageURL)

                    if isEditingCaption {
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Caption", text: $captionText, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                            HStack {
                                Button("Cancel") {
                                    captionText = memory.caption
                                    isEditingCaption = false
                                }
                                .buttonStyle(.bordered)

                                Button("Save Caption") {
                                    Task {
                                        await viewModel.updateMemoryCaption(memory, caption: captionText)
                                        if let latest = viewModel.memories.first(where: { $0.id == memory.id }) {
                                            memory = latest
                                            captionText = latest.caption
                                        }
                                        isEditingCaption = false
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                    } else if !memory.caption.isEmpty {
                        HStack(alignment: .top, spacing: 8) {
                            Text(memory.caption)
                                .font(.subheadline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            if canEditCaption {
                                Button {
                                    captionText = memory.caption
                                    isEditingCaption = true
                                } label: {
                                    Image(systemName: "pencil")
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    } else if canEditCaption {
                        Button {
                            captionText = ""
                            isEditingCaption = true
                        } label: {
                            Label("Add Caption", systemImage: "pencil")
                        }
                        .buttonStyle(.bordered)
                    }

                    reactionBar

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Comments").font(.headline)
                        ForEach(memory.comments.sorted { $0.timestamp < $1.timestamp }) { comment in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(comment.userName)
                                    .font(.caption.weight(.semibold))
                                Text(comment.text)
                                    .font(.subheadline)
                            }
                            .padding(.vertical, 4)
                        }

                        HStack(spacing: 8) {
                            TextField("Add a comment", text: $commentText, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                            Button("Send") {
                                let text = commentText
                                commentText = ""
                                Task {
                                    await viewModel.addMemoryComment(memory, text: text)
                                    if let latest = viewModel.memories.first(where: { $0.id == memory.id }) {
                                        memory = latest
                                    }
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .navigationTitle(localized("Memories", language: viewModel.language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Close", action: onClose)
            }
        }
    }

    private var reactionBar: some View {
        ReactionBarView(
            reactions: memory.reactions,
            currentUserId: viewModel.currentUser?.id,
            members: viewModel.allResolvedMembers
        ) { emoji in
            Task {
                await viewModel.toggleMemoryReaction(memory, emoji: emoji)
                if let latest = viewModel.memories.first(where: { $0.id == memory.id }) {
                    memory = latest
                }
            }
        }
    }

    private var canEditCaption: Bool {
        viewModel.currentUser?.id == memory.userId || viewModel.hasAdminPrivileges
    }
}

private struct AudioPlayerWidget: View {
    let urlString: String
    let language: AppLanguage
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var cachedURL: URL?
    @State private var isPreparing = false

    var body: some View {
        HStack(spacing: 10) {
            Button {
                Task {
                    await togglePlayback()
                }
            } label: {
                ZStack {
                    if isPreparing {
                        ProgressView()
                            .controlSize(.mini)
                    } else {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.headline)
                    }
                }
                .frame(width: 34, height: 34)
                .background(AndroidLook.lightGolden.opacity(0.62), in: Circle())
            }
            .buttonStyle(.plain)
            .foregroundStyle(AndroidLook.softBrown)
            .disabled(isPreparing)

            Text(isPlaying ? localized("Playing voice memory...", language: language) : localized("Voice Memory", language: language))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AndroidLook.deepBrown)

            Spacer()
        }
        .padding(10)
        .background(AndroidLook.cream.opacity(0.82), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(AndroidLook.softBrown.opacity(0.22), lineWidth: 1)
        )
        .onDisappear {
            player?.pause()
            isPlaying = false
        }
        .task(id: urlString) {
            cachedURL = await preparedAudioURL()
        }
    }

    private func togglePlayback() async {
        if isPlaying {
            player?.pause()
            isPlaying = false
            return
        }

        isPreparing = true
        let url: URL?
        if let cachedURL {
            url = cachedURL
        } else {
            url = await preparedAudioURL()
        }
        cachedURL = url
        isPreparing = false
        guard let url else { return }

        if player == nil {
            player = AVPlayer(url: url)
        }
        player?.play()
        isPlaying = true
    }

    private func preparedAudioURL() async -> URL? {
        guard let url = URL(string: urlString) else { return nil }
        return (try? await RemoteMediaCache.shared.cachedFileURL(for: url)) ?? url
    }
}

private struct MemoryEditorSheet: View {
    @Bindable var viewModel: AppViewModel
    let onClose: () -> Void

    @State private var caption = ""
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedPhotos: [MemoryPhotoSelection] = []
    @State private var isPosting = false
    @State private var postingProgress = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    PhotosPicker(selection: $selectedItems, maxSelectionCount: 20, matching: .images) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                            Text(selectedPhotos.isEmpty ? "Choose Photos" : "\(selectedPhotos.count) Photos Selected")
                        }
                    }

                    if !selectedPhotos.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(selectedPhotos) { photo in
                                    if let image = UIImage(data: photo.data) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 84, height: 84)
                                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }

                    TextField("Caption", text: $caption, axis: .vertical)

                    if !postingProgress.isEmpty {
                        Text(postingProgress)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Post Photos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onClose)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isPosting ? "Posting..." : "Post") {
                        Task { await post() }
                    }
                    .disabled(isPosting || selectedPhotos.isEmpty)
                }
            }
            .onChange(of: selectedItems) { _, newValue in
                Task {
                    var loadedPhotos: [MemoryPhotoSelection] = []
                    for item in newValue {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            loadedPhotos.append(MemoryPhotoSelection(data: data))
                        }
                    }
                    selectedPhotos = loadedPhotos
                }
            }
        }
    }

    private func post() async {
        guard let currentUser = viewModel.currentUser else { return }
        guard !selectedPhotos.isEmpty else { return }
        isPosting = true
        defer {
            isPosting = false
            postingProgress = ""
        }

        let trimmedCaption = caption.trimmingCharacters(in: .whitespacesAndNewlines)
        var postedCount = 0

        for (index, photo) in selectedPhotos.enumerated() {
            postingProgress = "Uploading \(index + 1) of \(selectedPhotos.count)"
            guard let url = await viewModel.uploadImageData(photo.data, folder: "memories") else { continue }

            let memory = MemoryPost(
                id: UUID().uuidString,
                userId: currentUser.id,
                userName: currentUser.name,
                imageURL: url,
                caption: trimmedCaption,
                timestamp: .now,
                status: viewModel.newContentStatus,
                reactions: [:],
                comments: []
            )

            await viewModel.saveMemory(memory)
            postedCount += 1
        }

        if postedCount > 0 {
            onClose()
        }
    }
}

private struct MemoryPhotoSelection: Identifiable {
    let id = UUID()
    let data: Data
}

private func detailImage(urlString: String) -> some View {
    Group {
        if let url = URL(string: urlString), !urlString.isEmpty {
            CachedRemoteImage(url: url) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.black.opacity(0.06))
                    .frame(height: 180)
            }
        } else {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.black.opacity(0.06))
                .frame(height: 180)
        }
    }
    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
}

private struct RecipeEditorSheet: View {
    @Bindable var viewModel: AppViewModel
    let existingRecipe: Recipe?
    let authorId: String
    let authorName: String
    let onSave: (Recipe) -> Void
    let onCancel: () -> Void

    @State private var title: String
    @State private var category: String
    @State private var description: String
    @State private var ingredients: String
    @State private var instructions: String
    @State private var imageURL: String
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data?

    init(
        viewModel: AppViewModel,
        existingRecipe: Recipe?,
        authorId: String,
        authorName: String,
        onSave: @escaping (Recipe) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.existingRecipe = existingRecipe
        self.authorId = authorId
        self.authorName = authorName
        self.onSave = onSave
        self.onCancel = onCancel
        _title = State(initialValue: existingRecipe?.title ?? "")
        _category = State(initialValue: existingRecipe?.category ?? "")
        _description = State(initialValue: existingRecipe?.description ?? "")
        _ingredients = State(initialValue: existingRecipe?.ingredients.joined(separator: "\n") ?? "")
        _instructions = State(initialValue: existingRecipe?.instructions ?? "")
        _imageURL = State(initialValue: existingRecipe?.imageURL ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(localized("Recipe", language: viewModel.language)) {
                    TextField("Title", text: $title)
                    TextField("Category", text: $category)
                    TextField("Description", text: $description, axis: .vertical)
                }
                Section(localized("Ingredients", language: viewModel.language)) {
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.black.opacity(0.03))

                        TextEditor(text: $ingredients)
                            .frame(minHeight: 150)
                            .scrollContentBackground(.hidden)
                            .padding(.horizontal, -4)
                            .padding(.vertical, 6)

                        if ingredients.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text("One ingredient per line")
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 14)
                        }
                    }
                    .frame(minHeight: 150)
                }
                Section(localized("Instructions", language: viewModel.language)) {
                    TextField("Write the steps", text: $instructions, axis: .vertical)
                }
                Section(localized("Photo", language: viewModel.language)) {
                    TextField("Image URL", text: $imageURL, axis: .vertical)
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Text("Choose from Photos")
                    }
                    Text(selectedImageData == nil ? "No device photo selected" : "Device photo selected")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(existingRecipe == nil ? localized("Add Recipe", language: viewModel.language) : localized("Edit Recipe", language: viewModel.language))
            .task(id: selectedPhotoItem) {
                guard let selectedPhotoItem else { return }
                if let data = try? await selectedPhotoItem.loadTransferable(type: Data.self) {
                    selectedImageData = data
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            var finalImageURL = imageURL.trimmingCharacters(in: .whitespacesAndNewlines)
                            if let data = selectedImageData, let uploaded = await viewModel.uploadImageData(data, folder: "recipes") {
                                finalImageURL = uploaded
                            }

                            onSave(
                                Recipe(
                                    id: existingRecipe?.id ?? UUID().uuidString,
                                    title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                                    authorId: existingRecipe?.authorId.isEmpty == false ? existingRecipe!.authorId : authorId,
                                    authorName: existingRecipe?.authorName.isEmpty == false ? existingRecipe!.authorName : authorName,
                                    category: category.trimmingCharacters(in: .whitespacesAndNewlines),
                                    description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                                    ingredients: ingredients
                                        .components(separatedBy: .newlines)
                                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                                        .filter { !$0.isEmpty },
                                    instructions: instructions.trimmingCharacters(in: .whitespacesAndNewlines),
                                    imageURL: finalImageURL,
                                    reactions: existingRecipe?.reactions ?? [:],
                                    comments: existingRecipe?.comments ?? [],
                                    status: existingRecipe?.status ?? viewModel.newContentStatus,
                                    timestamp: existingRecipe?.timestamp ?? .now
                                )
                            )
                        }
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

private struct TraditionEditorSheet: View {
    @Bindable var viewModel: AppViewModel
    let existingTradition: Tradition?
    let authorId: String
    let authorName: String
    let onSave: (Tradition) -> Void
    let onCancel: () -> Void

    @State private var title: String
    @State private var description: String
    @State private var imageURL: String
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data?

    init(
        viewModel: AppViewModel,
        existingTradition: Tradition?,
        authorId: String,
        authorName: String,
        onSave: @escaping (Tradition) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.existingTradition = existingTradition
        self.authorId = authorId
        self.authorName = authorName
        self.onSave = onSave
        self.onCancel = onCancel
        _title = State(initialValue: existingTradition?.title ?? "")
        _description = State(initialValue: existingTradition?.description ?? "")
        _imageURL = State(initialValue: existingTradition?.imageURL ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(localized("Tradition", language: viewModel.language)) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                }
                Section(localized("Photo", language: viewModel.language)) {
                    TextField("Image URL", text: $imageURL, axis: .vertical)
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Text("Choose from Photos")
                    }
                    Text(selectedImageData == nil ? "No device photo selected" : "Device photo selected")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(existingTradition == nil ? localized("Share Tradition", language: viewModel.language) : localized("Edit Tradition", language: viewModel.language))
            .task(id: selectedPhotoItem) {
                guard let selectedPhotoItem else { return }
                if let data = try? await selectedPhotoItem.loadTransferable(type: Data.self) {
                    selectedImageData = data
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            var finalImageURL = imageURL.trimmingCharacters(in: .whitespacesAndNewlines)
                            if let data = selectedImageData, let uploaded = await viewModel.uploadImageData(data, folder: "traditions") {
                                finalImageURL = uploaded
                            }

                            onSave(
                                Tradition(
                                    id: existingTradition?.id ?? UUID().uuidString,
                                    title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                                    authorId: existingTradition?.authorId.isEmpty == false ? existingTradition!.authorId : authorId,
                                    authorName: existingTradition?.authorName.isEmpty == false ? existingTradition!.authorName : authorName,
                                    description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                                    imageURL: finalImageURL,
                                    reactions: existingTradition?.reactions ?? [:],
                                    comments: existingTradition?.comments ?? [],
                                    status: existingTradition?.status ?? viewModel.newContentStatus,
                                    timestamp: existingTradition?.timestamp ?? .now
                                )
                            )
                        }
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

private struct DiscussionEditorSheet: View {
    @Bindable var viewModel: AppViewModel
    let authorId: String
    let authorName: String
    let onSave: (DiscussionThread) -> Void
    let onCancel: () -> Void

    @State private var title = ""
    @State private var content = ""
    @State private var kind: DiscussionKind = .text
    @State private var pollOptionOne = ""
    @State private var pollOptionTwo = ""
    @State private var pollOptionThree = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Discussion") {
                    TextField("Title", text: $title)
                    TextField("Message", text: $content, axis: .vertical)
                        .lineLimit(3...8)
                    Picker("Type", selection: $kind) {
                        Text("Text").tag(DiscussionKind.text)
                        Text("Image").tag(DiscussionKind.image)
                        Text("Poll").tag(DiscussionKind.poll)
                    }
                }

                if kind == .poll {
                    Section("Poll Options") {
                        TextField("Option 1", text: $pollOptionOne)
                        TextField("Option 2", text: $pollOptionTwo)
                        TextField("Option 3", text: $pollOptionThree)
                    }
                }
            }
            .navigationTitle("New Discussion")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") {
                        onSave(
                            DiscussionThread(
                                id: UUID().uuidString,
                                userId: authorId,
                                userName: authorName,
                                type: kind,
                                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                                content: content.trimmingCharacters(in: .whitespacesAndNewlines),
                                pollOptions: pollOptions,
                                timestamp: .now,
                                status: viewModel.newContentStatus,
                                comments: []
                            )
                        )
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || (kind == .poll && pollOptions.count < 2))
                }
            }
        }
    }

    private var pollOptions: [PollOption] {
        [pollOptionOne, pollOptionTwo, pollOptionThree]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { PollOption(id: UUID().uuidString, text: $0, voterIds: []) }
    }
}

private struct MilestoneEditorSheet: View {
    @Bindable var viewModel: AppViewModel
    let existingMilestone: Milestone?
    let authorId: String
    let authorName: String
    let onSave: (Milestone) -> Void
    let onCancel: () -> Void

    @State private var title: String
    @State private var description: String
    @State private var year: String
    @State private var imageURL: String
    @State private var audioURL: String
    @State private var location: String
    @State private var visibilityType: String
    @State private var familyContextId: String
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var isAudioImporterPresented = false
    @State private var selectedAudioData: Data?
    @State private var selectedAudioFileExtension = "m4a"

    init(
        viewModel: AppViewModel,
        existingMilestone: Milestone?,
        authorId: String,
        authorName: String,
        onSave: @escaping (Milestone) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.existingMilestone = existingMilestone
        self.authorId = authorId
        self.authorName = authorName
        self.onSave = onSave
        self.onCancel = onCancel
        _title = State(initialValue: existingMilestone?.title ?? "")
        _description = State(initialValue: existingMilestone?.description ?? "")
        _year = State(initialValue: existingMilestone?.year ?? "")
        _imageURL = State(initialValue: existingMilestone?.imageURL ?? "")
        _audioURL = State(initialValue: existingMilestone?.audioURL ?? "")
        _location = State(initialValue: existingMilestone?.location ?? "")
        _visibilityType = State(initialValue: existingMilestone?.visibilityType ?? "GLOBAL")
        _familyContextId = State(initialValue: existingMilestone?.familyContextId ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(localized("Milestone", language: viewModel.language)) {
                    TextField("Title", text: $title)
                    TextField("Year", text: $year)
                    TextField("Location", text: $location)
                    TextField("Description", text: $description, axis: .vertical)
                }
                Section("Visibility") {
                    Picker("Visibility", selection: $visibilityType) {
                        Text("Global").tag("GLOBAL")
                        Text("Private Family").tag("PRIVATE_FAMILY")
                        Text("Old Is Gold").tag("OLD_IS_GOLD")
                    }
                    TextField("Family Context ID", text: $familyContextId)
                }
                Section(localized("Photo", language: viewModel.language)) {
                    TextField("Image URL", text: $imageURL, axis: .vertical)
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Text("Choose from Photos")
                    }
                    Text(selectedImageData == nil ? "No device photo selected" : "Device photo selected")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Section(localized("Audio", language: viewModel.language)) {
                    TextField(localized("Audio URL", language: viewModel.language), text: $audioURL, axis: .vertical)
                    Button(localized("Choose Audio", language: viewModel.language)) {
                        isAudioImporterPresented = true
                    }
                    Text(selectedAudioData == nil ? localized("No audio selected", language: viewModel.language) : localized("Audio selected", language: viewModel.language))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if !audioURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        AudioPlayerWidget(urlString: audioURL.trimmingCharacters(in: .whitespacesAndNewlines), language: viewModel.language)
                    }
                }
            }
            .navigationTitle(existingMilestone == nil ? localized("Add Milestone", language: viewModel.language) : localized("Edit Milestone", language: viewModel.language))
            .task(id: selectedPhotoItem) {
                guard let selectedPhotoItem else { return }
                if let data = try? await selectedPhotoItem.loadTransferable(type: Data.self) {
                    selectedImageData = data
                }
            }
            .fileImporter(isPresented: $isAudioImporterPresented, allowedContentTypes: [.audio]) { result in
                guard case let .success(url) = result else { return }
                let didAccess = url.startAccessingSecurityScopedResource()
                defer {
                    if didAccess {
                        url.stopAccessingSecurityScopedResource()
                    }
                }
                if let data = try? Data(contentsOf: url) {
                    selectedAudioData = data
                    selectedAudioFileExtension = url.pathExtension.isEmpty ? "m4a" : url.pathExtension
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            var finalImageURL = imageURL.trimmingCharacters(in: .whitespacesAndNewlines)
                            if let data = selectedImageData, let uploaded = await viewModel.uploadImageData(data, folder: "memorylane") {
                                finalImageURL = uploaded
                            }
                            var finalAudioURL = audioURL.trimmingCharacters(in: .whitespacesAndNewlines)
                            if let data = selectedAudioData,
                               let uploaded = await viewModel.uploadAudioData(data, folder: "audio", fileExtension: selectedAudioFileExtension) {
                                finalAudioURL = uploaded
                            }

                            onSave(
                                Milestone(
                                    id: existingMilestone?.id ?? UUID().uuidString,
                                    title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                                    description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                                    year: year.trimmingCharacters(in: .whitespacesAndNewlines),
                                    imageURL: finalImageURL,
                                    audioURL: finalAudioURL,
                                    location: location.trimmingCharacters(in: .whitespacesAndNewlines),
                                    timestamp: existingMilestone?.timestamp ?? .now,
                                    authorId: existingMilestone?.authorId.isEmpty == false ? existingMilestone!.authorId : authorId,
                                    authorName: existingMilestone?.authorName.isEmpty == false ? existingMilestone!.authorName : authorName,
                                    visibilityType: visibilityType,
                                    familyContextId: familyContextId.trimmingCharacters(in: .whitespacesAndNewlines),
                                    reactions: existingMilestone?.reactions ?? [:],
                                    comments: existingMilestone?.comments ?? [],
                                    status: existingMilestone?.status ?? viewModel.newContentStatus
                                )
                            )
                        }
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

private struct FamilyEventRow: View {
    let event: DashboardFamilyEvent
    let language: AppLanguage
    var onGenerateCard: (() -> Void)?

    private var member: Member {
        event.member
    }

    var body: some View {
        eventRow
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .background(Color.white.opacity(0.84), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }

    private var eventRow: some View {
        HStack(spacing: 12) {
            AvatarView(member: member, size: 38)

            VStack(alignment: .leading, spacing: 2) {
                Text(member.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AndroidLook.deepBrown)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                Text(eventTitle)
                    .font(.caption)
                    .foregroundStyle(AndroidLook.mutedBrown)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .layoutPriority(1)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .trailing, spacing: 6) {
                Text(daysText)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AndroidLook.deepBrown)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)

                Text(secondaryText)
                    .font(.caption)
                    .foregroundStyle(AndroidLook.mutedBrown)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                if canGenerateCard, let onGenerateCard {
                    aiCardButton(action: onGenerateCard)
                }
            }
            .frame(width: 82, alignment: .trailing)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func aiCardButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "sparkles")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color(red: 0.29, green: 0.08, blue: 0.55))
                .frame(width: 42, height: 34)
                .background(Color(red: 0.88, green: 0.75, blue: 0.93), in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(localized("Generate Card", language: language))
    }

    private var canGenerateCard: Bool {
        event.type == .birthday || event.type == .anniversary
    }

    private var daysText: String {
        switch event.daysUntil {
        case 0:
            return localized("Today", language: language)
        case 1:
            return localized("Tomorrow", language: language)
        default:
            return "\(event.daysUntil) \(localized("days", language: language))"
        }
    }

    private var eventTitle: String {
        switch event.type {
        case .birthday:
            return localized("Birth Anniversary", language: language)
        case .anniversary:
            return localized("Anniversary", language: language)
        case .remembrance:
            return localized("Punya Tithi", language: language)
        }
    }

    private var secondaryText: String {
        if event.type == .birthday, let age = member.turnsAge() {
            return "\(localized("Turns", language: language)) \(age)"
        }
        return event.date.formatted(.dateTime.day().month(.abbreviated))
    }
}

private struct FamilyAIAssistant: View {
    @Bindable var viewModel: AppViewModel
    let keyboardBottomInset: CGFloat
    @State private var isOpen = false
    @State private var draft = ""
    @State private var messages: [AssistantMessage] = [
        AssistantMessage(text: "Hello! I'm your Purawale AI. Ask me anything about the family directory.", isUser: false)
    ]
    @State private var assistantContext = AssistantConversationContext()

    var body: some View {
        GeometryReader { proxy in
            let panelWidth = min(340, max(280, proxy.size.width - 28))
            let verticalChrome: CGFloat = 118
            let availablePanelHeight = max(
                220,
                proxy.size.height - keyboardBottomInset - proxy.safeAreaInsets.top - 28
            )
            let messageListHeight = max(104, min(260, availablePanelHeight - verticalChrome))

            VStack(alignment: .leading, spacing: 10) {
                if isOpen {
                    VStack(spacing: 0) {
                        HStack {
                            Label(localized("Family AI Assistant", language: viewModel.language), systemImage: "sparkles")
                                .font(.subheadline.weight(.bold))
                            Spacer()
                            Button {
                                isOpen = false
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.caption.weight(.bold))
                            }
                            .buttonStyle(.plain)
                        }
                        .foregroundStyle(.white)
                        .padding(12)
                        .background(AndroidLook.deepBrown)

                        ScrollViewReader { scrollProxy in
                            ScrollView {
                                VStack(spacing: 8) {
                                    ForEach(messages) { message in
                                        AssistantBubble(message: message)
                                            .id(message.id)
                                    }
                                }
                                .padding(12)
                            }
                            .frame(height: messageListHeight)
                            .onAppear {
                                if let last = messages.last {
                                    scrollProxy.scrollTo(last.id, anchor: .bottom)
                                }
                            }
                            .onChange(of: messages.count) { _, _ in
                                if let last = messages.last {
                                    scrollProxy.scrollTo(last.id, anchor: .bottom)
                                }
                            }
                        }

                        HStack(spacing: 8) {
                            TextField(localized("Ask a question...", language: viewModel.language), text: $draft, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .lineLimit(1...3)

                            Button {
                                send()
                            } label: {
                                Image(systemName: "paperplane.fill")
                                    .frame(width: 34, height: 34)
                            }
                            .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            .buttonStyle(.borderedProminent)
                            .tint(AndroidLook.accentGold)
                        }
                        .padding(10)
                    }
                    .frame(width: panelWidth)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(Color.white.opacity(0.40), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.20), radius: 18, x: 0, y: 10)
                } else {
                    Button {
                        isOpen = true
                    } label: {
                        Image(systemName: "sparkles")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(AndroidLook.deepBrown)
                            .frame(width: 54, height: 54)
                            .background(AndroidLook.accentGold, in: Circle())
                            .shadow(color: .black.opacity(0.18), radius: 12, x: 0, y: 6)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(localized("AI Assistant", language: viewModel.language))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
    }

    private func send() {
        let question = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty else { return }
        draft = ""
        messages.append(AssistantMessage(text: question, isUser: true))
        messages.append(AssistantMessage(text: answer(for: question), isUser: false))
    }

    private func answer(for question: String) -> String {
        let lower = question.lowercased()
        let members = viewModel.allResolvedMembers
        if isAssistantGreeting(lower) {
            assistantContext.reset()
            return "Hi! Ask me about birthdays, anniversaries, profile details, locations, phone numbers, family relationships, or counts from the saved family directory."
        }

        if let selfMatch = currentUserMatch(in: members), isSelfReferenceQuestion(lower) {
            assistantContext.rememberResolved(selfMatch)
            return answerForSelfQuestion(lower, match: selfMatch, members: members)
        }

        let directMatches = findMemberMatches(question: question, members: members)
        let selectedPendingMatch = assistantContext.matchFromPendingSelection(question)
        let usesPreviousContext = directMatches.isEmpty && selectedPendingMatch == nil && isAssistantFollowUpQuestion(lower)
        let matches = selectedPendingMatch.map { [$0] }
            ?? (usesPreviousContext ? assistantContext.lastMatches : directMatches)

        if let directoryAnswer = AssistantDirectoryQuery.answer(
            question: lower,
            members: members,
            matchedMembers: directMatches.map(\.member)
        ) {
            return directoryAnswer
        }

        if isBirthdayQuestion(lower) {
            if matches.count > 1 {
                assistantContext.remember(matches)
                let options = matches.map { match in
                    let date = shortDisplayDate(match.member.dateOfBirth) ?? "birthday not saved"
                    return "- \(match.member.name) (\(match.member.familyId)) - \(date)"
                }
                .joined(separator: "\n")
                return "I found multiple matching people. Which one do you mean?\n\(options)"
            }

            guard let match = matches.first else {
                return "Tell me the name too, and I can look up the saved birthday."
            }
            assistantContext.rememberResolved(match)
            let member = match.member
            let date = shortDisplayDate(member.dateOfBirth) ?? "not saved"
            let prefix = assistantContextPrefix(match: match, usesPreviousContext: usesPreviousContext)
            return "\(prefix)\(member.name)'s birthday is \(date)."
        }

        if isAnniversaryQuestion(lower) {
            if matches.count > 1 {
                assistantContext.remember(matches)
                let options = matches.map { match in
                    let date = shortDisplayDate(match.member.marriageDate) ?? "anniversary not saved"
                    return "- \(match.member.name) (\(match.member.familyId)) - \(date)"
                }
                .joined(separator: "\n")
                return "I found multiple matching people. Which one do you mean?\n\(options)"
            }

            guard let match = matches.first else {
                return "Tell me the couple or member name, and I can check the saved anniversary."
            }
            assistantContext.rememberResolved(match)
            let member = match.member
            let date = shortDisplayDate(member.marriageDate) ?? "not saved"
            let prefix = assistantContextPrefix(match: match, usesPreviousContext: usesPreviousContext)
            return "\(prefix)\(member.name)'s anniversary is \(date)."
        }

        if matches.isEmpty, lower.contains("today") {
            let names = viewModel.todayEvents.prefix(6).map { "\($0.member.name): \($0.type.rawValue)" }
            return names.isEmpty ? "No family birthdays, anniversaries, or remembrance events are listed for today." : "Today: " + names.joined(separator: ", ")
        }

        if matches.isEmpty, lower.contains("upcoming") || lower.contains("next") {
            let names = viewModel.upcomingEvents.prefix(6).map { "\($0.member.name) in \($0.daysUntil) days" }
            return names.isEmpty ? "Nothing is listed in the next 7 days." : "Coming up: " + names.joined(separator: ", ")
        }

        if matches.isEmpty, lower.contains("members") || lower.contains("count") {
            return "There are \(viewModel.activeMembers.count) approved active members, \(viewModel.pendingCount) pending profiles, and \(viewModel.visibleChannels.count) chat threads visible to you."
        }

        if matches.isEmpty, isRelationshipQuestion(lower) {
            return "Tell me the person's name too, and I can explain the relationship using RelationshipRules.md."
        }

        if matches.count > 1 {
            assistantContext.remember(matches)
            let options = matches.map { "- \(AssistantDirectoryQuery.memberChoiceLine($0.member))" }.joined(separator: "\n")
            return "I found multiple matching people. Which one do you mean?\n\(options)"
        }

        if let match = matches.first {
            if usesPreviousContext && !isAssistantContextReuseQuestion(lower) {
                return "Tell me the person’s name or the detail you want, and I’ll look it up from the saved family directory."
            }

            assistantContext.rememberResolved(match)
            let member = match.member
            let prefix = assistantContextPrefix(match: match, usesPreviousContext: usesPreviousContext)

            if isLocationQuestion(lower) {
                let location = member.location?.isEmpty == false ? member.location! : "not saved"
                return "\(prefix)\(member.name)'s location is \(location)."
            }

            if isPhoneQuestion(lower) {
                let phone = member.phoneNumber.isEmpty ? "not saved" : member.phoneNumber
                return "\(prefix)\(member.name)'s phone number is \(phone)."
            }

            if isRelationshipQuestion(lower) {
                return prefix + relationshipAnswer(for: member, members: members)
            }

            let relation = member.relationship
                ?? viewModel.currentUser.flatMap { FamilyUtils.getRelationship(target: member, observer: $0, allMembers: members) }
                ?? "a family member"
            let location = member.location?.isEmpty == false ? " They are listed in \(member.location!)." : ""
            return "\(prefix)\(member.name) is \(relation). Family ID: \(member.familyId).\(location)"
        }

        return "I can answer from the local family directory: birthdays, birth years, anniversaries, today/upcoming events, member counts, locations, profile matches, and relationships. Try asking “how many people were born in 1985?” or a person’s name."
    }

    private func currentUserMatch(in members: [Member]) -> AssistantMemberMatch? {
        guard let currentUser = viewModel.currentUser else { return nil }
        let resolvedUser = members.first { $0.id == currentUser.id } ?? currentUser
        return AssistantMemberMatch(member: resolvedUser, score: 200, isFuzzy: false)
    }

    private func answerForSelfQuestion(_ question: String, match: AssistantMemberMatch, members: [Member]) -> String {
        let member = match.member

        if isBirthdayQuestion(question) {
            let date = shortDisplayDate(member.dateOfBirth) ?? "not saved"
            return "Your birthday is \(date)."
        }

        if isAnniversaryQuestion(question) {
            let date = shortDisplayDate(member.marriageDate) ?? "not saved"
            return "Your anniversary is \(date)."
        }

        if isLocationQuestion(question) {
            let location = member.location?.isEmpty == false ? member.location! : "not saved"
            return "Your location is \(location)."
        }

        if isPhoneQuestion(question) {
            let phone = member.phoneNumber.isEmpty ? "not saved" : member.phoneNumber
            return "Your phone number is \(phone)."
        }

        if isRelationshipQuestion(question) {
            return relationshipAnswer(for: member, members: members)
        }

        return selfProfileSummary(member)
    }

    private func selfProfileSummary(_ member: Member) -> String {
        var details = ["You are \(member.name)."]
        details.append("Family ID: \(member.familyId).")

        if let fatherName = member.fatherName, !fatherName.isEmpty {
            details.append("Father: \(fatherName).")
        }
        if let motherName = member.motherName, !motherName.isEmpty {
            details.append("Mother: \(motherName).")
        }
        if let spouseName = member.spouseName, !spouseName.isEmpty {
            details.append("Spouse: \(spouseName).")
        }
        if let birthday = shortDisplayDate(member.dateOfBirth) {
            details.append("Birthday: \(birthday).")
        }
        if !member.phoneNumber.isEmpty {
            details.append("Mobile: \(member.phoneNumber).")
        }
        if let email = member.email, !email.isEmpty {
            details.append("Email: \(email).")
        }
        if let location = member.location, !location.isEmpty {
            details.append("Location: \(location).")
        }
        if member.isAdmin {
            details.append("You have admin access.")
        } else if member.isEditor {
            details.append("You have editor access.")
        }

        return details.joined(separator: " ")
    }

    private func assistantContextPrefix(match: AssistantMemberMatch, usesPreviousContext: Bool) -> String {
        if usesPreviousContext { return "Using the previous person, \(match.member.name): " }
        if match.isFuzzy { return "Closest match: \(match.member.name). " }
        return ""
    }

    private func relationshipAnswer(for member: Member, members: [Member]) -> String {
        guard let currentUser = viewModel.currentUser else {
            return "\(member.name)'s relationship needs a logged-in user as the point of view."
        }

        let resolvedObserver = members.first { $0.id == currentUser.id } ?? currentUser
        if member.id == resolvedObserver.id {
            let rule = RelationshipRulesGuide.rule(for: "Self")
            return "You are viewing your own profile. \(rule)"
        }

        let inferredRelation = FamilyUtils.getRelationship(target: member, observer: resolvedObserver, allMembers: members)
        let relation = member.manualRelationships[resolvedObserver.id]
            ?? inferredRelation
            ?? member.relationship
            ?? "not saved"

        guard relation != "not saved" else {
            return "I could not infer \(member.name)'s relationship from the saved family IDs yet. Please check their family ID, parents, spouse link, and gender."
        }

        let rule = RelationshipRulesGuide.rule(for: relation)
        let path = RelationshipRulesGuide.pathExplanation(target: member, observer: resolvedObserver)
        return "\(member.name) is \(relation) to \(resolvedObserver.name). \(path) Rule used: \(rule)"
    }
}

private enum RelationshipRulesGuide {
    private static let fallbackMarkdown = """
    # Relationship Rules

    ## Family ID Convention

    - A single base family ID such as `A` can be the root person.
    - A spouse is represented by adding `0` to the partner's family ID.
    - Children extend the parent's base family ID by one branch character.
    - Siblings usually share the same parent base and have IDs at the same depth.
    - Older and younger labels are inferred from birth date when available, otherwise by branch order.
    - Relationship answers are from the current logged-in user's point of view unless the question explicitly asks otherwise.

    ## Relationship Labels

    ### Self
    Use when the target is the current user. Say that this is the user's own profile.
    """

    static func rule(for relation: String) -> String {
        let normalizedRelation = normalizeHeading(relation)
        guard let section = relationshipSections()[normalizedRelation] else {
            return "The app compares family IDs, spouse suffixes, gender, and generation distance using RelationshipRules.md."
        }
        return section
    }

    static func pathExplanation(target: Member, observer: Member) -> String {
        let targetBase = baseFamilyId(target.familyId)
        let observerBase = baseFamilyId(observer.familyId)
        let targetSpouseNote = target.familyId.hasSuffix("0") ? " \(target.name) is stored as a spouse profile." : ""
        let observerSpouseNote = observer.familyId.hasSuffix("0") ? " Your profile is stored as a spouse profile." : ""

        if targetBase == observerBase {
            return "Both profiles share base family ID \(targetBase), so this is a spouse/same-household relation.\(targetSpouseNote)\(observerSpouseNote)"
        }

        let targetDepth = generationDepth(targetBase)
        let observerDepth = generationDepth(observerBase)
        let diff = observerDepth - targetDepth
        let direction: String
        if diff > 0 {
            direction = "\(target.name) is \(diff) generation\(diff == 1 ? "" : "s") above \(observer.name)."
        } else if diff < 0 {
            let distance = abs(diff)
            direction = "\(target.name) is \(distance) generation\(distance == 1 ? "" : "s") below \(observer.name)."
        } else {
            direction = "\(target.name) and \(observer.name) are in the same generation."
        }

        let shared = sharedPrefixDescription(targetBase: targetBase, observerBase: observerBase)
        return "\(direction) \(shared)\(targetSpouseNote)\(observerSpouseNote)"
    }

    private static func relationshipSections() -> [String: String] {
        parseSections(from: markdown)
    }

    private static var markdown: String {
        if let url = Bundle.main.url(forResource: "RelationshipRules", withExtension: "md"),
           let contents = try? String(contentsOf: url, encoding: .utf8) {
            return contents
        }
        return fallbackMarkdown
    }

    private static func parseSections(from markdown: String) -> [String: String] {
        var sections: [String: String] = [:]
        var currentHeading: String?
        var lines: [String] = []

        func flush() {
            guard let currentHeading else { return }
            let body = lines
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .joined(separator: " ")
            if !body.isEmpty {
                sections[normalizeHeading(currentHeading)] = body
            }
        }

        for line in markdown.components(separatedBy: .newlines) {
            if line.hasPrefix("### ") {
                flush()
                currentHeading = String(line.dropFirst(4)).trimmingCharacters(in: .whitespacesAndNewlines)
                lines = []
            } else if currentHeading != nil {
                lines.append(line)
            }
        }
        flush()
        return sections
    }

    private static func normalizeHeading(_ value: String) -> String {
        value.lowercased()
            .replacingOccurrences(of: " ", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func baseFamilyId(_ familyId: String) -> String {
        let normalizedId = familyId.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        return normalizedId.hasSuffix("0") ? String(normalizedId.dropLast()) : normalizedId
    }

    private static func generationDepth(_ baseId: String) -> Int {
        if baseId.isEmpty { return 0 }
        return max(0, baseId.count - 1)
    }

    private static func sharedPrefixDescription(targetBase: String, observerBase: String) -> String {
        guard !targetBase.isEmpty, !observerBase.isEmpty else {
            return "One of the profiles is missing a family ID, so the explanation may be incomplete."
        }

        let shared = String(zip(targetBase, observerBase).prefix { $0 == $1 }.map(\.0))
        if shared.isEmpty {
            return "Their family IDs are on different top-level branches."
        }
        if targetBase.hasPrefix(observerBase) {
            return "The target branch starts from your branch (\(observerBase) -> \(targetBase))."
        }
        if observerBase.hasPrefix(targetBase) {
            return "Your branch starts from the target branch (\(targetBase) -> \(observerBase))."
        }
        return "They share branch prefix \(shared), then split into separate family branches."
    }
}

private enum AssistantDirectoryQuery {
    static func answer(question: String, members: [Member], matchedMembers: [Member]) -> String? {
        if let year = birthYearQuestion(in: question) {
            return answerBirthYearQuery(question: question, year: year, members: members)
        }

        if isProfileMatchListQuestion(question), !matchedMembers.isEmpty {
            return answerProfileMatchQuery(matches: matchedMembers)
        }

        if isGeneralDirectoryHelpQuestion(question) {
            return "\(rule(for: "Profile Count Queries")) Examples: “how many people born in 1985?”, “who was born in 1985?”, “find people in Indore”, or “show profile for Amit”."
        }

        return nil
    }

    static func memberChoiceLine(_ member: Member) -> String {
        let birthday = shortDisplayDate(member.dateOfBirth) ?? "DOB not saved"
        let relation = clean(member.relationship) ?? "relationship not set"
        let location = clean(member.location).map { " - \($0)" } ?? ""
        return "\(member.name) (\(member.familyId)) - \(birthday) - \(relation)\(location)"
    }

    private static func answerBirthYearQuery(question: String, year: Int, members: [Member]) -> String {
        let matches = members
            .filter { birthYear($0) == year }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

        let guidance = rule(for: "Birth Year Queries")
        guard !matches.isEmpty else {
            return "No saved profiles match birth year \(year). \(guidance)"
        }

        let lines = matches.prefix(12).map { "- \(memberChoiceLine($0))" }.joined(separator: "\n")
        let more = matches.count > 12 ? "\n…and \(matches.count - 12) more." : ""

        if isCountQuestion(question) {
            let sample = matches.prefix(6).map(\.name).joined(separator: ", ")
            return "\(matches.count) people were born in \(year). Sample: \(sample). \(guidance)"
        }

        return "\(matches.count) people were born in \(year):\n\(lines)\(more)\n\(guidance)"
    }

    private static func answerProfileMatchQuery(matches: [Member]) -> String {
        let sorted = matches.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        let lines = sorted.prefix(10).map { "- \(memberChoiceLine($0))" }.joined(separator: "\n")
        let more = sorted.count > 10 ? "\n…and \(sorted.count - 10) more." : ""
        return "Profile matches from cached member data:\n\(lines)\(more)\n\(rule(for: "Name and Profile Matching"))"
    }

    private static func birthYearQuestion(in question: String) -> Int? {
        guard ["born", "birth", "birthday", "dob", "janam", "जन्म"].contains(where: { question.contains($0) }) else {
            return nil
        }
        return years(in: question).first
    }

    private static func years(in question: String) -> [Int] {
        question
            .components(separatedBy: CharacterSet.decimalDigits.inverted)
            .compactMap { Int($0) }
            .filter { (1900...Calendar.current.component(.year, from: .now)).contains($0) }
    }

    private static func birthYear(_ member: Member) -> Int? {
        guard let date = member.birthDateValue else { return nil }
        return Calendar.current.component(.year, from: date)
    }

    private static func isCountQuestion(_ question: String) -> Bool {
        ["how many", "count", "number of", "kitne", "kitni"].contains { question.contains($0) }
    }

    private static func isProfileMatchListQuestion(_ question: String) -> Bool {
        ["find", "search", "match", "matches", "list", "show profiles", "profile matches"].contains { question.contains($0) }
    }

    private static func isGeneralDirectoryHelpQuestion(_ question: String) -> Bool {
        ["what can you answer", "what questions", "query examples", "guidelines"].contains { question.contains($0) }
    }

    private static func rule(for heading: String) -> String {
        AssistantMarkdownGuide.section(named: heading, resource: "AssistantQueryGuidelines")
            ?? "Using AssistantQueryGuidelines.md, the assistant answers from cached profile data and does not invent missing fields."
    }

    private static func clean(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? nil : trimmed
    }
}

private enum AssistantMarkdownGuide {
    static func section(named heading: String, resource: String) -> String? {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "md"),
              let markdown = try? String(contentsOf: url, encoding: .utf8) else {
            return nil
        }
        return sections(in: markdown)[normalize(heading)]
    }

    private static func sections(in markdown: String) -> [String: String] {
        var sections: [String: String] = [:]
        var currentHeading: String?
        var lines: [String] = []

        func flush() {
            guard let currentHeading else { return }
            let body = lines
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .joined(separator: " ")
            if !body.isEmpty {
                sections[normalize(currentHeading)] = body
            }
        }

        for line in markdown.components(separatedBy: .newlines) {
            if line.hasPrefix("## ") {
                flush()
                currentHeading = String(line.dropFirst(3)).trimmingCharacters(in: .whitespacesAndNewlines)
                lines = []
            } else if currentHeading != nil {
                lines.append(line)
            }
        }
        flush()
        return sections
    }

    private static func normalize(_ value: String) -> String {
        value.lowercased()
            .replacingOccurrences(of: " ", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private struct AssistantMemberMatch {
    let member: Member
    let score: Int
    let isFuzzy: Bool
}

private struct AssistantConversationContext {
    var lastMatches: [AssistantMemberMatch] = []
    var pendingMatches: [AssistantMemberMatch] = []

    mutating func reset() {
        lastMatches = []
        pendingMatches = []
    }

    mutating func remember(_ matches: [AssistantMemberMatch]) {
        lastMatches = matches
        pendingMatches = matches
    }

    mutating func rememberResolved(_ match: AssistantMemberMatch) {
        lastMatches = [match]
        pendingMatches = []
    }

    func matchFromPendingSelection(_ question: String) -> AssistantMemberMatch? {
        guard !pendingMatches.isEmpty else { return nil }
        let normalized = question.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let index: Int?
        if normalized.contains("first") || normalized == "1" || normalized.contains("1st") {
            index = 0
        } else if normalized.contains("second") || normalized == "2" || normalized.contains("2nd") {
            index = 1
        } else if normalized.contains("third") || normalized == "3" || normalized.contains("3rd") {
            index = 2
        } else if normalized.contains("fourth") || normalized == "4" || normalized.contains("4th") {
            index = 3
        } else if normalized.contains("fifth") || normalized == "5" || normalized.contains("5th") {
            index = 4
        } else {
            index = nil
        }
        guard let index, pendingMatches.indices.contains(index) else { return nil }
        return pendingMatches[index]
    }
}

private let assistantIgnoredQuestionWords: Set<String> = [
    "a", "an", "and", "are", "birth", "birthday", "bday", "dob", "date", "day", "of", "on", "the",
    "is", "when", "what", "whats", "who", "whose", "tell", "me", "show", "for", "ka", "ki", "ke",
    "hai", "kab", "kya", "please", "pls", "anniversary", "marriage", "wedding", "shaadi", "vivah",
    "his", "her", "their", "he", "she", "they", "them", "that", "this", "same", "person", "one",
    "profile", "profiles", "member", "members", "about", "details", "detail", "info", "information",
    "location", "city", "where", "live", "lives", "living", "from", "relation", "relationship",
    "phone", "mobile", "number", "contact", "family", "id", "age", "old", "born", "year", "years",
    "people", "find", "search", "match", "matches", "list"
]

private let assistantIgnoredRelationshipWords: Set<String> = [
    "bhai", "bhaiya", "bhaiyaa", "dada", "dadaji", "dadi", "dadiji", "didi", "behan", "bhabhi",
    "jijaji", "kaka", "kakaji", "kaki", "chacha", "chachaji", "chachi", "mama", "mamaji", "mami",
    "mausa", "mausaji", "mausi", "bua", "fufa", "fufaji", "papa", "mummy", "beta", "beti",
    "uncle", "aunty", "ji", "sir", "badi", "bade", "choti", "chote", "chota", "bada",
    "nanad", "saala", "saali", "sasur", "sasurji", "saas", "saasuma", "devar", "jeth",
    "pota", "poti", "nati", "natin", "bahu", "damad", "damand", "bhatija", "bhatiji",
    "bhanja", "bhanji"
]

private func searchableAssistantWords(_ text: String) -> [String] {
    text.lowercased()
        .components(separatedBy: CharacterSet.alphanumerics.inverted)
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter {
            $0.count > 1
                && !assistantIgnoredQuestionWords.contains($0)
                && !assistantIgnoredRelationshipWords.contains($0)
        }
}

private func isBirthdayQuestion(_ question: String) -> Bool {
    ["birthday", "bday", "dob", "date of birth", "janam", "janmadin", "जन्म"].contains { question.contains($0) }
}

private func isAnniversaryQuestion(_ question: String) -> Bool {
    ["anniversary", "marriage", "wedding", "shaadi", "vivah", "सालगिरह"].contains { question.contains($0) }
}

private func isLocationQuestion(_ question: String) -> Bool {
    ["location", "city", "where", "live", "lives", "living", "from"].contains { question.contains($0) }
}

private func isPhoneQuestion(_ question: String) -> Bool {
    ["phone", "mobile", "number", "contact"].contains { question.contains($0) }
}

private func isRelationshipQuestion(_ question: String) -> Bool {
    let directRelationshipPhrases = [
        "relation", "relationship", "related", "rishta", "rishte", "kaun",
        "who is", "who's", "to me", "mere kya", "meri kya", "mera kya",
        "how is", "how are"
    ]
    if directRelationshipPhrases.contains(where: { question.contains($0) }) {
        return true
    }

    let normalized = " \(question.lowercased()) "
    guard normalized.contains(" my ") || normalized.contains(" meri ") || normalized.contains(" mere ") else {
        return false
    }
    return assistantIgnoredRelationshipWords.contains { word in
        normalized.contains(" \(word) ")
    }
}

private func isAssistantGreeting(_ question: String) -> Bool {
    let normalized = question
        .lowercased()
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .trimmingCharacters(in: CharacterSet(charactersIn: ".!,?"))
    return [
        "hi", "hii", "hiii", "hello", "hey", "namaste", "namaskar", "good morning",
        "good afternoon", "good evening", "नमस्ते", "नमस्कार"
    ].contains(normalized)
}

private func isSelfReferenceQuestion(_ question: String) -> Bool {
    let normalized = " \(question.lowercased()) "
    return [
        "who am i",
        "who i am",
        "about me",
        "my profile",
        "my details",
        "my info",
        "my information",
        "my birthday",
        "my bday",
        "my dob",
        "my anniversary",
        "my phone",
        "my mobile",
        "my number",
        "my contact",
        "my location",
        "my city",
        "where do i live",
        "where am i",
        "my relationship",
        "mera",
        "meri",
        "mujhe",
        "main kaun"
    ].contains { normalized.contains($0) }
}

private func isAssistantFollowUpQuestion(_ question: String) -> Bool {
    let words = searchableAssistantWords(question)
    if words.isEmpty {
        return isAssistantContextReuseQuestion(question)
    }
    guard isAssistantContextReuseQuestion(question) else { return false }
    return [
        "his", "her", "their", "he", "she", "they", "them", "same", "that person", "this person",
        "what about", "and ", "also", "where", "location", "birthday", "anniversary", "relation",
        "relationship", "phone", "contact"
    ].contains { question.contains($0) }
}

private func isAssistantContextReuseQuestion(_ question: String) -> Bool {
    [
        "his", "her", "their", "he", "she", "they", "them", "same", "that person", "this person",
        "what about", "and ", "also", "where", "location", "birthday", "anniversary", "relation",
        "relationship", "phone", "contact", "number", "city", "age", "details", "profile"
    ].contains { question.contains($0) }
}

private func findMemberMatches(question: String, members: [Member]) -> [AssistantMemberMatch] {
    let queryWords = searchableAssistantWords(question)
    guard !queryWords.isEmpty else { return [] }
    let joinedQuery = queryWords.joined(separator: " ")
    let familyIdTokens = assistantFamilyIdTokens(in: question)
    if !familyIdTokens.isEmpty {
        let exactFamilyIdMatches = members.filter { member in
            familyIdTokens.contains(normalizedAssistantFamilyId(member.familyId))
        }
        if !exactFamilyIdMatches.isEmpty {
            let nameFilteredMatches = exactFamilyIdMatches.filter { member in
                let nameWords = searchableAssistantWords(member.name)
                return queryWords.contains { query in
                    nameWords.contains(query) || nameWords.contains { $0.hasPrefix(query) }
                }
            }
            let preferredMatches = nameFilteredMatches.isEmpty ? exactFamilyIdMatches : nameFilteredMatches
            return preferredMatches
                .sorted { lhs, rhs in
                    lhs.familyId.localizedStandardCompare(rhs.familyId) == .orderedAscending
                }
                .map { AssistantMemberMatch(member: $0, score: 240, isFuzzy: false) }
        }
    }

    let matches = members.compactMap { member -> AssistantMemberMatch? in
        let nameWords = searchableAssistantWords(member.name)
        let contextWords = [
            member.familyId,
            member.spouseName,
            member.fatherName,
            member.motherName,
            member.relationship,
            member.location,
            member.address
        ]
        .compactMap { $0 }
        .flatMap(searchableAssistantWords)
        let candidateWords = nameWords + contextWords
        let searchableName = nameWords.joined(separator: " ")
        let searchableCandidate = candidateWords.joined(separator: " ")
        guard !candidateWords.isEmpty else { return nil }

        let exactScore: Int
        if searchableName == joinedQuery {
            exactScore = 120
        } else if searchableCandidate == joinedQuery {
            exactScore = 116
        } else if searchableName.contains(joinedQuery) {
            exactScore = 100 + joinedQuery.count
        } else if searchableCandidate.contains(joinedQuery) {
            exactScore = 92 + joinedQuery.count
        } else if queryWords.allSatisfy({ query in candidateWords.contains(query) }) {
            exactScore = 90 + queryWords.count
        } else if queryWords.allSatisfy({ query in candidateWords.contains { $0.hasPrefix(query) } }) {
            exactScore = 75 + queryWords.count
        } else if queryWords.contains(where: { query in candidateWords.contains(query) }) {
            exactScore = 50
        } else if queryWords.contains(where: { query in candidateWords.contains { $0.hasPrefix(query) } }) {
            exactScore = 35
        } else {
            exactScore = 0
        }

        let fuzzyScores = queryWords.map { query in
            nameWords.map { fuzzyWordScore(query: query, candidate: $0) }.max() ?? 0
        }
        let fuzzyScore: Int
        if !fuzzyScores.isEmpty, fuzzyScores.allSatisfy({ $0 > 0 }) {
            fuzzyScore = Int(Double(fuzzyScores.reduce(0, +)) / Double(fuzzyScores.count)) + queryWords.count
        } else {
            fuzzyScore = 0
        }

        let score = max(exactScore, fuzzyScore)
        guard score > 0 else { return nil }
        return AssistantMemberMatch(member: member, score: score, isFuzzy: exactScore == 0 && fuzzyScore > 0)
    }
    .sorted {
        if $0.score == $1.score {
            return $0.member.name < $1.member.name
        }
        return $0.score > $1.score
    }

    guard let bestScore = matches.first?.score else { return [] }
    return Array(matches.filter { $0.score >= bestScore - 12 && $0.score >= 42 }.prefix(5))
}

private func assistantFamilyIdTokens(in question: String) -> Set<String> {
    let rawTokens = question
        .uppercased()
        .components(separatedBy: CharacterSet.alphanumerics.inverted)
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }

    let compactQuestion = rawTokens.joined(separator: " ")
    var tokens = Set(rawTokens.filter { token in
        token.range(of: #"^[A-Z]{1,3}[0-9A-Z]{1,8}$"#, options: .regularExpression) != nil
            && token.rangeOfCharacter(from: .decimalDigits) != nil
    })

    for pair in zip(rawTokens, rawTokens.dropFirst()) {
        if pair.0 == "ID" || pair.0 == "FAMILYID" {
            tokens.insert(pair.1)
        }
    }

    if let range = compactQuestion.range(of: #"FAMILY\s+ID\s+([A-Z0-9]+)"#, options: .regularExpression) {
        let match = String(compactQuestion[range])
        if let id = match.components(separatedBy: .whitespaces).last {
            tokens.insert(id)
        }
    }

    return Set(tokens.map(normalizedAssistantFamilyId).filter { !$0.isEmpty })
}

private func normalizedAssistantFamilyId(_ value: String) -> String {
    value.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
}

private func fuzzyWordScore(query: String, candidate: String) -> Int {
    guard query.count >= 3, candidate.count >= 3 else { return 0 }
    let distance = editDistance(query, candidate)
    let maxLength = max(query.count, candidate.count)
    let similarity = 1.0 - (Double(distance) / Double(maxLength))

    if distance == 1 && maxLength >= 4 { return 68 }
    if distance == 2 && maxLength >= 6 { return 58 }
    if similarity >= 0.78 { return 58 }
    if similarity >= 0.70 && maxLength >= 5 { return 45 }
    return 0
}

private func editDistance(_ lhs: String, _ rhs: String) -> Int {
    if lhs == rhs { return 0 }
    if lhs.isEmpty { return rhs.count }
    if rhs.isEmpty { return lhs.count }

    let a = Array(lhs)
    let b = Array(rhs)
    var previous = Array(0...b.count)
    var current = Array(repeating: 0, count: b.count + 1)

    for i in 1...a.count {
        current[0] = i
        for j in 1...b.count {
            let cost = a[i - 1] == b[j - 1] ? 0 : 1
            current[j] = min(
                current[j - 1] + 1,
                previous[j] + 1,
                previous[j - 1] + cost
            )
        }
        previous = current
    }

    return previous[b.count]
}

private struct AssistantMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

private struct AssistantBubble: View {
    let message: AssistantMessage

    var body: some View {
        HStack {
            if message.isUser { Spacer(minLength: 40) }
            Text(message.text)
                .font(.footnote)
                .foregroundStyle(message.isUser ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(message.isUser ? AndroidLook.softBrown : Color.white.opacity(0.86), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            if !message.isUser { Spacer(minLength: 40) }
        }
    }
}

private struct AICardGeneratorScreen: View {
    @Bindable var viewModel: AppViewModel
    let member: Member
    let eventType: DashboardFamilyEvent.EventType
    @State private var headline: String
    @State private var nameLine: String
    @State private var message: String
    @State private var fromLabel = "With love from"
    @State private var sender = "Purawale - Hum aur Humare"
    @State private var closingLine: String
    @State private var selectedMode: StationeryMode = .sticker
    @State private var selectedStyle = 0
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedCharacterPhotoItem: PhotosPickerItem?
    @State private var selectedCollageItems: [PhotosPickerItem] = []
    @State private var selectedImageData: Data?
    @State private var selectedCharacterImageData: Data?
    @State private var selectedCollagePhotos: [Data] = []
    @State private var photoAdjustments = CardPhotoAdjustments()
    @State private var textSettings = CardTextSettings()
    @State private var aiDirection = "Create a premium transparent PNG cutout sticker with a clean white outline, expressive character pose, Indian family celebration details, crisp readable text, no background."
    @State private var occasion: String
    @State private var stickerConcept = "smiling celebratory character holding flowers and a small cake"
    @State private var decorativeThemeIndex = 0
    @State private var exportURL: URL?
    @State private var exportStatus: String?
    @State private var isPhotoEditorExpanded = false
    @State private var isTextStyleExpanded = false

    init(viewModel: AppViewModel, member: Member, eventType: DashboardFamilyEvent.EventType) {
        self.viewModel = viewModel
        self.member = member
        self.eventType = eventType
        _headline = State(initialValue: eventType == .anniversary ? "Happy Anniversary" : "Happy Birthday")
        _nameLine = State(initialValue: Self.defaultNameLine(for: member, eventType: eventType, members: viewModel.allResolvedMembers))
        _message = State(initialValue: Self.defaultMessage(for: member, eventType: eventType))
        _closingLine = State(initialValue: "We love you \(Self.defaultNameLine(for: member, eventType: eventType, members: viewModel.allResolvedMembers))")
        _occasion = State(initialValue: Self.defaultOccasion(for: eventType))
    }

    private let styles: [GreetingCardStyle] = [
        GreetingCardStyle(
            name: "Ivory",
            assetName: "AICardFrameIvory",
            background: Color(red: 1.0, green: 0.97, blue: 0.91),
            primary: Color(red: 0.48, green: 0.07, blue: 0.11),
            secondary: Color(red: 0.25, green: 0.14, blue: 0.09),
            accent: Color(red: 0.75, green: 0.54, blue: 0.10),
            photoBorder: Color(red: 0.75, green: 0.54, blue: 0.10),
            plate: Color(red: 1.0, green: 0.95, blue: 0.82).opacity(0.90)
        ),
        GreetingCardStyle(
            name: "Burgundy",
            assetName: "AICardFrameBurgundy",
            background: Color(red: 0.35, green: 0.06, blue: 0.08),
            primary: Color(red: 1.0, green: 0.83, blue: 0.48),
            secondary: Color(red: 1.0, green: 0.95, blue: 0.83),
            accent: Color(red: 0.83, green: 0.64, blue: 0.22),
            photoBorder: Color(red: 0.83, green: 0.64, blue: 0.22),
            plate: Color(red: 0.35, green: 0.06, blue: 0.08).opacity(0.70)
        ),
        GreetingCardStyle(
            name: "Navy",
            assetName: "AICardFrameNavy",
            background: Color(red: 0.04, green: 0.16, blue: 0.27),
            primary: Color(red: 1.0, green: 0.83, blue: 0.48),
            secondary: Color(red: 1.0, green: 0.95, blue: 0.83),
            accent: Color(red: 0.84, green: 0.66, blue: 0.31),
            photoBorder: Color(red: 0.84, green: 0.66, blue: 0.31),
            plate: Color(red: 0.04, green: 0.16, blue: 0.27).opacity(0.74)
        ),
        GreetingCardStyle(
            name: "Blush",
            assetName: "AICardFrameBlush",
            background: Color(red: 1.0, green: 0.88, blue: 0.91),
            primary: Color(red: 0.48, green: 0.07, blue: 0.11),
            secondary: Color(red: 0.29, green: 0.16, blue: 0.13),
            accent: Color(red: 0.75, green: 0.54, blue: 0.10),
            photoBorder: Color(red: 0.75, green: 0.54, blue: 0.10),
            plate: Color(red: 1.0, green: 0.88, blue: 0.91).opacity(0.86)
        ),
        GreetingCardStyle(
            name: "Blush Rose",
            assetName: "AICardFrameRose",
            background: Color(red: 1.0, green: 0.87, blue: 0.91),
            primary: Color(red: 0.51, green: 0.08, blue: 0.19),
            secondary: Color(red: 0.28, green: 0.10, blue: 0.14),
            accent: Color(red: 0.78, green: 0.44, blue: 0.48),
            photoBorder: Color(red: 0.78, green: 0.44, blue: 0.48),
            plate: Color(red: 1.0, green: 0.88, blue: 0.91).opacity(0.86)
        ),
        GreetingCardStyle(
            name: "Burgundy Emerald",
            assetName: "AICardFrameEmeraldLamp",
            background: Color(red: 0.03, green: 0.27, blue: 0.22),
            primary: Color(red: 0.97, green: 0.86, blue: 0.57),
            secondary: Color(red: 1.0, green: 0.96, blue: 0.82),
            accent: Color(red: 0.90, green: 0.57, blue: 0.16),
            photoBorder: Color(red: 0.90, green: 0.57, blue: 0.16),
            plate: Color(red: 0.02, green: 0.18, blue: 0.15).opacity(0.70)
        ),
        GreetingCardStyle(
            name: "Navy Peacock",
            assetName: "AICardFramePeacockFireworks",
            background: Color(red: 0.05, green: 0.17, blue: 0.31),
            primary: Color(red: 0.35, green: 0.82, blue: 0.79),
            secondary: Color(red: 1.0, green: 0.94, blue: 0.78),
            accent: Color(red: 1.0, green: 0.73, blue: 0.30),
            photoBorder: Color(red: 1.0, green: 0.73, blue: 0.30),
            plate: Color(red: 0.02, green: 0.10, blue: 0.20).opacity(0.72)
        ),
        GreetingCardStyle(
            name: "Ivory Marigold",
            assetName: "AICardFrameMarigold",
            background: Color(red: 1.0, green: 0.96, blue: 0.86),
            primary: Color(red: 0.50, green: 0.23, blue: 0.07),
            secondary: Color(red: 0.28, green: 0.13, blue: 0.06),
            accent: Color(red: 0.92, green: 0.53, blue: 0.11),
            photoBorder: Color(red: 0.92, green: 0.53, blue: 0.11),
            plate: Color.white.opacity(0.78)
        ),
        GreetingCardStyle(
            name: "Blush Lavender",
            assetName: "AICardFrameLavender",
            background: Color(red: 0.94, green: 0.90, blue: 1.0),
            primary: Color(red: 0.33, green: 0.20, blue: 0.52),
            secondary: Color(red: 0.21, green: 0.15, blue: 0.32),
            accent: Color(red: 0.77, green: 0.52, blue: 0.85),
            photoBorder: Color(red: 0.77, green: 0.52, blue: 0.85),
            plate: Color.white.opacity(0.80)
        )
    ]

    private var selectedDecorativeTheme: StickerDecorativeTheme {
        StickerDecorativeTheme.allCases[min(max(decorativeThemeIndex, 0), StickerDecorativeTheme.allCases.count - 1)]
    }

    private var geminiStickerPrompt: String {
        let base = aiDirection.trimmingCharacters(in: .whitespacesAndNewlines)
        let prompt = base.isEmpty ? "Create a premium transparent PNG cutout sticker." : base
        return """
        \(prompt)
        Name: \(nameLine)
        Occasion: \(occasion)
        Sticker idea: \(stickerConcept)
        Text on sticker: \(headline)
        Small caption: \(message)
        Decorative theme: \(selectedDecorativeTheme.promptPhrase)
        Output: transparent-background PNG sticker, centered subject, clean cutout edges, white border, high detail, no extra words beyond the provided text.
        """
    }

    var body: some View {
        AppBackground {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 20) {
                        StationeryPreview(
                            mode: selectedMode,
                            member: member,
                            headline: headline,
                            nameLine: nameLine,
                            message: message,
                            fromLabel: fromLabel,
                            sender: sender,
                            closingLine: closingLine,
                            eventType: eventType,
                            style: styles[selectedStyle],
                            customImageData: selectedImageData,
                            characterImageData: selectedCharacterImageData,
                            collagePhotos: selectedCollagePhotos,
                            photoAdjustments: photoAdjustments,
                            textSettings: textSettings,
                            aiDirection: geminiStickerPrompt,
                            decorativeTheme: selectedDecorativeTheme,
                            stickerConcept: stickerConcept
                        )
                        .frame(maxWidth: 360)
                        .aspectRatio(selectedMode.aspectRatio, contentMode: .fit)
                        .padding(.top, 12)

                        VStack(alignment: .leading, spacing: 14) {
                            GroupBox("Create") {
                                VStack(alignment: .leading, spacing: 12) {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 10) {
                                            ForEach([StationeryMode.sticker, StationeryMode.gif]) { mode in
                                                StationeryModeChoice(
                                                    mode: mode,
                                                    selected: selectedMode == mode,
                                                    action: { selectedMode = mode }
                                                )
                                            }
                                        }
                                        .padding(.vertical, 2)
                                    }

                                    if selectedMode == .gif {
                                        Label("GIFs will use the same prompt-only Gemini flow next. Sticker creation is ready first.", systemImage: "play.rectangle.fill")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(.secondary)
                                    }

                                    TextField("Gemini studio prompt", text: $aiDirection, axis: .vertical)
                                        .textFieldStyle(.roundedBorder)
                                        .lineLimit(3...5)
                                }
                            }

                            GroupBox("Sticker brief") {
                                VStack(alignment: .leading, spacing: 9) {
                                    TextField("Name", text: $nameLine)
                                        .textFieldStyle(.roundedBorder)
                                    TextField("Occasion", text: $occasion)
                                        .textFieldStyle(.roundedBorder)
                                    TextField("Sticker idea", text: $stickerConcept, axis: .vertical)
                                        .textFieldStyle(.roundedBorder)
                                        .lineLimit(2...4)
                                    TextField("Main sticker text", text: $headline)
                                        .textFieldStyle(.roundedBorder)
                                    TextField("Small caption", text: $message, axis: .vertical)
                                        .textFieldStyle(.roundedBorder)
                                        .lineLimit(2...4)
                                }
                                .padding(.top, 4)
                            }

                            GroupBox("Decorative theme") {
                                VStack(alignment: .leading, spacing: 12) {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(StickerDecorativeTheme.allCases.indices, id: \.self) { index in
                                                StickerThemeChoice(
                                                    theme: StickerDecorativeTheme.allCases[index],
                                                    selected: decorativeThemeIndex == index,
                                                    action: { decorativeThemeIndex = index }
                                                )
                                            }
                                        }
                                        .padding(.vertical, 2)
                                    }
                                    Picker("Card frame palette", selection: $selectedStyle) {
                                        ForEach(styles.indices, id: \.self) { index in
                                            Text(styles[index].name).tag(index)
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                }
                            }

                            DisclosureGroup(isExpanded: $isPhotoEditorExpanded) {
                                VStack(spacing: 12) {
                                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                        AndroidIconActionButtonLabel(
                                            title: selectedImageData == nil ? "Add base photo" : "Change base photo",
                                            subtitle: "Optional Gemini reference",
                                            systemImage: "photo.on.rectangle.angled"
                                        )
                                    }
                                    .buttonStyle(.plain)

                                    PhotosPicker(selection: $selectedCharacterPhotoItem, matching: .images) {
                                        AndroidIconActionButtonLabel(
                                            title: selectedCharacterImageData == nil ? "Add character photo" : "Change character photo",
                                            subtitle: "Cutout sticker character",
                                            systemImage: "person.crop.artframe"
                                        )
                                    }
                                    .buttonStyle(.plain)

                                    PhotoEditControls(
                                        adjustments: $photoAdjustments,
                                        onReset: { photoAdjustments = CardPhotoAdjustments() }
                                    )
                                }
                                .padding(.top, 8)
                            } label: {
                                Label("Photo editor", systemImage: "camera.filters")
                                    .font(.headline)
                            }

                            DisclosureGroup(isExpanded: $isTextStyleExpanded) {
                                TextStyleControls(style: styles[selectedStyle], settings: $textSettings)
                                    .padding(.top, 8)
                            } label: {
                                Label("Sticker text style", systemImage: "textformat")
                                    .font(.headline)
                            }

                            Button {
                                regenerate()
                            } label: {
                                AndroidIconActionButtonLabel(
                                    title: "Refresh sticker prompt",
                                    subtitle: "Name, occasion + cutout style",
                                    systemImage: "sparkles"
                                )
                            }
                            .buttonStyle(.plain)

                            GroupBox("Gemini prompt") {
                                Text(geminiStickerPrompt)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(AndroidLook.deepBrown)
                                    .textSelection(.enabled)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 4)
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Button {
                                    exportStationery()
                                } label: {
                                    AndroidIconActionButtonLabel(
                                        title: "Download sticker preview",
                                        subtitle: "PNG mockup for sharing",
                                        systemImage: "square.and.arrow.down"
                                    )
                                }
                                .buttonStyle(.plain)

                                if let exportURL {
                                    ShareLink(item: exportURL) {
                                        Label("Share / Save sticker preview", systemImage: "square.and.arrow.up")
                                            .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(AndroidLook.accentGold)
                                }

                                if let exportStatus {
                                    Text(exportStatus)
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(14)
                        .background(Color(red: 0.98, green: 0.94, blue: 0.86).opacity(0.96), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(AndroidLook.accentGold.opacity(0.45), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 24)
                }
                .task(id: selectedPhotoItem) {
                    guard let selectedPhotoItem else { return }
                    if let data = try? await selectedPhotoItem.loadTransferable(type: Data.self) {
                        selectedImageData = data
                        photoAdjustments = CardPhotoAdjustments()
                        exportURL = nil
                    }
                }
                .task(id: selectedCharacterPhotoItem) {
                    guard let selectedCharacterPhotoItem else { return }
                    if let data = try? await selectedCharacterPhotoItem.loadTransferable(type: Data.self) {
                        selectedCharacterImageData = data
                        photoAdjustments = CardPhotoAdjustments()
                        exportURL = nil
                    }
                }
                .task(id: selectedCollageItems) {
                    var loadedPhotos: [Data] = []
                    for item in selectedCollageItems {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            loadedPhotos.append(data)
                        }
                    }
                    selectedCollagePhotos = loadedPhotos
                    exportURL = nil
                }
                .navigationTitle(localized("AI Photo Studio", language: viewModel.language))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(localized("Home", language: viewModel.language)) {
                            viewModel.showDashboard()
                        }
                    }
                }
            }
        }
    }

    private func regenerate() {
        let options = selectedMode.messageOptions(defaultMessage: Self.defaultMessage(for: member, eventType: eventType))
        message = options.randomElement() ?? message
        stickerConcept = Self.stickerConceptOptions(for: occasion).randomElement() ?? stickerConcept
        exportURL = nil
    }

    @MainActor
    private func exportStationery() {
        let width = 900.0
        let content = StationeryPreview(
            mode: selectedMode,
            member: member,
            headline: headline,
            nameLine: nameLine,
            message: message,
            fromLabel: fromLabel,
            sender: sender,
            closingLine: closingLine,
            eventType: eventType,
            style: styles[selectedStyle],
            customImageData: selectedImageData,
            characterImageData: selectedCharacterImageData,
            collagePhotos: selectedCollagePhotos,
            photoAdjustments: photoAdjustments,
            textSettings: textSettings,
            aiDirection: geminiStickerPrompt,
            decorativeTheme: selectedDecorativeTheme,
            stickerConcept: stickerConcept
        )
        .frame(width: width, height: width / selectedMode.aspectRatio)

        let renderer = ImageRenderer(content: content)
        renderer.scale = 2

        guard let image = renderer.uiImage, let data = image.pngData() else {
            exportStatus = "Could not render this sticker preview."
            return
        }

        let filename = "circlebirthdays-\(selectedMode.exportName)-\(Int(Date().timeIntervalSince1970)).png"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        do {
            try data.write(to: url, options: .atomic)
            exportURL = url
            exportStatus = "Downloaded sticker preview is ready to share or save."
        } catch {
            exportStatus = "Could not save the downloaded sticker preview."
        }
    }

    private static func defaultNameLine(for member: Member, eventType: DashboardFamilyEvent.EventType, members: [Member]) -> String {
        if eventType == .anniversary {
            let partnerId = member.familyId.hasSuffix("0") ? String(member.familyId.dropLast()) : member.familyId + "0"
            let partner = members.first { $0.familyId == partnerId }
            if let partnerName = member.spouseName ?? partner?.name {
                return "\(member.name) & \(partnerName)"
            }
        }
        return member.name.split(separator: " ").first.map(String.init) ?? member.name
    }

    private static func defaultMessage(for member: Member, eventType: DashboardFamilyEvent.EventType) -> String {
        switch eventType {
        case .birthday:
            let firstName = member.name.split(separator: " ").first.map(String.init) ?? "you"
            return "Wishing \(firstName) health, happiness, and a year full of family blessings."
        case .anniversary:
            return "Celebrating your togetherness with love, respect, and warm wishes from the whole family."
        case .remembrance:
            return "Remembering with gratitude, love, and the quiet strength of family memories."
        }
    }

    private static func defaultOccasion(for eventType: DashboardFamilyEvent.EventType) -> String {
        switch eventType {
        case .birthday:
            return "Birthday"
        case .anniversary:
            return "Anniversary"
        case .remembrance:
            return "Remembrance"
        }
    }

    private static func stickerConceptOptions(for occasion: String) -> [String] {
        let occasion = occasion.trimmingCharacters(in: .whitespacesAndNewlines)
        let label = occasion.isEmpty ? "special day" : occasion.lowercased()
        return [
            "smiling celebratory character holding flowers for a \(label)",
            "cute cutout character with gift box, sparkles, and warm family energy",
            "premium sticker mascot with handwritten-style wish and festive accents",
            "expressive portrait sticker with clean white outline and joyful pose"
        ]
    }
}

private struct GreetingCardStyle {
    let name: String
    let assetName: String
    let background: Color
    let primary: Color
    let secondary: Color
    let accent: Color
    let photoBorder: Color
    let plate: Color
}

private enum StickerDecorativeTheme: String, CaseIterable, Identifiable {
    case celebration
    case floral
    case festival
    case playful
    case elegant

    var id: String { rawValue }

    var title: String {
        switch self {
        case .celebration: return "Celebration"
        case .floral: return "Floral"
        case .festival: return "Festival"
        case .playful: return "Playful"
        case .elegant: return "Elegant"
        }
    }

    var systemImage: String {
        switch self {
        case .celebration: return "party.popper.fill"
        case .floral: return "camera.macro"
        case .festival: return "flame.fill"
        case .playful: return "sparkles"
        case .elegant: return "seal.fill"
        }
    }

    var promptPhrase: String {
        switch self {
        case .celebration:
            return "confetti, balloons, cake sprinkles, bright celebration accents"
        case .floral:
            return "soft flowers, leaves, petals, graceful garden accents"
        case .festival:
            return "marigold garlands, diyas, gold sparkle, Indian festive accents"
        case .playful:
            return "rounded doodles, stars, hearts, cute sticker energy"
        case .elegant:
            return "minimal premium gold accents, soft glow, refined keepsake styling"
        }
    }

    var symbols: [String] {
        switch self {
        case .celebration: return ["✦", "★", "•"]
        case .floral: return ["✿", "❀", "•"]
        case .festival: return ["✦", "◆", "•"]
        case .playful: return ["★", "♥", "✦"]
        case .elegant: return ["◆", "✦", "•"]
        }
    }
}

private enum StationeryMode: String, CaseIterable, Identifiable {
    case card
    case sticker
    case gif
    case collage
    case vintage

    var id: String { rawValue }

    var title: String {
        switch self {
        case .card: return "Card"
        case .sticker: return "Prompt Sticker"
        case .gif: return "Prompt GIF"
        case .collage: return "Collage"
        case .vintage: return "Vintage Memory"
        }
    }

    var subtitle: String {
        switch self {
        case .card: return "Classic photo wish"
        case .sticker: return "Gemini cutout PNG"
        case .gif: return "Prompt animation"
        case .collage: return "Many-photo layout"
        case .vintage: return "Classic memory photo"
        }
    }

    var systemImage: String {
        switch self {
        case .card: return "rectangle.portrait"
        case .sticker: return "seal.fill"
        case .gif: return "play.rectangle.fill"
        case .collage: return "rectangle.grid.2x2.fill"
        case .vintage: return "camera.filters"
        }
    }

    var aspectRatio: CGFloat {
        switch self {
        case .card, .vintage: return 2.0 / 3.0
        case .sticker: return 1.0
        case .gif, .collage: return 4.0 / 5.0
        }
    }

    var exportName: String { rawValue.replacingOccurrences(of: " ", with: "-") }

    var regenerateSubtitle: String {
        switch self {
        case .card: return "Message"
        case .sticker: return "Sticker wish"
        case .gif: return "GIF frames"
        case .collage: return "Collage caption"
        case .vintage: return "Memory caption"
        }
    }

    func messageOptions(defaultMessage: String) -> [String] {
        switch self {
        case .card:
            return [
                defaultMessage,
                "May this day bring warmth, laughter, blessings, and memories your whole family will keep close.",
                "With love from all of us, wishing you a day filled with joy, grace, and togetherness."
            ]
        case .sticker:
            return [
                "Blessings, smiles, and love always.",
                "Made with love for your special day.",
                "A little family sparkle, just for you."
            ]
        case .gif:
            return [
                "Frame 1: warm smile. Frame 2: flowers bloom. Frame 3: wishes sparkle.",
                "A tiny animated wish with photos, lamps, and family love.",
                "Photo pop-in, golden text glow, celebration burst."
            ]
        case .collage:
            return [
                "A collection of little moments that became our favorite memories.",
                "Many photos, one family story, all our love.",
                "Faces, laughter, blessings, and the years we keep close."
            ]
        case .vintage:
            return [
                "A classic memory, softened with time and held with love.",
                "Old-photo warmth for a story the family never forgets.",
                "A keepsake memory with gentle grain, soft light, and love."
            ]
        }
    }
}

private struct CardPhotoAdjustments: Equatable {
    var scale: Double = 1.0
    var offsetX: Double = 0.0
    var offsetY: Double = 0.0
    var rotation: Double = 0.0
    var brightness: Double = 0.0
    var contrast: Double = 1.0
    var saturation: Double = 1.0
}

private struct CardTextSettings: Equatable {
    var fontIndex = 0
    var sizeScale: Double = 1.0
    var colorIndex = 0
}

private func cardStudioFont(size: CGFloat, weight: Font.Weight, settings: CardTextSettings) -> Font {
    let scaledSize = size * min(max(settings.sizeScale, 0.85), 1.25)
    switch settings.fontIndex {
    case 0:
        return .system(size: scaledSize, weight: weight, design: .serif)
    case 1:
        return .system(size: scaledSize, weight: weight, design: .rounded)
    case 2:
        return .system(size: scaledSize, weight: weight, design: .default)
    case 3:
        return .system(size: scaledSize, weight: weight, design: .monospaced)
    case 4:
        return .custom("Avenir Next", size: scaledSize).weight(weight)
    case 5:
        return .custom("Georgia", size: scaledSize).weight(weight)
    default:
        return .system(size: scaledSize, weight: weight, design: .serif)
    }
}

private func cardStudioTextColor(style: GreetingCardStyle, settings: CardTextSettings) -> Color {
    let options = cardTextColorOptions(for: style)
    return options[min(max(settings.colorIndex, 0), options.count - 1)].color
}

private struct StationeryPreview: View {
    let mode: StationeryMode
    let member: Member
    let headline: String
    let nameLine: String
    let message: String
    let fromLabel: String
    let sender: String
    let closingLine: String
    let eventType: DashboardFamilyEvent.EventType
    let style: GreetingCardStyle
    let customImageData: Data?
    let characterImageData: Data?
    let collagePhotos: [Data]
    let photoAdjustments: CardPhotoAdjustments
    let textSettings: CardTextSettings
    let aiDirection: String
    let decorativeTheme: StickerDecorativeTheme
    let stickerConcept: String

    var body: some View {
        switch mode {
        case .card:
            GreetingCardPreview(
                member: member,
                headline: headline,
                nameLine: nameLine,
                message: message,
                fromLabel: fromLabel,
                sender: sender,
                closingLine: closingLine,
                eventType: eventType,
                style: style,
                customImageData: customImageData,
                photoAdjustments: photoAdjustments,
                textSettings: textSettings
            )
        case .sticker:
            WishStickerPreview(
                member: member,
                headline: headline,
                nameLine: nameLine,
                message: message,
                style: style,
                customImageData: characterImageData ?? customImageData,
                photoAdjustments: photoAdjustments,
                textSettings: textSettings,
                decorativeTheme: decorativeTheme,
                stickerConcept: stickerConcept
            )
        case .gif:
            GifStoryboardPreview(
                headline: headline,
                nameLine: nameLine,
                message: message,
                style: style,
                customImageData: customImageData,
                collagePhotos: collagePhotos,
                aiDirection: aiDirection,
                textSettings: textSettings
            )
        case .collage:
            PhotoCollagePreview(
                headline: headline,
                nameLine: nameLine,
                message: message,
                style: style,
                customImageData: customImageData,
                collagePhotos: collagePhotos,
                textSettings: textSettings
            )
        case .vintage:
            VintageMemoryPreview(
                member: member,
                headline: headline,
                nameLine: nameLine,
                message: message,
                style: style,
                customImageData: customImageData,
                collagePhotos: collagePhotos,
                photoAdjustments: photoAdjustments,
                textSettings: textSettings
            )
        }
    }
}

private struct StationeryModeChoice: View {
    let mode: StationeryMode
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: mode.systemImage)
                        .font(.headline.weight(.semibold))
                    Text(mode.title)
                        .font(.caption.weight(.heavy))
                }
                Text(mode.subtitle)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            .foregroundStyle(selected ? AndroidLook.deepBrown : .primary)
            .padding(10)
            .frame(width: 132, alignment: .leading)
            .frame(minHeight: 74)
            .background(selected ? AndroidLook.accentGold.opacity(0.22) : Color.white.opacity(0.66), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(selected ? AndroidLook.accentGold : Color.secondary.opacity(0.25), lineWidth: selected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct StickerThemeChoice: View {
    let theme: StickerDecorativeTheme
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 7) {
                Image(systemName: theme.systemImage)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(selected ? AndroidLook.deepBrown : AndroidLook.accentGold)
                Text(theme.title)
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(AndroidLook.deepBrown)
                    .lineLimit(1)
            }
            .frame(width: 96, height: 72)
            .background(selected ? AndroidLook.accentGold.opacity(0.22) : Color.white.opacity(0.66), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(selected ? AndroidLook.accentGold : Color.secondary.opacity(0.25), lineWidth: selected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct GreetingCardPreview: View {
    let member: Member
    let headline: String
    let nameLine: String
    let message: String
    let fromLabel: String
    let sender: String
    let closingLine: String
    let eventType: DashboardFamilyEvent.EventType
    let style: GreetingCardStyle
    let customImageData: Data?
    let photoAdjustments: CardPhotoAdjustments
    let textSettings: CardTextSettings

    private var years: Int? {
        switch eventType {
        case .birthday:
            return completedYears(since: member.dateOfBirth)
        case .anniversary:
            return completedYears(since: member.marriageDate)
        case .remembrance:
            return nil
        }
    }

    private var eventLabel: String {
        switch eventType {
        case .birthday:
            return "Birthday"
        case .anniversary:
            return "Anniversary"
        case .remembrance:
            return "Remembrance"
        }
    }

    private var editableColor: Color {
        cardStudioTextColor(style: style, settings: textSettings)
    }

    var body: some View {
        ZStack {
            style.background

            CardFrameArtwork(style: style)
                .allowsHitTesting(false)

            VStack(spacing: 7) {
                Text(headline)
                    .font(cardStudioFont(size: 25, weight: .semibold, settings: textSettings))
                    .foregroundStyle(editableColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                if let years, years > 0 {
                    HStack(alignment: .top, spacing: 2) {
                        Text("\(years)")
                            .font(.system(size: 58, weight: .bold, design: .serif))
                            .foregroundStyle(style.accent)
                            .lineLimit(1)
                        Text(ordinalSuffix(years))
                            .font(.system(size: 17, weight: .semibold, design: .serif))
                            .foregroundStyle(style.primary)
                            .padding(.top, 10)
                    }
                    .frame(height: 62)
                } else {
                    Spacer()
                        .frame(height: 12)
                }

                Text(eventLabel)
                    .font(cardStudioFont(size: 35, weight: .semibold, settings: textSettings))
                    .foregroundStyle(editableColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                AICardOrnamentDivider(style: style)

                Text(nameLine)
                    .font(cardStudioFont(size: 27, weight: .semibold, settings: textSettings))
                    .foregroundStyle(editableColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .frame(maxWidth: .infinity)
                    .background(style.plate, in: RoundedRectangle(cornerRadius: 4, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .stroke(style.accent.opacity(0.80), lineWidth: 1)
                    )
                    .padding(.horizontal, 16)

                CardMemberPhoto(
                    member: member,
                    customImageData: customImageData,
                    adjustments: photoAdjustments,
                    border: style.photoBorder
                )
                    .frame(height: 144)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 4)

                Text(message)
                    .font(cardStudioFont(size: 16, weight: .semibold, settings: textSettings))
                    .foregroundStyle(editableColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.70)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(style.plate.opacity(0.72), in: RoundedRectangle(cornerRadius: 4, style: .continuous))
                    .padding(.horizontal, 18)

                Spacer(minLength: 0)

                Text(fromLabel)
                    .font(cardStudioFont(size: 11, weight: .semibold, settings: textSettings))
                    .foregroundStyle(editableColor.opacity(0.72))

                Text(sender)
                    .font(cardStudioFont(size: 12, weight: .bold, settings: textSettings))
                    .foregroundStyle(editableColor.opacity(0.88))
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                if !closingLine.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(closingLine)
                        .font(cardStudioFont(size: 11, weight: .semibold, settings: textSettings))
                        .foregroundStyle(editableColor.opacity(0.72))
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
            .padding(.horizontal, 34)
            .padding(.top, 34)
            .padding(.bottom, 28)
        }
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: .black.opacity(0.18), radius: 16, x: 0, y: 10)
        .accessibilityElement(children: .combine)
    }
}

private struct WishStickerPreview: View {
    let member: Member
    let headline: String
    let nameLine: String
    let message: String
    let style: GreetingCardStyle
    let customImageData: Data?
    let photoAdjustments: CardPhotoAdjustments
    let textSettings: CardTextSettings
    let decorativeTheme: StickerDecorativeTheme
    let stickerConcept: String

    private var textColor: Color {
        cardStudioTextColor(style: style, settings: textSettings)
    }

    var body: some View {
        ZStack {
            Color.clear
            stickerAccentBackground

            VStack(spacing: 12) {
                Text(headline)
                    .font(cardStudioFont(size: 25, weight: .bold, settings: textSettings))
                    .foregroundStyle(textColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)

                CardMemberPhoto(
                    member: member,
                    customImageData: customImageData,
                    adjustments: photoAdjustments,
                    border: style.photoBorder
                )
                .clipShape(Circle())
                .overlay(Circle().stroke(.white, lineWidth: 9))
                .overlay(Circle().stroke(style.accent, lineWidth: 4))
                .frame(width: 190, height: 190)
                .shadow(color: style.accent.opacity(0.22), radius: 14, x: 0, y: 8)

                Text(nameLine)
                    .font(cardStudioFont(size: 31, weight: .heavy, settings: textSettings))
                    .foregroundStyle(textColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)

                Text(stickerConcept)
                    .font(cardStudioFont(size: 11, weight: .bold, settings: textSettings))
                    .foregroundStyle(textColor.opacity(0.72))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.68)
                    .padding(.horizontal, 14)

                messagePlate
            }
            .padding(34)
        }
        .background(style.background.opacity(0.78), in: RoundedRectangle(cornerRadius: 42, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 42, style: .continuous)
                .stroke(.white, lineWidth: 8)
        )
        .clipShape(RoundedRectangle(cornerRadius: 42, style: .continuous))
        .shadow(color: .black.opacity(0.16), radius: 14, x: 0, y: 8)
    }

    private var messagePlate: some View {
        Text(message)
            .font(cardStudioFont(size: 15, weight: .bold, settings: textSettings))
            .foregroundStyle(textColor)
            .multilineTextAlignment(.center)
            .lineLimit(3)
            .minimumScaleFactor(0.70)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(style.plate.opacity(0.84), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(style.accent.opacity(0.82), lineWidth: 1.5)
            )
            .padding(.horizontal, 4)
    }

    private var stickerAccentBackground: some View {
        ZStack {
            ForEach(0..<16, id: \.self) { index in
                Text(decorativeTheme.symbols[index % decorativeTheme.symbols.count])
                    .font(.system(size: CGFloat([14, 18, 23, 28][index % 4]), weight: .heavy))
                    .foregroundStyle(index.isMultiple(of: 2) ? style.accent.opacity(0.50) : style.primary.opacity(0.28))
                    .rotationEffect(.degrees(Double(index * 23)))
                    .offset(
                        x: CGFloat((index * 61) % 280) - 140,
                        y: CGFloat((index * 43) % 300) - 150
                    )
            }
            RoundedRectangle(cornerRadius: 42, style: .continuous)
                .stroke(style.accent.opacity(0.44), lineWidth: 3)
                .padding(14)
        }
    }
}

private struct GifStoryboardPreview: View {
    let headline: String
    let nameLine: String
    let message: String
    let style: GreetingCardStyle
    let customImageData: Data?
    let collagePhotos: [Data]
    let aiDirection: String
    let textSettings: CardTextSettings

    private var storyboardPhotos: [Data] {
        var photos = collagePhotos
        if let customImageData, photos.isEmpty {
            photos = [customImageData]
        }
        return photos
    }

    private var textColor: Color {
        cardStudioTextColor(style: style, settings: textSettings)
    }

    var body: some View {
        ZStack {
            style.background
            gifAccentBackground

            VStack(spacing: 12) {
                Text("GIF Wish")
                    .font(cardStudioFont(size: 11, weight: .heavy, settings: textSettings))
                    .foregroundStyle(style.accent)
                    .textCase(.uppercase)

                Text(headline)
                    .font(cardStudioFont(size: 25, weight: .bold, settings: textSettings))
                    .foregroundStyle(textColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)

                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        VStack(spacing: 6) {
                            StationeryPhotoTile(data: storyboardPhotos.indices.contains(index) ? storyboardPhotos[index] : customImageData)
                                .frame(height: 122)
                                .overlay(alignment: .topLeading) {
                                    Text("\(index + 1)")
                                        .font(.caption2.weight(.heavy))
                                        .foregroundStyle(.white)
                                        .padding(6)
                                        .background(style.primary.opacity(0.82), in: Circle())
                                        .padding(6)
                                }
                            Text(gifFrameLabel(index))
                                .font(cardStudioFont(size: 10, weight: .bold, settings: textSettings))
                                .foregroundStyle(textColor.opacity(0.78))
                                .lineLimit(1)
                        }
                        .padding(6)
                        .background(style.plate.opacity(0.74), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                }

                Text(nameLine)
                    .font(cardStudioFont(size: 24, weight: .heavy, settings: textSettings))
                    .foregroundStyle(textColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)

                Text(message)
                    .font(cardStudioFont(size: 14, weight: .semibold, settings: textSettings))
                    .foregroundStyle(textColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.68)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(style.plate.opacity(0.78), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(style.accent.opacity(0.68), lineWidth: 1)
                    )

                Text(aiDirection)
                    .font(cardStudioFont(size: 10, weight: .semibold, settings: textSettings))
                    .foregroundStyle(textColor.opacity(0.72))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.62)
                    .padding(.horizontal, 12)
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 38)
        }
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: .black.opacity(0.16), radius: 14, x: 0, y: 8)
    }

    private var gifAccentBackground: some View {
        ZStack {
            LinearGradient(
                colors: [style.background, style.accent.opacity(0.20), style.background],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            HStack {
                Rectangle()
                    .fill(style.accent.opacity(0.24))
                    .frame(width: 10)
                Spacer()
                Rectangle()
                    .fill(style.primary.opacity(0.16))
                    .frame(width: 10)
            }
            .padding(.horizontal, 16)
        }
    }

    private func gifFrameLabel(_ index: Int) -> String {
        switch index {
        case 0: return "Photo"
        case 1: return "Wish"
        default: return "Sparkle"
        }
    }
}

private struct PhotoCollagePreview: View {
    let headline: String
    let nameLine: String
    let message: String
    let style: GreetingCardStyle
    let customImageData: Data?
    let collagePhotos: [Data]
    let textSettings: CardTextSettings

    private var photos: [Data] {
        var all = collagePhotos
        if let customImageData, all.isEmpty {
            all = [customImageData]
        }
        return all
    }

    private var textColor: Color {
        cardStudioTextColor(style: style, settings: textSettings)
    }

    var body: some View {
        ZStack {
            style.background
            CardFrameArtwork(style: style)
                .allowsHitTesting(false)

            VStack(spacing: 12) {
                Text(headline)
                    .font(cardStudioFont(size: 24, weight: .bold, settings: textSettings))
                    .foregroundStyle(textColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                    ForEach(0..<6, id: \.self) { index in
                        StationeryPhotoTile(data: photos.indices.contains(index) ? photos[index] : nil)
                            .aspectRatio(index == 0 ? 1.55 : 1.0, contentMode: .fit)
                            .gridCellColumns(index == 0 ? 2 : 1)
                    }
                }
                .padding(10)
                .background(style.plate.opacity(0.66), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                Text(nameLine)
                    .font(cardStudioFont(size: 24, weight: .heavy, settings: textSettings))
                    .foregroundStyle(textColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)

                Text(message)
                    .font(cardStudioFont(size: 14, weight: .semibold, settings: textSettings))
                    .foregroundStyle(textColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.68)
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 38)
        }
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: .black.opacity(0.16), radius: 14, x: 0, y: 8)
    }
}

private struct VintageMemoryPreview: View {
    let member: Member
    let headline: String
    let nameLine: String
    let message: String
    let style: GreetingCardStyle
    let customImageData: Data?
    let collagePhotos: [Data]
    let photoAdjustments: CardPhotoAdjustments
    let textSettings: CardTextSettings

    private var featuredPhoto: Data? {
        customImageData ?? collagePhotos.first
    }

    private var textColor: Color {
        cardStudioTextColor(style: style, settings: textSettings)
    }

    var body: some View {
        ZStack {
            Color(red: 0.91, green: 0.82, blue: 0.64)
            CardFrameArtwork(style: style)
                .opacity(0.72)
                .allowsHitTesting(false)

            VStack(spacing: 12) {
                Text(headline)
                    .font(cardStudioFont(size: 23, weight: .semibold, settings: textSettings))
                    .foregroundStyle(textColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)

                CardMemberPhoto(
                    member: member,
                    customImageData: featuredPhoto,
                    adjustments: photoAdjustments,
                    border: style.photoBorder
                )
                .saturation(0.18)
                .contrast(1.08)
                .brightness(0.03)
                .colorMultiply(Color(red: 1.0, green: 0.86, blue: 0.58))
                .frame(height: 270)
                .padding(12)
                .background(Color(red: 0.98, green: 0.92, blue: 0.76), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                .rotationEffect(.degrees(-1.4))
                .shadow(color: .black.opacity(0.20), radius: 8, x: 0, y: 5)

                Text(nameLine)
                    .font(cardStudioFont(size: 26, weight: .bold, settings: textSettings))
                    .foregroundStyle(textColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)

                Text(message)
                    .font(cardStudioFont(size: 15, weight: .semibold, settings: textSettings))
                    .foregroundStyle(textColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
                    .minimumScaleFactor(0.66)
                    .padding(.horizontal, 20)
            }
            .padding(.horizontal, 36)
            .padding(.vertical, 42)

            VintageGrain()
                .opacity(0.22)
                .allowsHitTesting(false)
        }
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: .black.opacity(0.18), radius: 16, x: 0, y: 10)
    }
}

private struct StationeryPhotoTile: View {
    let data: Data?

    var body: some View {
        Group {
            if let data, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(Color.white.opacity(0.80))
                    .overlay {
                        Image(systemName: "photo")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(AndroidLook.softBrown.opacity(0.65))
                    }
            }
        }
        .clipped()
        .background(Color.white, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(Color.white.opacity(0.72), lineWidth: 2)
        )
    }
}

private struct VintageGrain: View {
    var body: some View {
        Canvas { context, size in
            for index in 0..<140 {
                let x = CGFloat((index * 47) % 900) / 900 * size.width
                let y = CGFloat((index * 83) % 1350) / 1350 * size.height
                let rect = CGRect(x: x, y: y, width: 1.4, height: 1.4)
                context.fill(Path(ellipseIn: rect), with: .color(.black.opacity(0.24)))
            }
        }
    }
}

private struct CardFrameChoice: View {
    let style: GreetingCardStyle
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                CardFrameArtwork(style: style)
                    .frame(width: 62, height: 92)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(selected ? AndroidLook.accentGold : Color.secondary.opacity(0.40), lineWidth: selected ? 3 : 1)
                    )
                Text(style.name)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.primary)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct AndroidIconActionButtonLabel: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.white.opacity(0.18), lineWidth: 1)
                    )

                Image(systemName: systemImage)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AndroidLook.accentGold)
            }
            .frame(width: 46, height: 46)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.heavy))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(subtitle)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Color.white.opacity(0.64))
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.white.opacity(0.48))
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 64)
        .background(Color.black.opacity(0.58), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(AndroidLook.accentGold.opacity(0.28), lineWidth: 1)
        )
    }
}

private struct CardFrameArtwork: View {
    let style: GreetingCardStyle

    var body: some View {
        Image(style.assetName)
            .resizable()
            .scaledToFill()
    }
}

private struct CardMemberPhoto: View {
    let member: Member
    let customImageData: Data?
    let adjustments: CardPhotoAdjustments
    let border: Color

    var body: some View {
        Group {
            if let customImageData, let uiImage = UIImage(data: customImageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else if let data = imageData(fromStoredPhoto: member.photoURL), let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else if let url = imageURL(fromStoredPhoto: member.photoURL) {
                CachedRemoteImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    fallback
                }
            } else {
                fallback
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .scaleEffect(adjustments.scale)
        .offset(x: adjustments.offsetX, y: adjustments.offsetY)
        .rotationEffect(.degrees(adjustments.rotation))
        .brightness(adjustments.brightness)
        .contrast(adjustments.contrast)
        .saturation(adjustments.saturation)
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .stroke(border.opacity(0.58), lineWidth: 1)
        )
        .background(.white, in: RoundedRectangle(cornerRadius: 4, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 2, x: 0, y: 1)
    }

    private var fallback: some View {
        Rectangle()
            .fill(Color.white)
            .overlay {
                VStack(spacing: 8) {
                    Image(systemName: "person.crop.rectangle")
                        .font(.title)
                    Text(member.initials)
                        .font(.title2.weight(.bold))
                }
                .foregroundStyle(border)
            }
    }
}

private struct PhotoEditControls: View {
    @Binding var adjustments: CardPhotoAdjustments
    let onReset: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Photo edits")
                    .font(.headline)
                Spacer()
                Button("Reset", action: onReset)
                    .font(.caption.weight(.semibold))
            }

            LabeledCardSlider(label: "Zoom", value: $adjustments.scale, range: 0.8...3.0)
            LabeledCardSlider(label: "Pan X", value: $adjustments.offsetX, range: -90...90)
            LabeledCardSlider(label: "Pan Y", value: $adjustments.offsetY, range: -70...70)
            LabeledCardSlider(label: "Rotation", value: $adjustments.rotation, range: -180...180)
            LabeledCardSlider(label: "Brightness", value: $adjustments.brightness, range: -0.35...0.35)
            LabeledCardSlider(label: "Contrast", value: $adjustments.contrast, range: 0.65...1.65)
            LabeledCardSlider(label: "Saturation", value: $adjustments.saturation, range: 0.0...1.8)

            HStack(spacing: 8) {
                Button {
                    adjustments.rotation = normalizedRotation(adjustments.rotation - 90)
                } label: {
                    Label("Rotate left", systemImage: "rotate.left")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    adjustments.rotation = normalizedRotation(adjustments.rotation + 90)
                } label: {
                    Label("Rotate right", systemImage: "rotate.right")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .font(.caption.weight(.semibold))
        }
        .padding(12)
        .background(Color.secondary.opacity(0.10), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func normalizedRotation(_ value: Double) -> Double {
        var result = value.truncatingRemainder(dividingBy: 360)
        if result > 180 { result -= 360 }
        if result < -180 { result += 360 }
        return result
    }
}

private struct TextStyleControls: View {
    let style: GreetingCardStyle
    @Binding var settings: CardTextSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Editable text style")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(["Serif", "Rounded", "Classic", "Mono", "Avenir", "Georgia"].enumerated()), id: \.offset) { index, label in
                        Button(label) {
                            settings.fontIndex = index
                        }
                        .buttonStyle(.bordered)
                        .tint(settings.fontIndex == index ? AndroidLook.accentGold : .secondary)
                    }
                }
            }

            HStack(spacing: 8) {
                ForEach(Array(["Small", "Normal", "Large"].enumerated()), id: \.offset) { index, label in
                    Button(label) {
                        settings.sizeScale = [0.9, 1.0, 1.16][index]
                    }
                    .buttonStyle(.bordered)
                    .tint(abs(settings.sizeScale - [0.9, 1.0, 1.16][index]) < 0.02 ? AndroidLook.accentGold : .secondary)
                }
            }

            LabeledCardSlider(label: "Text size", value: $settings.sizeScale, range: 0.85...1.25)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(cardTextColorOptions(for: style).enumerated()), id: \.offset) { index, option in
                        Button {
                            settings.colorIndex = index
                        } label: {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(option.color)
                                    .frame(width: 14, height: 14)
                                    .overlay(Circle().stroke(Color.secondary.opacity(0.35), lineWidth: 1))
                                Text(option.name)
                            }
                            .font(.caption.weight(.semibold))
                        }
                        .buttonStyle(.bordered)
                        .tint(settings.colorIndex == index ? AndroidLook.accentGold : .secondary)
                    }
                }
            }
        }
        .padding(12)
        .background(Color.secondary.opacity(0.10), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct LabeledCardSlider: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>

    var body: some View {
        VStack(spacing: 2) {
            HStack {
                Text(label)
                    .font(.caption.weight(.semibold))
                Spacer()
                Text(value.formatted(.number.precision(.fractionLength(2))))
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            Slider(value: $value, in: range)
        }
    }
}

private func cardTextColorOptions(for style: GreetingCardStyle) -> [(name: String, color: Color)] {
    [
        ("Primary", style.primary),
        ("Secondary", style.secondary),
        ("Accent", style.accent),
        ("Gold", AndroidLook.accentGold),
        ("Burgundy", Color(red: 0.48, green: 0.07, blue: 0.11)),
        ("Navy", Color(red: 0.04, green: 0.16, blue: 0.27)),
        ("Emerald", Color(red: 0.03, green: 0.27, blue: 0.22)),
        ("Rose", Color(red: 0.78, green: 0.30, blue: 0.42)),
        ("Plum", Color(red: 0.33, green: 0.20, blue: 0.52)),
        ("Dark", AndroidLook.deepBrown),
        ("Ink", Color.black.opacity(0.86)),
        ("Light", Color.white)
    ]
}

private struct AICardOrnamentDivider: View {
    let style: GreetingCardStyle

    var body: some View {
        HStack(spacing: 6) {
            Rectangle()
                .fill(style.accent.opacity(0.55))
                .frame(height: 1)
            Text("♥")
                .font(.caption.weight(.semibold))
                .foregroundStyle(style.primary)
            Rectangle()
                .fill(style.accent.opacity(0.55))
                .frame(height: 1)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 64)
    }
}

private struct BusinessDirectoryScreen: View {
    @Bindable var viewModel: AppViewModel
    @State private var showAddBusiness = false
    @State private var businessToDelete: FamilyBusiness?

    var body: some View {
        AppBackground {
            NavigationStack {
                Group {
                    if viewModel.visibleBusinesses.isEmpty {
                        ContentUnavailableView(
                            "No businesses found",
                            systemImage: "building.2.fill"
                        )
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.visibleBusinesses) { business in
                                    BusinessCard(
                                        business: business,
                                        canDelete: viewModel.hasAdminPrivileges || business.addedBy == viewModel.currentUser?.id,
                                        onDelete: {
                                            businessToDelete = business
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                    }
                }
                .navigationTitle(localized("Business Directory", language: viewModel.language))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            viewModel.showDashboard()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.headline.weight(.semibold))
                                .frame(width: 40, height: 40)
                        }
                        .accessibilityLabel("Back")
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showAddBusiness = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.headline.weight(.bold))
                                .frame(width: 40, height: 40)
                        }
                        .accessibilityLabel("Add Business")
                    }
                }
                .sheet(isPresented: $showAddBusiness) {
                    AddBusinessSheet(
                        onSave: { business in
                            Task {
                                await viewModel.addBusiness(business)
                            }
                            showAddBusiness = false
                        },
                        onCancel: {
                            showAddBusiness = false
                        }
                    )
                }
                .alert("Confirm Delete", isPresented: Binding(
                    get: { businessToDelete != nil },
                    set: { if !$0 { businessToDelete = nil } }
                )) {
                    Button("Cancel", role: .cancel) {
                        businessToDelete = nil
                    }
                    Button("Delete", role: .destructive) {
                        if let businessToDelete {
                            Task {
                                await viewModel.deleteBusiness(businessToDelete)
                            }
                        }
                        businessToDelete = nil
                    }
                } message: {
                    Text("Are you sure you want to delete this business listing?")
                }
            }
        }
    }
}

private struct BusinessCard: View {
    let business: FamilyBusiness
    let canDelete: Bool
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(business.name)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(AndroidLook.deepBrown)
                    Text(business.type.isEmpty ? "Business" : business.type)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AndroidLook.accentGold)
                }

                Spacer()

                if canDelete {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.red)
                            .frame(width: 34, height: 34)
                    }
                    .buttonStyle(.borderless)
                    .accessibilityLabel("Delete")
                }
            }

            Text("Owner: \(business.ownerName)")
                .font(.subheadline)
                .foregroundStyle(AndroidLook.deepBrown)

            HStack(spacing: 10) {
                Image(systemName: "phone.fill")
                    .foregroundStyle(AndroidLook.mutedBrown)
                Text(business.contactNumber)
                    .font(.subheadline)
                    .foregroundStyle(AndroidLook.deepBrown)
                Spacer()
                if let callURL = URL(string: "tel://\(business.contactNumber)") {
                    Link(destination: callURL) {
                        Label("Call", systemImage: "phone.fill")
                            .font(.caption.weight(.bold))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AndroidLook.accentGold)
                }
            }

            if !business.address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Label(business.address, systemImage: "location.fill")
                    .font(.caption)
                    .foregroundStyle(AndroidLook.mutedBrown)
            }

            if let mapURL = businessDirectoryURL(business.locationLink) {
                Link(destination: mapURL) {
                    Label("View on Map", systemImage: "map.fill")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.86), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }
}

private func businessDirectoryURL(_ value: String) -> URL? {
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return nil }
    if let url = URL(string: trimmed), url.scheme != nil {
        return url
    }
    return URL(string: "https://\(trimmed)")
}

private struct AddBusinessSheet: View {
    let onSave: (FamilyBusiness) -> Void
    let onCancel: () -> Void

    @State private var name = ""
    @State private var ownerName = ""
    @State private var contactNumber = ""
    @State private var type = "Business"
    @State private var address = ""
    @State private var locationLink = ""

    private let businessTypes = ["Business", "Consultancy", "Shop", "Event Hall", "Public Place", "Other"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Business") {
                    TextField("Business Name", text: $name)
                    TextField("Owner Name", text: $ownerName)
                    TextField("Contact Number", text: $contactNumber)
                        .keyboardType(.phonePad)
                    Picker("Type", selection: $type) {
                        ForEach(businessTypes, id: \.self) { businessType in
                            Text(businessType).tag(businessType)
                        }
                    }
                    TextField("Address", text: $address, axis: .vertical)
                    TextField("Maps Link", text: $locationLink, axis: .vertical)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                }
            }
            .navigationTitle("Add Business")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onSave(
                            FamilyBusiness(
                                id: "",
                                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                                ownerName: ownerName.trimmingCharacters(in: .whitespacesAndNewlines),
                                contactNumber: contactNumber.trimmingCharacters(in: .whitespacesAndNewlines),
                                type: type,
                                address: address.trimmingCharacters(in: .whitespacesAndNewlines),
                                locationLink: locationLink.trimmingCharacters(in: .whitespacesAndNewlines),
                                latitude: nil,
                                longitude: nil,
                                addedBy: "",
                                treeId: "primary",
                                timestamp: Int64(Date().timeIntervalSince1970 * 1000)
                            )
                        )
                    }
                    .disabled(!canSave)
                }
            }
        }
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !ownerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !contactNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

private struct EmergencyScreen: View {
    @Bindable var viewModel: AppViewModel

    var body: some View {
        AppBackground {
            NavigationStack {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        locationStatusCard

                        emergencySectionTitle("Call Now")
                        ForEach(emergencyNumbers) { item in
                            EmergencyActionRow(
                                systemImage: item.systemImage,
                                iconColor: item.color,
                                title: item.title,
                                subtitle: "\(item.subtitle) • \(item.number)",
                                actionTitle: "Call",
                                actionImage: "phone.fill",
                                actionURL: URL(string: "tel://\(item.number)")
                            )
                        }

                        emergencySectionTitle("Find Nearby")
                        ForEach(nearbyServices) { service in
                            EmergencyActionRow(
                                systemImage: service.systemImage,
                                iconColor: service.color,
                                title: service.title,
                                subtitle: "Open nearby results in Maps",
                                actionTitle: "Map",
                                actionImage: "map.fill",
                                actionURL: mapsSearchURL(for: service.query)
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
                .navigationTitle("Emergency Help")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    Button(localized("Home", language: viewModel.language)) {
                        viewModel.showDashboard()
                    }
                }
            }
        }
    }

    private var emergencyNumbers: [EmergencyNumber] {
        [
            EmergencyNumber(title: "National Emergency", subtitle: "Police, fire, medical", number: "112", systemImage: "phone.fill", color: Color(red: 0.90, green: 0.22, blue: 0.20)),
            EmergencyNumber(title: "Ambulance", subtitle: "Medical emergency", number: "108", systemImage: "cross.case.fill", color: Color(red: 0.85, green: 0.10, blue: 0.38)),
            EmergencyNumber(title: "Police", subtitle: "Immediate police help", number: "100", systemImage: "shield.lefthalf.filled", color: Color(red: 0.22, green: 0.29, blue: 0.68)),
            EmergencyNumber(title: "Fire", subtitle: "Fire emergency", number: "101", systemImage: "flame.fill", color: Color(red: 0.96, green: 0.32, blue: 0.12)),
            EmergencyNumber(title: "Women Helpline", subtitle: "Emergency support", number: "1091", systemImage: "phone.badge.waveform.fill", color: Color(red: 0.56, green: 0.14, blue: 0.67)),
            EmergencyNumber(title: "Railway Helpline", subtitle: "Railway enquiry/help", number: "139", systemImage: "tram.fill", color: Color(red: 0.00, green: 0.54, blue: 0.48))
        ]
    }

    private var nearbyServices: [NearbyService] {
        [
            NearbyService(title: "Nearby Hospitals", query: "hospital near me", systemImage: "cross.case.fill", color: Color(red: 0.85, green: 0.10, blue: 0.38)),
            NearbyService(title: "Nearby Ambulance", query: "ambulance service near me", systemImage: "cross.fill", color: Color(red: 0.90, green: 0.22, blue: 0.20)),
            NearbyService(title: "Nearby Fire Station", query: "fire station near me", systemImage: "flame.fill", color: Color(red: 0.96, green: 0.32, blue: 0.12)),
            NearbyService(title: "Nearby Police Station", query: "police station near me", systemImage: "shield.lefthalf.filled", color: Color(red: 0.22, green: 0.29, blue: 0.68)),
            NearbyService(title: "Nearby Railway Station", query: "railway station near me", systemImage: "tram.fill", color: Color(red: 0.00, green: 0.54, blue: 0.48))
        ]
    }

    private var locationStatusCard: some View {
        let hasSavedLocation = viewModel.currentUser?.latitude != nil && viewModel.currentUser?.longitude != nil
        return HStack(spacing: 12) {
            Image(systemName: hasSavedLocation ? "location.fill" : "location.slash.fill")
                .font(.title3.weight(.semibold))
                .foregroundStyle(hasSavedLocation ? AndroidLook.accentGold : .secondary)
                .frame(width: 44, height: 44)
                .background(Color.white.opacity(0.84), in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(hasSavedLocation ? "Location ready" : "Location needed for nearby search")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(AndroidLook.deepBrown)
                Text(hasSavedLocation ? "Nearby searches will open in Maps." : "Nearby searches will still open in Maps, but may need your location there.")
                    .font(.caption)
                    .foregroundStyle(AndroidLook.mutedBrown)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.84), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }

    private func emergencySectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.headline.weight(.bold))
            .foregroundStyle(AndroidLook.deepBrown)
            .padding(.top, 4)
    }

    private func mapsSearchURL(for query: String) -> URL? {
        var components = URLComponents(string: "https://maps.apple.com/")
        var items = [URLQueryItem(name: "q", value: query)]
        if let latitude = viewModel.currentUser?.latitude,
           let longitude = viewModel.currentUser?.longitude {
            items.append(URLQueryItem(name: "sll", value: "\(latitude),\(longitude)"))
        }
        components?.queryItems = items
        return components?.url
    }
}

private struct EmergencyNumber: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let number: String
    let systemImage: String
    let color: Color
}

private struct NearbyService: Identifiable {
    let id = UUID()
    let title: String
    let query: String
    let systemImage: String
    let color: Color
}

private struct EmergencyActionRow: View {
    let systemImage: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let actionTitle: String
    let actionImage: String
    let actionURL: URL?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.title3.weight(.semibold))
                .foregroundStyle(iconColor)
                .frame(width: 44, height: 44)
                .background(iconColor.opacity(0.14), in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(AndroidLook.deepBrown)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(AndroidLook.mutedBrown)
                    .lineLimit(2)
            }

            Spacer()

            if let actionURL {
                Link(destination: actionURL) {
                    HStack(spacing: 6) {
                        Image(systemName: actionImage)
                        Text(actionTitle)
                            }
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AndroidLook.deepBrown)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .background(AndroidLook.accentGold, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.84), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }
}

private struct AchievementsScreen: View {
    @Bindable var viewModel: AppViewModel
    @State private var showEditor = false
    @State private var achievementToDelete: CommunityAchievement?

    var body: some View {
        AppBackground {
            NavigationStack {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        if viewModel.communityAchievements.isEmpty {
                            ContentUnavailableView(
                                "Purawale Achievements",
                                systemImage: "trophy.fill",
                                description: Text("No community achievements have been shared yet.")
                            )
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 360)
                        } else {
                            ForEach(viewModel.communityAchievements.sorted { $0.timestamp > $1.timestamp }) { achievement in
                                AchievementCard(
                                    achievement: achievement,
                                    canDelete: viewModel.hasAdminPrivileges || achievement.addedBy == viewModel.currentUser?.id,
                                    onDelete: { achievementToDelete = achievement }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
                .navigationTitle("Purawale Achievements")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(localized("Home", language: viewModel.language)) {
                            viewModel.showDashboard()
                        }
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showEditor = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        .accessibilityLabel("Add Achievement")
                    }
                }
                .sheet(isPresented: $showEditor) {
                    AchievementEditorSheet(
                        currentUser: viewModel.currentUser,
                        onSave: { achievement in
                            viewModel.saveAchievement(achievement)
                            showEditor = false
                        },
                        onCancel: {
                            showEditor = false
                        }
                    )
                }
                .alert("Delete Achievement", isPresented: Binding(
                    get: { achievementToDelete != nil },
                    set: { if !$0 { achievementToDelete = nil } }
                )) {
                    Button("Cancel", role: .cancel) {
                        achievementToDelete = nil
                    }
                    Button("Delete", role: .destructive) {
                        if let achievementToDelete {
                            viewModel.deleteAchievement(achievementToDelete)
                        }
                        achievementToDelete = nil
                    }
                } message: {
                    Text("Are you sure you want to delete this achievement?")
                }
            }
        }
    }
}

private struct AchievementCard: View {
    let achievement: CommunityAchievement
    let canDelete: Bool
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            achievementImage

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 10) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(achievement.title)
                            .font(.title3.weight(.heavy))
                            .foregroundStyle(.white)
                        Text(achievement.memberName)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(AndroidLook.accentGold)
                    }

                    Spacer()

                    if canDelete {
                        Button(action: onDelete) {
                            Image(systemName: "trash.fill")
                                .frame(width: 34, height: 34)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.red)
                    }
                }

                if !achievement.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(achievement.description)
                        .font(.subheadline)
                        .foregroundStyle(Color.white.opacity(0.80))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Label(achievement.date.isEmpty ? "Date not set" : achievement.date, systemImage: "calendar")
                    if !achievement.location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Label(achievement.location, systemImage: "location.fill")
                    }
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.white.opacity(0.86))

                if let mapsURL = sanitizedURL(achievement.mapsLink) {
                    Link(destination: mapsURL) {
                        Label("View on Map", systemImage: "map.fill")
                            .font(.subheadline.weight(.bold))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(AndroidLook.accentGold)
                }
            }
            .padding(16)
        }
        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }

    @ViewBuilder
    private var achievementImage: some View {
        if let data = imageData(fromStoredPhoto: achievement.imageURL), let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .clipped()
        } else if let url = sanitizedURL(achievement.imageURL) {
            CachedRemoteImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(height: 200)
            .frame(maxWidth: .infinity)
            .clipped()
        }
    }

    private func sanitizedURL(_ value: String) -> URL? {
        var string = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !string.isEmpty else { return nil }
        if !string.localizedCaseInsensitiveContains("://") {
            string = "https://\(string)"
        }
        return URL(string: string)
    }
}

private struct AchievementEditorSheet: View {
    let currentUser: Member?
    let onSave: (CommunityAchievement) -> Void
    let onCancel: () -> Void

    @State private var title = ""
    @State private var memberName = ""
    @State private var description = ""
    @State private var date = Member.isoDateFormatter.string(from: .now)
    @State private var location = ""
    @State private var mapsLink = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data?

    var body: some View {
        NavigationStack {
            Form {
                Section("Achievement") {
                    TextField("Achievement Title", text: $title)
                    TextField("Member Name", text: $memberName)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(2...5)
                    ISODatePickerRow(title: "Date", value: $date, allowsClear: true)
                }

                Section("Location") {
                    TextField("Location", text: $location)
                    TextField("Maps Link", text: $mapsLink, axis: .vertical)
                }

                Section("Photo") {
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Label(selectedImageData == nil ? "Add Photo" : "Photo Selected", systemImage: "photo")
                    }
                    if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
            }
            .task(id: selectedPhotoItem) {
                guard let selectedPhotoItem else { return }
                selectedImageData = try? await selectedPhotoItem.loadTransferable(type: Data.self)
            }
            .navigationTitle("Add Achievement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onSave(
                            CommunityAchievement(
                                id: UUID().uuidString,
                                memberName: memberName.trimmingCharacters(in: .whitespacesAndNewlines),
                                memberId: nil,
                                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                                description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                                date: date.trimmingCharacters(in: .whitespacesAndNewlines),
                                location: location.trimmingCharacters(in: .whitespacesAndNewlines),
                                mapsLink: mapsLink.trimmingCharacters(in: .whitespacesAndNewlines),
                                imageURL: imageString,
                                timestamp: .now,
                                addedBy: currentUser?.id ?? ""
                            )
                        )
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || memberName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                if memberName.isEmpty {
                    memberName = currentUser?.name ?? ""
                }
            }
        }
    }

    private var imageString: String {
        guard let selectedImageData, let image = UIImage(data: selectedImageData), let data = image.jpegData(compressionQuality: 0.78) else {
            return ""
        }
        return storedPhotoString(from: data)
    }
}

private struct ActivityLogScreen: View {
    @Bindable var viewModel: AppViewModel

    var body: some View {
        AppBackground {
            NavigationStack {
                List {
                    Section("Recent App Activity") {
                        ActivityLogRow(icon: "person.3.fill", title: "Approved profiles", detail: "\(viewModel.approvedMembers.count) members")
                        ActivityLogRow(icon: "photo.fill", title: "Memory posts", detail: "\(viewModel.approvedMemories.count) visible posts")
                        ActivityLogRow(icon: "text.bubble.fill", title: "Discussion threads", detail: "\(viewModel.visibleDiscussions.count) visible threads")
                        ActivityLogRow(icon: "trash.fill", title: "Deletion requests", detail: "\(viewModel.pendingDeletionCount) pending")
                        ActivityLogRow(icon: "arrow.triangle.branch", title: "Relationship requests", detail: "\(viewModel.pendingOverrideCount) pending")
                    }
                }
                .scrollContentBackground(.hidden)
                .navigationTitle(localized("Activity Log", language: viewModel.language))
                .toolbar { Button(localized("Home", language: viewModel.language)) { viewModel.showDashboard() } }
            }
        }
    }
}

private struct LoginLogScreen: View {
    @Bindable var viewModel: AppViewModel

    var body: some View {
        AppBackground {
            NavigationStack {
                List {
                    Section("Recent Sign-ins") {
                        ForEach(viewModel.approvedMembers.filter { $0.lastLoggedIn != nil }.sorted { ($0.lastLoggedIn ?? 0) > ($1.lastLoggedIn ?? 0) }.prefix(30)) { member in
                            HStack(spacing: 12) {
                                AvatarView(member: member, size: 34)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(member.name)
                                        .font(.subheadline.weight(.semibold))
                                    Text(loginDisplayDate(member.lastLoggedIn) ?? "No login timestamp")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .navigationTitle(localized("Login Log", language: viewModel.language))
                .toolbar { Button(localized("Home", language: viewModel.language)) { viewModel.showDashboard() } }
            }
        }
    }
}

private struct ActivityLogRow: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: icon)
                .foregroundStyle(AndroidLook.accentGold)
        }
    }
}

private struct PlaceholderFeatureScreen: View {
    @Bindable var viewModel: AppViewModel
    let title: String
    let systemImage: String
    let message: String

    var body: some View {
        AppBackground {
            NavigationStack {
                VStack(spacing: 16) {
                    Image(systemName: systemImage)
                        .font(.system(size: 48, weight: .semibold))
                        .foregroundStyle(AndroidLook.accentGold)
                    Text(title)
                        .font(.title2.weight(.bold))
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationTitle(title)
                .toolbar { Button(localized("Home", language: viewModel.language)) { viewModel.showDashboard() } }
            }
        }
    }
}

private struct MemberEventRow: View {
    let member: Member

    var body: some View {
        FamilyEventRow(
            event: DashboardFamilyEvent(
                id: "\(member.id)-birthday-row",
                member: member,
                type: .birthday,
                date: nextBirthdayDate,
                daysUntil: member.daysUntilBirthday() ?? .max
            ),
            language: .english
        )
    }

    private var nextBirthdayDate: Date {
        let calendar = Calendar.current
        guard let birthDate = member.birthDateValue else { return .now }
        let month = calendar.component(.month, from: birthDate)
        let day = calendar.component(.day, from: birthDate)
        let year = calendar.component(.year, from: Date.now)
        let currentYear = calendar.date(from: DateComponents(year: year, month: month, day: day)) ?? .now
        if calendar.startOfDay(for: currentYear) < calendar.startOfDay(for: .now) {
            return calendar.date(byAdding: .year, value: 1, to: currentYear) ?? currentYear
        }
        return currentYear
    }
}

private struct ChannelRow: View {
    let channel: ChatChannel
    let otherMember: Member
    let unreadCount: Int

    var body: some View {
        HStack(spacing: 12) {
            AvatarView(member: otherMember, size: 42)

            VStack(alignment: .leading, spacing: 4) {
                Text(otherMember.name)
                    .foregroundStyle(.primary)
                    .fontWeight(unreadCount > 0 ? .bold : .regular)
                Text(channel.lastMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text(channel.lastTimestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if unreadCount > 0 {
                    Text("\(unreadCount)")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange, in: Capsule())
                }
            }
        }
        .padding(.vertical, 4)
    }
}

private struct MessageBubble: View {
    let message: ChatMessage
    let isCurrentUser: Bool

    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer(minLength: 50)
            }

            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 6) {
                Text(message.text)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        isCurrentUser ? Color.orange.opacity(0.18) : Color.black.opacity(0.06),
                        in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                    )

                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            if !isCurrentUser {
                Spacer(minLength: 50)
            }
        }
    }
}

private struct AvatarView: View {
    let member: Member
    let size: CGFloat

    var body: some View {
        Group {
            if let data = imageData(fromStoredPhoto: member.photoURL), let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else if let url = imageURL(fromStoredPhoto: member.photoURL) {
                CachedRemoteImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    placeholder
                }
            } else {
                placeholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    private var placeholder: some View {
        Circle()
            .fill(Color.orange.opacity(0.14))
            .overlay {
                Text(member.initials)
                    .font(.system(size: size * 0.34, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.orange)
            }
    }
}

private struct ProfilePhotoEditor: View {
    let member: Member
    let storedPhoto: String
    let selectedImageData: Data?
    let adjustments: CardPhotoAdjustments

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.black.opacity(0.08))

            photoImage
                .scaledToFill()
                .scaleEffect(adjustments.scale)
                .offset(x: adjustments.offsetX, y: adjustments.offsetY)
                .rotationEffect(.degrees(adjustments.rotation))
                .brightness(adjustments.brightness)
                .contrast(adjustments.contrast)
                .saturation(adjustments.saturation)
        }
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.secondary.opacity(0.22), lineWidth: 1)
        )
    }

    @ViewBuilder
    private var photoImage: some View {
        if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
            Image(uiImage: uiImage)
                .resizable()
        } else if let data = imageData(fromStoredPhoto: storedPhoto), let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
        } else if let url = imageURL(fromStoredPhoto: storedPhoto) {
            CachedRemoteImage(url: url) { image in
                image.resizable()
            } placeholder: {
                placeholder
            }
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        Rectangle()
            .fill(AndroidLook.lightGolden.opacity(0.36))
            .overlay {
                VStack(spacing: 8) {
                    Image(systemName: "person.crop.square")
                        .font(.title)
                    Text(member.initials)
                        .font(.title2.weight(.bold))
                }
                .foregroundStyle(AndroidLook.softBrown)
            }
    }
}

private extension UIImage {
    func editedSquareJPEGData(adjustments: CardPhotoAdjustments, side: CGFloat = 900) -> Data? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: side, height: side), format: format)
        let rendered = renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(x: 0, y: 0, width: side, height: side))

            let cgContext = context.cgContext
            cgContext.translateBy(x: side / 2 + adjustments.offsetX * 2.7, y: side / 2 + adjustments.offsetY * 2.7)
            cgContext.rotate(by: CGFloat(adjustments.rotation * .pi / 180))

            let aspectFill = max(side / size.width, side / size.height)
            let drawWidth = size.width * aspectFill * adjustments.scale
            let drawHeight = size.height * aspectFill * adjustments.scale
            draw(in: CGRect(x: -drawWidth / 2, y: -drawHeight / 2, width: drawWidth, height: drawHeight))
        }

        let tuned = rendered.applyingColorControls(
            brightness: adjustments.brightness,
            contrast: adjustments.contrast,
            saturation: adjustments.saturation
        )
        return tuned.jpegData(compressionQuality: 0.82)
    }

    func applyingColorControls(brightness: Double, contrast: Double, saturation: Double) -> UIImage {
        guard brightness != 0 || contrast != 1 || saturation != 1,
              let ciImage = CIImage(image: self) else {
            return self
        }

        let filter = CIFilter.colorControls()
        filter.inputImage = ciImage
        filter.brightness = Float(brightness)
        filter.contrast = Float(contrast)
        filter.saturation = Float(saturation)

        guard let output = filter.outputImage,
              let cgImage = CIContext().createCGImage(output, from: output.extent) else {
            return self
        }
        return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
    }
}

private struct StatTile: View {
    let title: String
    let value: String
    let layoutScale: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: max(3.0, 4.0 * layoutScale)) {
            Text(value)
                .font(.system(size: max(16.0, 18.0 * layoutScale), weight: .bold, design: .rounded))
                .foregroundStyle(AndroidLook.deepBrown)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(title)
                .font(.system(size: max(10.0, 12.0 * layoutScale), weight: .regular, design: .default))
                .foregroundStyle(AndroidLook.mutedBrown)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(max(10.0, 12.0 * layoutScale))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.84), in: RoundedRectangle(cornerRadius: max(14.0, 16.0 * layoutScale), style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: max(14.0, 16.0 * layoutScale), style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }
}

private struct DashboardWeatherTile: View {
    @StateObject private var weatherModel = DashboardWeatherModel()
    let layoutScale: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: max(3.0, 4.0 * layoutScale)) {
            HStack(spacing: 6) {
                Text(weatherModel.icon)
                    .font(.system(size: max(15.0, 17.0 * layoutScale)))
                Text(weatherModel.temperatureText)
                    .font(.system(size: max(16.0, 18.0 * layoutScale), weight: .bold, design: .rounded))
                    .foregroundStyle(AndroidLook.deepBrown)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            Text(weatherModel.summaryText)
                .font(.system(size: max(10.0, 12.0 * layoutScale), weight: .regular, design: .default))
                .foregroundStyle(AndroidLook.mutedBrown)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .padding(max(10.0, 12.0 * layoutScale))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.84), in: RoundedRectangle(cornerRadius: max(14.0, 16.0 * layoutScale), style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: max(14.0, 16.0 * layoutScale), style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
        .task {
            weatherModel.requestWeather()
        }
    }
}

private let dashboardWeatherLogger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "CircleBirthdays",
    category: "DashboardWeather"
)

@MainActor
private final class DashboardWeatherModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var temperatureText = "--"
    @Published var summaryText = "Weather"
    @Published var icon = "○"

    private let locationManager = CLLocationManager()
    private var didRequestWeather = false

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }

    func requestWeather() {
        guard !didRequestWeather else { return }
        didRequestWeather = true

        guard CLLocationManager.locationServicesEnabled() else {
            dashboardWeatherLogger.error("Location services are disabled; WeatherKit request will not start.")
            summaryText = "Location off"
            icon = "⌖"
            return
        }

        dashboardWeatherLogger.info("Weather request started. Authorization: \(String(describing: self.locationManager.authorizationStatus), privacy: .public)")

        switch locationManager.authorizationStatus {
        case .notDetermined:
            summaryText = "Allow location"
            icon = "⌖"
            dashboardWeatherLogger.info("Requesting location authorization before WeatherKit fetch.")
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            summaryText = "Locating"
            icon = "⌖"
            dashboardWeatherLogger.info("Requesting current location for WeatherKit fetch.")
            locationManager.requestLocation()
        case .denied, .restricted:
            summaryText = "Location off"
            icon = "⌖"
            dashboardWeatherLogger.error("Location authorization denied or restricted; WeatherKit request will not start.")
        @unknown default:
            summaryText = "Weather"
            dashboardWeatherLogger.error("Unknown location authorization status; WeatherKit request will not start.")
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            dashboardWeatherLogger.info("Location authorization changed: \(String(describing: manager.authorizationStatus), privacy: .public)")
            guard manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse else {
                if manager.authorizationStatus == .denied || manager.authorizationStatus == .restricted {
                    summaryText = "Location off"
                    icon = "⌖"
                    dashboardWeatherLogger.error("Location authorization denied or restricted after prompt.")
                }
                return
            }
            summaryText = "Locating"
            dashboardWeatherLogger.info("Location authorized; requesting current location.")
            manager.requestLocation()
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            dashboardWeatherLogger.info("Location received for WeatherKit fetch: lat \(location.coordinate.latitude, privacy: .public), lon \(location.coordinate.longitude, privacy: .public)")
            await fetchWeather(for: location)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            temperatureText = "--"
            summaryText = "Weather unavailable"
            icon = "○"
            dashboardWeatherLogger.error("Location request failed before WeatherKit fetch: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func fetchWeather(for location: CLLocation) async {
        #if canImport(WeatherKit)
        do {
            dashboardWeatherLogger.info("Calling WeatherKit WeatherService.shared.weather(for:).")
            let weather = try await WeatherService.shared.weather(for: location)
            let current = weather.currentWeather
            let celsius = current.temperature.converted(to: .celsius).value
            let condition = String(describing: current.condition)
            let windKph = current.wind.speed.converted(to: .kilometersPerHour).value

            temperatureText = "\(Int(celsius.rounded()))°C"
            summaryText = Self.summary(for: condition, windKph: windKph)
            icon = Self.icon(for: summaryText)
            dashboardWeatherLogger.info("WeatherKit fetch succeeded. Condition: \(condition, privacy: .public), tempC: \(celsius, privacy: .public)")
        } catch {
            temperatureText = "--"
            summaryText = "Weather unavailable"
            icon = "○"
            dashboardWeatherLogger.error("WeatherKit fetch failed: \(error.localizedDescription, privacy: .public)")
        }
        #else
        temperatureText = "--"
        summaryText = "WeatherKit off"
        icon = "○"
        dashboardWeatherLogger.error("WeatherKit framework is not available in this build.")
        #endif
    }

    private static func summary(for condition: String, windKph: Double) -> String {
        if windKph >= 24 {
            return "Windy"
        }

        let lower = condition.lowercased()
        if lower.contains("cloud") || lower.contains("overcast") || lower.contains("fog") || lower.contains("haze") {
            return "Cloudy"
        }
        if lower.contains("rain") || lower.contains("drizzle") || lower.contains("storm") {
            return "Rainy"
        }
        return "Sunny"
    }

    private static func icon(for summary: String) -> String {
        switch summary {
        case "Cloudy": return "☁"
        case "Windy": return "≋"
        case "Rainy": return "☂"
        default: return "☀"
        }
    }
}

private struct DashboardActionLabel<Background: ShapeStyle>: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let tint: Color
    let background: Background
    let layoutScale: CGFloat
    let tilePadding: CGFloat

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.white.opacity(0.84))

            VStack(alignment: .center, spacing: max(7.0, 8.0 * layoutScale)) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(AndroidLook.lightGolden.opacity(0.34))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(AndroidLook.accentGold.opacity(0.24), lineWidth: 1)
                        )
                    Image(systemName: systemImage)
                        .font(.system(size: max(22.0, 28.0 * layoutScale), weight: .semibold))
                        .foregroundStyle(AndroidLook.accentGold)
                }
                .frame(width: max(48.0, 54.0 * layoutScale), height: max(48.0, 54.0 * layoutScale))

                Text(title)
                    .font(.system(size: max(12.0, 13.0 * layoutScale), weight: .heavy))
                    .foregroundStyle(AndroidLook.deepBrown)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)

                Text(subtitle)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(AndroidLook.mutedBrown)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .padding(tilePadding)
        }
        .frame(maxWidth: .infinity, minHeight: max(104.0, 112.0 * layoutScale), alignment: .center)
        .clipShape(RoundedRectangle(cornerRadius: max(14.0, 16.0 * layoutScale), style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: max(14.0, 16.0 * layoutScale), style: .continuous)
                .strokeBorder(Color.black.opacity(0.08), lineWidth: 1)
        )
    }
}

struct MemberEditScreen: View {
    let originalMember: Member
    let canSaveDirectly: Bool
    let showsFamilyId: Bool
    let language: AppLanguage
    let onSave: (Member) -> Void
    let onRequestOverride: (String) -> Void
    let onCancel: () -> Void

    @State private var name: String
    @State private var dateOfBirth: String
    @State private var phoneNumber: String
    @State private var email: String
    @State private var location: String
    @State private var spouseName: String
    @State private var fatherName: String
    @State private var motherName: String
    @State private var marriageDate: String
    @State private var bereavementDate: String
    @State private var immediateFamily: String
    @State private var address: String
    @State private var latitude: Double?
    @State private var longitude: Double?
    @State private var flatNumber: String
    @State private var floor: String
    @State private var landmark: String
    @State private var relationship: String
    @State private var photoURL: String
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var photoAdjustments = CardPhotoAdjustments()
    @State private var facebookURL: String
    @State private var instagramURL: String
    @State private var youtubeURL: String
    @State private var relationshipMenuExpanded = false
    @State private var isAddressPickerPresented = false

    init(
        originalMember: Member,
        canSaveDirectly: Bool,
        showsFamilyId: Bool = false,
        language: AppLanguage,
        onSave: @escaping (Member) -> Void,
        onRequestOverride: @escaping (String) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.originalMember = originalMember
        self.canSaveDirectly = canSaveDirectly
        self.showsFamilyId = showsFamilyId
        self.language = language
        self.onSave = onSave
        self.onRequestOverride = onRequestOverride
        self.onCancel = onCancel
        _name = State(initialValue: originalMember.name)
        _dateOfBirth = State(initialValue: originalMember.dateOfBirth)
        _phoneNumber = State(initialValue: originalMember.phoneNumber)
        _email = State(initialValue: originalMember.email ?? "")
        _location = State(initialValue: originalMember.location ?? "")
        _spouseName = State(initialValue: originalMember.spouseName ?? "")
        _fatherName = State(initialValue: originalMember.fatherName ?? "")
        _motherName = State(initialValue: originalMember.motherName ?? "")
        _marriageDate = State(initialValue: originalMember.marriageDate ?? "")
        _bereavementDate = State(initialValue: originalMember.bereavementDate ?? "")
        _immediateFamily = State(initialValue: originalMember.immediateFamily)
        _address = State(initialValue: originalMember.address ?? "")
        _latitude = State(initialValue: originalMember.latitude)
        _longitude = State(initialValue: originalMember.longitude)
        _flatNumber = State(initialValue: originalMember.flatNumber ?? "")
        _floor = State(initialValue: originalMember.floor ?? "")
        _landmark = State(initialValue: originalMember.landmark ?? "")
        _relationship = State(initialValue: originalMember.relationship ?? "")
        _photoURL = State(initialValue: originalMember.photoURL ?? "")
        _facebookURL = State(initialValue: originalMember.facebookURL ?? "")
        _instagramURL = State(initialValue: originalMember.instagramURL ?? "")
        _youtubeURL = State(initialValue: originalMember.youtubeURL ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(localized("Basic", language: language)) {
                    if showsFamilyId {
                        LabeledContent("Family ID") {
                            Text(originalMember.familyId.isEmpty ? "Not set" : originalMember.familyId)
                                .font(.body.monospaced().weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                    }
                    TextField("Name", text: $name)
                    ISODatePickerRow(title: "Date of Birth", value: $dateOfBirth, allowsClear: false)
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                }

                Section(localized("Family", language: language)) {
                    TextField("Spouse", text: $spouseName)
                    TextField("Father", text: $fatherName)
                    TextField("Mother", text: $motherName)
                    ISODatePickerRow(title: "Marriage Date", value: $marriageDate, allowsClear: true)
                    ISODatePickerRow(title: "Bereavement Date", value: $bereavementDate, allowsClear: true)
                    TextField("Immediate Family", text: $immediateFamily, axis: .vertical)
                    TextField("Location", text: $location)
                    TextField("Address", text: $address, axis: .vertical)
                    HStack {
                        TextField("Flat/House No.", text: $flatNumber)
                        TextField("Floor", text: $floor)
                    }
                    TextField("Landmark", text: $landmark)
                    Button {
                        isAddressPickerPresented = true
                    } label: {
                        Label(latitude == nil || longitude == nil ? "Locate on Map" : "Update Map Location", systemImage: "location.fill")
                    }
                    if let latitude, let longitude {
                        Link(destination: mapURL(latitude: latitude, longitude: longitude)) {
                            Label("View on Map", systemImage: "map")
                        }
                    }
                    TextField("Relationship", text: $relationship)
                    if !canSaveDirectly {
                        Menu {
                            ForEach(relationshipSuggestions, id: \.self) { suggestion in
                                Button(suggestion) {
                                    relationship = suggestion
                                    onRequestOverride(suggestion)
                                }
                            }
                        } label: {
                            Label("Request Relationship Change", systemImage: "person.crop.circle.badge.questionmark")
                        }
                    }
                }

                Section(localized("Media & Social", language: language)) {
                    VStack(alignment: .leading, spacing: 12) {
                        ProfilePhotoEditor(
                            member: originalMember,
                            storedPhoto: photoURL,
                            selectedImageData: selectedImageData,
                            adjustments: photoAdjustments
                        )
                        .frame(maxWidth: .infinity)

                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            Label(hasProfilePhoto ? "Change Profile Photo" : "Choose Profile Photo", systemImage: "photo")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)

                        PhotoEditControls(
                            adjustments: $photoAdjustments,
                            onReset: { photoAdjustments = CardPhotoAdjustments() }
                        )
                    }

                    TextField("Facebook URL", text: $facebookURL, axis: .vertical)
                    TextField("Instagram URL", text: $instagramURL, axis: .vertical)
                    TextField("YouTube URL", text: $youtubeURL, axis: .vertical)
                }

                Section {
                    Text(canSaveDirectly ? "Saving will update this profile directly." : "Saving will submit this profile for admin approval.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    if !canSaveDirectly {
                        Text("If you select a relationship and save, it will be treated as a request.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .task(id: selectedPhotoItem) {
                guard let selectedPhotoItem else { return }
                if let data = try? await selectedPhotoItem.loadTransferable(type: Data.self) {
                    selectedImageData = data
                    photoAdjustments = CardPhotoAdjustments()
                }
            }
            .navigationTitle(localized("Edit Profile", language: language))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(
                            Member(
                                id: originalMember.id,
                                familyId: originalMember.familyId,
                                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                                gender: originalMember.gender,
                                dateOfBirth: dateOfBirth.trimmingCharacters(in: .whitespacesAndNewlines),
                                phoneNumber: phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines),
                                email: emptyToNil(email),
                                location: emptyToNil(location),
                                spouseName: emptyToNil(spouseName),
                                fatherName: emptyToNil(fatherName),
                                motherName: emptyToNil(motherName),
                                marriageDate: emptyToNil(marriageDate),
                                bereavementDate: emptyToNil(bereavementDate),
                                photoURL: finalPhotoURL(),
                                immediateFamily: immediateFamily.trimmingCharacters(in: .whitespacesAndNewlines),
                                address: emptyToNil(address),
                                latitude: latitude,
                                longitude: longitude,
                                flatNumber: emptyToNil(flatNumber),
                                floor: emptyToNil(floor),
                                landmark: emptyToNil(landmark),
                                password: originalMember.password,
                                isAdmin: originalMember.isAdmin,
                                isEditor: originalMember.isEditor,
                                status: originalMember.status,
                                lastLoggedIn: originalMember.lastLoggedIn,
                                relationship: emptyToNil(relationship),
                                fcmToken: originalMember.fcmToken,
                                facebookURL: emptyToNil(facebookURL),
                                instagramURL: emptyToNil(instagramURL),
                                youtubeURL: emptyToNil(youtubeURL),
                                manualRelationships: originalMember.manualRelationships,
                                requestedBy: originalMember.requestedBy,
                                requestedByName: originalMember.requestedByName,
                                requestedRelationship: originalMember.requestedRelationship
                            )
                        )
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .sheet(isPresented: $isAddressPickerPresented) {
                AddressPickerView(
                    initialAddress: address,
                    initialCoordinate: coordinate,
                    language: language,
                    onSelect: { picked in
                        address = picked.address
                        latitude = picked.latitude
                        longitude = picked.longitude
                        if location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            location = cityFromAddress(picked.address)
                        }
                        isAddressPickerPresented = false
                    },
                    onCancel: {
                        isAddressPickerPresented = false
                    }
                )
            }
        }
    }

    private func finalPhotoURL() -> String? {
        guard let selectedImageData, let image = UIImage(data: selectedImageData) else {
            return emptyToNil(photoURL)
        }
        guard let editedData = image.editedSquareJPEGData(adjustments: photoAdjustments) else {
            return emptyToNil(photoURL)
        }
        return storedPhotoString(from: editedData)
    }

    private var hasProfilePhoto: Bool {
        selectedImageData != nil || !photoURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func emptyToNil(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private var coordinate: CLLocationCoordinate2D? {
        guard let latitude, let longitude else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    private func mapURL(latitude: Double, longitude: Double) -> URL {
        let query = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://maps.apple.com/?ll=\(latitude),\(longitude)&q=\(query)")!
    }

    private func cityFromAddress(_ address: String) -> String {
        address
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .dropLast()
            .last ?? ""
    }

    private var relationshipSuggestions: [String] {
        [
            "Dadaji", "Bade Dadaji", "Chote Dadaji", "Dadi", "Badi Dadi", "Choti Dadi",
            "Nana", "Bade Nana", "Chote Nana", "Nani", "Badi Nani", "Choti Nani",
            "Papa", "Mummy", "Bade Papa", "Badi Amma", "Chachaji", "Chachiji",
            "Bade Mamaji", "Chote Mamaji", "Badi Mamiji", "Choti Mamiji", "Bhaiya",
            "Bhabhi", "Didi", "Jijaji", "Bade Mausa", "Chote Mausa", "Badi Mausi",
            "Choti Mausi", "Bade Fufa", "Chote Fufa", "Badi Bua", "Choti Bua",
            "Bhatija", "Bhatiji", "Bhanja", "Bhanji", "Beta", "Beti", "Pota",
            "Poti", "Nati", "Natin", "Bahu", "Damand", "Sasurji", "Saasuma",
            "Devar", "Jeth", "Nanad", "Saala", "Saali"
        ]
    }
}

private struct SocialLinkDot: View {
    let symbol: String
    let color: Color
    let isVisible: Bool

    var body: some View {
        Group {
            if isVisible {
                Image(systemName: symbol)
                    .foregroundStyle(color)
            } else {
                EmptyView()
            }
        }
    }
}

private struct ISODatePickerRow: View {
    let title: String
    @Binding var value: String
    let allowsClear: Bool

    private var dateBinding: Binding<Date> {
        Binding(
            get: {
                Member.isoDateFormatter.date(from: value) ?? .now
            },
            set: { newValue in
                value = Member.isoDateFormatter.string(from: newValue)
            }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                Spacer()
                if allowsClear && !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Button("Clear") {
                        value = ""
                    }
                    .font(.caption.weight(.semibold))
                    .buttonStyle(.borderless)
                }
            }

            DatePicker(
                value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && allowsClear ? "Not set" : value,
                selection: dateBinding,
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
        }
    }
}

struct MemberDetailScreen: View {
    let member: Member
    let canEdit: Bool
    let language: AppLanguage
    let onEdit: () -> Void
    let onClose: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    profileSection
                    familySection
                    if hasSocialLinks {
                        socialSection
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .navigationTitle(localized("Profile", language: language))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: onClose)
                }
                if canEdit {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Edit", action: onEdit)
                    }
                }
            }
        }
    }

    private var header: some View {
        HStack(spacing: 16) {
            AvatarView(member: member, size: 72)
            VStack(alignment: .leading, spacing: 6) {
                Text(profileDisplayCase(member.name) ?? member.name)
                    .font(.title2.weight(.bold))
                Text(profileDisplayCase(member.relationship) ?? "No relationship set")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(member.phoneNumber.isEmpty ? "No phone number" : member.phoneNumber)
                    .font(.subheadline)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.orange.opacity(0.10), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var profileSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Profile Details")
                .font(.headline)
            DetailRow(label: "DOB", value: member.dateOfBirth)
            DetailRow(label: "Email", value: member.email)
            DetailRow(label: "Location", value: profileDisplayCase(member.location))
            DetailRow(label: "Address", value: profileDisplayCase(member.address))
            DetailRow(label: "Flat/Floor", value: profileDisplayCase([member.flatNumber, member.floor].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: ", ")))
            DetailRow(label: "Landmark", value: profileDisplayCase(member.landmark))
            if let latitude = member.latitude, let longitude = member.longitude {
                Link(destination: mapURL(latitude: latitude, longitude: longitude)) {
                    Label("View on Map", systemImage: "map")
                        .font(.subheadline.weight(.semibold))
                }
            }
            DetailRow(label: "Spouse", value: profileDisplayCase(member.spouseName))
            DetailRow(label: "Parents", value: profileDisplayCase([member.fatherName, member.motherName].compactMap { $0 }.joined(separator: " & ")))
            DetailRow(label: "Marriage", value: member.marriageDate)
            DetailRow(label: "Bereavement", value: member.bereavementDate)
            DetailRow(label: "Immediate Family", value: profileDisplayCase(member.immediateFamily))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.black.opacity(0.04), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func mapURL(latitude: Double, longitude: Double) -> URL {
        let query = (member.address ?? member.location ?? member.name).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://maps.apple.com/?ll=\(latitude),\(longitude)&q=\(query)")!
    }

    private var familySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Relationship")
                .font(.headline)
            DetailRow(label: "Global", value: profileDisplayCase(member.relationship))
            if !member.manualRelationships.isEmpty {
                ForEach(member.manualRelationships.sorted(by: { $0.key < $1.key }), id: \.key) { entry in
                    DetailRow(label: profileDisplayCase(entry.key) ?? entry.key, value: profileDisplayCase(entry.value))
                }
            } else {
                Text("No manual relationship overrides yet.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.black.opacity(0.04), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var socialSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Social")
                .font(.headline)
            HStack(spacing: 10) {
                if let url = socialURL(member.facebookURL) {
                    socialIconLink(url: url, systemImage: "f.circle.fill", color: .blue, label: "Facebook")
                }
                if let url = socialURL(member.instagramURL) {
                    socialIconLink(url: url, systemImage: "camera.circle.fill", color: .pink, label: "Instagram")
                }
                if let url = socialURL(member.youtubeURL) {
                    socialIconLink(url: url, systemImage: "play.rectangle.fill", color: .red, label: "YouTube")
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.black.opacity(0.04), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var hasSocialLinks: Bool {
        socialURL(member.facebookURL) != nil || socialURL(member.instagramURL) != nil || socialURL(member.youtubeURL) != nil
    }

    private func socialIconLink(url: URL, systemImage: String, color: Color, label: String) -> some View {
        Link(destination: url) {
            Image(systemName: systemImage)
                .font(.title3.weight(.semibold))
                .foregroundStyle(color)
                .frame(width: 38, height: 38)
                .background(color.opacity(0.12), in: Circle())
        }
        .accessibilityLabel(label)
    }

    private func socialURL(_ value: String?) -> URL? {
        guard var string = value?.trimmingCharacters(in: .whitespacesAndNewlines), !string.isEmpty else { return nil }
        if !string.localizedCaseInsensitiveContains("://") {
            string = "https://\(string)"
        }
        return URL(string: string)
    }
}

private struct FamilyTreeScreen: View {
    let member: Member
    let allMembers: [Member]
    let canEdit: Bool
    let language: AppLanguage
    let onEdit: () -> Void
    let onClose: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    FamilyTreeView(member: member, allMembers: allMembers)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .navigationTitle(localized("Family Tree", language: language))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: onClose)
                }
                if canEdit {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Edit", action: onEdit)
                    }
                }
            }
        }
    }

    private var header: some View {
        HStack(spacing: 16) {
            AvatarView(member: member, size: 72)
            VStack(alignment: .leading, spacing: 6) {
                Text(member.name)
                    .font(.title2.weight(.bold))
                Text(member.familyId.isEmpty ? "No family ID" : "Family ID: \(member.familyId)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(member.relationship ?? "No relationship set")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.orange.opacity(0.10), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct WholeFamilyTreeScreen: View {
    @Bindable var viewModel: AppViewModel

    var body: some View {
        let members = viewModel.allResolvedMembers
        NavigationStack {
            FamilyTreeCanvas(
                members: members,
                currentUser: viewModel.currentUser,
                language: viewModel.language,
                onMemberTap: { _ in }
            )
            .navigationTitle(localized("Family Tree", language: viewModel.language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        viewModel.showDashboard()
                    } label: {
                        Label(localized("Home", language: viewModel.language), systemImage: "house")
                    }
                }
            }
        }
    }
}

private struct DetailRow: View {
    let label: String
    let value: String?

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(width: min(110, UIScreen.main.bounds.width * 0.28), alignment: .leading)
            Text(value?.isEmpty == false ? value! : "Not set")
                .font(.subheadline)
            Spacer()
        }
    }
}

private struct RelationshipOverrideRow: View {
    let override: RelationshipOverride
    let onApprove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(override.observerName) -> \(override.targetName)")
                .font(.headline)
            Text("Requested: \(override.relationship)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack {
                Spacer()
                ApprovalIconButton(systemImage: "checkmark", title: "Approve", tint: .green, action: onApprove)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct ContentApprovalRow: View {
    let title: String
    let detail: String
    let onApprove: () -> Void
    let onReject: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .lineLimit(2)
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            ApprovalIconButton(systemImage: "xmark", title: "Reject", role: .destructive, action: onReject)
            ApprovalIconButton(systemImage: "checkmark", title: "Approve", tint: .green, action: onApprove)
        }
        .padding(.vertical, 4)
    }
}

private struct SignupApprovalRow: View {
    let request: SignupRequest
    let suggestedMember: Member?
    let assignableMembers: [Member]
    let onApprove: (Member) -> Void
    let onReject: () -> Void
    @State private var selectedMemberID: String?

    private var selectedMember: Member? {
        let resolvedID = selectedMemberID ?? suggestedMember?.id
        return assignableMembers.first { $0.id == resolvedID }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(request.name)
                .font(.headline)

            Text("Parent: \(request.parentName)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("Mobile: \(request.mobileNumber)\(request.email.isEmpty ? "" : " • \(request.email)")")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                Menu {
                    ForEach(assignableMembers) { member in
                        Button(member.name) {
                            selectedMemberID = member.id
                        }
                    }
                } label: {
                    Label(selectedMember?.name ?? "Choose profile", systemImage: "person.crop.circle.badge.checkmark")
                        .font(.caption.weight(.semibold))
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                ApprovalIconButton(systemImage: "xmark", title: "Reject", role: .destructive, action: onReject)
                ApprovalIconButton(systemImage: "checkmark", title: "Save", tint: .green) {
                    if let selectedMember {
                        onApprove(selectedMember)
                    }
                }
                .disabled(selectedMember == nil)
            }

            if let suggestedMember {
                Text("Suggested: \(suggestedMember.name)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                Text("No confident match. Reassign to a profile or reject.")
                    .font(.caption2)
                    .foregroundStyle(.orange)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct DeletionRequestRow: View {
    let request: DeletionRequest
    let onApprove: () -> Void
    let onReject: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(request.title)
                .font(.headline)
            Text("\(request.collectionName) • \(request.reason)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Requested by \(request.requestedByName)")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack {
                ApprovalIconButton(systemImage: "xmark", title: "Reject", role: .destructive, action: onReject)
                Spacer()
                ApprovalIconButton(systemImage: "checkmark", title: "Approve", tint: .green, action: onApprove)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct ApprovalIconButton: View {
    let systemImage: String
    let title: String
    var role: ButtonRole?
    var tint: Color?
    let action: () -> Void

    var body: some View {
        Button(role: role, action: action) {
            Image(systemName: systemImage)
                .font(.headline.weight(.bold))
                .frame(width: 34, height: 34)
        }
        .buttonStyle(.borderedProminent)
        .tint(tint)
        .accessibilityLabel(title)
    }
}

private struct PendingDeletionRequest: Identifiable {
    let id = UUID()
    let collectionName: String
    let docId: String
    let title: String
}

private struct DeletionRequestSheet: View {
    let language: AppLanguage
    let requestTitle: String
    let onSubmit: (String) -> Void
    let onCancel: () -> Void
    @State private var reason = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(localized("Request", language: language)) {
                    Text(requestTitle)
                }

                Section(localized("Reason", language: language)) {
                    TextField("Why should this be removed?", text: $reason, axis: .vertical)
                }
            }
            .navigationTitle(localized("Request Delete", language: language))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        onSubmit(reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Requested from iOS" : reason)
                    }
                }
            }
        }
    }
}

private struct FamilyTreeView: View {
    let member: Member
    let allMembers: [Member]

    var body: some View {
        FamilyTreeCanvas(
            members: allMembers,
            currentUser: member,
            language: .english,
            onMemberTap: { _ in }
        )
        .frame(minHeight: 520)
    }
}

private struct FamilyTreeCanvas: View {
    let members: [Member]
    let currentUser: Member?
    let language: AppLanguage
    let onMemberTap: (Member) -> Void

    @State private var scale: CGFloat = 1
    @State private var expandedIds: Set<String> = []
    @State private var focusedId: String?
    @State private var searchText = ""
    @State private var isSearchVisible = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView([.horizontal, .vertical], showsIndicators: true) {
                LazyVStack(alignment: .center, spacing: 28) {
                    if rootMembers.isEmpty {
                        ContentUnavailableView(
                            "Family Tree",
                            systemImage: "tree",
                            description: Text("No family members are available to display.")
                        )
                        .frame(maxWidth: .infinity, minHeight: 360)
                    } else {
                        ForEach(rootMembers) { root in
                            RecursiveFamilyNode(
                                member: root,
                                members: displayMembers,
                                currentUserId: currentUser?.id,
                                focusedId: focusedId,
                                expandedIds: $expandedIds,
                                onMemberTap: handleMemberTap
                            )
                        }
                    }
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 24)
                .frame(width: canvasBaseWidth, height: canvasBaseHeight, alignment: .top)
                .scaleEffect(scale, anchor: .topLeading)
                .frame(width: canvasBaseWidth * scale, height: canvasBaseHeight * scale, alignment: .topLeading)
            }
            .background(Color(red: 0.94, green: 0.92, blue: 0.88))
            .overlay(alignment: .top) {
                if isSearchVisible {
                    searchPanel
                        .padding(.top, 12)
                }
            }
            .safeAreaInset(edge: .top) {
                treeToolbar
                    .background(.ultraThinMaterial)
            }

            VStack(spacing: 12) {
                Button {
                    scale = min(scale * 1.2, 2.5)
                } label: {
                    Image(systemName: "plus")
                }
                Button {
                    scale = max(scale * 0.8, 0.45)
                } label: {
                    Image(systemName: "minus")
                }
                Button {
                    resetTree()
                } label: {
                    Image(systemName: "scope")
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(20)
        }
        .onAppear {
            if expandedIds.isEmpty {
                expandedIds = Set(members.map(\.id))
            }
        }
    }

    private var displayMembers: [Member] {
        members
            .filter { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .sorted { lhs, rhs in
                let comparison = lhs.familyId.localizedStandardCompare(rhs.familyId)
                return comparison == .orderedSame ? lhs.name < rhs.name : comparison == .orderedAscending
            }
    }

    private var canvasBaseWidth: CGFloat {
        let nonSpouseCount = displayMembers.filter { !$0.familyId.hasSuffix("0") }.count
        let rootAllowance = max(1, rootMembers.count)
        return max(1_180, CGFloat(max(1, nonSpouseCount)) * 190 + CGFloat(rootAllowance) * 240)
    }

    private var canvasBaseHeight: CGFloat {
        let deepestGeneration = displayMembers.map { generationDepth(for: $0.familyId) }.max() ?? 1
        return max(780, CGFloat(deepestGeneration + 1) * 230 + 220)
    }

    private var rootMembers: [Member] {
        let nonSpouseMembers = displayMembers.filter { !$0.familyId.hasSuffix("0") }
        let branchRootMembers = nonSpouseMembers.filter { member in
            guard member.familyId != "P" else { return false }
            let parentBase = parentBaseId(for: member.familyId)
            return parentBase.isEmpty
                || parentBase == "P"
                || !displayMembers.contains { $0.familyId == parentBase }
        }

        if !branchRootMembers.isEmpty {
            return branchRootMembers
        }

        return nonSpouseMembers.filter { member in
            let parentBase = parentBaseId(for: member.familyId)
            return parentBase.isEmpty || !displayMembers.contains { $0.familyId == parentBase }
        }
    }

    private func parentBaseId(for familyId: String) -> String {
        let base = familyId.hasSuffix("0") ? String(familyId.dropLast()) : familyId
        guard !base.isEmpty, base != "P" else { return "" }
        return base.count == 1 ? "P" : String(base.dropLast())
    }

    private func generationDepth(for familyId: String) -> Int {
        let base = familyId.hasSuffix("0") ? String(familyId.dropLast()) : familyId
        if base == "P" || base.isEmpty { return 0 }
        return max(1, base.count)
    }

    private var treeToolbar: some View {
        HStack(spacing: 12) {
            Button {
                isSearchVisible.toggle()
                if !isSearchVisible {
                    searchText = ""
                }
            } label: {
                Image(systemName: isSearchVisible ? "xmark" : "magnifyingglass")
            }

            Button {
                if let id = currentUser?.id {
                    focus(id)
                }
            } label: {
                Image(systemName: "location.fill")
            }
            .disabled(currentUser == nil)

            Button {
                resetTree()
            } label: {
                Image(systemName: "arrow.up.left.and.down.right.magnifyingglass")
            }

            Spacer()

            Text("\(Int(scale * 100))%")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
    }

    private var searchPanel: some View {
        VStack(spacing: 0) {
            TextField(localized("Search family...", language: language), text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(10)

            ForEach(searchResults) { result in
                Button {
                    focus(result.id)
                    isSearchVisible = false
                    searchText = ""
                } label: {
                    HStack {
                        AvatarView(member: result, size: 34)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(result.name)
                                .font(.subheadline.weight(.semibold))
                            Text(result.relationship ?? result.familyId)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(width: 320)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.18), radius: 14, x: 0, y: 8)
    }

    private var searchResults: [Member] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return [] }
        return members
            .filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.familyId.localizedCaseInsensitiveContains(searchText) }
            .prefix(5)
            .map { $0 }
    }

    private func handleMemberTap(_ member: Member) {
        if focusedId == member.id {
            onMemberTap(member)
        } else {
            focus(member.id)
        }
    }

    private func focus(_ id: String) {
        focusedId = id
        scale = 1

        guard let member = members.first(where: { $0.id == id }) else { return }
        var idsToExpand = expandedIds
        var familyId = member.familyId.hasSuffix("0") ? String(member.familyId.dropLast()) : member.familyId
        while !familyId.isEmpty {
            if let ancestor = members.first(where: { $0.familyId == familyId }) {
                idsToExpand.insert(ancestor.id)
            }
            familyId = familyId.count > 1 ? String(familyId.dropLast()) : ""
        }
        expandedIds = idsToExpand
    }

    private func resetTree() {
        focusedId = nil
        scale = 1
        expandedIds = Set(members.map(\.id))
    }
}

private struct FamilyTreeBranch: Identifiable {
    let id: String
    let title: String
    let members: [Member]

    var generationRows: [(id: Int, members: [Member])] {
        let grouped = Dictionary(grouping: members, by: generation(for:))
        return grouped.keys.sorted().map { generation in
            (id: generation, members: (grouped[generation] ?? []).sorted { lhs, rhs in
                let comparison = lhs.familyId.localizedStandardCompare(rhs.familyId)
                return comparison == .orderedSame ? lhs.name < rhs.name : comparison == .orderedAscending
            })
        }
    }

    private func generation(for member: Member) -> Int {
        let base = member.familyId.hasSuffix("0") ? String(member.familyId.dropLast()) : member.familyId
        if base == "P" || base.isEmpty { return 0 }
        return max(1, base.count)
    }
}

private struct FamilyTreeBranchGrid: View {
    let branch: FamilyTreeBranch
    let currentUserId: String?
    let focusedId: String?
    let onMemberTap: (Member) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Text(branch.id)
                    .font(.title3.weight(.black))
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(Color.brown, in: RoundedRectangle(cornerRadius: 8, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(branch.title)
                        .font(.headline)
                    Text("\(branch.members.count) members")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)
            }

            ForEach(branch.generationRows, id: \.id) { row in
                VStack(alignment: .leading, spacing: 8) {
                    Text("Generation \(row.id)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: 12) {
                            ForEach(row.members) { member in
                                TreeMemberCard(
                                    member: member,
                                    isSelf: member.id == currentUserId,
                                    isFocused: member.id == focusedId,
                                    onTap: { onMemberTap(member) }
                                )
                            }
                        }
                        .padding(.bottom, 2)
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.86), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct RecursiveFamilyNode: View {
    let member: Member
    let members: [Member]
    let currentUserId: String?
    let focusedId: String?
    @Binding var expandedIds: Set<String>
    let onMemberTap: (Member) -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ZStack(alignment: .bottom) {
                    TreeMemberCard(
                        member: member,
                        isSelf: member.id == currentUserId,
                        isFocused: member.id == focusedId,
                        onTap: { onMemberTap(member) }
                    )

                    if !children.isEmpty {
                        Button {
                            toggleExpanded()
                        } label: {
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.caption.weight(.bold))
                                .frame(width: 22, height: 22)
                                .background(.white, in: Circle())
                                .overlay(Circle().stroke(Color.brown.opacity(0.55), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .offset(y: 12)
                    }
                }

                if let spouse {
                    TreeConnector(horizontal: true, length: 32)
                    TreeMemberCard(
                        member: spouse,
                        isSelf: spouse.id == currentUserId,
                        isFocused: spouse.id == focusedId,
                        onTap: { onMemberTap(spouse) }
                    )
                }
            }

            if !children.isEmpty && isExpanded {
                TreeConnector(horizontal: false, length: 32)
                Text("Children")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(AndroidLook.mutedBrown)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.72), in: Capsule())

                HStack(alignment: .top, spacing: 26) {
                    ForEach(children) { child in
                        VStack(spacing: 0) {
                            Rectangle()
                                .fill(Color.brown.opacity(0.65))
                                .frame(width: 2, height: 24)

                            RecursiveFamilyNode(
                                member: child,
                                members: members,
                                currentUserId: currentUserId,
                                focusedId: focusedId,
                                expandedIds: $expandedIds,
                                onMemberTap: onMemberTap
                            )
                        }
                    }
                }
                .overlay(alignment: .top) {
                    if children.count > 1 {
                        Rectangle()
                            .fill(Color.brown.opacity(0.65))
                            .frame(height: 2)
                            .padding(.horizontal, 76)
                    }
                }
            }
        }
    }

    private var isExpanded: Bool {
        expandedIds.contains(member.id)
    }

    private var spouse: Member? {
        let spouseId = member.familyId.hasSuffix("0") ? String(member.familyId.dropLast()) : member.familyId + "0"
        return members.first { $0.familyId == spouseId }
    }

    private var children: [Member] {
        let baseId = member.familyId.hasSuffix("0") ? String(member.familyId.dropLast()) : member.familyId
        guard !baseId.isEmpty else { return [] }
        return members
            .filter { candidate in
                if baseId == "P" {
                    return candidate.familyId.count == 1 && candidate.familyId != "P" && !candidate.familyId.hasSuffix("0")
                }
                return candidate.familyId.count == baseId.count + 1
                    && candidate.familyId.hasPrefix(baseId)
                    && !candidate.familyId.hasSuffix("0")
            }
            .sorted { $0.familyId < $1.familyId }
    }

    private func toggleExpanded() {
        if expandedIds.contains(member.id) {
            expandedIds.remove(member.id)
        } else {
            expandedIds.insert(member.id)
        }
    }
}

private struct TreeMemberCard: View {
    let member: Member
    let isSelf: Bool
    let isFocused: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                AvatarView(member: member, size: 58)
                    .overlay(Circle().stroke(.white.opacity(0.8), lineWidth: 2))

                Text(member.name)
                    .font(.caption.weight(.bold))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .foregroundStyle(.white)
                    .frame(height: 32)

                Text(relationshipText)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white.opacity(0.92))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
                    .frame(minHeight: 24)
            }
            .padding(10)
            .frame(width: 150)
            .background(cardFill, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(accent, lineWidth: isFocused ? 4 : 3)
            )
            .shadow(color: .black.opacity(isFocused ? 0.22 : 0.10), radius: isFocused ? 14 : 5, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    private var accent: Color {
        let value = member.gender.lowercased()
        if value == "female" || value == "f" || value.contains("woman") || value.contains("स्त्री") {
            return .pink
        }
        if value == "male" || value == "m" || value.contains("man") {
            return .blue
        }
        return .brown
    }

    private var cardFill: Color {
        let value = member.gender.lowercased()
        if value == "female" || value == "f" || value.contains("woman") || value.contains("स्त्री") {
            return Color.pink.opacity(0.78)
        }
        if value == "male" || value == "m" || value.contains("man") {
            return Color.blue.opacity(0.78)
        }
        return Color.brown.opacity(0.70)
    }

    private var relationshipText: String {
        if isSelf, let relationship = member.relationship, !relationship.isEmpty {
            return "Me • \(relationship)"
        }
        if isSelf {
            return "Me"
        }
        if let relationship = member.relationship, !relationship.isEmpty {
            return relationship
        }
        if member.familyId.hasSuffix("0") {
            return "Spouse"
        }
        return "Family member"
    }
}

private struct TreeConnector: View {
    let horizontal: Bool
    let length: CGFloat

    var body: some View {
        Rectangle()
            .fill(Color.brown.opacity(0.65))
            .frame(width: horizontal ? length : 2, height: horizontal ? 2 : length)
    }
}

#Preview {
    ContentView()
}
