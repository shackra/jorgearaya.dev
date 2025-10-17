# jorgearaya.dev

This repository has my professional blog and the Nix files that configures the server on Digital Ocean.

## Notes

How to make a new Digital Ocean image:

```sh
nix build .#digital-ocean
```

How to rebuild the OS of the remote server:

```sh
nix run github:serokell/deploy-rs .#site
```

### Secrets

Secrets are provided with this repository and installed after Digital Ocean has created the droplet. They cannot be installed on the Digital Ocean image on creation (AFAIK) thus we need to ssh into the server and generate the AGE key from the public SSH key of the system.

```sh
$ nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'
```

After getting the AGE key, we have to update `.sops.yaml` and run `sops updatekeys` for the `secrets.yaml` file.
