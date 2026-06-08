import SwiftUI

private func gameTitle(_ gameType: FamilyGameType, language: AppLanguage) -> String {
    language == .hindi ? gameType.hindiTitle : gameType.title
}

private func otherPlayerName(session: GameSession, currentUserID: String) -> String {
    guard let otherID = session.players.first(where: { $0 != currentUserID }) else { return "Waiting" }
    return session.playerNames[otherID] ?? "Player"
}

private func gameRoomActionTitle(session: GameSession, currentUserID: String?) -> String {
    if session.isParticipant(currentUserID) { return "Open" }
    if session.canJoin(currentUserID) { return "Join" }
    return "View"
}

private func gameRoomStatusText(session: GameSession, currentUserID: String?) -> String {
    if !session.isParticipant(currentUserID), !session.canJoin(currentUserID) {
        return "View only"
    }
    if session.status == "WAITING" {
        return "Waiting"
    }
    return session.status.capitalized
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
                                    SessionRow(session: session, language: viewModel.language, currentUserID: viewModel.currentUser?.id)
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

                    Section(viewModel.language == .hindi ? "गेम रूम" : "Game Rooms") {
                        let sessions = viewModel.visibleGameSessions.filter { $0.gameType == gameType }
                        if sessions.isEmpty {
                            Text(viewModel.language == .hindi ? "कोई सक्रिय गेम नहीं। एक बनाएं!" : "No active games. Create one!")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(sessions) { session in
                                Button {
                                    Task { await viewModel.joinGameSession(session) }
                                } label: {
                                    SessionRow(session: session, language: viewModel.language, currentUserID: viewModel.currentUser?.id)
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
    let currentUserID: String?

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
            VStack(alignment: .trailing, spacing: 6) {
                Text("\(session.players.count)/2")
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(.thinMaterial, in: Capsule())
                Text(gameRoomActionTitle(session: session, currentUserID: currentUserID))
                    .font(.caption.bold())
                    .foregroundStyle(session.canJoin(currentUserID) ? .green : .secondary)
            }
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
            if isViewOnly {
                Label("View only. This room is full, so game actions are locked.", systemImage: "eye.fill")
                    .font(.caption.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .background(Color.black.opacity(0.72), in: Capsule())
                    .foregroundStyle(.white)
            }

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

    private var isViewOnly: Bool {
        !session.isParticipant(viewModel.currentUser?.id)
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(gameRoomStatusText(session: session, currentUserID: viewModel.currentUser?.id), systemImage: isViewOnly ? "eye.fill" : (session.status == "ACTIVE" ? "bolt.fill" : "hourglass"))
                Spacer()
                Text("\(session.players.count)/2 players")
            }
            .font(.headline)

            if let user = viewModel.currentUser {
                if isViewOnly {
                    Text("Watching \(session.playerNames.values.joined(separator: " vs "))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else if let winnerID = session.winnerId {
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
        .background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Color.white.opacity(0.35), lineWidth: 1))
    }
}

private struct SnakesLaddersGame: View {
    @Bindable var viewModel: AppViewModel
    let session: GameSession

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                BoardGrid(size: 10) { index in
                    let square = Self.square(for: index)
                    ZStack(alignment: .topLeading) {
                        Rectangle().fill(Self.tileColor(for: square))
                        Text("\(square)")
                            .font(.caption2.bold())
                            .foregroundStyle(.black.opacity(0.58))
                            .padding(4)
                        tokenStack(for: square)
                    }
                }
                SnakesLaddersOverlay(snakes: Self.snakes, ladders: Self.ladders)
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
        let final = Self.ladders[moved] ?? Self.snakes[moved] ?? moved
        var state = session.gameState
        state[user.id] = final
        state["lastRoll"] = dice
        let next = final >= 100 ? "" : (session.players.first { $0 != user.id } ?? user.id)
        Task { await viewModel.updateGameState(sessionID: session.id, state: state, nextTurnID: next, winnerID: final >= 100 ? user.id : nil) }
    }

    private static let snakes = [17: 7, 54: 34, 62: 19, 98: 79]
    private static let ladders = [3: 38, 24: 33, 42: 93, 72: 84]

    private static func square(for index: Int) -> Int {
        let rowFromTop = index / 10
        let col = index % 10
        let boardRow = 9 - rowFromTop
        if boardRow.isMultiple(of: 2) {
            return boardRow * 10 + col + 1
        }
        return boardRow * 10 + (10 - col)
    }

    private static func tileColor(for square: Int) -> Color {
        let colors: [Color] = [
            Color(red: 1.00, green: 0.80, blue: 0.82),
            Color(red: 0.78, green: 0.90, blue: 0.79),
            Color(red: 0.73, green: 0.87, blue: 0.98),
            Color(red: 1.00, green: 0.98, blue: 0.77),
            Color(red: 0.88, green: 0.75, blue: 0.91),
            Color(red: 1.00, green: 0.88, blue: 0.70)
        ]
        return colors[(square - 1) % colors.count]
    }
}

private struct SnakesLaddersOverlay: View {
    let snakes: [Int: Int]
    let ladders: [Int: Int]

    var body: some View {
        GeometryReader { proxy in
            let cell = min(proxy.size.width, proxy.size.height) / 10
            ZStack {
                ForEach(ladders.sorted(by: { $0.key < $1.key }), id: \.key) { start, end in
                    LadderShape(start: point(for: start, cell: cell), end: point(for: end, cell: cell), cell: cell)
                        .stroke(Color(red: 0.38, green: 0.25, blue: 0.22), style: StrokeStyle(lineWidth: max(5, cell * 0.10), lineCap: .round))
                    LadderRungs(start: point(for: start, cell: cell), end: point(for: end, cell: cell), cell: cell)
                        .stroke(Color(red: 0.55, green: 0.43, blue: 0.39), style: StrokeStyle(lineWidth: max(2, cell * 0.05), lineCap: .round))
                }
                ForEach(snakes.sorted(by: { $0.key < $1.key }), id: \.key) { start, end in
                    SnakeShape(start: point(for: start, cell: cell), end: point(for: end, cell: cell), cell: cell)
                        .stroke(Color(red: 0.18, green: 0.49, blue: 0.20), style: StrokeStyle(lineWidth: max(8, cell * 0.16), lineCap: .round, lineJoin: .round))
                    Circle()
                        .fill(Color(red: 0.10, green: 0.37, blue: 0.13))
                        .frame(width: max(16, cell * 0.34), height: max(16, cell * 0.34))
                        .position(point(for: start, cell: cell))
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func point(for square: Int, cell: CGFloat) -> CGPoint {
        let index = square - 1
        let row = index / 10
        let col = row.isMultiple(of: 2) ? index % 10 : 9 - (index % 10)
        return CGPoint(x: CGFloat(col) * cell + cell / 2, y: CGFloat(9 - row) * cell + cell / 2)
    }
}

private struct SnakeShape: Shape {
    let start: CGPoint
    let end: CGPoint
    let cell: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: start)
        let mid = CGPoint(x: (start.x + end.x) / 2, y: (start.y + end.y) / 2)
        let controlA = CGPoint(x: mid.x - cell * 0.55, y: mid.y)
        let controlB = CGPoint(x: mid.x + cell * 0.55, y: mid.y)
        path.addCurve(to: end, control1: controlA, control2: controlB)
        return path
    }
}

private struct LadderShape: Shape {
    let start: CGPoint
    let end: CGPoint
    let cell: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let offset = cell / 6
        path.move(to: CGPoint(x: start.x - offset, y: start.y))
        path.addLine(to: CGPoint(x: end.x - offset, y: end.y))
        path.move(to: CGPoint(x: start.x + offset, y: start.y))
        path.addLine(to: CGPoint(x: end.x + offset, y: end.y))
        return path
    }
}

private struct LadderRungs: Shape {
    let start: CGPoint
    let end: CGPoint
    let cell: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let offset = cell / 6
        for step in 1..<7 {
            let t = CGFloat(step) / 7
            let x = start.x + (end.x - start.x) * t
            let y = start.y + (end.y - start.y) * t
            path.move(to: CGPoint(x: x - offset, y: y))
            path.addLine(to: CGPoint(x: x + offset, y: y))
        }
        return path
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
    @State private var selectedCard: String?

    var body: some View {
        let userID = viewModel.currentUser?.id ?? ""
        let hand = stringArray(session.gameState["hand_\(userID)"])
        let discard = stringArray(session.gameState["discardPile"])
        let deckCount = sanitizedDeck().count
        VStack(spacing: 16) {
            VStack(spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Indian Rummy")
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                        Text(rummyPrompt(handCount: hand.count))
                            .font(.caption.bold())
                            .foregroundStyle(isMyTurn ? Color(red: 1, green: 0.94, blue: 0.72) : .white.opacity(0.72))
                    }
                    Spacer()
                    Text("\(deckCount)")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .background(Color.white.opacity(0.14), in: Circle())
                        .overlay(Circle().strokeBorder(Color.white.opacity(0.22), lineWidth: 1))
                }

                HStack(spacing: 28) {
                    VStack(spacing: 8) {
                        RummyCardFace(card: nil, isBack: true, isSelected: false)
                            .onTapGesture { drawCard(fromDeck: true) }
                            .opacity(isMyTurn && hand.count < 11 && deckCount > 0 ? 1 : 0.55)
                        Text("Deck")
                            .font(.caption.bold())
                            .foregroundStyle(.white.opacity(0.74))
                    }

                    VStack(spacing: 8) {
                        RummyCardFace(card: discard.last, isBack: false, isSelected: false)
                            .onTapGesture { drawCard(fromDeck: false) }
                            .opacity(isMyTurn && hand.count < 11 && !discard.isEmpty ? 1 : 0.55)
                        Text("Discard")
                            .font(.caption.bold())
                            .foregroundStyle(.white.opacity(0.74))
                    }
                }
                .padding(.vertical, 8)
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.04, green: 0.35, blue: 0.22), Color(red: 0.08, green: 0.20, blue: 0.16)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(Color.white.opacity(0.16), lineWidth: 1))

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(session.isParticipant(viewModel.currentUser?.id) ? "Your Hand" : "Player hands are hidden")
                        .font(.headline)
                    Spacer()
                    Button {
                        arrangeHand(hand)
                    } label: {
                        Label("Arrange", systemImage: "arrow.up.arrow.down")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .disabled(!session.isParticipant(viewModel.currentUser?.id) || hand.count <= 1 || session.winnerId != nil)
                }

                if hand.isEmpty {
                    Text(session.isParticipant(viewModel.currentUser?.id) ? "Cards appear after a second player joins." : "Open room state is visible, but private cards stay hidden.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 96)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: -18) {
                            ForEach(hand, id: \.self) { card in
                                RummyCardFace(card: card, isBack: false, isSelected: selectedCard == card)
                                    .onTapGesture {
                                        guard isMyTurn else { return }
                                        selectedCard = selectedCard == card ? nil : card
                                    }
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 18)
                    }
                    .frame(height: 150)
                }

                if let selectedCard, isMyTurn {
                    HStack(spacing: 10) {
                        Text("Selected: \(selectedCard)")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Button("Discard") {
                            discardCard(selectedCard, declare: false)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(hand.count != 11)
                        Button("Declare") {
                            discardCard(selectedCard, declare: true)
                        }
                        .buttonStyle(.bordered)
                        .disabled(hand.count != 11)
                    }
                    .padding(12)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
            .padding(14)
            .background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private var isMyTurn: Bool { session.currentTurn == viewModel.currentUser?.id && session.winnerId == nil }

    private func rummyPrompt(handCount: Int) -> String {
        if session.winnerId != nil { return "Hand finished" }
        if session.status == "WAITING" { return "Waiting for another player" }
        if !session.isParticipant(viewModel.currentUser?.id) { return "Watching live room state" }
        if isMyTurn && handCount <= 10 { return "Draw from deck or discard pile" }
        if isMyTurn { return "Select a card, then discard or declare" }
        return "Waiting for \(otherPlayerName(session: session, currentUserID: viewModel.currentUser?.id ?? ""))"
    }

    private func drawCard(fromDeck: Bool) {
        guard isMyTurn, let user = viewModel.currentUser else { return }
        var hand = stringArray(session.gameState["hand_\(user.id)"])
        guard hand.count < 11 else { return }
        var deck = sanitizedDeck()
        var discard = stringArray(session.gameState["discardPile"])
        let card: String?
        if fromDeck {
            card = deck.isEmpty ? nil : deck.removeFirst()
        } else {
            card = discard.popLast()
        }
        guard let card else { return }
        hand.append(card)
        var state = session.gameState
        state["hand_\(user.id)"] = hand
        state["deck"] = deck
        state["deckCount"] = deck.count
        state["discardPile"] = discard
        Task { await viewModel.updateGameState(sessionID: session.id, state: state, nextTurnID: session.currentTurn) }
    }

    private func arrangeHand(_ hand: [String]) {
        guard session.isParticipant(viewModel.currentUser?.id), let user = viewModel.currentUser else { return }
        let arranged = hand.sorted { lhs, rhs in
            let left = Self.cardSortValue(lhs)
            let right = Self.cardSortValue(rhs)
            return left == right ? lhs < rhs : left < right
        }
        guard arranged != hand else { return }
        var state = session.gameState
        state["hand_\(user.id)"] = arranged
        selectedCard = nil
        Task { await viewModel.updateGameState(sessionID: session.id, state: state, nextTurnID: session.currentTurn) }
    }

    private func discardCard(_ card: String, declare: Bool) {
        guard isMyTurn, let user = viewModel.currentUser else { return }
        var hand = stringArray(session.gameState["hand_\(user.id)"])
        guard hand.count == 11 else { return }
        hand.removeAll { $0 == card }
        var discard = stringArray(session.gameState["discardPile"])
        discard.append(card)
        var state = session.gameState
        state["hand_\(user.id)"] = hand
        state["discardPile"] = discard
        let next = session.players.first { $0 != user.id } ?? user.id
        selectedCard = nil
        Task { await viewModel.updateGameState(sessionID: session.id, state: state, nextTurnID: declare ? nil : next, winnerID: declare ? user.id : nil) }
    }

    private func sanitizedDeck() -> [String] {
        let deck = stringArray(session.gameState["deck"])
        guard !deck.isEmpty else { return [] }

        var unavailable = Set(stringArray(session.gameState["discardPile"]))
        for playerID in session.players {
            unavailable.formUnion(stringArray(session.gameState["hand_\(playerID)"]))
        }
        return deck.filter { !unavailable.contains($0) }
    }

    private static func rummyDeck() -> [String] {
        ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"].flatMap { rank in
            ["\(rank)♠", "\(rank)♥", "\(rank)♦", "\(rank)♣"]
        }
    }

    private static func cardSortValue(_ card: String) -> Int {
        let suit = card.last.map(String.init) ?? ""
        let rank = String(card.dropLast())
        let suitIndex = ["♠", "♥", "♦", "♣"].firstIndex(of: suit) ?? 0
        let rankIndex = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"].firstIndex(of: rank) ?? 0
        return suitIndex * 20 + rankIndex
    }
}

private struct RummyCardFace: View {
    let card: String?
    let isBack: Bool
    let isSelected: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isBack ? Color(red: 0.54, green: 0.11, blue: 0.13) : .white)
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .strokeBorder(isBack ? Color.white.opacity(0.34) : suitColor.opacity(0.28), lineWidth: isBack ? 2 : 1)
                .padding(7)
            if isBack {
                Image(systemName: "suit.club.fill")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.white.opacity(0.88))
            } else if let card {
                VStack(alignment: .leading) {
                    Text(String(card.dropLast()))
                        .font(.headline.bold())
                    Spacer()
                    Text(card.last.map(String.init) ?? "")
                        .font(.title.bold())
                        .frame(maxWidth: .infinity)
                    Spacer()
                    Text(String(card.dropLast()))
                        .font(.headline.bold())
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(9)
                .foregroundStyle(suitColor)
            } else {
                Text("-")
                    .font(.title.bold())
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 78, height: 112)
        .shadow(color: .black.opacity(isSelected ? 0.28 : 0.14), radius: isSelected ? 10 : 4, x: 0, y: isSelected ? 8 : 3)
        .offset(y: isSelected ? -18 : 0)
        .animation(.snappy(duration: 0.18), value: isSelected)
    }

    private var suitColor: Color {
        guard let suit = card?.last else { return .secondary }
        return suit == "♥" || suit == "♦" ? .red : .black
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
