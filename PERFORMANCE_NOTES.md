# Performance Notes

## Targets
- **CPU Idle:** < 1%
- **Ingestion Latency:** < 10ms from event to detection.
- **RAM Idle:** < 150MB.

## Benchmarking Plan
- Baseline measurements of ETW throughput.
- Simulation of "Event Storms" (e.g., rapid process creation).
- Memory profiling during high-load telemetry.
