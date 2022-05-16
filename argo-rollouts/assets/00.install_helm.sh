#!/bin/bash
# installs helm if it isn't already present

set -e

HELM_VERSION="v3.8.2"

if command -v helm >/dev/null 2>&1; then
    exit 0
fi

DOWNLOAD_LINK=""
case "$(arch)" in
    "x86_64")
        DOWNLOAD_LINK="https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz"
        BINARY_FOLDER=linux-amd64
    ;;

  *)
    echo "$(arch) not supported for helm install yet in this script"
    exit 1
    ;;
esac

wget "$DOWNLOAD_LINK" --output-document /tmp/helm.tar.gz --quiet
mkdir /tmp/helm
tar xf /tmp/helm.tar.gz -C /tmp/helm
cp "/tmp/helm/$BINARY_FOLDER/helm" /usr/local/bin/helm
chmod +x /usr/local/bin/helm

echo -n "Installed Helm :"
helm version
echo ""
