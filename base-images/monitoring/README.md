# Aicage custom base-image: 'monitoring' (Debian)

Used to test and develop Prometheus-style monitoring for local agent containers.

This base adds the published `herakles-node-exporter` release binary and starts it
next to the normal `aicage` workload.

Default endpoints:

- `http://localhost:9215/metrics`
- `http://localhost:9215/health`

Notes:

- eBPF-related features are disabled in the bundled config for this container use case
- the exporter can be disabled with `AICAGE_ENABLE_HERAKLES=0`
