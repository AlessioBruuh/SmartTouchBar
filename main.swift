import Cocoa
import IOKit.ps

// MARK: - DFRFoundation (privato, caricato a runtime)

private let dfr = dlopen("/System/Library/PrivateFrameworks/DFRFoundation.framework/DFRFoundation", RTLD_NOW)

func setControlStripPresence(_ id: String, _ visible: Bool) {
    typealias Fn = @convention(c) (CFString, Bool) -> Void
    guard let sym = dlsym(dfr, "DFRElementSetControlStripPresenceForIdentifier") else { return }
    unsafeBitCast(sym, to: Fn.self)(id as CFString, visible)
}

// MARK: - Configurazione

struct Action: Codable {
    var title: String?
    var symbol: String?   // nome SF Symbol
    var keys: String?     // es. "cmd+shift+n", "ctrl+c", "f5"
    var shell: String?    // comando zsh
    var system: String?   // play, next, prev, volup, voldown, mute, brightup, brightdown
}

struct Config: Codable {
    var apps: [String: [Action]]   // bundle id -> azioni
    var sites: [String: [Action]]?  // dominio -> azioni (nel browser)
    var fallback: [Action]
}

enum ConfigStore {
    static let dir = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library/Application Support/SmartTouchBar")
    static let url = dir.appendingPathComponent("config.json")

