# packipk - Create .ipk from folder

Github action for packing an input directory comprising of control as well as data directories into an .ipk file named by reference to the package control file's Package value. Setting timestamp to 1 will update the SourceDateEpoch field whereas setting timestmap_patch to 1 will update the Version field's Patch number to the current date.

Example:

      - name: Pack my-application.ipk
        uses: resmh/action-ipkpack@master
        with:
          input: relative-input-folder
          output: relative-output-folder
          timestamp: 1
          timestamp_patch: 1
