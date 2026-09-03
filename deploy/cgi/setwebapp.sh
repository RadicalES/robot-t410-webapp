#!/bin/sh
#
# setwebapp.sh
# Install a device web app uploaded at the terminal, or serve a version that is
# already on it.
#
#   POST ?action=install   the .tar.gz as the whole request body
#   POST ?action=activate  slug=<slug>&version=<version>
#   POST ?action=release   slug=<slug>   - let the server decide again
#
# The bundle is the body rather than a multipart form: a shell CGI parsing
# multipart is a way to lose a tarball halfway through, and the page has the
# file already.
#
# Nothing here decides what the app is. The bundle carries manifest.json and
# says so itself, which is also what stops somebody uploading one app under
# another's name - see device-webapp/docs/WEBAPP-MANIFEST.md.
#
# (C) 2017-2026, Radical Electronic Systems - www.radicalsystems.co.za

echo "Access-Control-Allow-Origin: *"
echo "Content-Type: application/json"
echo ""

if [ "$REQUEST_METHOD" != "POST" ]; then
    echo '{"status":"ERROR","message":"POST required"}'
    exit 0
fi

ACTION=$(echo "${QUERY_STRING:-}" | tr '&' '\n' | grep '^action=' | cut -d= -f2-)
[ -n "$ACTION" ] || ACTION=install

if [ "$ACTION" = "release" ]; then
    read -r BODY
    SLUG=$(echo "$BODY" | tr '&' '\n' | grep '^slug=' | cut -d= -f2-)
    sudo /usr/local/sbin/webapp-config release "$SLUG" 2>/dev/null \
        || echo '{"status":"FAILED","message":"could not hand it back"}'
    exit 0
fi

if [ "$ACTION" = "activate" ]; then
    read -r BODY
    SLUG=$(echo "$BODY" | tr '&' '\n' | grep '^slug=' | cut -d= -f2-)
    VERSION=$(echo "$BODY" | tr '&' '\n' | grep '^version=' | cut -d= -f2-)
    sudo /usr/local/sbin/webapp-config activate "$SLUG" "$VERSION" 2>/dev/null \
        || echo '{"status":"FAILED","message":"could not serve that version"}'
    exit 0
fi

# An upload. Refuse an empty one before writing anything, and cap it: a
# terminal has a card for a disk, and a request that fills it takes the whole
# device down rather than just this page.
LENGTH=${CONTENT_LENGTH:-0}
if [ "$LENGTH" -le 0 ]; then
    echo '{"status":"FAILED","message":"no bundle in the request"}'
    exit 0
fi
if [ "$LENGTH" -gt 67108864 ]; then
    echo '{"status":"FAILED","message":"that bundle is larger than 64 MB"}'
    exit 0
fi

TMP=$(mktemp /tmp/webapp-upload-XXXXXX.tar.gz) || {
    echo '{"status":"FAILED","message":"no room to receive the bundle"}'
    exit 0
}
trap 'rm -f "$TMP"' EXIT

# Exactly the bytes the browser sent, no more: dd stops at the declared length
# rather than waiting on a connection the client has not closed.
dd bs=4096 count=$(( (LENGTH + 4095) / 4096 )) 2>/dev/null | head -c "$LENGTH" > "$TMP"

if [ ! -s "$TMP" ]; then
    echo '{"status":"FAILED","message":"the bundle did not arrive"}'
    exit 0
fi

sudo /usr/local/sbin/webapp-config install "$TMP" 2>/dev/null \
    || echo '{"status":"FAILED","message":"could not install that bundle"}'
