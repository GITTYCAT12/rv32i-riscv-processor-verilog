# Verification Coverage

This document tracks the verification scope of the RV32I processor and provides a concise checklist for extending regression coverage.

## Current verification areas

- ALU arithmetic and logical operations
- ALU control decoding
- Branch condition evaluation
- Control-unit decoding
- Immediate generation, including signed I/S/B encodings
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
| ALU | `tb/tb_alu.v` | Module testbench present |
| ALU control | `tb/tb_alu_control.v` | Module testbench present |
| Branch unit | `tb/tb_branch_unit.v` | Module testbench present |
| Control unit | `tb/tb_control_unit.v` | Module testbench present |
| Data memory | `tb/tb_data_memory.v` | Module testbench present |
| Immediate generator | `tb/tb_immediate_generator.v` | Self-checking signed I/S/B cases in CI |
| Instruction decoder | `tb/tb_instruction_decoder.v` | Self-checking CI test |
| Instruction memory | `tb/tb_instruction_memory.v` | Module testbench present |
| Next-PC mux | `tb/tb_next_pc_mux.v` | Self-checking sequential/target selection test in CI |
| PC adder | `tb/tb_pc_adder.v` | Module testbench present |
| Program counter | `tb/tb_program_counter.v` | Module testbench present |
| Register file | `tb/tb_register_file.v` | Module testbench present |
| Top-level RV32I smoke test | `tb/tb_rv32i_smoke.v` | Self-checking Icarus CI regression |

## Top-level smoke-test scope

The integration test exercises the program loaded in instruction memory and checks:

- `ADDI`, `ADD`, `SUB`, `AND`, and `OR` results through the register file.
- `SW` followed by `LW` using the processor data-memory path.
- A taken `BEQ` and the resulting flush of the younger `ADDI` instruction.
- Legal `SLLI`, `SRLI`, and `SRAI` immediate-shift results.
- Reserved shift-immediate encodings follow the core's documented no-write policy.
- A reserved JALR `funct3` encoding neither redirects the PC nor writes its link register; the following sequential instruction still executes.
- Selected EX/MEM and MEM/WB forwarding cases for ALU operands, store data, and BEQ comparison operands.
- Final write-back values for the directed program.
- An unsupported R-type `funct7` encoding does not commit a destination-register write.

The testbench is self-checking and returns a non-zero simulator exit status when any expected value does not match. The top-level regression has passed in [GitHub Actions run 40346494088](https://github.com/GITTYCAT12/rv32i-riscv-processor-verilog/actions/runs/40346494088).

## Immediate-generator regression scope

The immediate-generator test now checks positive and negative I-type values, the minimum signed I-type immediate, positive and negative S-type offsets, positive and negative B-type offsets, and the default immediate type. These checks are run with Icarus Verilog by `.github/workflows/rtl-smoke.yml`.

## Next verification targets

- Add directed tests for additional load/store instruction sequences and byte/halfword semantics if implemented.
- Expand branch coverage beyond the current BEQ forwarding cases, including not-taken and other comparison conditions.
- Add JALR dependency/target tests and additional control-flow flush cases.
- Add end-to-end instruction programs and waveform review.

The checklist distinguishes the self-checking tests currently executed in CI from module testbenches that are present but are not yet part of the automated workflow.
