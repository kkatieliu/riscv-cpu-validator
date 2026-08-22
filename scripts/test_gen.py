## the code idea, instead of randomly writting instructions we can radnomly generate them using a python script 
## some using python and then test them against the RTL 

# Python script
#      generates random instructions
#      calculates expected results
#      writes to a .txt or .hex file

# SystemVerilog testbench
#      reads the file
#      feeds each instruction into the CPU
#      checks result against expected

import random
import struct

# Number of random tests to generate
NUM_TESTS = 20

# everything gets shifted before the or so there are no collosions 
def encode_rtype(funct7, rs2, rs1, funct3, rd, opcode):
    """Encode an R-type RISC-V instruction into 32 bits"""
    return (funct7 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode

def to_signed(val):
    if val >= 0x80000000:
        return val - 0x100000000
    return val

def generate_add(rs1, rs2, rs1_val, rs2_val):
    rd = random.randint(1, 31)  # only rd is random now
    
    instruction = encode_rtype(
        funct7 = 0b0000000,
        rs2    = rs2,
        rs1    = rs1,
        funct3 = 0b000,
        rd     = rd,
        opcode = 0b0110011
    )
    expected = (rs1_val + rs2_val) & 0xFFFFFFFF
    return instruction, expected, rs1, rs2, rd

def generate_sub(rs1, rs2, rs1_val, rs2_val):
    rd = random.randint(1, 31)
    instruction = encode_rtype(
        funct7 = 0b0100000, ## the ony diff is the fifth bit in the funct7 filed is 1 for sub 
        rs2    = rs2,
        rs1    = rs1,
        funct3 = 0b000,
        rd     = rd,
        opcode = 0b0110011
    )
    expected = (rs1_val - rs2_val) & 0xFFFFFFFF
    return instruction, expected, rs1, rs2, rd

def generate_and(rs1, rs2, rs1_val, rs2_val):
    rd = random.randint(1, 31)
    instruction = encode_rtype(
        funct7 = 0b0000000, 
        rs2    = rs2,
        rs1    = rs1,
        funct3 = 0b111,
        rd     = rd,
        opcode = 0b0110011
    )
    expected = (rs1_val & rs2_val) & 0xFFFFFFFF
    return instruction, expected, rs1, rs2, rd

def generate_or(rs1, rs2, rs1_val, rs2_val):
    rd = random.randint(1, 31)
    instruction = encode_rtype(
        funct7 = 0b0000000, 
        rs2    = rs2,
        rs1    = rs1,
        funct3 = 0b110,
        rd     = rd,
        opcode = 0b0110011
    )
    expected = (rs1_val | rs2_val) & 0xFFFFFFFF
    return instruction, expected, rs1, rs2, rd

def generate_xor(rs1, rs2, rs1_val, rs2_val):
    rd = random.randint(1, 31)
    instruction = encode_rtype(
        funct7 = 0b0000000, 
        rs2    = rs2,
        rs1    = rs1,
        funct3 = 0b100,
        rd     = rd,
        opcode = 0b0110011
    )
    expected = (rs1_val ^ rs2_val) & 0xFFFFFFFF
    return instruction, expected, rs1, rs2, rd

def generate_slt(rs1, rs2, rs1_val, rs2_val):
    rd = random.randint(1, 31)
    instruction = encode_rtype(
        funct7 = 0b0000000, 
        rs2    = rs2,
        rs1    = rs1,
        funct3 = 0b010,
        rd     = rd,
        opcode = 0b0110011
    )
    expected = 1 if (to_signed(rs1_val) < to_signed(rs2_val)) else 0
    return instruction, expected, rs1, rs2, rd

def generate_sltu(rs1, rs2, rs1_val, rs2_val):
    rd = random.randint(1, 31)
    instruction = encode_rtype(
        funct7 = 0b0000000, 
        rs2    = rs2,
        rs1    = rs1,
        funct3 = 0b011,
        rd     = rd,
        opcode = 0b0110011
    )
    expected = 1 if rs1_val < rs2_val else 0
    return instruction, expected, rs1, rs2, rd

def generate_sll(rs1, rs2, rs1_val, rs2_val):
    rd = random.randint(1, 31)
    instruction = encode_rtype(
        funct7 = 0b0000000, 
        rs2    = rs2,
        rs1    = rs1,
        funct3 = 0b001,
        rd     = rd,
        opcode = 0b0110011
    )
    expected = (rs1_val << (rs2_val & 0x1F)) & 0xFFFFFFFF
    return instruction, expected, rs1, rs2, rd

def generate_srl(rs1, rs2, rs1_val, rs2_val):
    rd = random.randint(1, 31)
    instruction = encode_rtype(
        funct7 = 0b0000000, 
        rs2    = rs2,
        rs1    = rs1,
        funct3 = 0b101,
        rd     = rd,
        opcode = 0b0110011
    )
    expected = (rs1_val >> (rs2_val & 0x1F)) & 0xFFFFFFFF
    return instruction, expected, rs1, rs2, rd

def generate_sra(rs1, rs2, rs1_val, rs2_val):
    rd = random.randint(1, 31)
    instruction = encode_rtype(
        funct7 = 0b0100000, 
        rs2    = rs2,
        rs1    = rs1,
        funct3 = 0b101,
        rd     = rd,
        opcode = 0b0110011
    )
    # arithmetic right shift: convert to signed first, shift, mask back
    signed_val = to_signed(rs1_val)
    expected = (signed_val >> (rs2_val & 0x1F)) & 0xFFFFFFFF
    return instruction, expected, rs1, rs2, rd


def main():
    # Random register values: these will be loaded into the register file
    reg_vals = [0] * 32  # all registers start at 0
    reg_vals[0] = 0      # x0 is always 0
    
    # Initialize some registers with random values
    for i in range(1, 32):
        reg_vals[i] = random.randint(0, 0xFFFFFFFF)
        
    initial_reg_vals = reg_vals.copy()
    
    # randomly generate which type of instruction to generate for each test 
    generators = [
        generate_add, generate_sub, generate_and, generate_or,
        generate_xor, generate_slt, generate_sltu, generate_sll,
        generate_srl, generate_sra
    ]
    
    tests = []
    for _ in range(NUM_TESTS):
        rs1 = random.randint(1, 31)
        rs2 = random.randint(1, 31)
        gen = random.choice(generators)
        instr, expected, rs1_idx, rs2_idx, rd = gen(
            rs1, rs2, reg_vals[rs1], reg_vals[rs2]
        )
        tests.append((instr, expected, rs1_idx, rs2_idx, rd))
        reg_vals[rd] = expected
    
    # Write to file ( but need to write to three seperate files since sv readmemh can only read one format at a time)
    # write the inital values of the registers to a file before they get changed my rd 
    with open("scripts/reg_init.txt", "w") as f:
        for i in range(32):
            f.write(f"{initial_reg_vals[i]:08x}\n")
    
    with open("scripts/instructions.txt", "w") as f:
        for instr, expected, rs1, rs2, rd in tests:
            f.write(f"{instr:08x}\n")
    
    with open("scripts/expected.txt", "w") as f:
        for instr, expected, rs1, rs2, rd in tests:
            f.write(f"{expected:08x}\n")
    
    print(f"Generated {NUM_TESTS} test vectors and put into scripts/test_vectors.txt")
    print(f"Initial reg[9] = {initial_reg_vals[9]:08x}")
    print(f"After test 0, reg[9] should be = {tests[0][1]:08x}")

if __name__ == "__main__":
    main()