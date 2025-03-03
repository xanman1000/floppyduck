# Game Center Setup Guide for Floppy Duck

This guide helps you set up Game Center features for your Floppy Duck game.

## Prerequisites

1. An Apple Developer Program membership ($99/year)
2. Access to Apple Developer website (developer.apple.com)
3. Xcode installed on your Mac

## Step 1: Configure Your App ID

1. Log in to your Apple Developer account
2. Go to Certificates, Identifiers & Profiles
3. Select "Identifiers" from the sidebar
4. Click the "+" button to register a new App ID
5. Select "App IDs" and click "Continue"
6. Select "App" as the type and click "Continue"
7. Enter the following information:
   - Description: "Floppy Duck"
   - Bundle ID: Use your bundle identifier (e.g., com.yourname.FloppyDuck)
8. Scroll down to the "Capabilities" section
9. Enable "Game Center"
10. Click "Continue" and then "Register"

## Step 2: Set Up Game Center in App Store Connect

1. Log in to App Store Connect (appstoreconnect.apple.com)
2. Go to "My Apps"
3. Click the "+" button and select "New App"
4. Fill out the required information:
   - Platform: iOS
   - Name: "Floppy Duck"
   - Primary language: Your choice
   - Bundle ID: Select the App ID you created earlier
   - SKU: A unique identifier (e.g., "FloppyDuck001")
5. Click "Create"

## Step 3: Configure Leaderboards

1. In App Store Connect, select your Floppy Duck app
2. Go to "Features" > "Game Center"
3. Click the "+" button next to "Leaderboards"
4. Select "Single Leaderboard"
5. Fill out the information:
   - Reference Name: "Floppy Duck High Scores"
   - ID: "floppyduck.highscores" (This ID will be used in your code)
   - Score Format: Integer
   - Score Submission: Higher is Better
   - Sort Order: Descending (Highest to Lowest)
6. Add localization information as needed
7. Click "Save"

## Step 4: Configure Achievements (Optional)

1. In the Game Center section, click the "+" button next to "Achievements"
2. Fill out the achievement information:
   - Reference Name: e.g., "First Flight"
   - ID: e.g., "floppyduck.firstflight"
   - Points: 10 (or your choice)
   - Hidden: Your choice
3. Add a title, description, and image for your achievement
4. Click "Save"
5. Repeat for additional achievements:
   - "Distance Flyer" - For flying 1000 meters total
   - "Flap Master" - For flapping 1000 times total
   - "High Scorer" - For achieving a score of 50

## Step 5: Update Your Code

Update your game code to use the correct leaderboard IDs. In GameViewController.swift:

```swift
// Update this line with your actual leaderboard ID
self.gcDefaultLeaderBoard = "floppyduck.highscores"
```

## Step 6: Testing Game Center

### Sandbox Testing

1. On your iOS device, sign out of Game Center in Settings
2. In Xcode, run the app on your device
3. You'll be prompted to sign in with a sandbox Game Center account
4. Use your Apple ID test account to sign in

### Real Device Testing

For the best testing experience:

1. Make sure your device is running the latest iOS
2. Sign in with a real Game Center account
3. Test all features: leaderboards, achievements, and multiplayer

## Step 7: Set Up Multiplayer (Advanced)

For multiplayer functionality:

1. Go to your app in App Store Connect
2. Under Game Center, click on "Multiplayer" and configure:
   - Session type: Turn-Based or Real-Time
   - Number of players
   - Other advanced settings

## Troubleshooting

### Authentication Issues
- Make sure your device has an active internet connection
- Check that the user is signed in to Game Center
- Verify that your app has Game Center capability enabled

### Leaderboard/Achievement Not Showing
- Double-check the leaderboard/achievement IDs in your code
- Ensure your app is properly registered with Game Center
- Wait a few minutes for changes to propagate in the system

### Sandbox Environment
- Remember that test accounts only work in the sandbox environment
- Data in the sandbox environment is separate from production 