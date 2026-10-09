#!/usr/bin/env bash
# Uploads te-tengo.apk and te-tengo.apk.sha256 (assets of the release candidate, built by
# build-apk.yml) to the public R2 bucket and checks that its public URL serves them. Used by
# release.yml (staging), produccion.yml and rollback.yml.
#
#   upload_apk.sh <artifact dir> <key prefix>
#
# <key prefix> is "staging/" for staging and "" for production (stable keys at the bucket root, linked
# from the landing).
# Smoke check: HEAD <DESCARGAS_BASE_URL>/<prefix>te-tengo.apk answers 200 with the file's size, and the
# public .sha256 equals the uploaded one, retried for up to 1 minute.
#
# Environment: CLOUDFLARE_API_TOKEN, CLOUDFLARE_ACCOUNT_ID (secrets), R2_BUCKET, DESCARGAS_BASE_URL,
# WRANGLER_VERSION, GITHUB_STEP_SUMMARY.
set -euo pipefail

dir=$1
prefix=$2
apk="${prefix}te-tengo.apk"

if [ -z "${CLOUDFLARE_API_TOKEN:-}" ] || [ -z "${CLOUDFLARE_ACCOUNT_ID:-}" ]; then
  echo "::error title=Cloudflare secrets missing::CLOUDFLARE_API_TOKEN and CLOUDFLARE_ACCOUNT_ID must be repository secrets (Cloudflare API token with Account → Cloudflare Pages: Edit and Workers R2 Storage: Edit; docs/RELEASES.md)."
  exit 1
fi
if [ -z "${DESCARGAS_BASE_URL:-}" ]; then
  echo "::error title=DESCARGAS_BASE_URL missing::Set the repository variable DESCARGAS_BASE_URL to the public URL of the R2 bucket (docs/RELEASES.md)."
  exit 1
fi
base=${DESCARGAS_BASE_URL%/}
test -s "$dir/te-tengo.apk" || { echo "::error::The APK artifact has no te-tengo.apk"; exit 1; }
test -s "$dir/te-tengo.apk.sha256" || { echo "::error::The APK artifact has no te-tengo.apk.sha256"; exit 1; }

put() {
  npx --yes "wrangler@$WRANGLER_VERSION" r2 object put "$R2_BUCKET/$1" --remote --file "$2" "${@:3}"
}
put "$apk" "$dir/te-tengo.apk" --content-type application/vnd.android.package-archive \
  --cache-control no-cache --content-disposition 'attachment; filename="te-tengo.apk"'
put "$apk.sha256" "$dir/te-tengo.apk.sha256" --content-type "text/plain; charset=utf-8" \
  --cache-control no-cache

size=$(wc -c < "$dir/te-tengo.apk" | tr -d ' ')
sha=$(cut -d' ' -f1 "$dir/te-tengo.apk.sha256")
status=""
length=""
served=""
for attempt in $(seq 1 6); do
  headers=$(curl -sSI "$base/$apk?check=$attempt" || true)
  status=$(printf '%s\n' "$headers" | sed -n '1s/^HTTP\/[0-9.]* \([0-9]*\).*/\1/p')
  length=$(printf '%s\n' "$headers" | tr -d '\r' | sed -n 's/^[Cc]ontent-[Ll]ength: *//p' | tail -n1)
  served=$(curl -fsS "$base/$apk.sha256?check=$attempt" 2> /dev/null | cut -d' ' -f1 || true)
  if [ "$status" = 200 ] && [ "$length" = "$size" ] && [ "$served" = "$sha" ]; then
    break
  fi
  echo "Attempt $attempt: HTTP ${status:-none}, Content-Length ${length:-none} (expected $size), SHA-256 ${served:-none}"
  sleep 10
done

{
  echo "### APK → R2 \`$R2_BUCKET/$apk\`"
  echo "- URL: $base/$apk"
  echo "- SHA-256: \`$sha\` ($size bytes)"
} >> "$GITHUB_STEP_SUMMARY"

if [ "$status" != 200 ] || [ "$length" != "$size" ] || [ "$served" != "$sha" ]; then
  echo "::error title=APK smoke check failed::$base/$apk answered HTTP ${status:-none} with Content-Length ${length:-none} (expected 200 and $size), and its .sha256 is ${served:-unreadable} (expected $sha)."
  echo "- Smoke check: **failed**" >> "$GITHUB_STEP_SUMMARY"
  exit 1
fi
echo "- Smoke check: HTTP 200, size and SHA-256 match" >> "$GITHUB_STEP_SUMMARY"
