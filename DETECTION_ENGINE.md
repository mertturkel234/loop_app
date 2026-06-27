# Detection Engine

## Logic Overview
SentraEDR uses a multi-layered scoring system.
1. **Telemetry Event:** Raw event from ETW.
2. **Behavioral Signal:** Analysis engine marks event as "suspicious" based on a specific rule.
3. **Correlation:** `engine-detection` links signals into an attack chain.
4. **Verdict:** Final risk score determines if the threat is confirmed.

## High-Fidelity Detection Rules

### 1. Process Execution
- **PPID Spoofing:** Triggered when `ParentProcessID` $\neq$ `Execution Process ID` from `Microsoft-Windows-Kernel-Process` EID 1.
- **Suspicious Parent:** Processes launched by `spoolsv.exe` or `svchost.exe` that are not standard Windows services.
- **AppData Execution:** Any binary executing from `\AppData\Local\Temp\` or `\Roaming\`.

### 2. PowerShell Abuse
- **Script Block Analysis:** Monitoring EID 4104 for keywords: `Invoke-Expression`, `IEX`, `WebClient.DownloadString`, `base64`.
- **Obfuscation Detection:** High ratio of non-alphanumeric characters in a script block.

### 3. Persistence
- **Task Scheduler:** New task registration (EID 106) where the action points to an unsigned binary or a script.
- **Run Key Trigger:** Command execution from Run keys (EID 9707) not matched to a known-good installer.

## False Positive Prevention
- **Whitelisting:** Cryptographic hashing of known-good system binaries.
- **Contextual Weighting:** `powershell.exe` execution is weighted lower if the parent is a known administrative tool (e.g., `mstsc.exe`).
- **Multi-Signal Agreement:** Remediation is only triggered if $\ge 2$ independent signals (e.g., Process + Network) agree on a high risk score.
