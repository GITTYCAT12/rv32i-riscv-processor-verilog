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

The current implementation supports `ADD`, `SUB`, `AND`, `OR`, `ADDI`, `LW`, `SW`, and `BEQ`.

## Verification Strategy

Verification is organized around focused testbenches for individual RTL blocks. This makes it possible to isolate functional issues in the ALU, control logic, memory, register file, immediate generation, PC logic, and branch logic before debugging complete processor behavior.

## Future Enhancements

- Expand the implemented RV32I instruction subset
- Add data forwarding paths
- Add load-use hazard detection and pipeline stalls
- Add branch flushing and more complete control-hazard handling
- Add automated regression tests
- Add synthesis utilization and timing reports
