# Verification Evidence Template

Use this template when adding or updating a verification result. Keep the recorded result tied to a specific simulator run and commit so that claims remain reproducible.

## Test identification

- Testbench:
- DUT / module:
- Commit:
- Simulator and version:
- Date:

## Intent

Describe the behavior being checked in one or two sentences.

## Stimulus

List the inputs, instruction sequence, reset behavior, and any relevant memory initialization.

## Expected behavior

Record the expected architectural or signal-level result before running the simulation.

## Observed behavior

Record the actual result, including any important cycle counts or waveform observations.

## Result

- [ ] PASS
- [ ] FAIL
- [ ] BLOCKED

## Evidence

- Console output:
- Waveform file or screenshot:
- Relevant signal window / cycle range:

## Notes and limitations

Document assumptions, known limitations, unsupported instructions, and any follow-up issue required. Do not describe a test as passing unless the result was actually observed in simulation.
