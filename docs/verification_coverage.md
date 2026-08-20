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

## Next verification targets

- Add directed tests for load/store instruction sequences.
- Add branch and control-flow regression cases.
- Add pipeline-oriented checks for forwarding and stall behavior.
- Add end-to-end instruction programs and waveform review.

The checklist is intentionally kept separate from RTL so verification scope can evolve without changing the processor implementation.
