`timescale 1ns/1ns

module TB ();

    reg clk=1'b0, rst=1'b1, start=1'b0;
    reg [3:0] entry = 4'd15;
    wire load_init;
    wire updater;
    wire alu;
    wire cal_res;
    wire res_updater;
    wire poping;
    wire dont_check;
    wire push;
    wire updated;
    wire done;
    wire backtrack;
    wire cal_update;
    wire [20:0] result;

    Controller c(
    clk,
    rst,
    start,

    updated,
    done,
    backtrack,
    cal_update,

    load_init,
    updater,
    alu,
    cal_res,
    res_updater,
    poping,
    dont_check,
    push
    );

    Datapath dp(
    clk,
    rst,

    entry,
    load_init,
    updater,
    alu,
    cal_res,
    res_updater,
    poping,
    dont_check,
    push,

    updated,
    done,
    backtrack,
    cal_update,
    result
    );

    always #20 clk = ~clk;

    initial begin
        #40 rst = 1'b0; start = 1'b1;
        #100 start = 1'b0;
    	#20000 $stop;
    end

endmodule