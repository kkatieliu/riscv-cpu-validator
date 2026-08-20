`timescale 1ns/1ps
// for the testbench it uses an internal counter but this is saying a single time unit is 1ns and the precision is 1ps

module cpu_tb;

    logic clk;
    logic rst;
    logic [31:0] instruction;
    logic [31:0] result;


    // Clock generation - toggle every 5 time units
    initial clk = 0;
    always #5 clk = ~clk;


    cpu dut(
        .clk(clk), 
        .rst(rst), 
        .instruction(instruction), 
        .result(result)
    );

    initial begin
        // Initialize
        rst = 1;
        instruction = 32'b0;
        
        // Hold reset for 2 clock cycles
        @(posedge clk);
        @(posedge clk);
        
        // Release reset
        rst = 0;
        // Initialize registers via writeback
        // Write 10 into x1
        dut.regfile_inst.registers[1] = 32'd10;
        dut.regfile_inst.registers[2] = 32'd20;
        
        // Feed an ADD instruction
        // ADD x3, x1, x2 in RISC-V binary encoding
        instruction = 32'b0000000_00010_00001_000_00011_0110011;
        
        // Wait for pipeline to produce result (3 cycles)
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        $display("Result = %0d", result);
        $finish;
    end
endmodule