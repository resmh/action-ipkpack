#!/bin/bash
set -e

INPUT_PKGNAME=${INPUT_PKGNAME:-'package'}
INPUT_PKGREPO=${INPUT_PKGREPO:-'0'}
INPUT_PKGGPGREPOKEY=${INPUT_PKGGPGREPOKEY:-''}
INPUT_PKGSIGNIFYREPOKEY=${INPUT_PKGSIGNIFYREPOKEY:-''}

echo "Packing control, data and debian-binary to ${INPUT_PKGNAME}.ipk ..."

echo "Packing control ..."
cd "control"
tar czvf "../control.tar.gz" "."
cd ..
echo "Done."

echo "Packing data ..."
cd "data"
tar czvf "../data.tar.gz" "."
cd ..
echo "Done."

echo "Checking debian-binary..."
if [ ! -f "./debian-binary" ]; then echo "2.0" > "./debian-binary"; fi
echo "Done."

echo "Packing ipk ..."
tar czvf "${INPUT_PKGNAME}.ipk" "control.tar.gz" "data.tar.gz" "debian-binary"
echo "Done."

echo "Cleaning up ..."
rm "control.tar.gz"
rm "data.tar.gz"
echo "Done."

if [ ! "$INPUT_PKGREPO" == "1" ]; then

	echo "Not creating single package index."
	
else

	echo "Creating single package index..."

	cp ./control/control ./Packages
	
	sed -i '/^Size: .*/d' ./Packages
	pkgsize=$(stat -c %s ${INPUT_PKGNAME}.ipk)
	echo "Size: $pkgsize" >> ./Packages

	sed -i '/^SHA256sum: .*/d' ./Packages
	pkghash=$(sha256sum ${INPUT_PKGNAME}.ipk | grep -o "^[^ ]*")
	echo "SHA256sum: $pkghash" >> ./Packages

	sed -i '/^SourceDateEpoch: .*/d' ./Packages
	pkgdate=$(date +%s)
	echo "SourceDateEpoch: $pkgdate" >> ./Packages

	pkgversion=""
	if ! pkgversion=$(cat control/control | grep -o "Version: .*\."); then pkgversion = "Version: 0.0."; fi
	sed -i '/^Version: .*/d' ./Packages
	pkgversion="${pkgversion}"$(date +%Y%m%d%H%M)
	echo "New package $pkgversion"
	echo "$pkgversion" >> ./Packages

	echo "Single package index created."

	if [ "$INPUT_PKGGPGREPOKEY" == "" ]; then

		echo "Not signing single package index with gpg."
		
	else

		echo "Signing single package index..."
		
		echo -n "$INPUT_PKGGPGREPOKEY" | base64 --decode | gpg --import
		gpg -a --output ./Packages.asc --detach-sig ./Packages

		echo "Single package index signed with gpg."

	fi

	if [ "$INPUT_PKGSIGNIFYREPOKEY" == "" ]; then

		echo "Not signing single package index with signify-openbsd."
		
	else

		echo "Preparing to sign single package index with signify-openbsd..."
		
		sudo apt-get install -y signify-openbsd

		echo "Signing single package index with signify-openbsd..."
		echo -n "$INPUT_PKGSIGNIFYREPOKEY" | base64 --decode > "key.sec"
		signify-openbsd -S -s "key.sec" -m "Packages"
		rm "key.sec"

		echo "Single package index signed with signify."

	fi

fi

echo "Successfully packed ${INPUT_PKGNAME}.ipk."
exit 0