    static func load() -> Config {
        if let data = try? Data(contentsOf: url),
           let cfg = try? JSONDecoder().decode(Config.self, from: data) {
            return cfg
        }
        if !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            let enc = JSONEncoder()
            enc.outputFormatting = [.prettyPrinted, .sortedKeys]
            try? enc.encode(defaults).write(to: url)
        }
        return defaults
    }

    static let browser: [Action] = [
        Action(symbol: "chevron.left", keys: "cmd+left"),
        Action(symbol: "chevron.right", keys: "cmd+right"),
        Action(symbol: "arrow.clockwise", keys: "cmd+r"),
        Action(title: "Google", symbol: "magnifyingglass", keys: "cmd+l"),
        Action(title: "Nuova scheda", symbol: "plus", keys: "cmd+t"),
        Action(symbol: "xmark", keys: "cmd+w"),
        Action(title: "Riapri", symbol: "arrow.uturn.backward", keys: "cmd+shift+t"),
        Action(title: "Privata", symbol: "eyeglasses", keys: "cmd+shift+n"),
        openClaude,
    ]
    static let openClaude = Action(title: "Claude", symbol: "sparkle", shell: "open -a Claude")
    static let media: [Action] = [
        Action(symbol: "backward.fill", system: "prev"),
        Action(symbol: "playpause.fill", system: "play"),
        Action(symbol: "forward.fill", system: "next"),
    ]

    static let defaults = Config(
        apps: [
            "com.apple.Safari": browser,
            "com.google.Chrome": browser,
            "company.thebrowser.Browser": browser,
            "org.mozilla.firefox": browser,
            "com.anthropic.claudefordesktop": [
                Action(title: "Nuova chat", symbol: "square.and.pencil", keys: "cmd+n"),
                Action(title: "Cerca", symbol: "magnifyingglass", keys: "cmd+k"),
                Action(title: "Invia", symbol: "paperplane.fill", keys: "return"),
                Action(title: "A capo", symbol: "return", keys: "shift+return"),
                Action(title: "Impostazioni", symbol: "gearshape", keys: "cmd+,"),
            ],
            "com.apple.finder": [
                Action(title: "Cartella", symbol: "folder.badge.plus", keys: "cmd+shift+n"),
                Action(title: "Info", symbol: "info.circle", keys: "cmd+i"),
                Action(title: "Vai a…", symbol: "arrow.right.circle", keys: "cmd+shift+g"),
                Action(title: "Nascosti", symbol: "eye", keys: "cmd+shift+."),
                Action(symbol: "trash", keys: "cmd+delete"),
                Action(title: "Terminale qui", symbol: "terminal",
                       shell: "osascript -e 'tell application \"Finder\" to set p to POSIX path of (insertion location as alias)' | xargs -I{} open -a Terminal {}"),
            ],
            "com.microsoft.VSCode": [
                Action(title: "Comandi", symbol: "command", keys: "cmd+shift+p"),
                Action(title: "Apri file", symbol: "doc.text.magnifyingglass", keys: "cmd+p"),
                Action(title: "Cerca", symbol: "magnifyingglass", keys: "cmd+shift+f"),
                Action(title: "Sidebar", symbol: "sidebar.left", keys: "cmd+b"),
                Action(title: "Esegui", symbol: "play.fill", keys: "f5"),
            ],
            "com.apple.dt.Xcode": [
                Action(title: "Build", symbol: "hammer", keys: "cmd+b"),
                Action(title: "Run", symbol: "play.fill", keys: "cmd+r"),
                Action(symbol: "stop.fill", keys: "cmd+."),
                Action(title: "Test", symbol: "checkmark.diamond", keys: "cmd+u"),
                Action(title: "Clean", symbol: "sparkles", keys: "cmd+shift+k"),
            ],
            "com.apple.Terminal": [
                Action(title: "Scheda", symbol: "plus", keys: "cmd+t"),
                Action(title: "Pulisci", symbol: "clear", keys: "cmd+k"),
                Action(title: "^C", symbol: "stop.circle", keys: "ctrl+c"),
                Action(symbol: "arrow.up", keys: "up"),
                Action(symbol: "arrow.down", keys: "down"),
                Action(symbol: "arrow.right.to.line", keys: "tab"),
                openClaude,
            ],
            "com.apple.mail": [
                Action(title: "Nuova", symbol: "square.and.pencil", keys: "cmd+n"),
                Action(title: "Rispondi", symbol: "arrowshape.turn.up.left", keys: "cmd+r"),
                Action(title: "A tutti", symbol: "arrowshape.turn.up.left.2", keys: "cmd+shift+r"),
                Action(title: "Inoltra", symbol: "arrowshape.turn.up.right", keys: "cmd+shift+f"),
                Action(title: "Invia", symbol: "paperplane.fill", keys: "cmd+shift+d"),
            ],
            "com.apple.Music": media,
            "com.spotify.client": media,
        ],
        sites: [
            "youtube.com": [
                Action(title: "-10s", symbol: "gobackward.10", keys: "j"),
                Action(symbol: "playpause.fill", keys: "k"),
                Action(title: "+10s", symbol: "goforward.10", keys: "l"),
                Action(title: "Sottotitoli", symbol: "captions.bubble", keys: "c"),
                Action(title: "Teatro", symbol: "rectangle.expand.vertical", keys: "t"),
                Action(title: "Schermo intero", symbol: "arrow.up.left.and.arrow.down.right", keys: "f"),
            ],
            "mail.google.com": [
                Action(title: "Scrivi", symbol: "square.and.pencil", keys: "c"),
                Action(title: "Rispondi", symbol: "arrowshape.turn.up.left", keys: "r"),
                Action(title: "Archivia", symbol: "archivebox", keys: "e"),
                Action(symbol: "chevron.up", keys: "k"),
                Action(symbol: "chevron.down", keys: "j"),
            ],
            "claude.ai": [
                Action(title: "Nuova chat", symbol: "square.and.pencil", keys: "cmd+k"),
                Action(title: "A capo", symbol: "return", keys: "shift+return"),
            ],
        ],
        fallback: [
            openClaude,
            Action(title: "Spotlight", symbol: "magnifyingglass", keys: "cmd+space"),
            Action(title: "Mission", symbol: "rectangle.3.group", shell: "open -a 'Mission Control'"),
            Action(title: "Screenshot", symbol: "camera.viewfinder", keys: "cmd+shift+5"),
            Action(title: "Blocca", symbol: "lock.fill", keys: "ctrl+cmd+q"),
        ]
    )
}

// MARK: - Input sintetico

