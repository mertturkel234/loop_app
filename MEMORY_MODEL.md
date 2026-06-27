# Memory Model

## Budget
- **Total Idle RAM:** < 150 MB.
- **Telemetry Buffer:** Bounded.
- **Heap Usage:** Minimized in hot paths.

## Allocation Strategy
- **Object Pooling:** Use of pools for `TelemetryEvent` structures to avoid frequent allocations during event storms.
- **Zero-Copy Parsing:** Parse ETW event properties as slices (`&[u8]`) referencing the original buffer.
- **Avoidance of `String` Cloning:** Use `Cow<'a, str>` or `Arc<str>` for common process names and paths.

## High-Throughput Pipeline Design
- **Ingestion Buffer:** A bounded `crossbeam-channel` between the ETW callback thread and the worker pool.
- **Capacity Limit:** Maximum of 10,000 events in flight per subsystem.
- **Drop Policy:** If the buffer is full, drop `LOW` priority events (e.g., routine image loads) to preserve `CRITICAL` events (e.g., process creation).
