# App icon sources

Rendered from the brand file `icono-app.svg` («La T que sostiene»: `#4A2A85` background, white stroke 13 with round caps, `#FFB59C` dot) with `rsvg-convert -w 1024 -h 1024 <file>.svg -o <file>.png`.

| File | Use |
|---|---|
| `ios.svg` | iOS: full-bleed square, no transparency (iOS applies its own mask) |
| `legado.svg` | Android before 8.0: the brand icon as is (rounded square, radius 28/120) |
| `adaptativo-frente.svg` | Android 8+ adaptive foreground: the 120-unit icon mapped to the 72 dp visible area of the 108 dp layer (viewBox `-30 -30 180 180`) |
| `adaptativo-monocromo.svg` | Android 13+ themed icon: the same symbol in a single colour |

After changing a source, render the PNGs and run `dart run flutter_launcher_icons` (config in `flutter_launcher_icons.yaml`).
