# App Store Connect Setup Checklist

This document provides a step-by-step guide for setting up Floppy Duck in App Store Connect for TestFlight distribution.

## 1. Create App Record in App Store Connect

- [ ] Log in to [App Store Connect](https://appstoreconnect.apple.com)
- [ ] Navigate to "Apps" section
- [ ] Click the "+" button to add a new app
- [ ] Enter required information:
  - [ ] Platforms: iOS
  - [ ] Name: Floppy Duck
  - [ ] Primary language: English (or your primary language)
  - [ ] Bundle ID: Select from registered IDs or enter com.floppyduck.game
  - [ ] SKU: FloppyDuck2023 (or your preferred SKU)
  - [ ] User Access: Full Access

## 2. Configure App Information

- [ ] Select the newly created app
- [ ] Navigate to "App Information" tab
- [ ] Fill in required fields:
  - [ ] Subtitle (optional): "The Modern Flappy Bird"
  - [ ] Privacy Policy URL: Your privacy policy URL
  - [ ] Category: Games > Arcade
  - [ ] Content Rights: Confirm you have rights
  - [ ] Age Rating: Complete questionnaire (likely 4+)

## 3. Set Up App Store Information

- [ ] Navigate to "App Store" tab
- [ ] Complete Promotional Text (optional)
- [ ] Enter Description (highlight key features)
- [ ] Add Keywords (comma-separated)
- [ ] Upload at least one screenshot for each required device
- [ ] Upload app preview videos (optional)
- [ ] Upload app icon if not included in build
- [ ] Fill in support URL and marketing URL

## 4. Configure App Features

- [ ] Navigate to "Features" tab
- [ ] Game Center:
  - [ ] Enable Game Center
  - [ ] Add leaderboards:
    - [ ] Single Player High Score
    - [ ] Tournament Champions
  - [ ] Add achievements (minimum 5 recommended)
  - [ ] Configure leaderboard images and descriptions

- [ ] App Services:
  - [ ] Enable required capabilities:
    - [ ] Push Notifications (if applicable)
    - [ ] iCloud (if applicable)
    - [ ] In-App Purchase (if applicable)

## 5. Configure TestFlight

- [ ] Navigate to "TestFlight" tab
- [ ] Enable internal testing:
  - [ ] Add internal testers by email (limited to users with App Store Connect access)
  - [ ] Enable automatic distribution to internal testers

- [ ] Enable external testing:
  - [ ] Add external testers by email
  - [ ] Create test groups (e.g., "Core Testers", "Friends & Family")
  - [ ] Configure build distribution for each group

- [ ] Beta App Review Information:
  - [ ] Fill in contact info for review
  - [ ] Enter demo account info (if required)
  - [ ] Add notes for Beta App Review
  - [ ] Select if app uses encryption

## 6. Prepare for Build Upload

- [ ] Navigate to "App Information"
- [ ] Verify Build Settings:
  - [ ] Ensure version and build numbers match your project
  - [ ] Confirm proper signing configuration in Xcode

- [ ] Check App Store Connect API access:
  - [ ] Verify your account has API access for automated uploads
  - [ ] Generate App-specific password for automated uploads

## 7. Post-Upload Steps

- [ ] After build is processed by TestFlight:
  - [ ] Add build to internal testing
  - [ ] Submit build for Beta App Review (required for external testing)
  - [ ] Add build to external testing groups (after Beta App Review approval)
  - [ ] Add build release notes

- [ ] Manage testers:
  - [ ] Track testing status and build installations
  - [ ] Review submitted feedback
  - [ ] Respond to crash reports

## 8. Prepare for Public Testing

- [ ] Create a public link:
  - [ ] Navigate to "Public Link" section
  - [ ] Configure the public link options
  - [ ] Copy the URL to share with a wider audience
  - [ ] Set tester limit (recommended: start with 100-500)

- [ ] Monitor testing metrics:
  - [ ] Number of testers
  - [ ] Session counts
  - [ ] Crash reports
  - [ ] Feedback submissions

## Additional Resources

- [TestFlight Documentation](https://developer.apple.com/testflight/)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Game Center Configuration Guide](https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/GameKit_Guide/Introduction/Introduction.html) 