# Threat Model

## Target Threats
- **Remote Access Trojans (RATs):** Beaconing, C2 communication, shell access.
- **Advanced Persistence:** 
    - Registry Run keys, WMI Event consumers, Scheduled Task abuse.
    - "Registry-only" task creation (bypassing Task Scheduler API).
- **Defense Evasion:**
    - **PPID Spoofing:** Claiming a legitimate parent (e.g., `svchost.exe`) to hide the actual execution chain.
    - **ETW Patching:** Overwriting `EtwEventWrite` in `ntdll.dll` with `RET` to blind the EDR.
- **Execution:**
    - PowerShell Script Block abuse (obfuscated commands).
    - DLL Injection / Thread Hijacking.

## Attack Surface
- **ETW Consumer:** Vulnerable to event flooding (DoS) or malformed event packets.
- **IPC Named Pipes:** Potential for unauthorized messaging if permissions are weak.
- **UI Interface:** Critical control of remediation actions (must be gated).

## Mitigation Strategies
- **Telemetry Overload:** Bounded queues and adaptive sampling.
- **ETW Evasion:** Combination of memory scanning and Kernel-to-User gap analysis.
- **Spoofing:** Header-level validation of the actual calling process.
- **Remediation Safety:** Strict confidence thresholds and quarantine-first policies.
