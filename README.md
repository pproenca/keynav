# KeyNav

A free, open-source keyboard navigation app for macOS. Navigate and click any UI element using only your keyboard.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-macOS%2013%2B-lightgrey)

## Features

- **Hint Mode** - Press `⌘⇧Space` to show clickable hints on all UI elements. Type to search/filter, then type the hint code to click.
- **Scroll Mode** - Press `⌘⇧J` to scroll using Vim-style keys (H/J/K/L).
- **Search Mode** - Press `⌘⇧/` to search across all visible UI elements in all windows.
- **Custom Shortcuts** - Bind global hotkeys to specific UI elements for one-key actions.

## Installation

### Homebrew

```bash
brew install --cask keynav
```

### Manual Download

Download the latest `.dmg` from [GitHub Releases](https://github.com/yourusername/keynav/releases).

## Requirements

- macOS 13.0 or later
- Accessibility permission (granted on first launch)

## Usage

1. Launch KeyNav - it appears as a keyboard icon in your menu bar
2. Grant Accessibility permission when prompted
3. Press `⌘⇧Space` to activate hint mode
4. Type to filter elements, then type the hint code to click

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `⌘⇧Space` | Activate hint mode |
| `⌘⇧J` | Activate scroll mode |
| `⌘⇧/` | Activate search mode |
| `Escape` | Cancel/exit current mode |

### Scroll Mode Keys

| Key | Action |
|-----|--------|
| `H` | Scroll left |
| `J` | Scroll down |
| `K` | Scroll up |
| `L` | Scroll right |
| `D` | Page down |
| `U` | Page up |
| `G` | Scroll to bottom |
| `gg` | Scroll to top |

## Building from Source

```bash
git clone https://github.com/yourusername/keynav.git
cd keynav
./scripts/build-app.sh
```

This creates `KeyNav.app` in the project directory. To grant accessibility permissions:

1. Open **System Settings > Privacy & Security > Accessibility**
2. Click **+** and add `KeyNav.app`
3. Run with `open KeyNav.app`

### Development Build

For quick iteration without the app bundle:

```bash
swift build
swift run
```

Note: Running via `swift run` requires adding **Terminal.app** to Accessibility permissions instead.

## License

MIT License - see [LICENSE](LICENSE) for details.

## Acknowledgments

- Inspired by [Homerow](https://homerow.app) and [Vimac](https://github.com/nchudleigh/vimac)
- Uses [HotKey](https://github.com/soffes/HotKey) for global hotkey registration
