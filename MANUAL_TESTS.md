# Manual Test Checklist

This checklist covers features that cannot be fully automated due to system-level requirements (Accessibility permissions, global hotkeys, cross-app interactions).

## Pre-Release Testing

### Permission Flow

- [ ] **Fresh Install**: On a clean install, onboarding window appears
- [ ] **Open System Settings**: "Open System Settings" button navigates to correct pane
- [ ] **Permission Grant Detection**: App detects permission grant within 5 seconds
- [ ] **Permission Denial**: App shows appropriate message when permission is denied
- [ ] **Permission Revocation**: App detects when permission is revoked during use

### Hint Mode (Cmd+Shift+Space)

- [ ] **Activation**: Hotkey activates hint mode
- [ ] **Hint Display**: Hints appear over clickable UI elements
- [ ] **Menu Hints**: Hints appear over menu bar items
- [ ] **Open Menu Hints**: Hints appear over items in open menus
- [ ] **Hint Selection**: Typing hint character(s) selects element
- [ ] **Single Character**: Single-character hints work correctly
- [ ] **Two Character**: Two-character hints work correctly
- [ ] **Fuzzy Search**: Typing element text filters hints
- [ ] **Click Modifiers**:
  - [ ] Regular click (no modifier) performs left-click
  - [ ] Shift performs right-click
  - [ ] Control performs double-click
  - [ ] Option moves mouse without clicking
- [ ] **Escape Exit**: Escape key deactivates hint mode
- [ ] **Ctrl+[ Exit**: Ctrl+[ also deactivates hint mode
- [ ] **Cursor Hiding**: Cursor is hidden during hint mode

### Scroll Mode (Cmd+Shift+J)

- [ ] **Activation**: Hotkey activates scroll mode
- [ ] **Visual Indicator**: Overlay shows scrollable area
- [ ] **Basic Scrolling**:
  - [ ] `h` scrolls left
  - [ ] `l` scrolls right
  - [ ] `j` scrolls down
  - [ ] `k` scrolls up
- [ ] **Page Scrolling**:
  - [ ] `d` pages down
  - [ ] `u` pages up
- [ ] **Jump Scrolling**:
  - [ ] `gg` scrolls to top
  - [ ] `G` scrolls to bottom
- [ ] **Escape Exit**: Escape key deactivates scroll mode

### Search Mode (Cmd+Shift+/)

- [ ] **Activation**: Hotkey activates search mode
- [ ] **Search Bar**: Search bar appears centered on screen
- [ ] **Search Filtering**: Typing filters UI elements
- [ ] **Results Display**: Results show element label and role
- [ ] **Navigation**: Arrow keys navigate through results
- [ ] **Selection**: Enter key selects highlighted element
- [ ] **Escape Exit**: Escape key closes search mode

### Preferences Window

- [ ] **Open via Menu**: Cmd+, opens preferences
- [ ] **Shortcuts Tab**:
  - [ ] All three mode shortcuts displayed
  - [ ] Shortcut recording works
  - [ ] Re-register All Shortcuts button works
  - [ ] Reset to Defaults button works
- [ ] **Hints Tab**:
  - [ ] Hint characters field editable
  - [ ] Hint size slider works
  - [ ] Changes persist after restart
- [ ] **Diagnostic Tab**:
  - [ ] All status indicators displayed
  - [ ] Refresh Status button works
  - [ ] Copy Diagnostic Info button works
  - [ ] Retry All button works

### Menu Bar

- [ ] **Icon Display**: Menu bar icon appears
- [ ] **Status Display**: Menu shows correct status (Active/Issues Detected)
- [ ] **Error Icon**: Icon changes when issues detected
- [ ] **Troubleshoot Item**: Troubleshoot menu item appears when issues exist
- [ ] **Quit**: Quit KeyNav works

### Cross-App Testing

Test hint mode in various applications:

- [ ] **Finder**: Hints work on Finder windows
- [ ] **Safari/Chrome**: Hints work on web page elements
- [ ] **VS Code**: Hints work in editor interface
- [ ] **System Settings**: Hints work in preferences panes
- [ ] **Menu Bar Apps**: Hints work on third-party menu bar apps

### Edge Cases

- [ ] **Multiple Monitors**: Hints appear on correct monitor
- [ ] **Full Screen Apps**: Hints work in full-screen applications
- [ ] **Split View**: Hints work in Split View windows
- [ ] **Rapid Mode Switching**: Quickly switching between modes doesn't crash
- [ ] **Memory**: Extended use doesn't cause memory leaks

## Test Environment Setup

### Launch Arguments for Testing

```bash
# Launch with UI testing mode (disables auto-update checks)
open KeyNav.app --args --uitesting

# Launch simulating no permission (shows onboarding)
open KeyNav.app --args --simulate-no-permission

# Launch simulating hotkey failure (shows error state)
open KeyNav.app --args --simulate-hotkey-failure
```

### Resetting State

```bash
# Clear all preferences
defaults delete com.keynav.app

# Remove from Accessibility permissions
# System Settings > Privacy & Security > Accessibility > Remove KeyNav
```

## Reporting Issues

When reporting test failures, include:
1. macOS version
2. KeyNav version
3. Steps to reproduce
4. Diagnostic info (from Preferences > Diagnostic > Copy Diagnostic Info)
