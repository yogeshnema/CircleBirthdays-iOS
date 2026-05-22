import SwiftUI

private func gameTitle(_ gameType: FamilyGameType, language: AppLanguage) -> String {
    language == .hindi ? gameType.hindiTitle : gameType.title
}

private func otherPlayerName(session: GameSession, currentUserID: String) -> String {
    guard let otherID = session.players.first(where: { $0 != currentUserID }) else { return "Waiting" }
    return session.playerNames[otherID] ?? "Player"
}

private func numberArray(_ raw: Any?, fallback: [Int] = []) -> [Int] {
    if let values = raw as? [Int] { return values }
    return (raw as? [Any])?.compactMap { ($0 as? NSNumber)?.intValue ?? $0 as? Int } ?? fallback
}

private func stringArray(_ raw: Any?, fallback: [String] = []) -> [String] {
    if let values = raw as? [String] { return values }
    return (raw as? [Any])?.compactMap { $0 as? String } ?? fallback
}

private struct GameBackground<Content: View>: View {
    @ViewBuilder let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            Image("Background")
                .resizable()
                .scaledToFill()
                .overlay(Color(red: 0xF5 / 255.0, green: 0xE6 / 255.0, blue: 0xBE / 255.0).opacity(0.30))
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color(red: 0xF5 / 255.0, green: 0xE6 / 255.0, blue: 0xBE / 255.0).opacity(0.48),
                    Color(red: 0xEF / 255.0, green: 0xEB / 255.0, blue: 0xE9 / 255.0).opacity(0.30),
                    Color(red: 0xF5 / 255.0, green: 0xE6 / 255.0, blue: 0xBE / 255.0).opacity(0.36)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            content
        }
    }
}

struct FamilyGamesScreen: View {
    @Bindable var viewModel: AppViewModel

