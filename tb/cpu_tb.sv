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

    // Storage for test vectors (will get filled after reading from the python script output)
    logic [31:0] reg_init [31:0];
    logic [31:0] test_instructions [19:0];
    logic [31:0] test_expected [19:0];

    

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

        // read the test vectors from the python script output files 
        $readmemh("scripts/reg_init.txt", reg_init);
        $readmemh("scripts/instructions.txt", test_instructions);
        $readmemh("scripts/expected.txt", test_expected);

       

        // Reset
        rst = 1;
        instruction = 32'b0;
        @(posedge clk);
        @(posedge clk);
        rst = 0;

        // Initialize all registers from file
        for (int i = 0; i < 32; i++) begin
            dut.regfile_inst.registers[i] = reg_init[i];
        end

        for (int i = 0; i < 5; i++) begin
            $display("reg[%0d] = %h", i, dut.regfile_inst.registers[i]);
        end

        // Run all the 20 tests
        for (int i = 0; i < 20; i++) begin
            instruction = test_instructions[i];
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            
            assert (result == test_expected[i])
                else $error("Test %0d FAILED: got %h expected %h", i, result, test_expected[i]);
            
            $display("Test %0d: instruction=%h result=%h expected=%h %s",
                i, test_instructions[i], result, test_expected[i],
                (result == test_expected[i]) ? "PASS" : "FAIL");
        end

        $display("All tests completed.");

        $finish;
    end
endmodule