#!/usr/bin/env bash
# Release candidates of the mobile app (docs/RELEASES.md). A candidate is a GitHub pre-release
# vX.Y.Z-rc.N whose assets are the files built once by release.yml; produccion.yml and rollback.yml
# publish those same files and never rebuild. Each candidate's notes end with one hidden line,
#
#   <!-- te-tengo-candidata {"version":"0.3.0","rc":2,"build":8,"commit":"…","tree":"…",
#        "staging":"passed","canales":["pwa","apk"],…} -->
#
# (on one line), which this script writes and reads. Do not edit it by hand.
#
#   candidata.sh numerar <version> <pubspec build>   → rc, build and tag of the next candidate
#   candidata.sh crear <dir>                         → pre-release $TAG with every file of <dir>
#   candidata.sh staging <tag> <passed|skipped>      → records the staging result in the notes
#   candidata.sh buscar <version> <tree>             → the newest candidate of <version> built from <tree>
#   candidata.sh descargar <tag> <dir> <asset>...    → downloads assets and checks them against SHA256SUMS
#   candidata.sh final <candidate tag> <dir> <changelog>
#                                                    → GitHub Release v<version> on $GITHUB_SHA with <dir>
#
# Outputs go to $GITHUB_OUTPUT (key=value). Environment: GH_TOKEN, GITHUB_REPOSITORY, GITHUB_OUTPUT,
# GITHUB_STEP_SUMMARY, RUNNER_TEMP; `crear` and `final` also read GITHUB_SHA.
set -euo pipefail

repo=${GITHUB_REPOSITORY:?GITHUB_REPOSITORY is not set}
marca=te-tengo-candidata
out=${GITHUB_OUTPUT:-/dev/stdout}
summary=${GITHUB_STEP_SUMMARY:-/dev/null}
tmp=${RUNNER_TEMP:-$(mktemp -d)}

error() {
  echo "::error title=$1::$2"
  exit 1
}

# Every published release (drafts left out) as a JSON array of {tag, prerelease, candidata}, where
# candidata is the parsed hidden line, or null.
releases() {
  gh api "repos/$repo/releases?per_page=100" --paginate \
    --jq '.[] | select(.draft | not) | {tag: .tag_name, prerelease, body: (.body // "")} | @json' |
    jq -sc --arg m "$marca" '
      map({
        tag,
        prerelease,
        candidata: ([.body | match("<!-- " + $m + " (\\{.*\\}) -->").captures[0].string] | first
          | if . then fromjson else null end)
      })'
}

tag_existe() {
  gh api "repos/$repo/git/ref/tags/$1" > /dev/null 2>&1
}

# The hidden line of one release's notes, as JSON.
leer_marca() {
  gh release view "$1" --repo "$repo" --json body --jq .body |
    sed -n "s/^<!-- $marca \(.*\) -->\$/\1/p" | head -n1
}

# The checksums of every file of $1 except SHA256SUMS, written to $1/SHA256SUMS.
sumas() {
  (
    cd "$1"
    rm -f SHA256SUMS
    sha256sum -- * > "$tmp/SHA256SUMS"
    mv "$tmp/SHA256SUMS" SHA256SUMS
  )
}

# Markdown table of $1/SHA256SUMS.
tabla_sumas() {
  echo "| Asset | Size | SHA-256 |"
  echo "|---|---|---|"
  while read -r sha file; do
    echo "| \`$file\` | $(wc -c < "$1/$file" | tr -d ' ') bytes | \`$sha\` |"
  done < "$1/SHA256SUMS"
}

