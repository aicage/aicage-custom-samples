# Aicage Custom Samples

[aicage](https://github.com/aicage/aicage) - Runs agentic coding assistants in Docker containers

---

This project holds samples for customization of `aicage` images.

## Aicage Images

### Image Layers

Aicage images are built in layers:

1. base-image: The core layer with the OS and all software needed for development
2. agent: The coding-agent is added to a base-image
3, optional extensions: Custom extension to add more software to images

All layers can be fully customized - users can write their own and `aicage` builds the other layers on users PC.

### Image Updates

`aicage` also updates the images when needed by checking:
- base-image digest local vs. remote
- agent version
- (extensions currently not checked)

## Usage

Clone this repo to `~/.aicage-custom` and start `aicage` with a coding-agent.

```shell
git clone https://github.com/aicage/aicage-custom-samples.git ~/.aicage-custom

aicage <AGENT>
```

### New extensions

Extensions are the easiest way to add more software to Aicage images.

When starting `aicage` it will now suggest to add these extensions to images:
- `act`: Runs GitHub workflows locally
- `marker`: A dummy sample

Aicage will automatically build a custom image with your chosen extensions on top of the `base+agent` image.

### Add your own extension

You can easily add your own extension by adding a folder to `~/.aicage-custom/extensions`.

Examples/Templates:

- [act](extensions/act)
- [marker](extensions/marker)

### New custom agent

The coding agent `forge` is now available with:

```shell
aicage forge
```

Aicage will automatically build a custom image with your chosen `base`.

### Add your own coding agent

You can easily add your own custom agent by adding a folder to `~/.aicage-custom/agents`.

Examples/Templates:

- [forge](agents/forge)
- [aicage-image/agents](https://github.com/aicage/aicage-image/tree/main/agents) for the builtin agents.

### New base-images

When selecting a `base-image` during startup you will see the sample custom bases:

- `debian-mirror`
- `minimal`
- `php`
- ...

### Add your own custom base-image

_Extensions are much easier and more convenient than custom bases._

Add a folder to `~/.aicage-custom/base-images` for your personal base-image.

Examples/Templates:

- [base-images](base-images)
- [aicage-image-base/bases](https://github.com/aicage/aicage-image-base/tree/main/bases) for the builtin bases

> Notes:
>
> - A base-image must contain everything for development.
> - Plus the `entrypoint.sh` from `aicage` - feel free to copy and extend it.
> - The base.yml of builtin bases is slightly different

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
  agents/*/agent.yaml

echo "Validate base.yml files with schema"
check-jsonschema \
  --schemafile validation/base.schema.json \
  base-images/*/base.yml

echo "Validate base.yml files with schema"
check-jsonschema \
  --schemafile validation/extension.schema.json \
  extensions/*/extension.yml
```
