`timescale 1ns/1ns
module Register (
    clk, 
    rst,
    en, 
    pi, 
    po 
    );
    parameter size = 4;
    
    input clk, rst, en;
    input [size-1:0] pi;
    output reg [size-1:0] po;

    always @(posedge clk) begin
        if (rst)
            po = 0;
        else if (en)
            po = pi;
    end
    
endmodule