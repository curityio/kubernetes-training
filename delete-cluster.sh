#!/bin/bash

##########################################
# Clean up resources once finished testing
##########################################

cd "$(dirname "${BASH_SOURCE[0]}")"
kind delete cluster --name=demo
