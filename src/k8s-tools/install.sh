#!/usr/bin/env bash

architecture=$(dpkg --print-architecture)
case "${architecture}" in
	amd64) TARGETARCH="amd64" ;;
	arm64) TARGETARCH="arm64" ;;
	*)
		echo "Machine architecture '${architecture}' is not supported. Please use an x86-64 or ARM64 machine."
		exit 1
esac

# kind
# https://github.com/mpriscella/features/blob/main/src/kind/install.sh
curl -L "https://github.com/kubernetes-sigs/kind/releases/download/latest/kind-linux-${TARGETARCH}" \
	-o /usr/local/bin/kind

chmod +x /usr/local/bin/kind


# helm

# kubectl

# skaffold

# k9s

