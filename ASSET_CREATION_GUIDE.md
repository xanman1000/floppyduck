# Asset Creation Guide for Floppy Duck

This guide will help you create the necessary graphic assets for the Floppy Duck game.

## Required Assets

### Duck Sprites (Required)
You need to create at least two animation frames for the duck:

1. `duck-01.png`: Duck with wings up position
2. `duck-02.png`: Duck with wings down position

For optimal visual quality, create these at a resolution of at least 60x60 pixels. Use a yellow/orange color scheme for a classic rubber duck look, or get creative with your own design.

### Environment Assets (Required)
The following assets are needed for the game environment:

1. `PipeUp.png`: The bottom pipe (pointing upward)
2. `PipeDown.png`: The top pipe (pointing downward)
3. `land.png`: The ground texture
4. `sky.png`: The background sky texture

### UI Assets (Optional but Recommended)
For a better user experience, consider creating:

1. Button backgrounds for the menu system
2. Game logo or title graphics
3. Custom fonts or text styling

## Creating Duck Sprites

Here's a simple approach to creating the duck sprites:

1. **Basic Shape**: Start with an oval body shape in yellow
2. **Head**: Add a slightly larger oval for the head
3. **Bill**: Add an orange triangle or rounded rectangle for the bill
4. **Eyes**: Add small black circles for eyes
5. **Wings**: 
   - For `duck-01.png`: Draw the wings raised up from the body
   - For `duck-02.png`: Draw the wings in a lower position

## Quick Pixel Art Tips

If you're not experienced with creating game assets, here are some quick tips:

1. **Use a Pixel Art Editor**: Tools like Aseprite, Piskel (free online), or even GIMP with a grid enabled
2. **Keep It Simple**: Start with basic shapes and minimal details
3. **Use Limited Colors**: A limited palette often looks better for simple game graphics
4. **Consider Transparency**: Make the background transparent (use PNG format)
5. **Test In-Game**: Always test your assets in the actual game to see how they look

## Converting FlappyBird Assets

If you prefer, you can modify the original FlappyBird assets:

1. Change the colors from red/brown bird to yellow/orange duck
2. Modify the shape to be more duck-like (add a bill instead of a beak)
3. Consider adding small water splash effects when the duck falls

## File Organization

Place all your assets in the correct locations:

- Duck sprites: `FloppyDuck/duck.atlas/`
- Environment and UI: `FloppyDuck/Images.xcassets/`

## Resources

If you need help or inspiration, here are some resources:

1. Free pixel art editors:
   - [Piskel](https://www.piskelapp.com/)
   - [Lospec](https://lospec.com/pixel-editor/)

2. Tutorials on pixel art:
   - [Pixel Art Academy](https://pixelart.academy/)
   - [Pixel Joint](http://pixeljoint.com/) 