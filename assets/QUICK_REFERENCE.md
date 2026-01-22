# Assets Quick Reference

## Current Assets

### Logos
- `assets/logos/logo.png` - Main logo
- `assets/logos/logo_green.png` - Green variant logo

### Icons
- `assets/icons/app_icon.png` - App icon

## How to Use in Code

### Display Logo
```dart
Image.asset('assets/logos/logo.png')
```

### Display Icon
```dart
Image.asset('assets/icons/app_icon.png')
```

### With Size
```dart
Image.asset(
  'assets/logos/logo.png',
  width: 200,
  height: 50,
)
```

### In AppBar
```dart
AppBar(
  title: Image.asset(
    'assets/logos/logo.png',
    height: 40,
  ),
)
```

### In Splash Screen
```dart
Image.asset(
  'assets/logos/logo.png',
  width: 200,
  height: 200,
)
```

## Adding New Assets

1. **Add your file** to the appropriate folder:
   - `assets/logos/` - For logos
   - `assets/icons/` - For icons
   - `assets/images/` - For other images

2. **Run** `flutter pub get` (if you modified pubspec.yaml)

3. **Use in code** with `Image.asset('assets/path/to/file.png')`

## Recommended File Formats

- **PNG** - For logos and icons (supports transparency)
- **SVG** - For scalable graphics (use `flutter_svg` package)
- **WebP** - For optimized images (smaller file size)

## Notes

- All assets are already configured in `pubspec.yaml`
- Assets are bundled with the app
- Use optimized images to reduce app size
- Hot reload will pick up new assets automatically
