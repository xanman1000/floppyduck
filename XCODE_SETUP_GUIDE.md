# Xcode Project Setup Guide for Floppy Duck

This guide walks you through setting up a new Xcode project for Floppy Duck.

## Step 1: Create a New Project

1. Open Xcode
2. Select "Create a new Xcode project"
3. Choose the "Game" template under iOS
4. Click "Next"

## Step 2: Configure Your Project

1. **Product Name**: Enter "FloppyDuck"
2. **Organization Name**: Enter your name or organization
3. **Organization Identifier**: Enter a reverse domain identifier (e.g., com.yourname)
4. **Language**: Swift
5. **Game Technology**: SpriteKit
6. **User Interface**: Storyboard
7. **Make sure "Include Game Center" is checked**
8. Click "Next"
9. Choose a location to save your project and click "Create"

## Step 3: Replace Default Files

1. Delete the default files that the template created:
   - Delete the default GameScene.swift
   - Delete the default GameViewController.swift
   - Delete the default AppDelegate.swift
   - Delete the default Main.storyboard

2. Import the files you've created:
   - Right-click on your project in the navigator
   - Select "Add Files to 'FloppyDuck'..."
   - Navigate to where you saved the FloppyDuck directory
   - Select all files and folders (GameScene.swift, GameViewController.swift, AppDelegate.swift, etc.)
   - Make sure "Copy items if needed" is checked
   - Click "Add"

## Step 4: Set Up Asset Catalog

1. Open Assets.xcassets
2. Add the required image sets:
   - PipeUp
   - PipeDown
   - land
   - sky
   
3. For each image set, drag and drop your PNG files into the appropriate slots

## Step 5: Set Up Duck Atlas

1. Right-click on your project in the navigator
2. Select "New Group" and name it "duck.atlas"
3. Add your duck images to this group:
   - Right-click on the duck.atlas folder
   - Select "Add Files to 'duck.atlas'..."
   - Select your duck-01.png and duck-02.png files
   - Click "Add"

## Step 6: Configure Game Center

1. Select your project in the navigator
2. Select your target
3. Go to the "Signing & Capabilities" tab
4. Click "+ Capability"
5. Add "Game Center"

## Step 7: Set Up Bundle Identifier

1. Select your project in the navigator
2. Select your target
3. Under "Identity", ensure your Bundle Identifier matches what you set up (e.g., com.yourname.FloppyDuck)

## Step 8: Add GameScene.sks

1. Generate the GameScene.sks file using the SceneGenerator.swift utility if needed
2. Right-click on your project in the navigator
3. Select "Add Files to 'FloppyDuck'..."
4. Select the GameScene.sks file
5. Click "Add"

## Step 9: Run the Project

1. Select a simulator or device
2. Click the "Run" button
3. Test the basic functionality of the game
4. Debug any issues that arise

## Troubleshooting

### Missing Assets
If you see placeholder graphics or get errors about missing assets:
- Make sure all image files are added to the correct locations
- Check that the names match exactly what's referenced in the code

### Game Center Issues
If Game Center features aren't working:
- Make sure you've enabled Game Center in your Apple Developer account
- Check that your Bundle ID matches your registered App ID
- Test on a real device rather than the simulator for full Game Center functionality

### Build Errors
If you encounter build errors:
- Check that all required files are included in the project
- Ensure the correct deployment target is set (iOS 10.0 or later)
- Make sure the Swift language version is compatible (Swift 5.0 or later recommended) 