numerar() {
  local version=$1 minimo=$2 todas rcs rc build_max build
  [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || error "Unexpected version" "'$version' is not x.y.z."
  [[ "$minimo" =~ ^[0-9]+$ ]] || error "Unexpected build number" "'$minimo' is not a number."
  todas=$(releases)
  if tag_existe "v$version"; then
    error "v$version is already released" "The tag v$version exists, so $version was published and cannot change (SemVer rule 3). A fix is a new version: bump pubspec.yaml (e.g. a hotfix/x.y.z+1 from main)."
  fi
  # N: one more than the highest rc of this version, among the releases and the tags.
  rcs=$(
    {
      jq -r '.[].tag' <<< "$todas"
      gh api "repos/$repo/git/matching-refs/tags/v$version-rc." --jq '.[].ref'
    } | sed -nE "s#^(refs/tags/)?v${version//./\\.}-rc\.([0-9]+)\$#\2#p"
  )
  rc=$(( $(printf '%s\n' "$rcs" | sort -n | tail -n1 | grep . || echo 0) + 1 ))
  # B: one more than the highest build number of any candidate of any version, and never below the
  # +B of pubspec.yaml (a floor the team can raise, e.g. above a build uploaded by hand).
  build_max=$(jq '[.[].candidata.build // 0 | tonumber] | max // 0' <<< "$todas")
  build=$(( build_max + 1 ))
  [ "$build" -ge "$minimo" ] || build=$minimo
  {
    echo "rc=$rc"
    echo "build=$build"
    echo "tag=v$version-rc.$rc"
  } >> "$out"
  echo "Next candidate: v$version-rc.$rc, build number $build (highest used: $build_max; pubspec.yaml floor: $minimo)"
}

crear() {
  local dir=$1 todas tree marker notes
  : "${VERSION:?}" "${RC:?}" "${BUILD:?}" "${TAG:?}" "${GITHUB_SHA:?}"
  tree=$(git rev-parse "$GITHUB_SHA^{tree}")
  # Another release branch may have taken this rc or build number while this run was building.
  todas=$(releases)
  if tag_existe "$TAG" || jq -e --arg t "$TAG" 'any(.[]; .tag == $t)' <<< "$todas" > /dev/null; then
    error "$TAG exists" "Another run created $TAG while this one was building. Re-run all jobs to number a new candidate."
  fi
  if jq -e --argjson b "$BUILD" 'any(.[]; (.candidata.build // 0 | tonumber) == $b)' <<< "$todas" > /dev/null; then
    error "Build number $BUILD is taken" "Another candidate used build number $BUILD while this run was building. Re-run all jobs to number a new candidate."
  fi
  sumas "$dir"
  marker=$(jq -nc \
    --arg version "$VERSION" --argjson rc "$RC" --argjson build "$BUILD" \
    --arg commit "$GITHUB_SHA" --arg tree "$tree" --arg rama "${GITHUB_REF_NAME:-}" \
    --arg staging "${STAGING:-pending}" --arg canales "${CANALES:-}" \
    --arg package "${PACKAGE:-}" --arg bundle_id "${BUNDLE_ID:-}" --arg certificado "${APK_CERTIFICATE:-}" \
    '{version: $version, rc: $rc, build: $build, commit: $commit, tree: $tree, rama: $rama,
      staging: $staging, canales: ($canales | split(",") | map(select(. != ""))),
      package: $package, bundle_id: $bundle_id, certificado_apk: $certificado}')
  notes="$tmp/candidata-notes.md"
  {
    echo "Release candidate **$VERSION-rc.$RC** of the Te Tengo mobile app. Inside, every file is version \`$VERSION\` with build number \`$BUILD\` (Android versionCode, iOS CFBundleVersion, PWA \`version.json\`); \`rc\` is only this label. Not a release: \`v$VERSION\` is created after produccion publishes these same files."
    echo
    echo "- **Branch:** \`${GITHUB_REF_NAME:-}\`"
    echo "- **Commit:** \`$GITHUB_SHA\`"
    echo "- **Git tree:** \`$tree\` (produccion only publishes this candidate from a \`main\` commit with this tree)"
    echo "- **Build number:** \`$BUILD\`"
    echo "- **Channels checked when built:** ${CANALES:-none}"
    [ -z "${APK_CERTIFICATE:-}" ] || echo "- **APK signing certificate SHA-256:** \`$APK_CERTIFICATE\`"
    [ -z "${RUN_URL:-}" ] || echo "- **Built by:** $RUN_URL"
    echo "- **Staging:** ${STAGING:-pending}"
    echo
    tabla_sumas "$dir"
    echo
    echo "<!-- $marca $marker -->"
  } > "$notes"
  gh release create "$TAG" --repo "$repo" --prerelease --target "$GITHUB_SHA" \
    --title "$TAG" --notes-file "$notes" "$dir"/*
  {
    echo "### Candidate $TAG (build $BUILD)"
    echo "Pre-release: ${GITHUB_SERVER_URL:-https://github.com}/$repo/releases/tag/$TAG"
    echo
    tabla_sumas "$dir"
  } >> "$summary"
}

staging() {
  local tag=$1 estado=$2 marker nuevo notes
  marker=$(leer_marca "$tag")
  [ -n "$marker" ] || error "Not a candidate" "$tag has no $marca line in its notes."
  nuevo=$(jq -c --arg s "$estado" '.staging = $s' <<< "$marker")
  notes="$tmp/candidata-staging.md"
  gh release view "$tag" --repo "$repo" --json body --jq .body |
    awk -v m="<!-- $marca $nuevo -->" -v s="- **Staging:** $estado" '
      index($0, "<!-- '"$marca"' ") == 1 { print m; next }
      index($0, "- **Staging:** ") == 1 { print s; next }
      { print }
    ' > "$notes"
  gh release edit "$tag" --repo "$repo" --notes-file "$notes" > /dev/null
  echo "Recorded staging: $estado on $tag"
}

buscar() {
  local version=$1 tree=$2 todas match
  todas=$(releases)
  match=$(jq -c --arg v "$version" --arg t "$tree" '
    [.[] | select(.prerelease and .candidata != null and .candidata.version == $v and .candidata.tree == $t)]
    | max_by(.candidata.rc) // empty' <<< "$todas")
  if [ -z "$match" ]; then
    {
      echo "### No candidate of $version matches this commit"
      echo "\`main\` has tree \`$tree\`. Candidates of $version:"
      jq -r --arg v "$version" '.[] | select(.candidata.version == $v)
        | "- `\(.tag)`: tree `\(.candidata.tree)`, commit `\(.candidata.commit[0:12])`, staging \(.candidata.staging)"' <<< "$todas"
    } >> "$summary"
    error "main differs from the tested candidate" "No pre-release v$version-rc.N was built from this tree ($tree): main differs from the tested candidate. Push the change to the release (or hotfix) branch to build a new rc, test it on staging and merge again. The run summary lists the candidates of $version."
  fi
  local tag staging
  tag=$(jq -r .tag <<< "$match")
  staging=$(jq -r .candidata.staging <<< "$match")
  if [ "$staging" != passed ] && [ "$staging" != skipped ]; then
    error "$tag has not passed staging" "$tag matches this commit, but its staging is '$staging'. Approve and pass its staging (or push a new rc) before merging into main."
  fi
  jq -r '.candidata as $c | [
      "tag=\(.tag)",
      "rc=\($c.rc)",
      "build=\($c.build)",
      "commit=\($c.commit)",
      "staging=\($c.staging)",
      "canales=\($c.canales | join(","))",
      "package=\($c.package // "")",
      "bundle_id=\($c.bundle_id // "")"
    ] | .[]' <<< "$match" >> "$out"
  echo "Candidate $tag (build $(jq -r .candidata.build <<< "$match"), staging $staging) matches tree $tree"
}

descargar() {
  local tag=$1 dir=$2 asset linea
  shift 2
  [ $# -gt 0 ] || error "No assets" "descargar needs at least one asset name."
  mkdir -p "$dir"
  local patterns=(--pattern SHA256SUMS)
  for asset in "$@"; do patterns+=(--pattern "$asset"); done
  gh release download "$tag" --repo "$repo" --dir "$dir" --clobber "${patterns[@]}"
  for asset in "$@"; do
    linea=$(awk -v f="$asset" '$2 == f' "$dir/SHA256SUMS")
    [ -n "$linea" ] || error "$asset not in SHA256SUMS" "$tag has no checksum for $asset."
    [ -s "$dir/$asset" ] || error "$asset missing" "$tag has no asset $asset."
    (cd "$dir" && printf '%s\n' "$linea" | sha256sum --check --strict --quiet -) ||
      error "$asset changed" "The SHA-256 of $asset differs from the one recorded in $tag."
    echo "$asset: SHA-256 $(cut -d' ' -f1 <<< "$linea") verified"
  done
}

final() {
  local candidata=$1 dir=$2 changelog=$3 marker version build tag section notes
  : "${GITHUB_SHA:?}"
  marker=$(leer_marca "$candidata")
  [ -n "$marker" ] || error "Not a candidate" "$candidata has no $marca line in its notes."
  version=$(jq -r .version <<< "$marker")
  build=$(jq -r .build <<< "$marker")
  tag="v$version"
  # A re-run after an interrupted attempt: complete what exists instead of failing.
  if gh release view "$tag" --repo "$repo" > /dev/null 2>&1; then
    gh release upload "$tag" --repo "$repo" --clobber "$dir"/*
    echo "::notice title=$tag exists::$tag already existed (a re-run); its assets were uploaded again."
    echo "### $tag already existed; assets uploaded again" >> "$summary"
    return
  fi
  local verify=()
  if tag_existe "$tag"; then verify=(--verify-tag); fi
  # The section `## [X.Y.Z] …` of CHANGELOG.md, up to the next `## [`.
  section=$(awk -v head="## [$version]" '
    index($0, head) == 1 { found = 1; next }
    found && /^## \[/ { exit }
    found { print }
  ' "$changelog")
  if [ -z "$(printf '%s' "$section" | tr -d '[:space:]')" ]; then
    echo "::warning title=No CHANGELOG section::CHANGELOG.md has no section '## [$version]'; the release notes only give the version."
    section="No CHANGELOG section for $version."
  fi
  notes="$tmp/final-notes.md"
  {
    echo "Te Tengo mobile app **$version**, build number \`$build\` (Android versionCode, iOS CFBundleVersion). These are the files of the candidate [\`$candidata\`](${GITHUB_SERVER_URL:-https://github.com}/$repo/releases/tag/$candidata), tested on staging and published to produccion without rebuilding."
    echo
    printf '%s\n' "$section"
    echo
    echo "### Assets"
    tabla_sumas "$dir"
    echo
    echo "<!-- $marca $(jq -c --arg c "$candidata" --arg m "$GITHUB_SHA" '. + {candidata: $c, main: $m}' <<< "$marker") -->"
  } > "$notes"
  gh release create "$tag" --repo "$repo" --target "$GITHUB_SHA" --title "$tag" \
    ${verify[@]+"${verify[@]}"} --notes-file "$notes" "$dir"/*
  echo "### Released $tag (build $build) from $candidata" >> "$summary"
}

command=${1:-}
shift || true
case "$command" in
  numerar) numerar "$@" ;;
  crear) crear "$@" ;;
  staging) staging "$@" ;;
  buscar) buscar "$@" ;;
  descargar) descargar "$@" ;;
  final) final "$@" ;;
  *)
    echo "usage: candidata.sh numerar|crear|staging|buscar|descargar|final …" >&2
    exit 2
    ;;
esac
