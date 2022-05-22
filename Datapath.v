`timescale 1ns/1ns
module Datapath (
    clk,
    rst,

    entry,
    load_init,
    updater,
    alu,
    cal_res,
    res_updater,
    poping,

    updated,
    done,
    backtrack,
    cal_update,
    result
);

    parameter size = 4;
    parameter stack_length = 128;
    parameter stack_digit = 7;
    parameter max_length = 15; // max entry number

    input clk,rst;
    input [size-1:0] entry;
    input load_init;
    input updater;
    input alu;
    input cal_res;
    input res_updater;
    input poping;

    output updated;
    output done;
    output backtrack;
    output cal_update;
    output [2*size-1:0] result;


    wire [size-1:0] n;
    wire [size-1:0] n_input;
    wire [size-1:0] multi2_idx;
    wire [size-1:0] multi3_idx;
    wire [size-1:0] rm2;
    wire [size-1:0] rm3;
    reg [size-1:0] stack [stack_length-1:0];
    reg [stack_length-1:0] stack_right;
    reg [max_length-1:0] visited;
    reg [2*size-1:0] value [max_length-1:0];
    wire [2*size-1:0] multres;
    wire [stack_digit-1:0] stack_size;
    wire [stack_digit-1:0] update_size;
    wire [stack_digit-1:0] updater_size;
    wire [stack_digit-1:0] size_input;
    wire d2, d3;
    wire bt2, bt3;
    wire [size-1:0] ass2, ass3,assM2, assM3;
    wire assW;

    reg [size-1:0] two = {{(size-2){1'b0}}, 2'b10};
    reg [size-1:0] three = {{(size-2){1'b0}}, 2'b11};

    assign value[0] = { {(2*size-1){1'b0}}, 1'b1};
    assign value[1] = { {(2*size-1){1'b0}}, 1'b1};

    // Initer entryIniter(.clk(clk), .rst(rst), .val(entry), .en(load_init), .outreg(n));
    // Initer entryInit(.clk(clk), .rst(rst), .val(entry), .en(load_init), .outreg(stack[0]));
    // Initer #(1) visitedInit(.clk(clk), .rst(rst), .val(1'd1), .en(load_init), .outreg(visited[0]));
    // Initer #(7) stackSizeInit(.clk(clk), .rst(rst), .val(7'd1), .en(load_init), .outreg(stack_size));

    AddSub nMinus1(.left(n), .right(4'd1), .addsub(2'd0), .res(multi2_idx));
    AddSub nMinus2(.left(n), .right(4'd2), .addsub(2'd0), .res(multi3_idx));

    AddSub #(7) addStackLen(.left(stack_size), .right(7'd4), .addsub(2'd1), .res(update_size));

    // Register #(7) sizeReg(.clk(clk), .rst(rst), .en(updater), .pi(update_size), .po(stack_size));

    Register #(4) assign2(.clk(clk), .rst(rst), .en(updater), .pi(two), .po(ass2));
    Register #(4) assign3(.clk(clk), .rst(rst), .en(updater), .pi(three), .po(ass3));
    Register #(4) assignM2(.clk(clk), .rst(rst), .en(updater), .pi(multi2_idx), .po(assM2));
    Register #(4) assignM3(.clk(clk), .rst(rst), .en(updater), .pi(multi3_idx), .po(assM3));
    Register #(1) assignWait(.clk(clk), .rst(rst), .en(updater), .pi(1'b1), .po(assW));
    // Register #(1) assignVisited(.clk(clk), .rst(rst), .en(updater), .pi(1'b1), .po(visited[multi2_idx]));

    always @(*) begin
        if (load_init) begin
            stack[0] = entry;
            visited[0] = 1'b1;
        end
        if (updater) begin
            visited[multi2_idx] <= 1'b1;
        end
        if (bt2) begin
            value[multi2_idx] <= {4'd0,rm2};
        end
        if (bt3) begin
            value[multi3_idx] <= {4'd0,rm3};
        end
        if (cal_res) begin
            value[n] <= multres;
        end
        stack[stack_size-7'd3] <= ass2 ;
        stack[stack_size-7'd1] <= ass3 ;
        stack[stack_size-7'd2] <= assM2 ;
        stack[stack_size] <= assM3 ;
        stack_right[stack_size] <= assW ;    
    end
    Register #(1) ackUpdate(.clk(clk), .rst(rst), .en(updater), .pi(1'b1), .po(updated));
    
    ALU #(4) alu2(.alu(alu), .twothree(1'b1), .n(n), .m2(multi2_idx), .m3(multi3_idx),
        .result(rm2), .done(d2), .backtrack(bt2));
    ALU #(4) alu3(.alu(alu), .twothree(1'b0), .n(n), .m2(multi2_idx), .m3(multi3_idx),
        .result(rm3), .done(d3), .backtrack(bt3));

    // Register #(8) updateVal2(.clk(clk), .rst(rst), .en(bt2), .pi({4'd0,rm2}), .po(value[multi2_idx]));
    // Register #(8) updateVal3(.clk(clk), .rst(rst), .en(bt3), .pi({4'd0,rm3}), .po(value[multi3_idx]));


    // assign done = d2 | d3 | (stack_size==1'b1) & (load_init==1'b0);
    assign done = (stack_size==1'b1) & (load_init==1'b0);
    assign backtrack = bt3 | bt2;

    assign multres = two*value[multi2_idx] + three*value[multi3_idx];

    // Register #(8) updateTable(.clk(clk), .rst(rst), .en(cal_res), .pi(multres), .po(value[n]));
    AddSub #(7) subStackLen(.left(stack_size), .right(7'd4), .addsub(2'd0), .res(updater_size));

    assign size_input = load_init ? 7'd1 : (cal_res ? updater_size : (updater ? update_size : 7'd0));

    Register #(7) sizeRegUpdate(.clk(clk), .rst(rst), .en(cal_res|load_init|updater), .pi(size_input), .po(stack_size));
    Register #(1) cal_Updater(.clk(clk), .rst(rst), .en(cal_res), .pi(1'b1), .po(cal_update));
    // Register backtrackMUT(.clk(clk), .rst(rst), .en(cal_res), .pi(multi2_idx+1'b1), .po(n));

    Register assignNewMult2(.clk(clk), .rst(rst), .en(poping), .pi(stack[stack_size]), .po(multi3_idx));
    Register assignNewMult3(.clk(clk), .rst(rst), .en(poping), .pi(stack[stack_size-2]), .po(multi2_idx));
    // Register assignNewN(.clk(clk), .rst(rst), .en(poping), .pi(stack[stack_size-2]+1'b1), .po(n));


    assign n_input = res_updater ? multi2_idx : ( poping ? stack[stack_size-2]+1'b1 : (cal_res ? multi2_idx+1'b1 : (load_init ? entry : n_input)));
    Register res_update_n(.clk(clk), .rst(rst), .en(res_updater|poping|cal_res|load_init), .pi(n_input), .po(n));

    assign result = value[entry];

endmodule