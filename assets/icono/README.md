# App icon sources

Built from the brand kit file `05-prototipos/marca/icono-app.svg` (two embracing figures: violet
`#4B2E83` rounded square, radius 28/122, the embracing figure in white and the embraced one in coral
`#FF8F7E`), rendered with `rsvg-convert -w 1024 -h 1024 <file>.svg -o <file>.png`.

| File | Use |
|---|---|
| `ios.svg` | iOS: full-bleed square, no transparency (iOS applies its own mask) |
| `legado.svg` | Android before 8.0, PWA icons and favicon: the brand icon as is |
| `adaptativo-frente.svg` | Android 8+ adaptive foreground: the 122-unit icon mapped to the 72 dp visible area of the 108 dp layer (viewBox `-30.5 -30.5 183 183`) |
| `adaptativo-monocromo.svg` | Android 13+ themed icon: the same symbol in a single colour |
| `web-maskable.svg` | PWA maskable icon: the symbol inside the 80 % safe zone |
| `simbolo.svg` | Native launch screen (iOS, Android before 12): the symbol on cream, rendered at 384 px |
| `splash-android12.svg` | Android 12+ launch screen icon: the symbol inside the 192 dp circle of the 288 dp icon, rendered at 1152 px |

After changing a source, render the PNGs and run `dart run flutter_launcher_icons` (config in
`flutter_launcher_icons.yaml`) and `dart run flutter_native_splash:create`
(`flutter_native_splash.yaml`). The web icons are `rsvg-convert` of `legado.svg` (192, 512, 32 for
`favicon.png`), `web-maskable.svg` (maskable 192 and 512) and `ios.svg` (180, `apple-touch-icon.png`).
