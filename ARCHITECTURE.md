# Architecture

## Design Philosophy
- **Event-Driven:** No polling. The system reacts to telemetry.
- **Modular Isolation:** Engine crates are decoupled via IPC and shared models.
- **Low Footprint:** Strict memory budgets and allocation-free hot paths.

## High-Level Components
- `engine-etw`: The root source of truth.
- `engine-process`: Runtime process analysis.
- `engine-network`: C2 and traffic analysis.
- `engine-persistence`: Persistence monitoring.
- `engine-detection`: The "Brain" (Heuristics & Correlation).
- `shared-ipc`: The communication backbone.
- `shared-models`: The immutable contract layer.
- `ui-dashboard`: The visualization and control layer.

## Data Flow
`ETW Providers` → `engine-etw` → `shared-ipc` → `Analysis Engines` → `engine-detection` → `ui-dashboard`
