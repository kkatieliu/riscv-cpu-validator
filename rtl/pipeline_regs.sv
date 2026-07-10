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
        id_pc <= 32'b0;~
        id_instruction <= 32'b0; 
    end else begin 
        id_pc <= if_pc;
        id_instruction <= if_instruction;
    end 
end

endmodule