module if_id_reg(
    input logic clk, 
    input logic rst, 
    input logic [31:0] if_pc, 
    input logic [31:0] if_instruction, 
    output logic [31:0] id_pc, 
    output logic [31:0] id_instruction
);

// always ff is always comb but for sequential logic, ff is flip flop 
// always triggered on the positive edge of the clock 
// rst is the reset, if this is 1 set everything to zero 

always_ff @(posedge clk) begin
    if (rst) begin 
        id_pc <= 32'b0;
        id_instruction <= 32'b0; 
    end else begin 
        id_pc <= if_pc;
        id_instruction <= if_instruction;
    end 
end


endmodule

// id immidiate is for if we want to add a constant value 
// there are 32 registers x0 to x31! completely seperate from RAM, but also a storage space for data
module id_ex_reg (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] id_pc,
    input  logic [31:0] id_rs1_data,
    input  logic [31:0] id_rs2_data,
    input  logic [31:0] id_immediate,
    input  logic [4:0]  id_rd,
    input  logic [3:0]  id_alu_op,
    output logic [31:0] ex_pc,
    output logic [31:0] ex_rs1_data,
    output logic [31:0] ex_rs2_data,
    output logic [31:0] ex_immediate,
    output logic [4:0]  ex_rd,
    output logic [3:0]  ex_alu_op
);

always_ff @(posedge clk) begin
    if (rst) begin 
        ex_pc <= 32'b0;
        ex_rs1_data <= 32'b0;
        ex_rs2_data <= 32'b0;
        ex_immediate <= 32'b0;
        ex_rd <= 5'b0;
        ex_alu_op <= 4'b0;
    end else begin
        ex_pc <= id_pc;
        ex_rs1_data <= id_rs1_data;
        ex_rs2_data <= id_rs2_data;
        ex_immediate <= id_immediate;
        ex_rd <= id_rd;
        ex_alu_op <= id_alu_op;
    end 
end 

endmodule 