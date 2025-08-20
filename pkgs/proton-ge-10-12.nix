{ writeShellScriptBin, curl }:

writeShellScriptBin "install-proton-ge-10-12" ''
  set -e
  
  echo "Installing Proton GE 10-12..."
  
  # make temp working directory
  echo "Creating temporary working directory..."
  rm -rf /tmp/proton-ge-10-12
  mkdir /tmp/proton-ge-10-12
  cd /tmp/proton-ge-10-12
  
  # download specific tarball for GE-Proton10-12
  tarball_url="https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton10-12/GE-Proton10-12.tar.gz"
  tarball_name="GE-Proton10-12.tar.gz"
  echo "Downloading tarball: $tarball_name..."
  ${curl}/bin/curl -# -L "$tarball_url" -o "$tarball_name"
  
  # verify checksum
  echo "Verifying checksum..."
  echo "47dffcff346b35c75649a95a012ad4e9b6376087dceb43ac7b695e04f5ed3c1e  $tarball_name" | sha256sum -c
  
  # make steam directory if it does not exist
  echo "Creating Steam directory if it does not exist..."
  mkdir -p ~/.steam/steam/compatibilitytools.d
  
  # extract proton tarball to steam directory
  echo "Extracting $tarball_name to Steam directory..."
  tar -xf "$tarball_name" -C ~/.steam/steam/compatibilitytools.d/
  
  echo "Proton GE 10-12 installed successfully!"
  echo "Restart Steam to see the new compatibility tool."
''