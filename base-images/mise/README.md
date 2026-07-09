# Aicage custom base-image: `mise` (Alpine)

This is the `minimal` sample adapted to include
[mise](https://mise.jdx.dev/).

It keeps the existing `minimal` Alpine layout and install scripts, then adds
`mise` on top and routes Node.js through `mise` instead of the parent image.

Recommended pairing:

- enable the [`mise-cache`](../../extensions/mise-cache/extension.yml) extension
- or pass `--share ~/.config/mise --share ~/.local/share/mise --share ~/.cache/mise`

The first run on a machine will still need to download tools. Later runs can
reuse the host-backed `mise` directories.
