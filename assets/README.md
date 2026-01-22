# Assets Folder

This folder contains all static assets for the Silah app.

## Folder Structure

- `images/` - App images, illustrations, and graphics
- `icons/` - App icons and small graphics
- `logos/` - App logo files (PNG, SVG formats)

## Usage

### Adding Images

1. Place your image files in the appropriate folder
2. Use in code:
   ```dart
   Image.asset('assets/images/your_image.png')
   ```

### Adding Icons

1. Place icon files in `assets/icons/`
2. Use in code:
   ```dart
   Image.asset('assets/icons/your_icon.png')
   ```

### Adding Logo

1. Place logo files in `assets/logos/`
2. Recommended formats:
   - PNG (with transparency)
   - SVG (for scalable logo)
3. Use in code:
   ```dart
   Image.asset('assets/logos/silah_logo.png')
   ```

## Recommended Sizes

### App Icon
- Android: 512x512px (for Play Store)
- iOS: 1024x1024px (for App Store)
- Use `flutter_launcher_icons` package to generate all sizes

### Logo
- Full logo: 800x200px (for splash screen, headers)
- Icon logo: 256x256px (for app bar, small displays)

## Notes

- All assets are included in the app bundle
- Use optimized images to reduce app size
- Consider using WebP format for better compression
- SVG is recommended for logos (scalable, small file size)
