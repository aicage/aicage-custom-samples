# Aicage Custom Samples

[aicage](https://github.com/aicage/aicage) - Runs agentic coding assistants in Docker containers

---

This project holds samples for customization of `aicage` images.

## Aicage Images

### Image Layers

Aicage images are built in layers:

1. base-image: The core layer with the OS and all software needed for development
2. agent: The coding agent is added to a base-image
3. optional extensions: Custom extensions add more software to images

All layers can be fully customized. Users can write their own, and `aicage` builds the remaining layers on the user's PC.

### Image Updates

`aicage` also updates the images when needed by checking:

- base-image digest local vs. remote
- agent version
- (extensions currently not checked)

## Usage

Clone this repo to `~/.aicage-custom` and start `aicage` with a coding agent.

```shell
git clone https://github.com/aicage/aicage-custom-samples.git ~/.aicage-custom

aicage <AGENT>
```

### Extensions

Extensions are the easiest way to add more software to Aicage images.

Current extension samples in this repository:

- `act`: Run GitHub Actions locally
- `crane`: Install crane
- `cosign`: Install sigstore/cosign
- `dotnet`: Install the .NET SDK
- `gcloud`: Install the Google Cloud CLI
- `gh`: Install GitHub CLI
- `grype`: Scan container images, filesystems, and SBOMs for known vulnerabilities
- `haskell`: Install the Haskell toolchain with GHCup, GHC, Cabal, Stack, and HLS
- `java17`: Install the Java Development Kit 17
- `java21`: Install the Java Development Kit 21
- `nvidia-cuda`: Install NVIDIA CUDA user-space tooling
- `php`: Install PHP CLI tooling and Composer
- `regctl`: Install regctl
- `shellcheck`: Install ShellCheck
- `skopeo`: Work with remote container images and registries
- `syft`: Generate software bills of materials for container images and filesystems

Aicage will automatically build a custom image with your chosen extensions on top of the `base+agent` image.

### Add your own extension

You can easily add your own extension by adding a folder to `~/.aicage-custom/extensions`.

Examples/Templates:

- [act](extensions/act)
- [crane](extensions/crane)
- [cosign](extensions/cosign)
- [dotnet](extensions/dotnet)
- [gcloud](extensions/gcloud)
- [gh](extensions/gh)
- [grype](extensions/grype)
- [haskell](extensions/haskell)
- [java17](extensions/java17)
- [java21](extensions/java21)
- [nvidia-cuda](extensions/nvidia-cuda)
- [php](extensions/php)
- [regctl](extensions/regctl)
- [shellcheck](extensions/shellcheck)
- [skopeo](extensions/skopeo)
- [syft](extensions/syft)

### Custom agents

Current custom agent samples in this repository:

- `aider`
- `amp`
- `auggie`
- `cline`
- `forge`
- `kimi`
- `kiro-cli`
- `vibe`

Use one with:

```shell
aicage <AGENT>
```

Aicage will automatically build a custom image with your chosen `base`.

### Add your own coding agent

You can easily add your own custom agent by adding a folder to `~/.aicage-custom/agents`.

Examples/Templates:

- [aider](agents/aider)
- [amp](agents/amp)
- [auggie](agents/auggie)
- [cline](agents/cline)
- [forge](agents/forge)
- [kimi](agents/kimi)
- [kiro-cli](agents/kiro-cli)
- [vibe](agents/vibe)
- [aicage-image/agents](https://github.com/aicage/aicage-image/tree/main/agents) for the builtin agents.

### Base-images

Current custom base-image samples in this repository:

- `act`
- `debian-mirror`
- `minimal`
- `php`

### Add your own custom base-image

_Extensions are much easier and more convenient than custom bases._

Add a folder to `~/.aicage-custom/base-images` for your personal base-image.

Examples/Templates:

- [act](base-images/act)
- [debian-mirror](base-images/debian-mirror)
- [minimal](base-images/minimal)
- [php](base-images/php)
- [aicage-image-base/bases](https://github.com/aicage/aicage-image-base/tree/main/bases) for the builtin bases

> Notes:
>
> - A base-image must contain everything for development.
> - Plus the `entrypoint.sh` from `aicage` - feel free to copy and extend it.
> - Use the same `base.yml` schema as the builtin bases.

### Test build your custom base-image

`aicage` builds images automatically on start, this helps when writing your custom base-image.

Test-build it with (example for base `minimal`):

```shell
BASE=minimal
FROM_IMAGE=alpine:latest

docker build \
  --tag aicage-image-base:${BASE} \
  --build-arg FROM_IMAGE=${FROM_IMAGE} \
  ~/.aicage-custom/base-images/${BASE}
```

## YAML validation

You can validate your YAML files against their schemas.

### Setup

```shell
cd ~/.aicage-custom

echo "Setting up dependencies"
python3 -m venv .venv
source .venv/bin/activate
pip install check-jsonschema

echo "Validate agent.yml files with schema"
check-jsonschema \
  --schemafile validation/agent.schema.json \
  agents/*/agent.yml

echo "Validate base.yml files with schema"
check-jsonschema \
  --schemafile validation/base.schema.json \
  base-images/*/base.yml

echo "Validate extension.yml files with schema"
check-jsonschema \
  --schemafile validation/extension.schema.json \
  extensions/*/extension.yml
```
