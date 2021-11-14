#!/bin/sh

. /scripts/functions

# Logging helper. Send the argument list to plymouth(1), or fold it
# and print it to the standard error.
usbkey_message() {
    local IFS=' '
    if [ -x /bin/plymouth ] && plymouth --ping; then
        plymouth message --text="usbkey: $*"
    elif [ ${#*} -lt 70 ]; then
        echo "usbkey: $*" >&2
    else
        # use busybox's fold(1) and sed(1) at initramfs stage
        echo "usbkey: $*" | fold -s | sed '1! s/^/    /' >&2
    fi
    return 0
}

TRUE=1
FALSE=0

USBKEY_DISKLABELS=""
if [ -f /etc/cryptsetup-usbkey/conf ] ; then
	. /etc/cryptsetup-usbkey/conf
fi

usbkey_message "Searching for keyfile"

wait_for_udev 10

TMPDIR=`mktemp -d`
TMPFILE=`mktemp`

FOUND=$FALSE
if [ -n "${USBKEY_DISKLABELS}" ]; then
	for USBKEY_DISKLABEL in $USBKEY_DISKLABELS ; do
		USBKEY_PART="/dev/disk/by-label/$USBKEY_DISKLABEL"
		if [ -e $USBKEY_PART ] ; then
			if mount -r "$USBKEY_PART" $TMPDIR >/dev/null; then
				if [ -e "$TMPDIR/$CRYPTTAB_NAME.luksKey" ]; then
					cp -f "$TMPDIR/$CRYPTTAB_NAME.luksKey" "$TMPFILE" >/dev/null
					umount "$TMPDIR" >/dev/null
					FOUND=$TRUE
					break
				else
				umount "$TMPDIR" >/dev/null
				fi
			fi
		fi
		USBKEY_PART=""
	done
fi

if [ "$FOUND" -eq "$TRUE" ]; then
	if [ -s "$TMPFILE" ]; then
		cat $TMPFILE
	fi
	rmdir $TMPDIR
	rm $TMPFILE

else
	rmdir $TMPDIR
	rm $TMPFILE

        keyscript="/lib/cryptsetup/askpass"
        keyscriptarg="No keyfile found. Please unlock disk $CRYPTTAB_NAME: "
	exec "$keyscript" "$keyscriptarg"
fi

exit 0
