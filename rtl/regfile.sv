module regfile (
    input  logic        clk,
    input  logic [4:0]  rs1,
    input  logic [4:0]  rs2,
    input  logic [4:0]  rd,
    input  logic [31:0] wr_data,
    input  logic        wr_en,
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data
);

    // 32 registers, each 32 bits wide
    logic [31:0] registers [31:0];

    // read data from registers 
    assign rs1_data = registers[rs1];
    assign rs2_data = registers[rs2];

    // write data to registers on the rising edge of the clock 
    always_ff @(posedge clk) begin 
        if(wr_en && rd != 5'b0) begin // dont write to x0
            registers[rd] <= wr_data;
        end 
    end 
endmodule 