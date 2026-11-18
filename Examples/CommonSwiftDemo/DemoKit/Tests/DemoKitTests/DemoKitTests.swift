import StorybookCoverageScope
import Testing

/// Runs every screen test one at a time, since rendering a screen closes the one before. The coverage
/// tool maps each test from one run of the suite.
@MainActor
@Suite(.serialized, .storybookCoverage) struct DemoKitTests {}
