# Project Rules

## Testing Constraints

- **All tests must NOT use real API interfaces or external network calls.**
- Tests must use mocks, stubs, or local in-memory implementations only.
- Never invoke actual App Store Connect, AI provider, or any third-party endpoints in test code.
- Shared singletons used in tests (e.g., `NetworkRequestLogger.shared`) must be reset/cleared before and after each test to avoid cross-test state leakage.
