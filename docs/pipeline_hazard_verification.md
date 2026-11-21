# Pipeline Hazard Verification

This document defines the directed verification plan for data hazards in the 5-stage RV32I pipeline.

## Verification objective

Verify that dependent instructions receive the correct operand values when producer and consumer instructions overlap in the pipeline.

## Directed scenarios

| Scenario | Expected behavior | Status |
|---|---|---|
| ALU result used by immediately following instruction | Forward newest result from EX/MEM | Tested for two consecutive ADDI dependencies |
| ALU result used after one independent instruction | Forward from MEM/WB when the newer EX/MEM destination does not match | Tested for ADDI x19 → ADDI x21 |
| Load result consumed by the next instruction | Insert required load-use stall, then use loaded value | Partial: top-level LW x7 → BEQ x3,x7 checks one EX-stage and one MEM-stage stall |
| Multiple consecutive consumers | Preserve correct value across dependent operations | Partial: two adjacent consumers are covered; broader consumer combinations remain planned |
| Independent instructions around a dependency | No unnecessary stall | Planned |
| Store-data dependency | Forward the newest source value into the store path | Tested for immediate ADDI x23 → SW x23 |
| Branch operand dependency on an ALU result | Forward the newest value before branch comparison | Planned |

## Current automated ALU forwarding check

The top-level Icarus smoke program includes three directed ALU dependencies:

1. ADDI x18,x0,7 followed immediately by ADDI x19,x18,3; the test checks EX/MEM forwarding of 7.
2. ADDI x19,x18,3 followed immediately by ADDI x20,x19,5; the test checks EX/MEM forwarding of 10.
3. ADDI x19,x18,3, one independent ADDI, then ADDI x21,x19,2; the test checks MEM/WB forwarding of 10 while a different destination is in EX/MEM.

The test samples the forwarding operand and the corresponding pipeline-register write-enable/destination signals at the falling edge, after rising-edge pipeline updates. It also checks the final architectural register values.

These cases validate the two forwarding sources for the tested ALU-source operand. A separate immediate ADDI-to-SW case checks EX/MEM forwarding of operand B into the store-data pipeline register and the final memory word. This does not establish exhaustive forwarding coverage for all stores, branches, JALR, or every instruction class.

## Current automated store-data check

The top-level Icarus smoke program executes `ADDI x23,x0,85` immediately followed by `SW x23,4(x0)`. The test checks that:

- The store's EX-stage `ex_forward_b` receives 85 from the preceding instruction in EX/MEM.
- The EX/MEM store-data register captures the forwarded value.
- The write reaches data-memory word 1 at byte address 4.
- The producer/consumer overlap incurs no load-use stall.

This is one directed ALU-to-store dependency. It does not verify store-data forwarding from MEM/WB or every store/producer combination.

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
- Forwarding operand values and source-stage match conditions.
- Stall/enable controls, when implemented.
- Program-counter progression during a load-use dependency.

## Acceptance criteria

A hazard test passes only when the architectural result matches the expected value and the waveform demonstrates the intended forwarding or stall behavior.

## Implementation note

The current RTL contains EX/MEM and MEM/WB forwarding, load-use interlock logic, and EX-stage branch/jump flushing. This document tracks the directed tests still needed to verify those mechanisms; the presence of RTL logic is not itself evidence that every hazard case is correct.
