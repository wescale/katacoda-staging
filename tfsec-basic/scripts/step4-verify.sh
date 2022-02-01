#!/bin/bash
grep -q "#tfsec:ignore:aws-kms-auto-rotate-keys" main.tf && echo "done"