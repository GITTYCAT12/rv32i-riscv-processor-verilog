# 32-bit RV32I Pipelined RISC-V Processor

A modular **32-bit RISC-V RV32I processor** implemented in **Verilog HDL** using a classic **5-stage pipeline: IF → ID → EX → MEM → WB**.

The repository is structured as an RTL-focused hardware design project, separating processor RTL, verification, simulation assets, documentation, and constraints.

## Highlights

- 32-bit RV32I architecture
- 5-stage in-order pipeline
- Modular synthesizable RTL organization
- Dedicated control and datapath logic
- Pipeline registers between stages
- Separate instruction and data memory models
- Module-level Verilog testbenches
- Waveform-oriented RTL verification workflow

## Supported Instructions

| Type | Instructions |
|---|---|
| R-Type | `ADD`, `SUB`, `AND`, `OR` |
| I-Type | `ADDI`, `LW` |
| S-Type | `SW` |
| B-Type | `BEQ` |

> This table reflects the current implementation and does not represent the complete RV32I specification.

## Architecture

```text
                 ┌───────────────┐
                 │      IF       │  Instruction Fetch
                 └───────┬───────┘
                         │
                      IF/ID
                         │
                         ▼
                 ┌───────────────┐
                 │      ID       │  Instruction Decode
                 └───────┬───────┘
                         │
                      ID/EX
                         │
                         ▼
                 ┌───────────────┐
                 │      EX       │  ALU / Branch
                 └───────┬───────┘
                         │
                     EX/MEM
                         │
                         ▼
                 ┌───────────────┐
                 │     MEM       │  Data Memory
                 └───────┬───────┘
                         │
                     MEM/WB
                         │
                         ▼
                 ┌───────────────┐
                 │      WB       │  Register Write Back
                 └───────────────┘
```

## Repository Structure

```text
rv32i-riscv-processor-verilog/
├── rtl/
│   ├── control/       # Control and decode logic
│   ├── core/          # Core and top-level integration
│   ├── datapath/      # ALU, register file, PC and datapath blocks
│   └── memory/        # Instruction and data memory
├── tb/                # Module-level Verilog testbenches
├── sim/
│   ├── programs/      # Simulation programs / instruction data
│   └── waves/         # Waveform output location
├── docs/              # Design documentation
├── constraints/       # Hardware constraint files
├── README.md
└── .gitignore
```

## RTL Blocks

The processor is composed from reusable blocks including:

- Program Counter
- Instruction Memory
- Instruction Decoder
- Register File
- Immediate Generator
- Control Unit
- ALU Control
- ALU
- Branch Unit
- Data Memory
- PC Adder
- Next-PC Multiplexer
- IF/ID, ID/EX, EX/MEM and MEM/WB pipeline registers
- RISC-V core and top-level integration

## Verification

The `tb/` directory contains focused testbenches for major components such as the ALU, ALU control, branch unit, control unit, memories, immediate generator, instruction decoder, PC logic, and register file.

Simulation artifacts are intentionally kept separate from RTL so the design remains easy to navigate and review.

### Simulation Environment

The project was developed and simulated using **Xilinx Vivado / XSim**. The RTL is written in Verilog HDL and the testbench structure supports waveform-based debugging.

## Design Flow

1. Fetch the instruction using the program counter.
2. Decode the instruction and generate control signals.
3. Read source operands and generate the required immediate.
4. Execute arithmetic, logical, address-generation, or branch operations.
5. Perform load/store memory access where required.
6. Write the final result back to the register file.
7. Transfer stage information through the pipeline registers.

## Current Scope

This repository focuses on a small RV32I subset and its modular RTL implementation and verification. Natural next extensions include additional RV32I instructions, forwarding, hazard detection, branch flushing, automated regression testing, and synthesis/STA reporting.

## Tools

- **HDL:** Verilog
- **ISA:** RISC-V RV32I
- **Simulation:** Xilinx Vivado / XSim
- **Verification:** Verilog testbenches and waveform inspection

## Author

**GITTYCAT12**

Hardware-design portfolio project focused on RTL design, processor microarchitecture, and digital verification.

## License

Released under the MIT License. See [`LICENSE`](LICENSE) for details.
