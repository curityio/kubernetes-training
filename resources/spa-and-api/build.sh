#!/bin/bash

#########################################################################
# Build the SPA and API application level components to Docker containers
#########################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Clone the code example repo
#
rm -rf download 2>/dev/null
git clone https://github.com/curityio/spa-using-curitytokenhandler download
if [ $? -ne 0 ]; then
  exit 1
fi
cd download

#
# Build the SPA to static content
#
cd spa
npm install
if [ $? -ne 0 ]; then
  exit 1
fi

npm run build
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Build the Express HTTP server for the SPA's static content into a Docker container
#
cd ../webhost
npm install
if [ $? -ne 0 ]; then
  exit 1
fi

npm run build
if [ $? -ne 0 ]; then
  exit 1
fi

cd ..
docker build -f webhost/Dockerfile -t example-spa:1.0 .
if [ $? -ne 0 ]; then
  exit 1
fi

kind load docker-image example-spa:1.0 --name demo
if [ $? -ne 0 ]; then
  exit 1
fi


#
# Build the Express HTTP server for the API into a Docker container
#
cd api
npm install
if [ $? -ne 0 ]; then
  exit 1
fi

npm run build
if [ $? -ne 0 ]; then
  exit 1
fi

docker build -f Dockerfile -t example-api:1.0 .
if [ $? -ne 0 ]; then
  exit 1
fi

kind load docker-image example-api:1.0 --name demo
if [ $? -ne 0 ]; then
  exit 1
fi
