@AGENTS.md

## Notas para Claude Code
- En la nube, el hook `SessionStart` (`scripts/cloud/preparar-entorno.sh`) instala Flutter 3.44.8 y corre `flutter pub get`. Si `flutter` no existe, revisa primero ese script.
- En la nube no hay emulador: verifica con `flutter analyze` y `flutter test`, que incluye pruebas de widgets.
- Respeta las reglas del usuario: textos y commits en español, Conventional Commits **sin** línea de coautor, y no inventar datos: los textos y valores salen de `docs/referencias/`.
