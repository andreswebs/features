## Starting

1. Add a `.devcontainer/postcreate.sh` script to start the Nix daemon:

```sh
cat << EOF > .devcontainer/postcreate.sh
#!/bin/sh

# shellcheck disable=SC1091
sudo . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

EOF
```

2. Add to the `.devcontainer/devcontainer.json`:

```jsonc
{
  // ...
  "postStartCommand": "bash ./.devcontainer/poststart.sh"
}
```

## References

<https://github.com/DeterminateSystems/nix-installer>
