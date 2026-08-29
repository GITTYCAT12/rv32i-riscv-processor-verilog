# Next Verification Milestone

## Goal

Add a top-level smoke testbench that exercises the current supported instruction subset through the integrated 5-stage datapath.

## In scope

- Load a short instruction program covering `ADD`, `SUB`, `AND`, `OR`, `ADDI`, `LW`, `SW`, and `BEQ`.
- Verify program-counter progression and branch target behavior.
- Check register write-back and load/store effects at the architectural level.
- Capture a reproducible waveform or simulator transcript.

## Out of scope for this milestone

- Full RV32I compliance.
- Pipeline forwarding and hazard detection.
- Branch prediction or speculative execution.
- Formal verification or coverage claims.

## Acceptance criteria

- The testbench runs from a documented simulator command.
- Each supported instruction has at least one directed check.
- The testbench reports pass/fail status rather than relying only on waveform inspection.
- Any unsupported behavior is documented instead of silently ignored.
