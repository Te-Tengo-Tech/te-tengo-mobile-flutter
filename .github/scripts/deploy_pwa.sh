#!/usr/bin/env bash
# Deploys a PWA build (the te-tengo-pwa artifact of build-web.yml) to the Cloudflare Pages project
# $PAGES_PROJECT and checks that the public URL serves it. Used by release.yml.
#
#   deploy_pwa.sh <build dir> <pages branch> <public url>
#
# <pages branch> main is the project's production branch (https://app.tetengo.reqsai.tech); any other
# name is a preview alias, https://<branch>.<project>.pages.dev (staging).
# Smoke check: GET <public url>/ answers 200 and <public url>/version.json has the version and build
# number of this build (Flutter writes version.json from pubspec.yaml), retried for up to 2 minutes.
#
# Environment: CLOUDFLARE_API_TOKEN, CLOUDFLARE_ACCOUNT_ID (secrets), PAGES_PROJECT, WRANGLER_VERSION,
# GITHUB_SHA, GITHUB_STEP_SUMMARY.
set -euo pipefail

dir=$1
branch=$2
url=${3%/}

if [ -z "${CLOUDFLARE_API_TOKEN:-}" ] || [ -z "${CLOUDFLARE_ACCOUNT_ID:-}" ]; then
  echo "::error title=Cloudflare secrets missing::CLOUDFLARE_API_TOKEN and CLOUDFLARE_ACCOUNT_ID must be repository secrets (Cloudflare API token with Account → Cloudflare Pages: Edit and Workers R2 Storage: Edit; docs/RELEASES.md)."
  exit 1
fi
for f in index.html version.json manifest.json firebase-messaging-sw.js _headers robots.txt; do
  test -s "$dir/$f" || { echo "::error::The PWA artifact has no $f"; exit 1; }
done

wrangler() { npx --yes "wrangler@$WRANGLER_VERSION" "$@"; }

if ! wrangler pages project list 2> /dev/null | grep -q " $PAGES_PROJECT "; then
  wrangler pages project create "$PAGES_PROJECT" --production-branch main
fi

log=$(mktemp)
wrangler pages deploy "$dir" --project-name="$PAGES_PROJECT" --branch="$branch" \
  --commit-hash="$GITHUB_SHA" --commit-message="te-tengo-mobile-flutter ${GITHUB_SHA:0:12}" \
  --commit-dirty=true | tee "$log"
deployment=$(grep -oE 'https://[a-z0-9.-]+\.pages\.dev' "$log" | head -n1 || true)

expected=$(jq -c '{version, build_number}' "$dir/version.json")
status=""
served=""
for attempt in $(seq 1 12); do
  status=$(curl -sS -o /dev/null -w '%{http_code}' "$url/" || true)
  served=$(curl -fsS "$url/version.json?check=$attempt" 2> /dev/null | jq -c '{version, build_number}' 2> /dev/null || true)
  if [ "$status" = 200 ] && [ "$served" = "$expected" ]; then
    break
  fi
  echo "Attempt $attempt: $url/ answered ${status:-nothing}, version.json ${served:-unreadable}; expected $expected"
  sleep 10
done

{
  echo "### PWA → $PAGES_PROJECT ($branch)"
  echo "- URL: $url"
  echo "- Deployment: ${deployment:-n/a}"
  echo "- Build: \`$expected\`"
} >> "$GITHUB_STEP_SUMMARY"

if [ "$status" != 200 ] || [ "$served" != "$expected" ]; then
  echo "::error title=PWA smoke check failed::$url/ answered ${status:-nothing} and its version.json is ${served:-unreadable}; expected HTTP 200 and $expected."
  echo "- Smoke check: **failed** (HTTP ${status:-none}, version.json ${served:-unreadable})" >> "$GITHUB_STEP_SUMMARY"
  exit 1
fi
echo "- Smoke check: HTTP 200 and version.json matches" >> "$GITHUB_STEP_SUMMARY"
