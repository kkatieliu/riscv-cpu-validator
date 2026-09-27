# Mini RISC-V CPU Validation Framework

A 3-stage pipelined RISC-V CPU implemented in SystemVerilog, 
paired with a full validation framework including self-checking 
testbenches, SVA assertions, functional coverage tracking, and 
a Python random test generator - mirroring industry CPU silicon 
verification workflows.

---

## Architecture

┌─────────┐     ┌──────────┐     ┌─────────────┐

instr →│ IF │────▶│ IF/ID │────▶│ ID/EX │
│ Fetch │ │ Reg │ │ Decode + │
└─────────┘ └──────────┘ │ Execute │
└──────┬──────┘
│
┌──────▼──────┐
│ EX/MEM │
│ Reg │
└──────┬──────┘
│
┌──────▼──────┐
│ MEM/WB │
│ Writeback │
└─────────────┘


**Supported instructions (RV32I subset):**
ADD, SUB, AND, OR, XOR, SLT, SLTU, SLL, SRL, SRA

---

## Project Structure

rtl/
├── alu.sv # 10-operation ALU (combinational)
├── decode.sv # Instruction decode — extracts rs1, rs2, rd, alu_op
├── pipeline_regs.sv # IF/ID, ID/EX, EX/MEM pipeline registers
├── regfile.sv # 32x32-bit register file (2 read ports, 1 write port)
└── cpu.sv # Top-level: wires all modules together

tb/
├── alu_tb.sv # Self-checking ALU testbench (15 directed tests)
├── cpu_tb.sv # Full CPU testbench with assertions + random tests
└── coverage.sv # Functional coverage groups (Questa/VCS compatible)

scripts/
└── test_gen.py # Python random RISC-V test generator + reference model

docs/
└── validation_plan.md # Feature list, test cases, pass/fail criteria


---

## How to Run

**Requirements:** Icarus Verilog 13.0+, Python 3.x

**ALU unit tests:**
```bash
iverilog -g2012 -o alu_tb rtl/alu.sv tb/alu_tb.sv
./alu_tb
```

**Generate random tests then run full CPU testbench:**
```bash
python3 scripts/test_gen.py
iverilog -g2012 -o cpu_tb rtl/alu.sv rtl/pipeline_regs.sv \
    rtl/decode.sv rtl/cpu.sv rtl/regfile.sv tb/cpu_tb.sv
./cpu_tb
```

**Expected output:**

ADD result = 30
SUB result = -10
AND result = 0
Test 0: ... PASS
Test 1: ... PASS
...
Test 19: ... PASS
All tests completed.


---

## Validation Framework

### Layer 1 — Directed Tests (alu_tb.sv)
15 hand-written test vectors covering all 10 ALU operations
with known inputs and expected outputs. Self-checking via
a `check()` task that tracks pass/fail counts.

### Layer 2 — Random Test Generator (scripts/test_gen.py)
Python script that:
- Initializes 32 registers with random 32-bit values
- Randomly selects one of 10 R-type operations per test
- Encodes valid 32-bit RISC-V binary instructions
- Computes expected results via an independent Python reference model
- Writes stimulus and expected outputs to files consumed by the testbench

20 random tests generated per run, all checked against the
Python reference model. **20/20 passing** across all operation types.

### Layer 3 — Functional Coverage (tb/coverage.sv)
Written in Questa/VCS-compatible SystemVerilog syntax:
- `cp_alu_op` — 10 bins, one per ALU operation
- `cp_zero` — tracks zero flag set vs cleared
- `cp_result_range` — result value distribution
- `cx_op_zero` — cross coverage: every operation × zero flag state

*Note: covergroup syntax requires Questa or VCS. 
Icarus Verilog is used for simulation; coverage file 
documents intended coverage model.*

### Assertions
- Immediate assertions on directed test results
- Concurrent SVA property for no-X propagation after reset
  (Questa/VCS compatible, documented in cpu_tb.sv)

---

## Bugs Found by the Framework

**Bug 1 — Golden Reference Model (Python)**
The test generator was writing final register state to the
initialization file instead of initial state. This caused
the hardware and reference model to start from different
register values, producing false failures on all 20 random tests.

*Fix:* Snapshot register state with `reg_vals.copy()` before
generating any tests.

**Bug 2 — Pipeline Writeback Timing**
The ALU result was connected combinationally to the register
file write port. Subsequent instructions reading the same
register saw stale values because the writeback hadn't been
clocked in yet.

*Fix:* Added `ex_mem_reg` pipeline register to properly
clock the ALU result before writeback, resolving the
data hazard.

---

## Known Limitations

- No hazard detection or forwarding — testbench inserts
  sufficient cycles between instructions
- PC is hardcoded to 0 (no branch/jump support yet)
- R-type instructions only (no load/store or immediate ops)
- Coverage report requires Questa/VCS (not Icarus)

---

## Skills Demonstrated

| Apple JD Requirement | This Project |
|---|---|
| CPU architecture: pipelines | 3-stage pipeline with registers |
| Logic design and verification | RTL + self-checking testbenches |
| SVA assertions | Immediate + concurrent assertions |
| Random test generator | scripts/test_gen.py |
| Functional coverage | covergroup with cross coverage |
| Python | Reference model + test generator |
| Assembly programming | RISC-V binary instruction encoding |
| Debug pipeline timing bugs | ex_mem_reg writeback fix |

