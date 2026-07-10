module alu (
    input logic [31:0] operand_a, 
    input logic [31:0] operand_b, 
    input logic [3:0] alu_op, 
    output logic [31:0] result, 
    output logic       zero
);

    always_comb begin // this runs continuously and updates the output whenever the inputs change
        case(alu_op)
            4'b0000: result = operand_a + operand_b; // addition 
            4'b0001: result = operand_a - operand_b; // subtraction 
            4'b0010: result = operand_a & operand_b; // bitwise AND 
            4'b0011: result = operand_a | operand_b; // bitwise OR 
            4'b0100: result = operand_a ^ operand_b; // bitwise XOR
            4'b0101: result = ($signed(operand_a) < $signed(operand_b)) ? 32'b1 : 32'b0; // set result to be 1 if a < b else 0, signed comparison
            4'b0110: result = (operand_a < operand_b) ? 32'b1 : 32'b0; // set result to be 1 if a < b else 0, unsigned comparison
            // shifting left is the same as multiplying by 2, shifting right is the same as dividing by 2
            4'b0111: result = operand_a << operand_b[4:0]; // logical left shift 
            4'b1000: result = operand_a >> operand_b[4:0]; // logical right shift 
            4'b1001: result = $signed(operand_a) >>> operand_b[4:0]; // arithmetic right shift 
            default: result = 32'hBAAD_C0DE;
        endcase 

    end 

    assign zero = (result == 32'b0);

endmodule