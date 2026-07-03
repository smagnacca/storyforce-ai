# iOS App Deployment Guide — StoryForce.AI

**Target:** App Store release  
**Timeline:** 2-3 hours from start to submission  
**Platforms:** iOS 14.0+  
**Requirements:** Xcode 14+, Apple Developer account  

---

## Pre-Deployment Checklist

### Development Setup
- [ ] Xcode 14+ installed
- [ ] Apple Developer account active ($99/year)
- [ ] Mac with 10GB free space
- [ ] iPhone or iPad for testing (iOS 14+)

### App Configuration
- [ ] Bundle ID: `com.scottmagnacca.storyforce`
- [ ] App Name: "StoryForce"
- [ ] Version: 1.0.0
- [ ] Build: 1
- [ ] Minimum iOS: 14.0

### Assets Required
- [ ] App Icon (1024x1024 PNG)
- [ ] Launch Screen (1242x2208 PNG)
- [ ] Screenshot (Retina 6.5" - 1242x2688 PNG)
- [ ] Screenshot (iPad - 2048x2732 PNG)

---

## Step 1: Xcode Project Setup (15 min)

### Open Project
```bash
cd code/ios/StoryForce
open StoryForce.xcodeproj
```

### Configure Signing
1. Select "StoryForce" project in navigator
2. Select "StoryForce" target
3. Go to "Signing & Capabilities"
4. Select Team: Your Apple Developer Team
5. Bundle ID: `com.scottmagnacca.storyforce`
6. Automatic signing: Enabled

### Configure Build Settings
1. Build Settings tab
2. Search: "Swift Language Version"
3. Set to Swift 5.7+
4. Search: "Minimum Deployment Target"
5. Set to iOS 14.0

### Add App Icon
1. Assets.xcassets
2. AppIcon set
3. Drag 1024x1024 image to "App Store" slot

### Configure Launch Screen
1. Select "LaunchScreen.storyboard"
2. Add ImageView with launch image
3. Set constraints to fill screen

---

## Step 2: Verify API Endpoints (10 min)

**Update API configuration in `App.swift`:**

```swift
#if DEBUG
let API_BASE_URL = "http://localhost:3000"
#else
let API_BASE_URL = "https://api.storyforce.ai"  // Production
#endif
```

### Test Against Staging
1. Build and run on simulator or device
2. Attempt signup at login screen
3. Verify API connection success
4. Test story generation (may mock without live backend)

---

## Step 3: Prepare App Store Metadata (20 min)

### Create App in App Store Connect
1. Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Click "Apps" → "+" → "New App"
3. Fill in:
   - Platform: iOS
   - Name: StoryForce
   - Primary Language: English
   - Bundle ID: `com.scottmagnacca.storyforce`
   - SKU: `storyforce-2026`

### Add Screenshots & Description
1. Go to App Store Connect app
2. Select "StoryForce"
3. Go to "App Information"

**Screenshots needed:**
- iPhone 6.5": Login screen, Dashboard, Story view, Practice screen (4 total)
- iPad: Dashboard, Story detail (2 total)

**Description:**
```
Generate AI-powered sales stories in seconds.

StoryForce uses Narrative Intelligence and the Three-Act Framework to create
personalized, powerful sales stories that move prospects from "Winter" (pain)
to "Spring" (vision).

FEATURES:
- AI-Powered Story Generation: Create compelling Three-Act stories instantly
- Practice Coaching: Record your delivery and get real-time AI feedback
- Performance Analytics: Track your progress and conversion metrics
- Client Profiles: Capture pain points and vision for each prospect
- Delivery Guidance: Act-by-act tips for maximum impact

Perfect for sales reps, consultants, financial advisors, and entrepreneurs.

PRICING:
- Free: 5 stories/month + basic practice
- Professional: $12.99/month - Unlimited stories + AI coaching
- Team: $99/month - Team management + advanced analytics

Try 5 free stories today.
```

**Keywords:**
```
sales,storytelling,AI,sales training,sales coaching,presentation,pitch,sales enablement
```

### Privacy Policy & Terms
Create files:
- `PRIVACY_POLICY.md`
- `TERMS_OF_SERVICE.md`

Add URLs to App Store Connect

---

## Step 4: Build for Release (15 min)

### Archive Build
1. Xcode: Product → Archive
2. Wait for build to complete
3. Organizer window opens automatically

### Export for App Store
1. Select latest archive
2. Click "Distribute App"
3. Choose "App Store Connect"
4. Select "Upload"
5. Choose Team: Your Developer Team
6. Next → Next → Upload

### Wait for Processing
- Apple processes upload (5-15 minutes)
- Check email for confirmation

---

## Step 5: App Store Review Submission (10 min)

### Prepare Submission
1. Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Select StoryForce app
3. Go to "Prepare for Submission"
4. Fill in:
   - Version: 1.0.0
   - What's New: "Initial launch with AI-powered story generation and practice coaching"
   - Build: Select your uploaded build
   - Category: Productivity
   - Content Rights: Confirm you own rights

### Review Information
1. Age Rating Questionnaire: Complete
2. GDPR/Privacy: Confirm
3. Cryptography: Not used
4. Advertising: Not implemented
5. Export Compliance: Not required

### Submit for Review
1. Review summary
2. Click "Submit for Review"
3. Confirm submission

### Expected Timeline
- **In Review:** 24-48 hours
- **Review Approved:** Automatic release or manual action
- **Rejected:** Review feedback within 24 hours

---

## Step 6: Post-Launch Monitoring (Ongoing)

### Monitor App Store Metrics
- Daily active users (DAU)
- Session length
- Crash rate
- Rating and reviews

### Handle Feedback
- Respond to reviews professionally
- Track bug reports
- Plan updates for next version

### Update Strategy
- Bug fixes: As needed
- Features: Monthly updates
- Performance: Continuous optimization

---

## Troubleshooting

### Build Fails
```bash
# Clean build
xcode clean
# Clear derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/*
# Rebuild
xcode build
```

### Signing Issues
```bash
# Check certificates
security find-identity -v -p codesigning
# Refresh certificates in Xcode
Xcode → Preferences → Accounts → Download Manual Profiles
```

### Upload Failed
1. Check internet connection
2. Verify Apple ID has correct permissions
3. Try uploading again via Organizer

### App Rejected
1. Read rejection reason carefully
2. Address specific issues
3. Resubmit with explanation

---

## Version Update Procedure

### For Next Release (v1.1.0)
1. Update version in Xcode: General tab
2. Increment build number
3. Archive and upload new build
4. Submit new version to App Store
5. Same review process applies

---

## Performance Targets

### Startup Time
- **Target:** <3 seconds to interactive
- **Measure:** Profile in Xcode Instruments

### Memory Usage
- **Target:** <200MB base, <500MB peak
- **Measure:** Xcode Memory Debugger

### Frame Rate
- **Target:** 60 FPS scrolling
- **Measure:** Core Animation tool

### Battery Impact
- **Target:** <5% per hour normal use
- **Measure:** Energy Impact Gauge

---

## App Store Listing Optimization

### For Visibility
- Use all 30 characters of keyword field
- Include trending sales/AI keywords
- Monitor App Store search rankings
- Encourage user reviews (in-app prompt)

### Rating Strategy
- Show review prompt after first successful story
- Respond to all 5-star and 1-star reviews
- Fix issues quickly, encourage re-rating

---

## Marketing Launch Plan

### Pre-Launch (1 week)
- Prepare product hunt post
- Email to sales contacts
- LinkedIn announcement

### Launch Day
- App Store featured placement (request from Apple)
- Social media announcement
- Sales team notification

### Post-Launch (ongoing)
- Monitor daily rankings
- Iterate based on user feedback
- Plan feature releases quarterly

---

## Compliance Checklist

- [ ] Privacy Policy complies with GDPR/CCPA
- [ ] Terms of Service reviewed by legal
- [ ] No hardcoded secrets or API keys
- [ ] No tracking without user consent
- [ ] Data deletion on app uninstall
- [ ] Secure token storage (Keychain)
- [ ] HTTPS for all API calls
- [ ] No background activity draining battery

---

**Ready to deploy?** Submit archive to App Store → Expect review in 24-48 hours → Launch!
