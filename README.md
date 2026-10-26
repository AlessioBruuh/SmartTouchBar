# SmartTouchBar ✨

Una Touch Bar per MacBook Pro che si adatta a quello che stai facendo: cambia con l'app in primo piano, riconosce il sito aperto nel browser, reagisce agli appunti e mette in testa i pulsanti che usi di più.

*A context-aware Touch Bar for MacBook Pro: it adapts to the frontmost app, the website you're on, your clipboard and your habits. English below.*

![YouTube in Chrome](docs/youtube.png)
![Claude](docs/claude.png)
![TextEdit, comandi letti dai menu](docs/textedit.png)

## Cosa fa

- **Pulsanti per ogni app**: Chrome, Safari, Arc, Firefox, Finder, VS Code, Xcode, Terminale, Mail, Musica, Spotify e Claude hanno i loro profili.
- **Funziona con qualsiasi app**: per le app senza profilo legge la barra dei menu e crea i pulsanti dai comandi con scorciatoia, con un'icona scelta in base al nome. I pulsanti premono la voce di menu, quindi funzionano con qualsiasi layout di tastiera.
- **Riconosce il sito**: su YouTube compaiono −10s, play/pausa, +10s, sottotitoli, modalità teatro e schermo intero; su Gmail compaiono scrivi, rispondi e archivia. I siti si aggiungono dal config.
- **Reagisce agli appunti**: se copi un link compare **Apri link**; se copi del testo compare **Chiedi a Claude**, che apre Claude e lo incolla.
- **Impara**: un pulsante premuto almeno 3 volte sale in testa per quell'app.
- **Stato del sistema**: CPU (arancione sopra l'80%), batteria (rossa sotto il 20%, verde in carica) e un avviso quando la batteria è bassa.
- **Controlli fissi**: esc (utile sui modelli senza tasto fisico), luminosità, volume, play/pausa e orologio. Il pulsante » torna alla Touch Bar di sistema; per riaprire SmartTouchBar tocca ✨ nella Control Strip.

![Appunti](docs/clipboard.png)

## Installazione

Serve macOS 11 o successivo e un Mac con Touch Bar.

**Dalla release**: scarica `SmartTouchBar.zip` dalle [Releases](../../releases), estrailo e sposta `SmartTouchBar.app` in Applicazioni. L'app non è firmata da uno sviluppatore Apple: la prima volta aprila con tasto destro › Apri, oppure:

```bash
xattr -dr com.apple.quarantine /Applications/SmartTouchBar.app
```

**Dal sorgente** (bastano gli strumenti da riga di comando di Xcode):

```bash
./build.sh
```

Al primo avvio concedi:

1. **Accessibilità** (Impostazioni › Privacy e sicurezza › Accessibilità), per inviare i tasti e leggere i menu.
2. **Automazione** del browser, quando richiesta, per riconoscere il sito aperto.

Per farla partire all'accensione aggiungila in Impostazioni › Generali › Elementi login.

## Personalizzazione

Al primo avvio viene creato `~/Library/Application Support/SmartTouchBar/config.json`. Le modifiche si applicano al cambio di app, senza riavviare.

```json
{
  "apps": {
    "com.apple.Notes": [
      { "title": "Nuova nota", "symbol": "square.and.pencil", "keys": "cmd+n" }
    ]
  },
  "sites": {
    "github.com": [
      { "title": "Cerca file", "symbol": "doc.text.magnifyingglass", "keys": "t" }
    ]
  },
  "fallback": [ ... ]
}
```

Ogni pulsante può avere:

| Campo | Esempio | Effetto |
|---|---|---|
| `title` | `"Nuova nota"` | testo del pulsante |
| `symbol` | `"square.and.pencil"` | icona [SF Symbols](https://developer.apple.com/sf-symbols/) |
| `keys` | `"cmd+shift+n"`, `"f5"`, `"ctrl+c"` | invia una scorciatoia |
| `shell` | `"open -a Calendar"` | esegue un comando zsh |
| `system` | `play`, `next`, `prev`, `volup`, `voldown`, `mute`, `brightup`, `brightdown` | tasto multimediale |

Il bundle id di un'app si trova con `osascript -e 'id of app "Nome App"'`.

## Come funziona

È un'unica app Swift senza dipendenze. Usa le stesse API private di AppKit e DFRFoundation usate da [MTMR](https://github.com/Toxblh/MTMR) e [Pock](https://github.com/pock/pock) per mostrare una Touch Bar globale, quindi un futuro aggiornamento di macOS potrebbe romperla.

`build.sh` firma l'app ad-hoc con un requisito basato sul bundle id, così il permesso di Accessibilità resta valido anche dopo una ricompilazione.

---

## English

SmartTouchBar replaces the Touch Bar with a context-aware one:

- **Per-app buttons** for browsers, Finder, VS Code, Xcode, Terminal, Mail, Music, Spotify and Claude.
- **Any app works**: for apps without a profile it reads the menu bar and turns commands with shortcuts into buttons.
- **Site-aware**: YouTube and Gmail controls in the browser, extendable via `sites` in the config.
- **Clipboard-aware**: copy a link → *Apri link* (open link); copy text → *Chiedi a Claude* (ask Claude).
- **Learns** which buttons you use and moves them to the front.
- **Always there**: esc, brightness, volume, play/pause, clock, CPU and battery.

Build with `./build.sh`, grant Accessibility permission, and customize `~/Library/Application Support/SmartTouchBar/config.json`. The UI is in Italian.

## Licenza / License

MIT
