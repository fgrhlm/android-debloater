# Android Debloater Script
Helps you automate the removal of unwanted apps (bloat) preinstalled on your phone.

The script parses a list (manifest) of unwanted apps and issues adb commands that uninstalls the apps on your phone.

## Running the script
1. Review the entirety of `debloat.sh`.
2. Install `adb`
3. Find your device key by running `adb devices`. the key should look something like this: `YGAAAJANHGFAUGAA`
4. Compile a list of unwanted apps or use one of the provided manifests in this repo (in manifests/).
5. Run the script `debloat.sh -d <DEVICE_KEY> -f <MANIFEST_FILE>`
