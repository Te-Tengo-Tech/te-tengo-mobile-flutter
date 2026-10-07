@AGENTS.md

## Notes for Claude Code
- **Working mode:** this repository is meant to be built autonomously from [docs/WORK_PLAN.md](docs/WORK_PLAN.md). When asked to "work", "continue" or `/work`, follow the loop in that file **until every task is checked or only blocked tasks remain. Do not stop after one task.**
- **Cloud environment:** the `SessionStart` hook (`scripts/cloud/setup-environment.sh`) installs Flutter 3.44.8 and runs `flutter pub get`.
  - There is no emulator in the cloud, so verify with `flutter analyze` and `flutter test`, including widget tests.
  - Compare your widgets against the PNG screens by reading the images.
- **User rules:**
  - English for docs and commits; Conventional Commits with **no co-author line**.
  - Spanish UI copy taken from the references; never invent copy or business values.
