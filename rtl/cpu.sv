module cpu (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] instruction,
    output logic [31:0] result
);
// cpu is the highest level module so it needs to speak to other parts of the system
// specifically it communicates with RAM to get the instruction and then stores the output result into RAM as well 
// rst is controlled externally 
// clk comes from the clock generator which is a dediacted circuits whos only job is to perfectly ossilate 0 and 1 
// the cpu doesnt need to have input and output bcuz these are internal connections , nothing outside the cpu sees them 
// q: how does cpu.sv talk to alu.sv? a: at compile time they all compile together 

    

    // IF/ID signals
    logic [31:0] if_pc;
    logic [31:0] id_pc;
    logic [31:0] id_instruction;

    // ID/EX signals
    logic [31:0] id_rs1_data;
    logic [31:0] id_rs2_data;
    logic [31:0] id_immediate;
    logic [4:0]  id_rd;
    logic [3:0]  id_alu_op;

    logic [4:0] id_rs1;
    logic [4:0] id_rs2;

    // EX signals
    logic [31:0] ex_rs1_data;
    logic [31:0] ex_rs2_data;
    logic [31:0] ex_immediate;
    logic [4:0]  ex_rd;
    logic [3:0]  ex_alu_op;
    logic [31:0] ex_pc;

    // ALU signals 
    logic zero;

    // in a real CPU the pc is generated itself 
    // in this case we will hard code it as 0 first so we can test it for now. 
    assign if_pc = 32'b0;

    if_id_reg if_id(
        .clk(clk), 
        .rst(rst), 
        .if_pc(if_pc), 
        .if_instruction(instruction), 
        .id_pc(id_pc), 
        .id_instruction(id_instruction)
    );

    id_ex_reg id_ex(
        .clk(clk),
        .rst(rst),
        .id_pc(id_pc),
        .id_rs1_data(id_rs1_data),
        .id_rs2_data(id_rs2_data),
        .id_immediate(id_immediate),
        .id_rd(id_rd),
        .id_alu_op(id_alu_op),
        .ex_pc(ex_pc),
        .ex_rs1_data(ex_rs1_data),
        .ex_rs2_data(ex_rs2_data),
        .ex_immediate(ex_immediate),
        .ex_rd(ex_rd),
        .ex_alu_op(ex_alu_op)
    );

    alu alu_inst(
        .operand_a(ex_rs1_data), 
        .operand_b(ex_rs2_data), 
        .alu_op(ex_alu_op), 
        .result(result), 
        .zero(zero)
    );

    decode decode_inst(
        .instruction(id_instruction),
        .rs1_data(id_rs1_data), 
        .rs2_data(id_rs2_data), 
        .rs1(id_rs1), 
        .rs2(id_rs2), 
        .rd(id_rd), 
        .immediate(id_immediate), 
        .alu_op(id_alu_op)
    );

endmodule