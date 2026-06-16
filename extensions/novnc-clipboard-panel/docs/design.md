# Design notes

## Purpose

Add a clipboard tool to the Proxmox noVNC console side panel so text can be pasted into a VM console from the browser.

## First version

The first version uses paste-as-keystrokes:

1. User clicks the clipboard button.
2. A small panel opens.
3. User pastes text into the panel.
4. User clicks Send to Console.
5. The script focuses the noVNC canvas and sends keyboard events.

## Button placement

Target placement is between the keyboard button and the settings gear in the noVNC side bar.

Expected visual order:

```text
Keyboard
Clipboard
Settings
Power
```

## Limits

This is not true guest clipboard sync. It sends text as typed characters. That is safer for a first prototype and works for command lines and config text.

Special keys, non-US layouts, and advanced shortcuts need later testing.

## Test plan

- Test in a disposable VM first.
- Start with simple text.
- Test one command at a time.
- Test multi-line shell commands after simple text works.
- Do not use secrets until clear-after-send behavior is verified.
