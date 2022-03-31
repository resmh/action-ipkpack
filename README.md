# packipk - Create .ipk and single package repository

Github action for packing control as well as data directories into an .ipk file named by the parameter pkgname (default: package). If the package control file contains all required keys, setting pkgrepo to 1 will generate an opkg package index for it. If pkggpgrepokey and/or pkgsignifyrepokey are set to passwordless (armored and) base64-encoded private keys, the package index is furthermore signed.

Example using repository secrets for base64 key storage:

      - name: Pack my-application.ipk
        uses: resmh/action-packipk@master
        with:
          pkgname: my-application
          pkgrepo: 1
          pkggpgrepokey: ${{ secrets.GPGKEY }}
          pkgsignifyrepokey: ${{ secrets.SIGNIFYKEY }}
          
Keys are generated using gpg --gen-key without setting a passphrase followed by an --armored --export-secret-key as well as signify-openbsd -G -n -p key.pub -s key.sec. They are then subjected to the base64 utility and finally configured as action secret. The resulting files are ready to use as opkg repository.
