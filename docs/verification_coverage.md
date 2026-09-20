# Verification Coverage

This document tracks the verification scope of the RV32I processor and provides a concise checklist for extending regression coverage.

## Current verification areas

- ALU arithmetic and logical operations
- ALU control decoding
- Branch condition evaluation
- Control-unit decoding
- Immediate generation
- Instruction decoding
- Instruction memory access
- Data memory read/write behavior
- Program-counter sequencing
- Register-file read/write behavior
- Next-PC selection
- Top-level pipeline integration smoke test

## Coverage checklist

| Area | Testbench | Status |
|---|---|---|
| ALU | `tb/tb_alu.v` | Covered |
| ALU control | `tb/tb_alu_control.v` | Covered |
| Branch unit | `tb/tb_branch_unit.v` | Covered |
| Control unit | `tb/tb_control_unit.v` | Covered |
| Data memory | `tb/tb_data_memory.v` | Covered |
| Immediate generator | `tb/tb_immediate_generator.v` | Covered |
| Instruction decoder | `tb/tb_instruction_decoder.v` | Covered |
| Instruction memory | `tb/tb_instruction_memory.v` | Covered |
| Next-PC mux | `tb/tb_next_pc_mux.v` | Covered |
| PC adder | `tb/tb_pc_adder.v` | Covered |
| Program counter | `tb/tb_program_counter.v` | Covered |
| Register file | `tb/tb_register_file.v` | Covered |
| Top-level RV32I smoke test | `tb/tb_rv32i_smoke.v` | Implemented; simulation execution pending |

## Top-level smoke-test scope

The new integration test exercises the program already loaded in instruction memory and checks:

- `ADDI`, `ADD`, `SUB`, `AND`, and `OR` results through the register file.
- `SW` followed by `LW` using the processor data-memory path.
- A taken `BEQ` and the resulting flush of the younger `ADDI` instruction.
- Final write-back values for the directed program.

The testbench is self-checking and returns a non-zero simulator exit status when any expected value does not match.

## Next verification targets

- Execute the top-level smoke test in the documented simulator environment and record the console result.
- Add directed tests for additional load/store instruction sequences.
- Expand branch and control-flow regression cases.
- Add pipeline-oriented checks for forwarding and stall behavior.
- Add end-to-end instruction programs and waveform review.

The checklist is intentionally kept separate from RTL so verification scope can evolve without changing the processor implementation.
