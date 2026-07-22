/// Composition safety mode (ADR-007).
///
/// - [scaffold]: in-memory / mock adapters are allowed (templates, tests).
/// - [production]: missing real adapters must throw at startup.
enum AfterBootstrapMode {
  scaffold,
  production,
}
