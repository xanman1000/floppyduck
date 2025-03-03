# TestFlight Distribution Instructions

This document contains step-by-step instructions for distributing and testing Floppy Duck via TestFlight.

## For Developers: Build & Upload Process

### Prerequisites

1. **Apple Developer Account**: An active Apple Developer Program membership
2. **Distribution Certificate**: A valid Apple Distribution Certificate installed in your keychain
3. **App Store Provisioning Profile**: A valid provisioning profile for App Store distribution
4. **App Record in App Store Connect**: The app must already be created in App Store Connect

### Steps to Build and Upload

1. **Configure the Export Options**: 
   - Edit `ExportOptions.plist` and update:
     - The `teamID` with your Apple Developer Team ID
     - The bundle identifier in `provisioningProfiles` dictionary
     - The provisioning profile name

2. **Configure Upload Credentials**:
   - Edit `build_and_upload.sh` and update:
     - Your Apple ID (email)
     - Your app-specific password (generate from Apple ID account page)

3. **Run the Build Script**:
   ```bash
   chmod +x build_and_upload.sh
   ./build_and_upload.sh
   ```

4. **Wait for Processing**:
   - Apple needs to process your build before it becomes available in TestFlight
   - This typically takes 15-30 minutes
   - You'll receive an email notification when the build is ready

### Troubleshooting Build Issues

- **Certificate Problems**: Ensure your distribution certificate is valid and installed
- **Provisioning Profile Issues**: Verify the profile in ExportOptions.plist matches one in your Apple Developer account
- **Xcode Errors**: Check that all capabilities in the app match those in App Store Connect
- **Upload Errors**: Verify your Apple ID and app-specific password are correct

## For Testers: How to Install Floppy Duck on Your iOS Device

### Prerequisites

1. **iOS Device**: iPhone or iPad running iOS 14.0 or newer
2. **Apple ID**: Your personal Apple ID (no developer account needed)
3. **TestFlight App**: Download from the App Store if not already installed
4. **Invitation**: You need to be invited as a tester by the developer

### Installation Steps

1. **Accept Invitation**:
   - You'll receive an email invitation from TestFlight
   - Tap the "View in TestFlight" or "Start Testing" button in the email
   - This will open the TestFlight app (or prompt you to download it)

2. **Alternative: Use Redemption Code**:
   - If you received a redemption code instead of an email:
   - Open the TestFlight app
   - Tap "Redeem" in the top-right corner
   - Enter the code provided by the developer

3. **Install Floppy Duck**:
   - In the TestFlight app, find Floppy Duck in your list of available apps
   - Tap "Install" to download the app to your device
   - The app will appear on your home screen like any other app

4. **Launch and Test**:
   - Open Floppy Duck from your home screen
   - Play the game and explore all features
   - Note any issues or feedback you encounter

### Providing Feedback

TestFlight makes it easy to send feedback directly to the developers:

1. **Screenshot Feedback**:
   - Take a screenshot while using the app
   - TestFlight will prompt you to send feedback with that screenshot
   - Add your comments and tap Send

2. **Manual Feedback**:
   - Open TestFlight
   - Select Floppy Duck
   - Tap "Send Feedback"
   - Type your feedback and tap Submit

3. **Crash Reports**:
   - If the app crashes, TestFlight automatically collects crash logs
   - These are sent to developers when you reopen the app

### Important Notes

- **Beta Expiration**: TestFlight builds expire after 90 days
- **App Restrictions**: Some features like in-app purchases may be in sandbox mode
- **Updates**: You'll be notified when new test builds are available
- **Uninstalling**: You can remove your participation at any time via TestFlight app

## TestFlight Build Information

- **Version**: 1.0.0 (1001)
- **Required iOS**: 14.0 or later
- **Supported Devices**: iPhone and iPad
- **TestFlight Expiration**: 90 days from upload date
- **Key Features to Test**:
  - Game mechanics and physics
  - Multiplayer functionality
  - Tournament mode
  - Leaderboards
  - Customization options
  - All language localizations 