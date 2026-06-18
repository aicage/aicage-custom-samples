# Aicage custom base-image: 'monitoring' (Alpine)

Used to test and develop image monitoring for local agent containers.

Additions on top of the `minimal` sample:

- basic inspection tools: `htop`, `procps`, `lsof`, `iproute2`, `sysstat`
- `aicage-monitor` snapshot helper
- a basic Docker `HEALTHCHECK`

Useful commands inside a running container:

```sh
aicage-monitor
htop
ss -tupan
```

The health check is intentionally basic. It verifies that:

- `/proc` is available
- the workspace directory exists
- the helper scripts were installed

This is enough for local experiments without turning the image into a full monitoring stack.
