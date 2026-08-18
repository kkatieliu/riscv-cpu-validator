module decode (
    input  logic [31:0] instruction,
    input  logic [31:0] rs1_data,
    input  logic [31:0] rs2_data,
    output logic [4:0]  rs1,
    output logic [4:0]  rs2,
    output logic [4:0]  rd,
    output logic [31:0] immediate,
    output logic [3:0]  alu_op
);

// Extract fields directly from instruction bits
// within the instrcution it holds the of which register is being used 

// full break down
// 31-25    24-20  19-15  14-12  11-7   6-0
// funct7   rs2    rs1    funct3  rd    opcode
// 7 bits   5bits  5bits  3bits  5bits  7bits
    assign rs1     = instruction[19:15];
    assign rs2     = instruction[24:20];
    assign rd      = instruction[11:7];

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    assign opcode = instruction[6:0];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];

    always_comb begin
        case (opcode)
            7'b0110011: begin // R-type (ADD, SUB, AND, OR, XOR, shifts)
                case (funct3)
                    3'b000: alu_op = (funct7[5]) ? 4'b0001 : 4'b0000; // SUB or ADD
                    3'b111: alu_op = 4'b0010; // AND
                    3'b110: alu_op = 4'b0011; // OR
                    3'b100: alu_op = 4'b0100; // XOR
                    3'b010: alu_op = 4'b0101; // SLT
                    3'b011: alu_op = 4'b0110; // SLTU
                    3'b001: alu_op = 4'b0111; // SLL
                    3'b101: alu_op = (funct7[5]) ? 4'b1001 : 4'b1000; // SRA or SRL
                    default: alu_op = 4'hF;
                endcase
            end
            default: alu_op = 4'hF;
        endcase

        // For the load, rs1 is a base address, immediate is an offset, and rd is where the loaded value goes.
        // The immediate lets you access nearby memory locations without loading a new address every time.
        // * this initally confused me bcuz LW its changing a memory to a value,
        // x1 was an adress and x3 is now a value, esentially * defrencing a pointer similar to how it works in C!
        // store is the same thing but now you put the value that is in one spot and writting to a memory in RAM 
        
        case (opcode)
            7'b0010011: // I-type (ADDI etc)
                immediate = {{20{instruction[31]}}, instruction[30:20]};
            7'b0000011: // Load
                immediate = {{20{instruction[31]}}, instruction[30:20]};
            7'b0100011: // Store
                immediate = {{20{instruction[31]}}, instruction[30:25], instruction[11:7]};
            default: immediate = 32'b0;
        endcase

    end

endmodule 