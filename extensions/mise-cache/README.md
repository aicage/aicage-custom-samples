# Aicage extension: `mise-cache`

This share-only extension mounts the default Linux `mise` data directories into
the container:

- `~/.config/mise`
- `~/.local/share/mise`
- `~/.cache/mise`

Use it with the custom [`mise`](../../base-images/mise/README.md) base-image or
with any other image where you want `mise` installs to persist across container
runs.
