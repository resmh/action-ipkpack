#!/bin/bash

# ######################################################################
# ######################################################################
#
# IPK PACK
# Packs a given package folder to a timestamped ipk file
# 
# ######################################################################
# ######################################################################



# ######################################################################
# ######################################################################
#
# VARIABLES
#
# ######################################################################
# ######################################################################

set -e

INPUT_INPUT=${INPUT_INPUT:-'.'}
INPUT_OUTPUT=${INPUT_OUTPUT:-'.'}

INPUT_TIMESTAMP=${INPUT_TIMESTAMP:-''}
INPUT_TIMESTAMP_PATCH=${INPUT_TIMESTAMP_PATCH:-''}

pkgcontrol="${INPUT_INPUT}/control/control"


# ######################################################################
# ######################################################################
#
# TIMESTAMPING AND PACKAGING
#
# ######################################################################
# ######################################################################

echo "Packing $INPUT_INPUT"

# ######################################################################

echo "Reading package control"
if ! pkgname=$(cat "$pkgcontrol" | grep -oP "Package: \K.*"); then echo "Failed to determine package name."; exit 2; fi
pkgoutput=$(realpath "${INPUT_OUTPUT}")"/${pkgname}.ipk"
echo "Packing $INPUT_INPUT to ${pkgname}.ipk"

# ######################################################################

if [ "$INPUT_TIMESTAMP" == "1" ]; then

	echo "Updating SourceDateEpoch to $pkgdate"
	sed -i '/^SourceDateEpoch: .*/d' "$pkgcontrol"
	pkgdate=$(date +%s)
	echo "SourceDateEpoch: $pkgdate" >> "$pkgcontrol"
	echo "SourceDateEpoch updated"

fi

# ######################################################################

if [ "$INPUT_TIMESTAMP_PATCH" == "1" ]; then

	echo "Updating Version Patch to $pkgdate"
	pkgversion=""
	if ! pkgversion=$(cat "$pkgcontrol" | grep -oP "Version: \K.*"); then echo "No version found, setting to 0.0.0"; pkgversion="0.0.0"; fi
	pkgversion=$(echo "$pkgversion" | grep -o "Version: .*\..*\.")"$pkgdate"
	echo "Updating Version to $pkgversion"
	sed -i '/^Version: .*/d' ./Packages
	echo "$pkgversion" >> ./Packages
	echo "Version updated"
	
fi

# ######################################################################

opwd="$(pwd)"
cd "$INPUT_INPUT"

# ######################################################################

echo "Packing control ..."
cd "control"
tar czvf "../control.tar.gz" "."
cd ..
echo "Done."

# ######################################################################

echo "Packing data ..."
cd "data"
tar czvf "../data.tar.gz" "."
cd ..
echo "Done."

# ######################################################################

echo "Checking debian-binary..."
if [ ! -f "./debian-binary" ]; then echo "2.0" > "./debian-binary"; fi
echo "Done."

# ######################################################################

echo "Packing ${pkgoutput} ..."
tar czvf "${pkgoutput}" "control.tar.gz" "data.tar.gz" "debian-binary"
echo "Done."

# ######################################################################

echo "Cleaning up ..."
rm "control.tar.gz"
rm "data.tar.gz"
echo "Done."

# ######################################################################

cd "$opwd"

# ######################################################################

echo "Successfully packed $pkgname"
exit 0

