# IPC Design

## Transport
- **Mechanism:** Windows Named Pipes.
- **Serialization:** Binary (Bincode) for efficiency.
- **Pattern:** Async Request-Response and Pub-Sub.

## Constraints
- Non-blocking communication.
- Bounded buffers to prevent memory explosion.
- Schema validation via `shared-models`.
