#!/bin/bash
#
# /var/www/cgi/getserialports.sh
#
# The serial ports the web UI may offer when something has to be told which
# port its hardware is on - the scale bridge, the card reader bridge.
#
# The list is filtered, and the filtering is the point. A terminal's /dev is
# full of ports that exist because the SoC has UARTs, not because anything is
# plugged into them: an ITPC-200 shows ttyS0 through ttyS3 and every one of
# them opens happily with nothing attached, so a service pointed at one waits
# forever for a reading and looks broken rather than misconfigured. Offering
# only the ports that could plausibly have hardware on them turns a support
# call into a choice between two.
#
# What may be offered is the device's business, because only the device knows
# how it was assembled. serialports.conf carries it:
#
#     SERIAL_PORTS_ALLOW="ttyACM* ttyS0"    # globs, space separated
#     SERIAL_PORTS_DENY="ttyACM0"           # never offered, whatever matched
#
# With no file, USB-attached ports only. A USB serial port exists because
# something was plugged in; a built-in UART exists either way, so a device
# with hardware wired to one says so explicitly. That default is deliberately
# the safe half of the answer: a port missing from the list is a config file
# to write, while a port wrongly in it is a service that looks broken.
#
# (C) 2017-2026, Radical Electronic Systems - www.radsys.io

# /etc/robot is where a terminal's configuration lives now; /etc/formfactor is
# the T420-era location the ITPC-200 still carries. Both are read so one file
# format works across the range, nearest convention first.
for FILTERFILE in /etc/robot/serialports.conf /etc/formfactor/serialports.conf; do
    [ -r "$FILTERFILE" ] && { . "$FILTERFILE"; break; }
done

# USB-attached only. See above: a bare UART is not evidence of hardware.
SERIAL_PORTS_ALLOW="${SERIAL_PORTS_ALLOW:-ttyACM* ttyUSB*}"
SERIAL_PORTS_DENY="${SERIAL_PORTS_DENY:-}"

# ?service=cardreader|scanner|scale narrows the list to what that service may
# use,
# because the two are not interchangeable: a T440's reader is soldered to
# ttyAMA4 and cannot be anywhere else, while its scale arrives on whichever
# USB port was free. A service with no list of its own falls back to the
# device-wide one.
SERVICE=$(printf '%s' "${QUERY_STRING:-}" | sed -n 's/.*\bservice=\([A-Za-z]*\).*/\1/p')
case "$SERVICE" in
    cardreader) [ -n "$SERIAL_PORTS_CARDREADER" ] && SERIAL_PORTS_ALLOW="$SERIAL_PORTS_CARDREADER" ;;
    scale)      [ -n "$SERIAL_PORTS_SCALE" ]      && SERIAL_PORTS_ALLOW="$SERIAL_PORTS_SCALE" ;;
    scanner)    [ -n "$SERIAL_PORTS_SCANNER" ]    && SERIAL_PORTS_ALLOW="$SERIAL_PORTS_SCANNER" ;;
    *)          SERVICE="" ;;
esac

# A list of one entry with no glob in it is a port that was decided when the
# terminal was built. The UI shows it instead of offering a choice, because a
# dropdown with one item reads as though there were others to find.
FIXED=false
case "$SERIAL_PORTS_ALLOW" in
    *[*?[]*|*" "*) ;;
    ?*)            FIXED=true ;;
esac

# --- what already claims a port -----------------------------------
# Reported so the UI can say "this one is the card reader" rather than
# letting two services be pointed at the same port, which fails at open
# with an error nobody sees.
CARDCFG=/etc/ttysocket/cardreader.conf
SCANCFG=/etc/ttysocket/scanner.conf
SCALECFG=/etc/ttysocket/scale.conf
CLAIM_CARD=""
CLAIM_SCAN=""
CLAIM_SCALE=""
claims_of() {
    [ -r "$1" ] || return 0
    sed -n "s/^[[:space:]]*$2=[\"']\?\([^\"'#[:space:]]*\).*/\1/p" "$1" | tr '\n' ' '
}
CLAIM_CARD=$(claims_of "$CARDCFG" 'TTYSOCKET_TTY2\?')
CLAIM_SCAN=$(claims_of "$SCANCFG" 'TTYSOCKET_TTY2\?')
CLAIM_SCALE=$(claims_of "$SCALECFG" 'TTYSCALE_TTY')