let keyCodes: [String: CGKeyCode] = [
    "a": 0, "s": 1, "d": 2, "f": 3, "h": 4, "g": 5, "z": 6, "x": 7, "c": 8, "v": 9,
    "b": 11, "q": 12, "w": 13, "e": 14, "r": 15, "y": 16, "t": 17,
    "1": 18, "2": 19, "3": 20, "4": 21, "6": 22, "5": 23, "=": 24, "9": 25, "7": 26,
    "-": 27, "8": 28, "0": 29, "]": 30, "o": 31, "u": 32, "[": 33, "i": 34, "p": 35,
    "return": 36, "enter": 36, "l": 37, "j": 38, "'": 39, "k": 40, ";": 41, "\\": 42,
    ",": 43, "/": 44, "n": 45, "m": 46, ".": 47, "tab": 48, "space": 49, "`": 50,
    "delete": 51, "esc": 53, "escape": 53,
    "f1": 122, "f2": 120, "f3": 99, "f4": 118, "f5": 96, "f6": 97, "f7": 98, "f8": 100,
    "f9": 101, "f10": 109, "f11": 103, "f12": 111,
    "left": 123, "right": 124, "down": 125, "up": 126,
]

func postShortcut(_ shortcut: String) {
    var flags: CGEventFlags = []
    var code: CGKeyCode?
    for part in shortcut.lowercased().split(separator: "+").map(String.init) {
        switch part {
        case "cmd", "command": flags.insert(.maskCommand)
        case "shift": flags.insert(.maskShift)
        case "alt", "opt", "option": flags.insert(.maskAlternate)
        case "ctrl", "control": flags.insert(.maskControl)
        case "fn": flags.insert(.maskSecondaryFn)
        default: code = keyCodes[part]
        }
    }
    guard let code else { NSLog("SmartTouchBar: tasto sconosciuto in \(shortcut)"); return }
    let src = CGEventSource(stateID: .hidSystemState)
    for down in [true, false] {
        let ev = CGEvent(keyboardEventSource: src, virtualKey: code, keyDown: down)
        ev?.flags = flags
        ev?.post(tap: .cghidEventTap)
    }
}

// Codici NX_KEYTYPE_* per i tasti multimediali
let systemKeys: [String: Int] = [
    "volup": 0, "voldown": 1, "brightup": 2, "brightdown": 3, "mute": 7,
    "play": 16, "next": 17, "prev": 18,
]

func postSystemKey(_ key: Int) {
    for down in [true, false] {
        let state = down ? 0xa : 0xb
        let ev = NSEvent.otherEvent(
            with: .systemDefined, location: .zero,
            modifierFlags: NSEvent.ModifierFlags(rawValue: UInt(state << 8)),
            timestamp: 0, windowNumber: 0, context: nil,
            subtype: 8, data1: (key << 16) | (state << 8), data2: -1)
        ev?.cgEvent?.post(tap: .cghidEventTap)
    }
}

func run(_ action: Action) {
    if let keys = action.keys { postShortcut(keys) }
    if let name = action.system, let key = systemKeys[name] { postSystemKey(key) }
    if let cmd = action.shell {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/bin/zsh")
        p.arguments = ["-lc", cmd]
        try? p.run()
    }
}

// MARK: - Statistiche di sistema

final class Stats {
    private var prevTicks: (UInt32, UInt32, UInt32, UInt32)?

    func cpu() -> Double {
        var info = host_cpu_load_info()
        var size = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info>.stride / MemoryLayout<integer_t>.stride)
        let res = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &size)
            }
        }
        guard res == KERN_SUCCESS else { return 0 }
        let t = info.cpu_ticks  // user, system, idle, nice
        defer { prevTicks = t }
        guard let p = prevTicks else { return 0 }
        let busy = Double((t.0 &- p.0) &+ (t.1 &- p.1) &+ (t.3 &- p.3))
        let total = busy + Double(t.2 &- p.2)
        return total > 0 ? busy / total : 0
    }

    func battery() -> (percent: Int, charging: Bool)? {
        guard let blob = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let list = IOPSCopyPowerSourcesList(blob)?.takeRetainedValue() as? [CFTypeRef] else { return nil }
        for ps in list {
            guard let d = IOPSGetPowerSourceDescription(blob, ps)?.takeUnretainedValue() as? [String: Any],
                  let cap = d[kIOPSCurrentCapacityKey] as? Int else { continue }
            let plugged = (d[kIOPSPowerSourceStateKey] as? String) == kIOPSACPowerValue
            return (cap, plugged)
        }
        return nil
    }
}

