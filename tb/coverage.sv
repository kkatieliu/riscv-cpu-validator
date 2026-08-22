
// Functional coverage: valid SystemVerilog, requires Questa/VCS
// Icarus Verilog does not support covergroup syntax
// Coverage tracks:
//   - cp_alu_op: which ALU operations were exercised (10 bins)
//   - cp_zero: whether zero flag was set/cleared
//   - cp_result_range: distribution of result values
//   - cx_op_zero: cross coverage of ALU op vs zero flag

// module coverage (
//     input logic        clk,
//     input logic [3:0]  alu_op,
//     input logic [31:0] operand_a,
//     input logic [31:0] operand_b,
//     input logic [31:0] result,
//     input logic        zero
// );

//     covergroup cpu_coverage @(posedge clk);
        
//         // Track which ALU operations are being tested
//         cp_alu_op: coverpoint alu_op {
//             bins add  = {4'b0000};
//             bins sub  = {4'b0001};
//             bins and_op = {4'b0010};
//             bins or_op  = {4'b0011};
//             bins xor_op = {4'b0100};
//             bins slt  = {4'b0101};
//             bins sltu = {4'b0110};
//             bins sll  = {4'b0111};
//             bins srl  = {4'b1000};
//             bins sra  = {4'b1001};
//         }

   

//     // Track zero flag behavior
//     cp_zero: coverpoint zero {
//         bins zero_set   = {1'b1};  // result was zero
//         bins zero_clear = {1'b0};  // result was nonzero
//     }

//     // Track result ranges
//     cp_result_range: coverpoint result {
//         bins zero        = {32'h0000_0000};
//         bins small       = {[32'h0000_0001 : 32'h0000_FFFF]};
//         bins medium      = {[32'h0001_0000 : 32'hFFFF_FFFF]};
//         bins max         = {32'hFFFF_FFFF};
//     }

//     // Cross coverage - did we test every ALU op AND see zero result?
//     cx_op_zero: cross cp_alu_op, cp_zero;

//     endgroup

//     // creating the new instance of the coverage group 
//     cpu_coverage cov_inst = new();

// endmodule