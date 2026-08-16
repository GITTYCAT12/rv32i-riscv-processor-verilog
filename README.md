# 32-bit RV32I Pipelined RISC-V Processor

A 32-bit RV32I RISC-V processor designed and implemented in Verilog HDL using a 5-stage pipelined architecture.

## Project Overview

This project implements a 32-bit RISC-V processor based on the RV32I instruction set.

The processor follows a 5-stage pipeline:

1. Instruction Fetch (IF)
2. Instruction Decode (ID)
3. Execute (EX)
4. Memory Access (MEM)
5. Write Back (WB)

The design was developed using a modular RTL approach, with separate modules for the datapath, control logic, instruction and data memory, register file, ALU, branch handling, and pipeline registers.

The processor was developed and simulated using Xilinx Vivado and XSim.

## 5-Stage Pipeline

| Stage | Description |
|---|---|
| IF | Fetches instructions from instruction memory using the Program Counter |
| ID | Decodes the instruction and reads register operands |
| EX | Performs ALU operations and branch calculations |
| MEM | Performs load and store memory operations |
| WB | Writes the final result back to the register file |

Pipeline registers are used to transfer data and control signals between the different stages.

This allows multiple instructions to be processed simultaneously at different stages of the processor pipeline.

## Architecture

The processor consists of the following major blocks:

- Program Counter
- Instruction Memory
- IF/ID Pipeline Register
- Instruction Decoder
- Register File
- Immediate Generator
- Control Unit
- ID/EX Pipeline Register
- ALU Control
- ALU
- Branch Unit
- EX/MEM Pipeline Register
- Data Memory
- MEM/WB Pipeline Register
- PC Adder
- Next PC Multiplexer
- RISC-V Core
- Top-Level Module

## Supported Instructions

The current implementation supports the following RV32I instructions:

### R-Type

- ADD
- SUB
- AND
- OR

### I-Type

- ADDI
- LW

### S-Type

- SW

### B-Type

- BEQ

## RTL Design

| Module | Description |
|---|---|
| `riscv_top.v` | Top-level processor module |
| `riscv_core.v` | Main pipelined processor core |
| `instruction_memory.v` | Stores and provides instructions |
| `instruction_decoder.v` | Decodes RISC-V instruction fields |
| `immediate_generator.v` | Generates immediate values |
| `control_unit.v` | Generates processor control signals |
| `alu_control.v` | Generates ALU operation control |
| `alu.v` | Performs arithmetic and logical operations |
| `branch_unit.v` | Handles branch decision logic |
| `data_memory.v` | Handles load and store operations |
| `register_file.v` | Implements the 32-register register file |
| `program_counter.v` | Stores the current program counter |
| `pc_adder.v` | Calculates the sequential PC value |
| `next_pc_mux.v` | Selects the next PC value |

## Pipeline Data Flow

        ┌─────┐
        │  IF │
        └──┬──┘
           │
        IF/ID
           │
           ▼
        ┌─────┐
        │  ID │
        └──┬──┘
           │
        ID/EX
           │
           ▼
        ┌─────┐
        │  EX │
        └──┬──┘
           │
        EX/MEM
           │
           ▼
        ┌─────┐
        │ MEM │
        └──┬──┘
           │
        MEM/WB
           │
           ▼
        ┌─────┐
        │  WB │
        └─────┘
