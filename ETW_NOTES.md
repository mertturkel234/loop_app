# ETW Notes

## Core Providers & Event IDs

### 1. Process Monitoring (`Microsoft-Windows-Kernel-Process`)
- **Event ID 1 (ProcessStart):** Critical for process creation. 
    - **Detection Logic:** Compare `ParentProcessID` (claimed) vs. `Execution Process ID` (actual caller) to detect **PPID Spoofing**.
- **Event ID 2 (ProcessStop):** Correlates process lifecycles.
- **Event ID 15 (ProcessRundown):** Enumerates existing processes upon trace start.

### 2. Image & DLL Monitoring (`Microsoft-Windows-Kernel-ImageLoad`)
- Monitors all DLL and image loads. Essential for detecting DLL injection and side-loading.

### 3. Persistence Monitoring
- **Task Scheduler (`Microsoft-Windows-TaskScheduler`):**
    - **EID 106:** Task registered.
    - **EID 140:** Task updated.
    - **EID 200/201:** Action started/completed (confirms execution).
- **Shell Core (`Microsoft-Windows-Shell-Core/Operational`):**
    - **EID 9707:** Run key execution started.
    - **EID 9708:** Run key execution completed.

### 4. PowerShell Telemetry
- **PowerShell Core (v6+):** 
    - **GUID:** `{f90714a8-5509-434a-bf6d-b1624c8a19a2}`
    - **EID 4104:** Script Block Logging (the gold standard for command content).
- **Windows PowerShell (v5.1):**
    - **Provider:** `Microsoft-Windows-PowerShell`
    - **EID 4104:** Script Block Logging.

## Implementation Strategy (Rust)

### Recommended Library: `ferrisetw`
- **Pattern:** Callback-based architecture.
- **Performance:** Schema caching and type-safe parsing using `windows-rs`.
- **Architecture:** 
    - **Ingestion:** ETW Callback $\rightarrow$ Lock-free Queue (`crossbeam-channel`).
    - **Processing:** Worker Pool $\rightarrow$ Normalization $\rightarrow$ `shared-ipc`.

### Anti-Evasion (ETW Patching)
- **Target:** `ntdll.dll` $\rightarrow$ `EtwEventWrite`.
- **Detection:** 
    - **Static:** Scan for `RET` (0xC3) opcodes at function start.
    - **Dynamic:** Monitor `VirtualProtect` for `PAGE_EXECUTE_READWRITE` on small regions (2-4 bytes) in `ntdll.dll`.
    - **Gap Analysis:** Correlate kernel-level image load callbacks (`PsSetLoadImageNotifyRoutine`) with ETW events. If kernel sees it but ETW doesn't, the process has patched ETW.