    var body: some View {
        GameBackground {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(viewModel.language == .hindi ? "गेमिफिकेशन हब" : "Gamification Hub")
                                    .font(.title2.bold())
                                Text(viewModel.language == .hindi ? "परिवार के साथ लाइव खेलें" : "Play live games with your family")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "star.circle.fill")
                                .font(.system(size: 42))
                                .foregroundStyle(.yellow, .orange)
                        }
                        .padding(16)
                        .background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                        Text(viewModel.language == .hindi ? "मल्टीप्लेयर गेम्स" : "Multiplayer Games")
                            .font(.headline)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(FamilyGameType.allCases) { gameType in
                                Button {
                                    viewModel.showGameLobby(gameType: gameType)
                                } label: {
                                    VStack(spacing: 10) {
                                        Image(systemName: gameType.systemImage)
                                            .font(.system(size: 30, weight: .bold))
                                            .foregroundStyle(color(for: gameType))
                                        Text(gameTitle(gameType, language: viewModel.language))
                                            .font(.headline)
                                            .foregroundStyle(Color.primary)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(2)
                                            .minimumScaleFactor(0.82)
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 112)
                                    .padding(10)
                                    .background(.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .strokeBorder(color(for: gameType).opacity(0.45), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        if !viewModel.visibleGameSessions.isEmpty {
                            Text(viewModel.language == .hindi ? "खुले लॉबी" : "Open Lobbies")
                                .font(.headline)
                            ForEach(viewModel.visibleGameSessions.prefix(5)) { session in
                                Button {
                                    Task { await viewModel.joinGameSession(session) }
                                } label: {
                                    SessionRow(session: session, language: viewModel.language)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(18)
                }
                .navigationTitle(viewModel.language == .hindi ? "फैमिली गेम्स" : "Family Games")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            viewModel.showDashboard()
                        } label: {
                            Label("Dashboard", systemImage: "chevron.left")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            Task { await viewModel.refreshGameSessions() }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
                .task {
                    await viewModel.refreshGameSessions()
                }
            }
        }
    }

    private func color(for gameType: FamilyGameType) -> Color {
        switch gameType {
        case .snakesLadders: return .green
        case .chess: return .brown
        case .chaupad: return .pink
        case .hangman: return .blue
        case .rummy: return .purple
        case .antakshari: return .orange
        }
    }
}

struct GameLobbyScreen: View {
    @Bindable var viewModel: AppViewModel
    let gameType: FamilyGameType

    var body: some View {
        GameBackground {
            NavigationStack {
                List {
                    Section {
                        Button {
                            Task { await viewModel.createGameSession(gameType: gameType) }
                        } label: {
                            Label(viewModel.language == .hindi ? "नया गेम बनाएं" : "Create New Game", systemImage: "plus.circle.fill")
                        }
                    }

                    Section(viewModel.language == .hindi ? "जॉइन करने के लिए उपलब्ध" : "Available to Join") {
                        let sessions = viewModel.visibleGameSessions.filter { $0.gameType == gameType }
                        if sessions.isEmpty {
                            Text(viewModel.language == .hindi ? "कोई सक्रिय गेम नहीं। एक बनाएं!" : "No active games. Create one!")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(sessions) { session in
                                Button {
                                    Task { await viewModel.joinGameSession(session) }
                                } label: {
                                    SessionRow(session: session, language: viewModel.language)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("\(gameTitle(gameType, language: viewModel.language)) Lobby")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            viewModel.showFamilyGames()
                        } label: {
                            Label("Games", systemImage: "chevron.left")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            Task { await viewModel.refreshGameSessions() }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
                .task {
                    await viewModel.refreshGameSessions()
                }
            }
        }
    }
}

private struct SessionRow: View {
    let session: GameSession
    let language: AppLanguage

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: session.gameType.systemImage)
                .font(.title3)
                .frame(width: 38, height: 38)
                .background(Color.orange.opacity(0.16), in: Circle())
            VStack(alignment: .leading, spacing: 3) {
                Text(gameTitle(session.gameType, language: language))
                    .font(.headline)
                Text("Host: \(session.playerNames.values.first ?? "Unknown")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(session.players.count)/2")
                .font(.caption.bold())
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(.thinMaterial, in: Capsule())
        }
        .padding(.vertical, 6)
    }
}

struct FamilyGameSessionScreen: View {
    @Bindable var viewModel: AppViewModel
    let sessionID: String

    var body: some View {
        GameBackground {
            NavigationStack {
                Group {
                    if let session = viewModel.currentGameSession, session.id == sessionID {
                        GamePlayView(viewModel: viewModel, session: session)
                    } else {
                        ProgressView("Loading game...")
                    }
                }
                .navigationTitle(viewModel.currentGameSession.map { gameTitle($0.gameType, language: viewModel.language) } ?? "Game")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            viewModel.showFamilyGames()
                        } label: {
                            Label("Games", systemImage: "chevron.left")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            Task { await viewModel.refreshGameSession(sessionID: sessionID) }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
                .task {
                    while !Task.isCancelled {
                        await viewModel.refreshGameSession(sessionID: sessionID)
                        try? await Task.sleep(for: .seconds(2))
                    }
                }
            }
        }
    }
}

private struct GamePlayView: View {
    @Bindable var viewModel: AppViewModel
    let session: GameSession

    var body: some View {
        VStack(spacing: 14) {
            statusCard

            if session.status == "WAITING" {
                ContentUnavailableView("Waiting for another player", systemImage: "person.2.badge.gearshape", description: Text("Android and iOS players can join this same session."))
            } else {
                switch session.gameType {
                case .snakesLadders:
                    SnakesLaddersGame(viewModel: viewModel, session: session)
                case .chess:
                    ChessGame(viewModel: viewModel, session: session)
                case .chaupad:
                    ChaupadGame(viewModel: viewModel, session: session)
                case .hangman:
                    HangmanGame(viewModel: viewModel, session: session)
                case .rummy:
                    RummyGame(viewModel: viewModel, session: session)
                case .antakshari:
                    AntakshariGame(viewModel: viewModel, session: session)
                }
            }
        }
        .padding(16)
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(session.status.capitalized, systemImage: session.status == "ACTIVE" ? "bolt.fill" : "hourglass")
                Spacer()
                Text("\(session.players.count)/2 players")
            }
            .font(.headline)

            if let user = viewModel.currentUser {
                if let winnerID = session.winnerId {
                    Text(winnerID == user.id ? "You won!" : "\(session.playerNames[winnerID] ?? "Other player") won")
                        .font(.subheadline.bold())
                } else {
                    Text(session.currentTurn == user.id ? "Your turn" : "\(otherPlayerName(session: session, currentUserID: user.id))'s turn")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(14)
        .background(.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct SnakesLaddersGame: View {
    @Bindable var viewModel: AppViewModel
    let session: GameSession

    var body: some View {
        VStack(spacing: 14) {
            BoardGrid(size: 10) { index in
                let square = 100 - index
                ZStack(alignment: .topLeading) {
                    Rectangle().fill(index.isMultiple(of: 2) ? Color.green.opacity(0.15) : Color.yellow.opacity(0.2))
                    Text("\(square)").font(.caption2).padding(4)
                    tokenStack(for: square)
                }
            }
            TurnButton(title: "Roll Dice", systemImage: "dice.fill", enabled: isMyTurn) {
                roll()
            }
        }
    }

    private var isMyTurn: Bool {
        session.currentTurn == viewModel.currentUser?.id && session.winnerId == nil
    }

    @ViewBuilder
    private func tokenStack(for square: Int) -> some View {
        HStack {
            ForEach(Array(session.players.enumerated()), id: \.element) { index, playerID in
                let position = (session.gameState[playerID] as? NSNumber)?.intValue ?? session.gameState[playerID] as? Int ?? 0
                if position == square {
                    Circle()
                        .fill(index == 0 ? Color.blue : Color.pink)
                        .frame(width: 16, height: 16)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    private func roll() {
        guard let user = viewModel.currentUser else { return }
        let dice = Int.random(in: 1...6)
        let current = (session.gameState[user.id] as? NSNumber)?.intValue ?? session.gameState[user.id] as? Int ?? 0
        let moved = min(100, current + dice)
        let jumps = [4: 14, 9: 31, 17: 7, 20: 38, 28: 84, 40: 59, 51: 67, 54: 34, 62: 19, 63: 81, 64: 60, 71: 91, 87: 24, 93: 73, 95: 75, 99: 78]
        let final = jumps[moved] ?? moved
        var state = session.gameState
        state[user.id] = final
        state["lastRoll"] = dice
        let next = final >= 100 ? "" : (session.players.first { $0 != user.id } ?? user.id)
        Task { await viewModel.updateGameState(sessionID: session.id, state: state, nextTurnID: next, winnerID: final >= 100 ? user.id : nil) }
    }
}

private struct ChessGame: View {
    @Bindable var viewModel: AppViewModel
    let session: GameSession
    @State private var selectedIndex: Int?

    var body: some View {
        VStack(spacing: 14) {
            BoardGrid(size: 8) { index in
                let board = stringArray(session.gameState["board"], fallback: Self.initialBoard)
                let piece = board.indices.contains(index) ? board[index] : ""
                ZStack {
                    Rectangle().fill(((index / 8) + index).isMultiple(of: 2) ? Color.gray.opacity(0.22) : Color.brown.opacity(0.38))
                    Text(symbol(for: piece)).font(.system(size: 26))
                }
                .overlay(selectedIndex == index ? Color.yellow.opacity(0.35) : Color.clear)
                .onTapGesture { tap(index: index, board: board) }
            }
            TurnButton(title: "Claim Victory", systemImage: "flag.checkered", enabled: isMyTurn) {
                guard let user = viewModel.currentUser else { return }
                Task { await viewModel.updateGameState(sessionID: session.id, state: session.gameState, nextTurnID: "", winnerID: user.id) }
            }
        }
    }

    private var isMyTurn: Bool {
        session.currentTurn == viewModel.currentUser?.id && session.winnerId == nil
    }

    private func tap(index: Int, board: [String]) {
        guard isMyTurn else { return }
        if let from = selectedIndex, from != index {
            var newBoard = board
            newBoard[index] = newBoard[from]
            newBoard[from] = ""
            selectedIndex = nil
            let next = session.players.first { $0 != viewModel.currentUser?.id } ?? ""
            Task { await viewModel.updateGameState(sessionID: session.id, state: ["board": newBoard], nextTurnID: next) }
        } else if !board[index].isEmpty {
            selectedIndex = index
        } else {
            selectedIndex = nil
        }
    }

    private func symbol(for piece: String) -> String {
        ["WK": "♔", "WQ": "♕", "WR": "♖", "WB": "♗", "WN": "♘", "WP": "♙", "BK": "♚", "BQ": "♛", "BR": "♜", "BB": "♝", "BN": "♞", "BP": "♟"][piece] ?? ""
    }

    private static let initialBoard = ["BR", "BN", "BB", "BQ", "BK", "BB", "BN", "BR", "BP", "BP", "BP", "BP", "BP", "BP", "BP", "BP", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "WP", "WP", "WP", "WP", "WP", "WP", "WP", "WP", "WR", "WN", "WB", "WQ", "WK", "WB", "WN", "WR"]
}

private struct ChaupadGame: View {
    @Bindable var viewModel: AppViewModel
    let session: GameSession

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 18).fill(Color.yellow.opacity(0.16))
                VStack(spacing: 10) {
                    Text("Royal Chaupad").font(.title2.bold())
                    Text("Last roll: \((session.gameState["lastRoll"] as? NSNumber)?.intValue ?? session.gameState["lastRoll"] as? Int ?? 0)")
                    HStack {
                        PieceRow(title: "P1", pieces: numberArray(session.gameState["p1_pieces"], fallback: [0, 0, 0, 0]), color: .red)
                        PieceRow(title: "P2", pieces: numberArray(session.gameState["p2_pieces"], fallback: [0, 0, 0, 0]), color: .blue)
                    }
                }
                .padding(20)
            }
            .frame(maxWidth: .infinity, minHeight: 260)
            TurnButton(title: "Roll", systemImage: "dice.fill", enabled: isMyTurn) { roll() }
        }
    }

    private var isMyTurn: Bool { session.currentTurn == viewModel.currentUser?.id && session.winnerId == nil }

    private func roll() {
        let dice = Int.random(in: 1...6)
        var state = session.gameState
        state["lastRoll"] = dice
        let next = session.players.first { $0 != viewModel.currentUser?.id } ?? ""
        Task { await viewModel.updateGameState(sessionID: session.id, state: state, nextTurnID: next) }
    }
}

private struct PieceRow: View {
    let title: String
    let pieces: [Int]
    let color: Color

    var body: some View {
        VStack {
            Text(title).font(.caption.bold())
            HStack {
                ForEach(pieces.indices, id: \.self) { index in
                    VStack {
                        Circle().fill(color).frame(width: 18, height: 18)
                        Text("\(pieces[index])").font(.caption2)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct HangmanGame: View {
    @Bindable var viewModel: AppViewModel
    let session: GameSession

    var body: some View {
        let word = session.gameState["word"] as? String ?? "FAMILY"
        let guessed = stringArray(session.gameState["guessedLetters"])
        let wrong = guessed.filter { !word.contains($0) }.count
        let won = Set(word.map { String($0) }.filter { $0 != " " }).isSubset(of: Set(guessed))
        VStack(spacing: 14) {
            Text(session.gameState["category"] as? String ?? "GENERAL").font(.headline)
            Text(word.map { char in
                char == " " || guessed.contains(String(char)) ? String(char) : "_"
            }.joined(separator: " "))
            .font(.system(size: 30, weight: .bold, design: .rounded))
            Text("Wrong guesses: \(wrong)/6")
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ").map(String.init), id: \.self) { letter in
                    Button(letter) {
                        guess(letter, word: word, guessed: guessed)
                    }
                    .buttonStyle(.bordered)
                    .disabled(!isMyTurn || guessed.contains(letter) || won || wrong >= 6)
                }
            }
        }
    }

    private var isMyTurn: Bool { session.currentTurn == viewModel.currentUser?.id && session.winnerId == nil }

    private func guess(_ letter: String, word: String, guessed: [String]) {
        guard let user = viewModel.currentUser else { return }
        var newGuessed = guessed
        newGuessed.append(letter)
        let won = Set(word.map { String($0) }.filter { $0 != " " }).isSubset(of: Set(newGuessed))
        let lost = newGuessed.filter { !word.contains($0) }.count >= 6
        var state = session.gameState
        state["guessedLetters"] = newGuessed
        let next = won || lost ? "" : (session.players.first { $0 != user.id } ?? user.id)
        Task { await viewModel.updateGameState(sessionID: session.id, state: state, nextTurnID: next, winnerID: won ? user.id : nil) }
    }
}

private struct RummyGame: View {
    @Bindable var viewModel: AppViewModel
    let session: GameSession

    var body: some View {
        let userID = viewModel.currentUser?.id ?? ""
        let hand = stringArray(session.gameState["hand_\(userID)"])
        let discard = stringArray(session.gameState["discardPile"])
        VStack(spacing: 14) {
            HStack {
                Label("\((session.gameState["deckCount"] as? NSNumber)?.intValue ?? 0) cards", systemImage: "rectangle.stack.fill")
                Spacer()
                Text("Discard: \(discard.last ?? "-")")
            }
            .font(.headline)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 8) {
                ForEach(hand, id: \.self) { card in
                    Text(card)
                        .font(.headline)
                        .frame(height: 58)
                        .frame(maxWidth: .infinity)
                        .background(.white, in: RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(.gray.opacity(0.35)))
                        .onTapGesture { discardCard(card) }
                }
            }
            Text("Tap a card on your turn to discard it.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var isMyTurn: Bool { session.currentTurn == viewModel.currentUser?.id && session.winnerId == nil }

    private func discardCard(_ card: String) {
        guard isMyTurn, let user = viewModel.currentUser else { return }
        var hand = stringArray(session.gameState["hand_\(user.id)"])
        hand.removeAll { $0 == card }
        var discard = stringArray(session.gameState["discardPile"])
        discard.append(card)
        var state = session.gameState
        state["hand_\(user.id)"] = hand
        state["discardPile"] = discard
        let next = session.players.first { $0 != user.id } ?? user.id
        Task { await viewModel.updateGameState(sessionID: session.id, state: state, nextTurnID: next, winnerID: hand.isEmpty ? user.id : nil) }
    }
}

private struct AntakshariGame: View {
    @Bindable var viewModel: AppViewModel
    let session: GameSession
    @State private var line = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Last letter: \(session.gameState["lastLetter"] as? String ?? "-")")
                .font(.headline)
            List {
                ForEach(recordings.indices, id: \.self) { index in
                    let item = recordings[index]
                    VStack(alignment: .leading) {
                        Text(item["senderName"] ?? "Player").font(.caption.bold())
                        Text(item["title"] ?? item["url"] ?? "Sang a turn")
                    }
                }
            }
            .frame(minHeight: 180)
            TextField("Song line", text: $line)
                .textFieldStyle(.roundedBorder)
            TurnButton(title: "Send Turn", systemImage: "music.note", enabled: isMyTurn && !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
                sendLine()
            }
        }
    }

    private var isMyTurn: Bool { session.currentTurn == viewModel.currentUser?.id && session.winnerId == nil }

    private var recordings: [[String: String]] {
        if let values = session.gameState["recordings"] as? [[String: String]] { return values }
        return (session.gameState["recordings"] as? [[String: Any]])?.map { item in
            item.reduce(into: [String: String]()) { $0[$1.key] = $1.value as? String }
        } ?? []
    }

    private func sendLine() {
        guard let user = viewModel.currentUser else { return }
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        var updated = recordings
        updated.append(["senderId": user.id, "senderName": user.name, "title": trimmed, "url": trimmed])
        var state = session.gameState
        state["recordings"] = updated
        state["lastLetter"] = trimmed.last.map { String($0).uppercased() } ?? ""
        line = ""
        let next = session.players.first { $0 != user.id } ?? user.id
        Task { await viewModel.updateGameState(sessionID: session.id, state: state, nextTurnID: next) }
    }
}

private struct BoardGrid<Cell: View>: View {
    let size: Int
    @ViewBuilder let cell: (Int) -> Cell

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: size), spacing: 0) {
            ForEach(0..<(size * size), id: \.self) { index in
                cell(index)
                    .aspectRatio(1, contentMode: .fit)
                    .border(Color.white.opacity(0.55), width: 0.5)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(Color.black.opacity(0.12)))
    }
}

private struct TurnButton: View {
    let title: String
    let systemImage: String
    let enabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .disabled(!enabled)
    }
}
