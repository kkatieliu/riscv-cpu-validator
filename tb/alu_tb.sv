module alu_tb;
    logic [31:0] operand_a, operand_b, result;
    logic [3:0] alu_op;
    logic zero;

    // dut stands for device under test, which is the module that we are testing 
    // the thing before the parenthesis is the alu port name, and the thing inside is the wire name 
    alu dut ( 
        .operand_a(operand_a), 
        .operand_b(operand_b), 
        .alu_op(alu_op), 
        .result(result), 
        .zero(zero)
    );

    // set up an automated set of tests to run the ALU and check on the results 
    // minimizes the amount of manual work to check the results match what we want 
    int pass_count = 0;
    int fail_count = 0; 

    task automatic check (
        input string test_name, 
        input logic [31:0] got,
        input logic [31:0] expected 
    ); 
    begin 
        if (got == expected) begin
            $display("PASS: %s:", test_name);
            pass_count++;
        end else begin 
            $display("FAIL: %s: got %0d, expected %0d", test_name, got, expected);
            fail_count++;
        end 
    end 
    endtask
    
    


    initial begin 
        // unlike always comb, this block runs once starting at time zero 
        operand_a = 32'd10;
        operand_b = 32'd20; 
        alu_op = 4'b0000; // addition as established in the alu_sv module 
        #1; // this means wait until time unit 1, we dont want to go right away, we want to 
        // wait for the ALUs always_comb block to run and update the results 
        check("10 + 20", result, 32'd30); // check that the result is equal to 30 
       // $display("10 + 20 = %0d", result); // should print 30
        
        // the test is using the same wires as before, simply over riding the old values 
        operand_a = 32'd50;
        operand_b = 32'd30;
        alu_op = 4'b0001; // subtraction 
        #1; 
        check("50 - 30", result, 32'd20);
       // $display("50 - 30 = %0d", result);

        operand_a = 32'hF0F0_F0F0;
        operand_b = 32'h0F0F_0F0F;
        alu_op    = 4'b0010;
        #1;
        check("AND result", result, 32'h0000_0000);
        // $display("AND result = %h", result);

        operand_a = 32'hF0F0_F0F0;
        operand_b = 32'h0F0F_0F0F;
        alu_op    = 4'b0011;
        #1;
        check("OR result", result, 32'hFFFF_FFFF);
        // $display("OR result = %h", result);

        operand_a = 32'hAAAA_AAAA;
        operand_b = 32'hAAAA_AAAA;
        alu_op = 4'b0100; // this is the bitwise XOR operation 
        // the result of XORing two identicals numbers is always zero 
        #1;
        check("XOR result", result, 32'h0000_0000);
        // $display("XOR result = %h", result);

        operand_a = 32'd5;
        operand_b = 32'd10;
        alu_op = 4'b0101;
        #1;
        check("5 < 10 signed", result, 32'd1);
        // $display("5 < 10 signed = %0d", result);

        operand_a = 32'hFFFF_FFFF;
        operand_b = 32'd1;
        alu_op = 4'b0101;
        #1;
        check("-1 < 1 signed", result, 32'd1);
        // $display("-1 < 1 signed = %0d", result);

        operand_a = 32'hFFFF_FFFF;
        operand_b = 32'd1;
        alu_op = 4'b0110; // unsigned comparison 
        #1;
        check("0xFFFFFFFF < 1 unsigned", result, 32'd0);
        // $display("0xFFFFFFFF < 1 unsigned = %0d", result);

        operand_a = 32'h0000_0001; // shift the hex value 1 to the left by 4 binary bits 
        operand_b = 32'd4;
        alu_op = 4'b0111; // logical left shift 
        #1; 
        check("1 << 4", result, 32'h0000_0010);
        // $display("1 << 4 = %h", result); 

        operand_a = 32'h8000_0000; // shift the hex value 0x80000000 to the right by 4 binary bits
        operand_b = 32'd4;
        alu_op = 4'b1000; // logical right shift 
        #1; 
        check("0x80000000 >> 4", result, 32'h0800_0000);
        // $display("0x80000000 >> 4 = %h", result);

        operand_a = 32'h8000_0000; 
        operand_b = 32'd4; 
        alu_op = 4'b1001; // arithmetic right shift 
        #1; 
        check("0x80000000 >>> 4", result, 32'hF800_0000);
        // $display("0x80000000 >>> 4 = %h", result);

        $display("\nTest Summary: %0d passed, %0d failed", pass_count, fail_count);

    end 

endmodule 