// MARK: - Comandi scoperti dai menu (Accessibilità)

struct MenuCommand {
    let title: String
    let element: AXUIElement
}

private func axAttr<T>(_ el: AXUIElement, _ name: String) -> T? {
    var value: CFTypeRef?
    guard AXUIElementCopyAttributeValue(el, name as CFString, &value) == .success else { return nil }
    return value as? T
}

// Scorciatoie troppo generiche per meritare un pulsante (modificatori + tasto)
private let genericShortcuts: Set<String> = ["0Q", "0H", "0C", "0V", "0X", "0Z", "0A", "0M", "0,", "0W", "1Z", "2H"]

// Voci che macOS aggiunge a tutte le app
private let systemItemHints = ["dettatura", "dictation", "emoji"]

// Legge la barra dei menu dell'app e tiene le voci che hanno una scorciatoia:
// funziona con qualsiasi app, senza configurazione.
func discoverMenuCommands(pid: pid_t, limit: Int = 40) -> [MenuCommand] {
    let app = AXUIElementCreateApplication(pid)
    AXUIElementSetMessagingTimeout(app, 0.3)
    guard let bar: AXUIElement = axAttr(app, kAXMenuBarAttribute),
          let tops: [AXUIElement] = axAttr(bar, kAXChildrenAttribute) else { return [] }
    var result: [MenuCommand] = []
    for top in tops.dropFirst(2).dropLast() {  // salta menu Apple, menu dell'app e Aiuto
        let menuTitle: String = axAttr(top, kAXTitleAttribute) ?? ""
        if ["Finestra", "Window"].contains(menuTitle) { continue }
        for menu in (axAttr(top, kAXChildrenAttribute) as [AXUIElement]?) ?? [] {
            for item in (axAttr(menu, kAXChildrenAttribute) as [AXUIElement]?) ?? [] {
                guard let title: String = axAttr(item, kAXTitleAttribute), !title.isEmpty,
                      let char: String = axAttr(item, kAXMenuItemCmdCharAttribute), !char.isEmpty,
                      (axAttr(item, kAXEnabledAttribute) as Bool?) != false else { continue }
                if systemItemHints.contains(where: title.lowercased().contains) { continue }
                let mods: Int = axAttr(item, kAXMenuItemCmdModifiersAttribute) ?? 0
                if genericShortcuts.contains("\(mods)\(char.uppercased())") { continue }
                result.append(MenuCommand(title: title, element: item))
                if result.count >= limit { return result }
            }
        }
    }
    return result
}

private let symbolHints: [(String, String)] = [
    ("nuov", "plus"), ("new", "plus"), ("apri", "folder"), ("open", "folder"),
    ("salva", "square.and.arrow.down"), ("save", "square.and.arrow.down"),
    ("cerca", "magnifyingglass"), ("trova", "magnifyingglass"), ("find", "magnifyingglass"), ("search", "magnifyingglass"),
    ("stampa", "printer"), ("print", "printer"),
    ("esporta", "square.and.arrow.up"), ("export", "square.and.arrow.up"),
    ("condividi", "square.and.arrow.up"), ("share", "square.and.arrow.up"),
    ("ricarica", "arrow.clockwise"), ("aggiorna", "arrow.clockwise"), ("reload", "arrow.clockwise"), ("refresh", "arrow.clockwise"),
    ("elimina", "trash"), ("delete", "trash"), ("duplica", "plus.square.on.square"), ("duplicate", "plus.square.on.square"),
    ("ingrand", "plus.magnifyingglass"), ("zoom in", "plus.magnifyingglass"),
    ("riduci", "minus.magnifyingglass"), ("zoom out", "minus.magnifyingglass"),
    ("schermo intero", "arrow.up.left.and.arrow.down.right"), ("full screen", "arrow.up.left.and.arrow.down.right"),
    ("barra laterale", "sidebar.left"), ("sidebar", "sidebar.left"),
    ("indietro", "chevron.left"), ("back", "chevron.left"), ("avanti", "chevron.right"), ("forward", "chevron.right"),
]

func guessSymbol(_ title: String) -> String? {
    let t = title.lowercased()
    return symbolHints.first { t.contains($0.0) }?.1
}

