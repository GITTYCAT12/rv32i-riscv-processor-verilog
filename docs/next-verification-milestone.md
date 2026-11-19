# Next Verification Milestone

## Goal

Expand directed verification of the current five-stage RV32I pipeline, with emphasis on forwarding and hazard behavior that is present in RTL but not yet covered across all operand and instruction classes.

## In scope

- Verify EX/MEM forwarding for back-to-back ALU dependencies.
- Verify MEM/WB forwarding when one independent instruction separates producer and consumer.
- Extend load-use checks beyond the current immediate LW-to-BEQ case.
- Add store-data forwarding checks.
- Add branch and JALR dependencies on recently produced register values.
- Check that independent instructions do not cause unnecessary stalls.
- Keep each scenario self-checking at both the pipeline-control and architectural-result levels.

## Out of scope for this milestone

- Full RV32I compliance.
- Branch prediction or speculative execution.
- Formal verification.
- Claims of complete hazard coverage from a finite directed test suite.

## Current evidence

The Icarus top-level smoke test currently checks:
- Two adjacent ALU dependencies using EX/MEM forwarding.
- One ALU dependency after an independent instruction using MEM/WB forwarding.
- One immediate load-to-branch dependency with an EX-stage and a MEM-stage stall.
- A taken BEQ flush and selected reserved instruction encodings.

See [pipeline hazard verification](pipeline_hazard_verification.md) for exact scenarios and remaining gaps.

## Acceptance criteria

- Every new dependency scenario has an explicit expected operand and architectural result.
- Forwarding/stall source conditions are asserted rather than inferred only from final register values.
- The testbench runs through the documented Icarus command and is included in GitHub Actions.
- Any uncovered instruction class or hazard mode remains marked as planned or partial.
