# packipk - Create .ipk and single package repository

Github action for packing an input directory comprising of control as well as data directories into an .ipk file named by reference to the package control file's Package value. Setting timestamp to 1 will update the SourceDateEpoch field whereas setting timestmap_patch to 1 will update the Version field's Patch number to the current date.

Example using repository secrets for base64 key storage:

      - name: Pack my-application.ipk
        uses: resmh/action-packipk@master
        with:
          input: relative-input-folder
          output: relative-output-folder
          timestamp: 1
          timestamp_patch: 1
          
Keys are generated using gpg --gen-key without setting a passphrase followed by an --armored --export-secret-key as well as signify-openbsd -G -n -p key.pub -s key.sec. They are then subjected to the base64 utility and finally configured as action secret. The resulting files are ready to use as opkg repository.