func shorten(_ title: String) -> String {
    let t = title.replacingOccurrences(of: "…", with: "").replacingOccurrences(of: "...", with: "")
    return t.count > 16 ? String(t.prefix(15)) + "…" : t
}

// MARK: - Apprendimento: conta quante volte usi ogni pulsante

enum Usage {
    private static let key = "usage"
    private static var counts = UserDefaults.standard.dictionary(forKey: key) as? [String: Int] ?? [:]

    static func bump(_ id: String) {
        counts[id, default: 0] += 1
        UserDefaults.standard.set(counts, forKey: key)
    }

    // Un pulsante sale in testa solo dopo qualche uso, così l'ordine non salta a caso.
    static func score(_ id: String) -> Int {
        let n = counts[id] ?? 0
        return n >= 3 ? n : 0
    }
}

// MARK: - Sito aperto nel browser

private let browserScripts: [String: String] = [
    "com.google.Chrome": "tell application id \"com.google.Chrome\" to get URL of active tab of front window",
    "company.thebrowser.Browser": "tell application id \"company.thebrowser.Browser\" to get URL of active tab of front window",
    "com.apple.Safari": "tell application id \"com.apple.Safari\" to get URL of front document",
]

func currentHost(bundle: String) -> String? {
    guard let source = browserScripts[bundle] else { return nil }
    var error: NSDictionary?
    let url = NSAppleScript(source: source)?.executeAndReturnError(&error).stringValue
    return url.flatMap { URL(string: $0)?.host }
}

// MARK: - UI

final class TBButton: NSButton {
    private var handler: () -> Void = {}

    static func make(title: String?, symbol: String?, width: CGFloat? = nil, tint: NSColor? = nil,
                     _ handler: @escaping () -> Void) -> TBButton {
        let b = TBButton(title: title ?? "", target: nil, action: nil)
        b.handler = handler
        b.target = b
        b.action = #selector(fire)
        if let symbol, let img = NSImage(systemSymbolName: symbol, accessibilityDescription: title) {
            b.image = img
            b.imagePosition = (title ?? "").isEmpty ? .imageOnly : .imageLeading
        }
        if let width { b.widthAnchor.constraint(equalToConstant: width).isActive = true }
        if let tint { b.bezelColor = tint }
        return b
    }

    @objc private func fire() { handler() }
}

extension NSTouchBarItem.Identifier {
    static let tray = Self("com.smarttouchbar.tray")
    static let esc = Self("com.smarttouchbar.esc")
    static let context = Self("com.smarttouchbar.context")
    static let stats = Self("com.smarttouchbar.stats")
    static let controls = Self("com.smarttouchbar.controls")
    static let clock = Self("com.smarttouchbar.clock")
    static let close = Self("com.smarttouchbar.close")
}

struct Item {
    let id: String
    let title: String?
    let symbol: String?
    let tint: NSColor?
    let perform: () -> Void
}

private let claudeBundle = "com.anthropic.claudefordesktop"

func askClaude() {
    NSWorkspace.shared.open(URL(fileURLWithPath: "/Applications/Claude.app"))
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { postShortcut("cmd+v") }
}

final class SmartBar: NSObject, NSTouchBarDelegate {
    private let bar = NSTouchBar()
    private let stats = Stats()
    private var collapsed = false

    private var frontApp: NSRunningApplication?
    private var menuCommands: [MenuCommand] = []
    private var lastSignature = ""
    private var clipChange = NSPasteboard.general.changeCount
    private var clip: (text: String, time: Date)?
    private var battery: (percent: Int, charging: Bool)?

    private let contextStack = NSStackView()
    private let contextScroll = NSScrollView()
    private var contextWidth: NSLayoutConstraint!
    private let statsLabel = NSTextField(labelWithString: "")
    private let clockLabel = NSTextField(labelWithString: "")
    private let clockFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    override init() {
        super.init()
        bar.delegate = self
        bar.defaultItemIdentifiers = [.esc, .context, .flexibleSpace, .stats, .controls, .clock, .close]

        contextStack.orientation = .horizontal
        contextStack.spacing = 6
        contextScroll.documentView = contextStack
        contextScroll.hasHorizontalScroller = false
        contextScroll.drawsBackground = false
        contextScroll.translatesAutoresizingMaskIntoConstraints = false
        contextWidth = contextScroll.widthAnchor.constraint(equalToConstant: 300)
        contextWidth.isActive = true

        for label in [statsLabel, clockLabel] {
            label.font = .monospacedDigitSystemFont(ofSize: 14, weight: .medium)
        }
    }

