# iOS Build Readiness — StoryForce

_Verified 2026-07-02 with local tooling ($0)._

## Status: BUILD-READY (pending full Xcode install)

The iOS app is a complete SwiftUI codebase and now has a generated Xcode
project. It will build/run once **Xcode.app** is installed (see blocker below).

## What was verified locally

| Check | Tool | Result |
|-------|------|--------|
| Swift syntax, all 9 files | `swiftc -parse` (Swift 6.1.2) | ✅ 0 errors |
| Xcode project generation | XcodeGen 2.45.4 | ✅ `StoryForce.xcodeproj` created |
| App entry point | `@main struct StoryForceApp` | ✅ present |

## Files

```
code/ios/
├── project.yml                  # XcodeGen spec (source of truth — regenerate anytime)
├── StoryForce.xcodeproj/        # generated
└── StoryForce/
    ├── App.swift                # @main, AuthManager, StoryManager, data models
    ├── Managers/AudioRecordingManager.swift
    └── Views/ (7 SwiftUI views: MainTab, Auth, Dashboard, StoriesList,
                StoryDetail, ClientProfiles, Analytics)
```

## Project config (project.yml)

- Bundle ID: `ai.storyforce.app`
- Deployment target: iOS 16.0
- `NSMicrophoneUsageDescription` set (app records audio for delivery coaching)
- `NSAllowsLocalNetworking` enabled (talks to `http://localhost:3000/api` in dev)

## ⚠️ Blocker: full Xcode required

`xcodebuild` here resolves to CommandLineTools only:
```
tool 'xcodebuild' requires Xcode, but active developer directory
'/Library/Developer/CommandLineTools' is a command line tools instance
```

### To build (on a Mac with Xcode.app installed)
```bash
# 1. Install Xcode from the App Store (or xcodes CLI), then point the toolchain at it:
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

# 2. Regenerate the project (if project.yml changed) and build:
cd code/ios
xcodegen generate
xcodebuild -project StoryForce.xcodeproj -scheme StoryForce \
  -destination 'platform=iOS Simulator,name=iPhone 16' build

# 3. Open in Xcode to run on simulator/device:
open StoryForce.xcodeproj
```

## Before shipping (known follow-ups, not blockers)
- Set `DEVELOPMENT_TEAM` in project.yml for device signing.
- Point `apiBaseURL` at the deployed backend (currently `localhost:3000`).
- Add an app icon / launch assets (uses default blank launch screen today).
</content_placeholder>
