`timescale 1ns/1ns
module ALU (
    alu,
    twothree,
    n,
    m2,
    m3,
    result,
    done,
    backtrack
);
    parameter size = 4;

    input alu;
    input twothree; // if is mult 2 vriable is one else it is mult 3 and zero
    input [size-1:0]n;
    input [size-1:0]m2;
    input [size-1:0]m3;

    output reg [size-1:0]result;
    output reg done;
    output reg backtrack;

    always @(alu) begin
        {result, done, backtrack} = 0;
        if(alu)
        begin
            if (n == {size{1'b0}} | n == {{(size-1){1'b0}}, 1'b1}) begin
                result = 4'd1;
                done = 1'b1;
            end
            else
            begin
                if (((m2 == 4'd0)|(m2 == 4'd1)) & twothree) begin
                    result = 4'd1;
                    backtrack = 1'b1;
                end 
                if (((m3 == 4'd0)|(m3 == 4'd1)) & (twothree == 1'b0)) begin
                    result = 4'd1;
                    backtrack = 1'b1;
                end 
            end
        end

    end

endmodule