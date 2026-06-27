# Project Roadmap

## Phase 0: Research and Planning
- Goal: Establish a scientifically sound foundation for detection and architecture.
- Deliverables: Architecture Diagram, Threat Model, Telemetry Model.

## Phase 1: Workspace Initialization
- Goal: Set up the modular Rust environment and UI scaffold.
- Deliverables: Working Monorepo, IPC primitives, Logging system.

## Phase 2: ETW Telemetry Engine
- Goal: Achieve real-time ingestion of critical Windows events.
- Deliverables: ETW Event Pipeline, Process/Registry/Thread subscriptions.

## Phase 3: Process Monitoring Engine
- Goal: Identify suspicious process behaviors and execution chains.
- Deliverables: Parent-Child analysis, Unsigned binary detection.

## Phase 4: Persistence Engine
- Goal: Detect and remove RAT persistence mechanisms.
- Deliverables: Run key/Scheduled Task/Service monitor.

## Phase 5: Network Engine
- Goal: Analyze outbound C2 traffic and beaconing.
- Deliverables: DNS anomaly detection, Connection graphing.

## Phase 6: Heuristic Detection Engine
- Goal: Correlate telemetry into high-confidence alerts.
- Deliverables: Scoring engine, Attack chain correlation.

## Phase 7: Quarantine and Remediation Engine
- Goal: Safely isolate threats and rollback changes.
- Deliverables: Process suspension, File quarantine, Registry rollback.

## Phase 8: Memory Inspection Engine
- Goal: Detect in-memory threats (DLL injection, shellcode).
- Deliverables: RWX scanner, Thread analysis.

## Phase 9: UI Dashboard
- Goal: Provide a real-time security operations center (SOC) view.
- Deliverables: Telemetry graph, Alert timeline, Control panel.

## Phase 10: Testing Infrastructure
- Goal: Validate efficacy against simulated threats.
- Deliverables: Atomic Red Team integration, Performance benchmarks.
