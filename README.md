# SentraEDR
Modern lightweight Anti-RAT / EDR (Endpoint Detection and Response) platform.

## Core Focus
- Real-time RAT detection
- Behavioral analysis
- Persistence detection/removal
- Low RAM usage (< 150MB idle)
- Advanced Windows telemetry (ETW, Sysmon)
- Modular Rust architecture

## Tech Stack
- **Core Engine:** Rust
- **UI:** Tauri + React
- **OS Integration:** windows-rs, WinAPI, ETW
- **Network:** pcap, pnet
- **Rule Engine:** YARA / yara-x
- **Database:** SQLite
- **IPC:** Named Pipes
