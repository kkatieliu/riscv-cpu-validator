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

    // SVA concurrent assertion: valid SystemVerilog, requires Questa/VCS
    // Icarus Verilog does not support concurrent assertions
    // property no_x_after_reset;
    //     @(posedge clk) ($fell(rst)) |-> ##3 !$isunknown(result);
    // endproperty
    // assert property (no_x_after_reset)
    //     else $error("Result is X after reset was released!");

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
        
        $display("ADD result = %0d", result);
        // first SVA assertsion, an immediate one to check if the value we got was expected 
        assert (result == 32'd30)
            else $error("FAIL: ADD x3,x1,x2 expected 30 got %0d", result);


        // SUB x3, x1, x2  (10 - 20)
        instruction = 32'b0100000_00010_00001_000_00011_0110011;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        $display("SUB result = %0d", $signed(result));
        assert (result == -32'd10)
            else $error("FAIL: SUB expected -10 got %0d", result);

        instruction = 32'b0000000_00010_00001_111_00011_0110011; // AND x3, x1, x2
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        $display("AND result = %0d", result);
        assert(result == 32'd0)
            else $error("FAIL: AND expected 0 got %0d", result);



        $finish;
    end
endmodule