# Processor Architecture

## Overview

The processor implements a 32-bit RISC-V RV32I subset using a five-stage in-order pipeline.

```text
PC → IF → IF/ID → ID → ID/EX → EX → EX/MEM → MEM → MEM/WB → WB
```

## Pipeline Stages

### IF — Instruction Fetch

The program counter selects the current instruction. The sequential next-PC path advances the processor to the next instruction address.

### ID — Instruction Decode

The instruction fields are decoded, control signals are generated, register operands are read, and the instruction immediate is constructed according to its encoding.

### EX — Execute

The ALU performs arithmetic and logical operations. Effective addresses are generated for memory instructions and branch comparison/target logic is handled here.

### MEM — Memory Access

Load and store instructions interact with the data-memory model. Other instructions pass their results through this stage.

### WB — Write Back

Results from the ALU or memory are written to the destination register when the instruction requires register write-back.

## Main RTL Groups

| Directory | Responsibility |
|---|---|
| `rtl/control` | Instruction decode and control generation |
| `rtl/core` | Processor integration and core-level logic |
| `rtl/datapath` | ALU, register file, PC and datapath elements |
| `rtl/memory` | Instruction and data memory |
| `tb` | Module-level verification testbenches |
| `sim` | Simulation programs and waveform locations |

## Instruction Flow

An instruction progresses through the five stages while later instructions occupy earlier stages. Pipeline registers preserve the required data and control information between stages.

The RTL decode/execute paths cover arithmetic and logical R/I-type operations, immediate shifts, `LW`, `SW`, all six standard conditional branch comparisons, `JAL`, `JALR`, `LUI`, and `AUIPC`. This is a partial implementation, not a claim of full RV32I compliance; see the repository README and verification coverage for the narrower tested subset.

## Current Data-Memory Model

The current `rtl/memory/data_memory.v` model contains 256 words of 32 bits each (1 KiB). It uses `address[9:2]` as the word index, performs writes on the rising clock edge, and provides a combinational read when `MemRead` is asserted.

This is a compact simulation model, not a complete RV32I memory subsystem. The low two address bits are ignored, addresses outside the 1 KiB indexed window alias into the same 256-word array, and the module does not implement byte enables, alignment traps, access faults, or a bus protocol. The current self-checking memory test therefore exercises aligned word accesses within the modeled range only.

## Verification Strategy

Verification is organized around focused testbenches for individual RTL blocks. This makes it possible to isolate functional issues in the ALU, control logic, memory, register file, immediate generation, PC logic, and branch logic before debugging complete processor behavior.

## Future Enhancements

- Expand the implemented RV32I instruction subset
- Expand directed architectural tests for forwarding, load-use stalls, and branch/jump flushing
- Validate instruction legality and memory alignment behavior
- Add broader automated regression and coverage reporting
- Add synthesis utilization and timing reports
