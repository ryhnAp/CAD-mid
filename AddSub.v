`timescale 1ns/1ns
module AddSub (
    left, 
    right, 
    addsub,
    res 
    );
    parameter size = 4;
    
    input [size-1:0] left, right;
    input [1:0] addsub;
    output reg [size-1:0] res;

    always @(left, right, addsub) begin
        case (addsub)
            2'd1: res = (left + right);
            2'd0: res = (left - right);
            2'd2: res = res;
        endcase
    end


endmodule