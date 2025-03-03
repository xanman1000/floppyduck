# Sound Files for Floppy Duck

To fully implement the audio in Floppy Duck, you'll need to create or obtain the following sound files:

## Required Sound Effects

1. **quack.wav** - Duck quacking sound effect (used when the duck flaps)
2. **flap.wav** - Wing flapping sound effect
3. **score.wav** - Sound played when passing through pipes
4. **crash.wav** - Sound played when the duck crashes
5. **splash.wav** - Water splash sound (optional, for when the duck falls)

## Background Music

You may also want to include background music for the game:

1. **background_music.mp3** - Looping background music for the main game

## How to Obtain Sound Files

1. **Create Your Own**: Use audio recording and editing software to create custom sounds
2. **Free Resources**: Many websites offer free sound effects with proper licensing:
   - [Freesound.org](https://freesound.org/)
   - [OpenGameArt.org](https://opengameart.org/)
   - [Zapsplat](https://www.zapsplat.com/)

3. **Paid Resources**: Consider purchasing sound packs from sites like:
   - [Unity Asset Store](https://assetstore.unity.com/)
   - [GameDev Market](https://www.gamedevmarket.net/)
   - [Sound Snap](https://www.soundsnap.com/)

## Adding Sounds to Your Project

1. Download or create the sound files in WAV or MP3 format
2. Drag them into your Xcode project
3. Make sure to add them to your app target
4. The SoundManager class will automatically try to load these files by name

## Attribution

If you use free sound assets, make sure to follow any attribution requirements and include proper credits in your game.

## Sound File Format Recommendations

- **Sound Effects**: WAV files (uncompressed, better quality for short sounds)
- **Background Music**: MP3 or M4A (compressed, better for longer audio) 