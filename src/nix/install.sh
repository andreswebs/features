#!/bin/sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix > nix-installer.sh
chmod +x nix-installer.sh
./nix-installer.sh install -—no-confirm --init none
rm nix-installer.sh