    func start() {
        let tray = NSCustomTouchBarItem(identifier: .tray)
        tray.view = TBButton.make(title: nil, symbol: "sparkles") { [weak self] in self?.present() }
        NSTouchBarItem.addSystemTrayItem(tray)
        setControlStripPresence(NSTouchBarItem.Identifier.tray.rawValue, true)

        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: .main
        ) { [weak self] note in
            self?.appChanged(note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication)
        }

        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in self?.tick() }
        tick()
        appChanged(NSWorkspace.shared.frontmostApplication)
    }

    private func present() {
        collapsed = false
        NSTouchBar.presentSystemModalTouchBar(bar, placement: 1, systemTrayItemIdentifier: .tray)
    }

    private func collapse() {
        collapsed = true
        NSTouchBar.minimizeSystemModalTouchBar(bar)
    }

    private func appChanged(_ app: NSRunningApplication?) {
        frontApp = app
        menuCommands = app.map { discoverMenuCommands(pid: $0.processIdentifier) } ?? []
        refresh(force: true)
        // Un'app appena lanciata può non avere ancora i menu pronti: riprova tra poco.
        if menuCommands.isEmpty, let app {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                guard let self, self.frontApp == app else { return }
                self.menuCommands = discoverMenuCommands(pid: app.processIdentifier)
                if !self.menuCommands.isEmpty { self.refresh(force: true) }
            }
        }
    }

    private var clipKind: String {
        guard let clip, Date().timeIntervalSince(clip.time) < 60 else { return "" }
        let text = clip.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.hasPrefix("http://") || text.hasPrefix("https://"), URL(string: text) != nil { return "url" }
        return text.count >= 3 ? "text" : ""
    }

    // Ricostruisce la barra solo quando cambia il contesto: app, sito, appunti, batteria.
    private func refresh(force: Bool = false) {
        let bundle = frontApp?.bundleIdentifier ?? ""
        let host = currentHost(bundle: bundle)
        let lowBattery = battery.map { !$0.charging && $0.percent <= 20 } ?? false
        let signature = "\(bundle)|\(host ?? "")|\(clipKind)|\(lowBattery)"
        guard force || signature != lastSignature else { return }
        lastSignature = signature
        rebuild(bundle: bundle, host: host, lowBattery: lowBattery)
    }

    private func item(from a: Action, prefix: String, tint: NSColor? = nil) -> Item {
        Item(id: "\(prefix)|\(a.title ?? a.symbol ?? a.keys ?? "")", title: a.title, symbol: a.symbol, tint: tint) { run(a) }
    }

    private func rebuild(bundle: String, host: String?, lowBattery: Bool) {
        let config = ConfigStore.load()

        // Suggerimenti del momento
        var chips: [Item] = []
        if lowBattery {
            chips.append(Item(id: "chip|battery", title: "Batteria", symbol: "battery.25", tint: .systemRed) {
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.battery")!)
            })
        }
        switch clipKind {
        case "url":
            if let url = clip.flatMap({ URL(string: $0.text.trimmingCharacters(in: .whitespacesAndNewlines)) }) {
                chips.append(Item(id: "chip|url", title: "Apri link", symbol: "link", tint: .systemBlue) {
                    NSWorkspace.shared.open(url)
                })
            }
        case "text" where bundle != claudeBundle:
            chips.append(Item(id: "chip|claude", title: "Chiedi a Claude", symbol: "sparkle", tint: .systemOrange) { askClaude() })
        default:
            break
        }

        // Azioni del sito aperto
        var site: [Item] = []
        if let host, let sites = config.sites ?? ConfigStore.defaults.sites,
           let match = sites.first(where: { host == $0.key || host.hasSuffix("." + $0.key) }) {
            site = match.value.map { item(from: $0, prefix: "site|\(match.key)", tint: .systemIndigo) }
        }

        // Azioni dell'app: config + comandi scoperti nei menu, ordinati per uso
        let configured = config.apps[bundle] ?? (menuCommands.isEmpty ? config.fallback : [])
        var regular = configured.map { item(from: $0, prefix: bundle) }
        let known = Set(regular.compactMap { $0.title?.lowercased() })
        regular += menuCommands.filter { !known.contains($0.title.lowercased()) }.map { cmd in
            Item(id: "\(bundle)|menu|\(cmd.title)", title: shorten(cmd.title), symbol: guessSymbol(cmd.title), tint: nil) {
                AXUIElementPerformAction(cmd.element, kAXPressAction as CFString)
            }
        }
        regular = regular.enumerated().sorted { a, b in
            let (sa, sb) = (Usage.score(a.element.id), Usage.score(b.element.id))
            return sa != sb ? sa > sb : a.offset < b.offset
        }.map(\.element)

        contextStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if let icon = frontApp?.icon {
            icon.size = NSSize(width: 22, height: 22)
            contextStack.addArrangedSubview(NSImageView(image: icon))
        }
        for it in chips + site + regular {
            contextStack.addArrangedSubview(TBButton.make(title: it.title, symbol: it.symbol, tint: it.tint) {
                Usage.bump(it.id)
                it.perform()
            })
        }
        contextStack.layoutSubtreeIfNeeded()
        let size = contextStack.fittingSize
        contextStack.frame = NSRect(origin: .zero, size: NSSize(width: size.width, height: 30))
        contextWidth.constant = min(size.width, 420)
        contextScroll.contentView.scroll(to: .zero)

        if !collapsed { present() }
    }

    private func tick() {
        clockLabel.stringValue = clockFormatter.string(from: Date())

        let pb = NSPasteboard.general
        if pb.changeCount != clipChange {
            clipChange = pb.changeCount
            clip = pb.string(forType: .string).map { ($0, Date()) }
        }

        battery = stats.battery()
        let cpu = Int(stats.cpu() * 100)
        let text = NSMutableAttributedString()
        let base: [NSAttributedString.Key: Any] = [.font: statsLabel.font!]
        func add(_ s: String, _ color: NSColor) {
            text.append(NSAttributedString(string: s, attributes: base.merging([.foregroundColor: color]) { $1 }))
        }
        add("CPU \(cpu)%", cpu > 80 ? .systemOrange : .labelColor)
        if let b = battery {
            let color: NSColor = b.charging ? .systemGreen : (b.percent <= 20 ? .systemRed : .labelColor)
            add("  \(b.charging ? "⚡︎" : "")\(b.percent)%", color)
        }
        statsLabel.attributedStringValue = text

        refresh()
    }

    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier id: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        let item = NSCustomTouchBarItem(identifier: id)
        switch id {
        case .esc:
            item.view = TBButton.make(title: "esc", symbol: nil, width: 56) { postShortcut("esc") }
        case .context:
            item.view = contextScroll
        case .stats:
            item.view = statsLabel
        case .controls:
            let controls: [(String, String)] = [
                ("sun.min", "brightdown"), ("sun.max", "brightup"),
                ("speaker.wave.1", "voldown"), ("speaker.wave.3", "volup"),
                ("playpause.fill", "play"),
            ]
            let stack = NSStackView(views: controls.map { symbol, key in
                TBButton.make(title: nil, symbol: symbol, width: 40) { postSystemKey(systemKeys[key]!) }
            })
            stack.spacing = 4
            item.view = stack
        case .clock:
            item.view = clockLabel
        case .close:
            item.view = TBButton.make(title: nil, symbol: "chevron.right.2", width: 36) { [weak self] in self?.collapse() }
        default:
            return nil
        }
        return item
    }
}

// MARK: - Avvio

let app = NSApplication.shared
app.setActivationPolicy(.accessory)

let trusted = AXIsProcessTrustedWithOptions(
    [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary)
if !trusted {
    NSLog("SmartTouchBar: concedi l'accesso in Impostazioni > Privacy e sicurezza > Accessibilità")
}

let smartBar = SmartBar()
smartBar.start()
app.run()
