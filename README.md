# jrnl

A macOS message composer application with markdown support that sends messages to Discord channels via webhooks.

## Features

- Markdown editor with live syntax highlighting
- Support for multiple Discord channels via webhooks
- Keyboard shortcuts for quick message sending
- Plain text paste to preserve markdown formatting
- Channel selection with keyboard navigation

## Keyboard Shortcuts

### Message Actions

- `⌘` + `Return` - Send message

### Channel Navigation

- `⌘` + `K` - Open channel selector
- `⌘` + `⌃` + `↑` - Switch to previous channel
- `⌘` + `⌃` + `↓` - Switch to next channel

### Channel Selector

- `↑` / `↓` - Navigate channels
- `Return` - Select highlighted channel
- `1`-`9` - Quick select channel by number
- `Esc` - Close selector

## Building for Local Use

Build the release version for local usage:

```bash
xcodebuild -scheme jrnl -configuration Release -derivedDataPath build
```

The built application will be located at:

```
build/Build/Products/Release/jrnl.app
```

Run the app directly from the build directory or copy it to `/Applications` for easier access.

## License

MIT. See [LICENSE](./LICENSE) for details.
