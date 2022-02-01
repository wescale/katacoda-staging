#!/bin/bash

# Download TFSec binary
curl -o /usr/local/bin/tfsec -L -J -O https://github.com/aquasecurity/tfsec/releases/download/v1.0.2/tfsec-linux-amd64

# Gives execution rights
chmod u+x /usr/local/bin/tfsec