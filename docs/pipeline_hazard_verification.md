# Pipeline Hazard Verification

This document defines the directed verification plan for data hazards in the 5-stage RV32I pipeline.

## Verification objective

Verify that dependent instructions receive the correct operand values when producer and consumer instructions overlap in the pipeline.

## Directed scenarios

| Scenario | Expected behavior | Status |
|---|---|---|
| ALU result used by immediately following instruction | Forward newest result or stall as required by implementation | Planned |
| ALU result used after one intervening instruction | Forward from the appropriate pipeline stage | Planned |
| Load result consumed by the next instruction | Insert required load-use stall, then use loaded value | Partial: top-level LW x7 → BEQ x3,x7 checks one EX-stage and one MEM-stage stall |
| Multiple consecutive consumers | Preserve correct value across dependent operations | Planned |
| Independent instructions around a dependency | No unnecessary stall | Planned |

## Current automated load-use check

The top-level Icarus smoke program stores a value, loads it into x7, and immediately uses x7 in a taken BEQ. The test checks the architectural branch outcome and also asserts that:

- The PC and IF/ID instruction remain stable during each load-use stall.
- ID/EX receives a bubble on each stall cycle.
- Exactly one EX-stage and one MEM-stage load-use hazard cycle are observed.

This is one directed load-to-branch case, not exhaustive coverage of load consumers or all pipeline hazard combinations.

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

The current RTL contains EX/MEM and MEM/WB forwarding, load-use interlock logic, and EX-stage branch/jump flushing. This document tracks the directed tests still needed to verify those mechanisms; the presence of RTL logic is not itself evidence that every hazard case is correct.
