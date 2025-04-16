#!/bin/bash

########################################################################
# A script to run cloud provider KIND to spin up external load balancers
########################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

EXISTING_PROCESS=$(ps -ef | grep '[c]loud-provider-kind')
if [ "$EXISTING_PROCESS" != '' ]; then
  echo 'Cloud provider KIND is already running'
  exit 0
fi

VERSION='0.6.0'
if [ "$(uname -m)" == 'arm64' ]; then
  ARCH='arm64'
else
  ARCH='amd64'
fi

case "$(uname -s)" in

  Darwin)
    PLATFORM='darwin'
  ;;

  MINGW64*)
    PLATFORM='windows'
  ;;

  Linux)
    PLATFORM='linux'
  ;;
esac
FILENAME="cloud-provider-kind_${VERSION}_${PLATFORM}_${ARCH}.tar.gz"
FILEPATH="https://github.com/kubernetes-sigs/cloud-provider-kind/releases/download/v${VERSION}/${FILENAME}"

echo 'Downloading cloud-provider-kind to provider development load balancers ...'
rm -rf download 2>/dev/null
mkdir download
cd download
curl -s -L -O $FILEPATH
if [ $? -ne 0 ]; then
  echo 'Problem encountered downloading cloud provider kind'
  exit 1
fi

tar -zxf $FILENAME
if [ $? -ne 0 ]; then
  echo '*** Problem encountered unpacking cloud provider kind'
  exit 1
fi

if [ "$PLATFORM" == 'darwin' ]; then
  
  #
  # On some macOS computers, adding an ad-hoc signature to the EXE may be required
  #
  echo 'Grant cloud-provider-kind macOS permissions to update the local loopback network ...'
  codesign -s - ./cloud-provider-kind
  sudo ./cloud-provider-kind

elif [ "$PLATFORM" == 'windows' ]; then
  
  #
  # On Windows, make sure you run from an administrator shell
  #
  echo 'Running a Windows administrator shell so that cloud-provider-kind can update the local loopback network ...'
  ./cloud-provider-kind
else
  
  #
  # On Linux, run the tool as a normal user
  #
  echo 'Running cloud-provider-kind on a Linux-based system ...'
  ./cloud-provider-kind
fi