claimed_by() {
    local dev="/dev/$1" name="$1" c
    # A claim can be written as the by-id link rather than the node, since that
    # is what survives a replug - so the link is resolved before comparing,
    # otherwise a claimed port looks free.
    for c in $CLAIM_CARD; do
        c=$(readlink -f "$c" 2>/dev/null || echo "$c")
        [ "$c" = "$dev" ] || [ "$c" = "$name" ] && { echo "cardreader"; return; }
    done
    for c in $CLAIM_SCAN; do
        c=$(readlink -f "$c" 2>/dev/null || echo "$c")
        [ "$c" = "$dev" ] || [ "$c" = "$name" ] && { echo "scanner"; return; }
    done
    for c in $CLAIM_SCALE; do
        c=$(readlink -f "$c" 2>/dev/null || echo "$c")
        [ "$c" = "$dev" ] || [ "$c" = "$name" ] && { echo "scale"; return; }
    done
    echo ""
}

# --- allow and deny ------------------------------------------------
matches() {
    local name="$1" pattern
    shift
    for pattern in $@; do
        case "$name" in $pattern) return 0 ;; esac
    done
    return 1
}

# --- what the port is, in words ------------------------------------
# /dev/serial/by-id names the thing that was plugged in, which is the only way
# to tell ttyACM0 from ttyACM1 when a terminal has two of the same reader.
label_for() {
    local name="$1" link target
    for link in /dev/serial/by-id/*; do
        [ -e "$link" ] || continue
        target=$(readlink -f "$link" 2>/dev/null)
        if [ "$target" = "/dev/$name" ]; then
            # usb-RadicalES_ITPC200_E6634466CF623535-if00 -> RadicalES ITPC200 (if00)
            basename "$link" \
                | sed -e 's/^usb-//' \
                      -e 's/-if\([0-9]*\)$/ (if\1)/' \
                      -e 's/_[0-9A-F]\{8,\}//' \
                      -e 's/_/ /g'
            return
        fi
    done
    case "$name" in
        ttyACM*|ttyUSB*) echo "USB serial port" ;;
        ttyAMA*|ttyS*)   echo "Built-in serial port" ;;
        *)               echo "Serial port" ;;
    esac
}

bus_for() {
    case "$1" in
        ttyACM*|ttyUSB*) echo "usb" ;;
        *)               echo "builtin" ;;
    esac
}

# --- enumerate -----------------------------------------------------
ENTRIES=""
for dev in /dev/tty*; do
    [ -c "$dev" ] || continue
    name=$(basename "$dev")

    # tty, tty0..tty63, ttyprintk and friends are consoles, not ports.
    case "$name" in
        tty|tty[0-9]*|ttyprintk|ttynull) continue ;;
    esac

    matches "$name" "$SERIAL_PORTS_ALLOW" || continue
    if [ -n "$SERIAL_PORTS_DENY" ]; then
        matches "$name" "$SERIAL_PORTS_DENY" && continue
    fi

    [ -n "$ENTRIES" ] && ENTRIES="$ENTRIES,"
    ENTRIES="$ENTRIES$(printf '{"device":"%s","path":"%s","label":"%s","bus":"%s","claimedBy":"%s","present":true}' \
        "$name" "$dev" "$(label_for "$name")" "$(bus_for "$name")" "$(claimed_by "$name")")"
done

# A fixed port that is not there is worth saying out loud. The port was decided
# when the terminal was built, so its absence means the board is not the one
# the configuration describes - and reporting an empty list would send someone
# looking for a port to choose instead of for the reason there is none.
if [ "$FIXED" = true ] && [ -z "$ENTRIES" ]; then
    ENTRIES=$(printf '{"device":"%s","path":"/dev/%s","label":"Not present","bus":"%s","claimedBy":"%s","present":false}' \
        "$SERIAL_PORTS_ALLOW" "$SERIAL_PORTS_ALLOW" "$(bus_for "$SERIAL_PORTS_ALLOW")" "$(claimed_by "$SERIAL_PORTS_ALLOW")")
fi

printf 'Access-Control-Allow-Origin: *\r\nContent-Type: application/json\r\n\r\n'
printf '{"status":"OK","service":"%s","fixed":%s,"serialPorts":[%s],"filter":{"allow":"%s","deny":"%s"}}\n' \
    "$SERVICE" "$FIXED" "$ENTRIES" "$SERIAL_PORTS_ALLOW" "$SERIAL_PORTS_DENY"
