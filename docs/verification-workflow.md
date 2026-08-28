# RTL Verification Workflow

This document defines the intended verification flow for the RV32I processor repository and keeps simulation evidence separate from synthesizable RTL.

## Scope

The current design implements a small RV32I instruction subset with a five-stage in-order pipeline:

`IF → ID → EX → MEM → WB`

The repository currently emphasizes module-level verification and waveform inspection. Full processor-level regression and hazard/forwarding verification remain future extensions.

## Recommended simulation sequence

1. **Compile one module-level testbench at a time**
   - Select the DUT and its corresponding testbench from `rtl/` and `tb/`.
   - Compile with the simulator's Verilog/SystemVerilog language setting matching the source files.
2. **Run the testbench to completion**
   - Check that the testbench reaches its intended end condition.
   - Treat compile warnings as review items rather than ignoring them.
3. **Inspect the waveform**
   - Confirm reset behavior, clock-to-clock state changes, and control/data alignment.
   - For sequential blocks, verify updates occur on the intended clock edge.
4. **Record the result**
   - Keep generated waveform/database files under `sim/waves/` or another ignored output directory.
   - Summarize any known limitations in the related documentation or issue.

## Minimum checks by block

| Block | Checks to perform |
|---|---|
| Program counter | Reset value, sequential increment, next-PC selection |
| Register file | Read-after-write behavior, x0 behavior, reset/initialization assumptions |
| Immediate generator | Correct sign extension for supported instruction formats |
| ALU / ALU control | Arithmetic, logical, comparison, and control decoding cases |
| Instruction memory | Address mapping and instruction word retrieval |
| Data memory | Read/write timing, byte/word assumptions, and reset state |
| Branch unit | Taken/not-taken decision and target calculation |
| Pipeline registers | Reset behavior and control/data propagation between stages |
| Core integration | Instruction sequencing and write-back visibility |

## Evidence expected in a professional review

For each verified block, capture:

- the testbench name;
- the simulator used;
- the test scenarios exercised;
- the expected-versus-observed result;
- one representative waveform or console transcript;
- any limitation that is not yet covered.

This makes the project easier to reproduce and prevents a waveform screenshot from being presented without the corresponding test intent.

## Current limitations

The project README identifies the following as future extensions: additional RV32I instructions, forwarding, hazard detection, branch flushing, automated regression, synthesis, and static-timing reporting. Verification claims should remain limited to the current RTL and testbench coverage until those features are implemented and demonstrated.
