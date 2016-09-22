#!/bin/bash
# Script to remove current and previous releases of CACKey from Mac OS X

if [ "`whoami`" != "root" ]; then
	echo "Please rerun this script with sudo or directly as root."
	exit 1
fi

# Remove Directories and Files
echo "Removing CACKey-related files and directories, if they exist..."
rm -rf /usr/lib/pkcs11/*cackey*
rm -rf /usr/local/lib/pkcs11/*cackey*
rm -rf /Library/CACKey
rm -rf /System/Library/Security/tokend/PKCS11.tokend
rm -rf /Library/Security/tokend/PKCS11.tokend

# Forget about packages installed
echo "Removing saved Mac OS X package information for CACKey..."
for package in `pkgutil --pkgs | grep -i CACKey`; do
	pkgutil --forget ${package}
done

# If on Sierra or newer, reenable the pivtoken CryptoTokenKit
echo "Reenabling the builtin pivtoken CryptoTokenKit..."
if [ "`uname -r | cut -d '.' -f 1`" -ge "16" ]; then
	security smartcards token -e com.apple.CryptoTokenKit.pivtoken
	defaults delete /Library/Preferences/com.apple.security.smartcard DisabledTokens -array com.apple.CryptoTokenKit.pivtoken
fi
