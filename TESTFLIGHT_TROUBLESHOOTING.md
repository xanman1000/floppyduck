# TestFlight Troubleshooting Guide

This document provides solutions for common issues encountered during the TestFlight distribution process for Floppy Duck.

## Build and Upload Issues

### Error: "No accounts with iTunes Connect access"

**Problem**: When uploading with Xcode or altool, you receive an error indicating your account doesn't have App Store Connect access.

**Solution**:
1. Ensure your Apple Developer account has the correct role (Admin, App Manager, etc.)
2. Verify your Apple ID is correctly entered in the upload command
3. Check that your account has accepted the latest Apple Developer agreement
4. Restart the upload process after a few minutes

### Error: "Application failed codesign verification"

**Problem**: Your build fails code signing validation during the upload process.

**Solution**:
1. Verify your distribution certificate is valid and not expired
2. Check that your provisioning profile matches your app's bundle identifier
3. Ensure all app extensions are properly signed with the same team
4. Try cleaning your project (`xcodebuild clean`) and rebuilding
5. Check that your entitlements match those in App Store Connect

### Error: "Missing Info.plist key"

**Problem**: Your build is rejected due to missing required Info.plist keys.

**Solution**:
1. Check the specific key mentioned in the error (common ones include NSCameraUsageDescription)
2. Add the required key and a meaningful description to your Info.plist
3. Rebuild and upload again

### Error: "App Store Connect Operation Error"

**Problem**: Generic error when uploading to App Store Connect.

**Solution**:
1. Check Apple's System Status page for any TestFlight outages
2. Verify your app-specific password is correct and not expired
3. Try uploading at a different time (server load can cause issues)
4. Use the most recent version of Xcode or altool

## TestFlight Internal Testing Issues

### Issue: Build Doesn't Appear in TestFlight

**Problem**: You've uploaded a build but it doesn't appear in TestFlight.

**Solution**:
1. Wait at least 30 minutes for Apple to process the build
2. Check your email for any rejection notifications
3. Verify the build was uploaded with the correct Apple ID
4. In App Store Connect, check if the build is in the "Processing" state
5. Ensure your app's TestFlight settings are properly configured

### Issue: iOS Compatibility Warnings

**Problem**: TestFlight shows warnings about iOS compatibility issues.

**Solution**:
1. Verify the minimum iOS version specified in your project matches App Store Connect
2. Check your app for APIs used that are not available in your minimum iOS version
3. Consider updating the minimum iOS version if necessary

### Issue: Expired Build

**Problem**: TestFlight build shows as expired.

**Solution**:
1. TestFlight builds automatically expire after 90 days
2. Upload a new build with the same or higher version number
3. Consider implementing a build version incrementing script for frequent test builds

## Tester Invitation Issues

### Issue: Testers Not Receiving Invitations

**Problem**: You've added testers, but they haven't received invitation emails.

**Solution**:
1. Check that the tester's email address is correct
2. Ask testers to check their spam/junk email folders
3. Try resending the invitation from App Store Connect
4. As an alternative, provide testers with a public link or redemption code

### Issue: Testers Cannot Install the App

**Problem**: Testers report they cannot install the test build.

**Solution**:
1. Verify testers have accepted the invitation and installed the TestFlight app
2. Check if the build is still in "Processing" state
3. Ensure testers are using a compatible iOS device and version
4. Have testers check their device storage space

## App Functionality Issues in TestFlight

### Issue: In-App Purchases Not Working

**Problem**: In-app purchases don't work in the TestFlight build.

**Solution**:
1. Remind testers that TestFlight uses Sandbox environment for in-app purchases
2. Testers need to use a sandbox Apple ID (not their personal one) for testing purchases
3. Verify in-app purchase products are properly configured in App Store Connect

### Issue: Push Notifications Not Working

**Problem**: Push notifications don't appear in TestFlight builds.

**Solution**:
1. Verify push notification certificates are correctly set up
2. Ensure the app is requesting notification permissions properly
3. Check that the correct push environment (development vs. production) is being used
4. Verify the device token is being correctly registered with your server

### Issue: Game Center Features Not Working

**Problem**: Game Center leaderboards or achievements aren't functioning.

**Solution**:
1. Ensure Game Center is properly set up in App Store Connect
2. Verify the test device has Game Center enabled and is signed in
3. Check that leaderboard and achievement IDs in code match those in App Store Connect
4. Use the Game Center sandbox environment for testing

## Crash Reporting

### Issue: No Crash Reports Available

**Problem**: Your app crashes during testing but no reports appear in App Store Connect.

**Solution**:
1. Ensure symbolication is enabled for your build
2. Verify that crash reports are being properly uploaded (requires network connection)
3. Wait 24 hours as crash reports can be delayed
4. Ask testers to open the app after a crash to trigger report submission

### Issue: Cannot Understand Crash Reports

**Problem**: Crash reports are available but difficult to interpret.

**Solution**:
1. Make sure symbols are properly uploaded with your build
2. Download the crash report and symbolicate it locally
3. Use Xcode's Organizer to view symbolicated crash reports
4. Look for patterns in user actions that trigger crashes

## Next Steps After Resolving Issues

1. Upload a new build with fixes
2. Increment your build number (but keep version number the same for minor fixes)
3. Notify testers of the new build and what issues were fixed
4. Track resolved vs. unresolved issues to ensure quality before App Store submission 