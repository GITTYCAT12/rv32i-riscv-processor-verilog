# Pipeline Hazard Verification

This document defines the directed verification plan for data hazards in the 5-stage RV32I pipeline.

## Verification objective

Verify that dependent instructions receive the correct operand values when producer and consumer instructions overlap in the pipeline.

## Directed scenarios

| Scenario | Expected behavior | Status |
|---|---|---|
| ALU result used by immediately following instruction | Forward newest result or stall as required by implementation | Planned |
| ALU result used after one intervening instruction | Forward from the appropriate pipeline stage | Planned |
| Load result consumed by the next instruction | Insert required load-use stall, then use loaded value | Planned |
| Multiple consecutive consumers | Preserve correct value across dependent operations | Planned |
| Independent instructions around a dependency | No unnecessary stall | Planned |

## Waveform checks

For each directed test, inspect:

- Source and destination register IDs.
- Register-write enable signals.
- Pipeline-stage register values.
- Forwarding select/control signals, when implemented.
- Stall/enable controls, when implemented.
- Program-counter progression during a load-use dependency.

## Acceptance criteria

A hazard test passes only when the architectural result matches the expected value and the waveform demonstrates the intended forwarding or stall behavior.

## Implementation note

The current processor documentation identifies forwarding, hazard detection, and branch flushing as natural extensions. This verification plan deliberately separates the expected behavior from the RTL implementation so the tests can expose missing or incorrect hazard handling rather than assuming a particular microarchitecture.
