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
    dont_check,

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
    input dont_check;

    output updated;
    output done;
    output backtrack;
    output cal_update;
    output [2*size-1:0] result;


    wire [size-1:0] n;
    wire [size-1:0] n_input;
    wire [size-1:0] multi2_idx;
    wire [size-1:0] multi3_idx;    
    wire [size-1:0] multi2_idx_;
    wire [size-1:0] multi3_idx_;
    wire [size-1:0] multi2_in;
    wire [size-1:0] multi3_in;
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

    AddSub nMinus1(.left(n), .right(4'd1), .addsub(2'd0), .res(multi2_idx_));
    AddSub nMinus2(.left(n), .right(4'd2), .addsub(2'd0), .res(multi3_idx_));

    AddSub #(7) addStackLen(.left(stack_size), .right(7'd4), .addsub(2'd1), .res(update_size));

    Register #(4) assign2(.clk(clk), .rst(rst), .en(updater), .pi(two), .po(ass2));
    Register #(4) assign3(.clk(clk), .rst(rst), .en(updater), .pi(three), .po(ass3));
    Register #(4) assignM2(.clk(clk), .rst(rst), .en(updater), .pi(multi2_idx), .po(assM2));
    Register #(4) assignM3(.clk(clk), .rst(rst), .en(updater), .pi(multi3_idx), .po(assM3));
    Register #(1) assignWait(.clk(clk), .rst(rst), .en(updater), .pi(1'b1), .po(assW));

    always @(*) begin
        if (load_init) begin
            stack[1] = entry;
            visited[entry] = 1'b1;
        end
        else begin
            if (updater) begin
                visited[multi2_idx] <= 1'b1;
            end
            if (alu) begin
                stack[stack_size-7'd3] <= ass2 ;
                stack[stack_size-7'd1] <= ass3 ;
                stack[stack_size-7'd2] <= assM2 ;
                stack[stack_size] <= assM3 ;
                stack_right[stack_size] <= assW ;            
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
        end
    end
    Register #(1) ackUpdate(.clk(clk), .rst(rst), .en(updater), .pi(1'b1), .po(updated));
    
    ALU #(4) alu2(.alu(alu), .twothree(1'b1), .n(n), .m2(multi2_idx), .m3(multi3_idx),
        .result(rm2), .done(d2), .backtrack(bt2));
    ALU #(4) alu3(.alu(alu), .twothree(1'b0), .n(n), .m2(multi2_idx), .m3(multi3_idx),
        .result(rm3), .done(d3), .backtrack(bt3));

    assign done = (dont_check == 1'b0) & (stack_size==1'b1) & (load_init==1'b0);
    assign backtrack = bt3 | bt2;

    assign multres = two*value[multi2_idx] + three*value[multi3_idx];

    AddSub #(7) subStackLen(.left(stack_size), .right(7'd4), .addsub(2'd0), .res(updater_size));

    assign size_input = load_init ? 7'd1 : (cal_res ? updater_size : (updater ? update_size : 7'd0));

    Register #(7) sizeRegUpdate(.clk(clk), .rst(rst), .en(cal_res|load_init|updater), .pi(size_input), .po(stack_size));
    Register #(1) cal_Updater(.clk(clk), .rst(rst), .en(cal_res), .pi(1'b1), .po(cal_update));

    assign multi3_in = poping ? stack[stack_size] : multi3_idx_ ;
    assign multi2_in = poping ? stack[stack_size-2] : multi2_idx_ ;

    Register assignNewMult3(.clk(clk), .rst(rst), .en(1'b1), .pi(multi3_in), .po(multi3_idx));
    Register assignNewMult2(.clk(clk), .rst(rst), .en(1'b1), .pi(multi2_in), .po(multi2_idx));

    assign n_input = res_updater ? multi2_idx : ( poping ? stack[stack_size-2]+1'b1 : (cal_res ? multi2_idx+1'b1 : (load_init ? entry : n_input)));
    Register res_update_n(.clk(clk), .rst(rst), .en(res_updater|poping|cal_res|load_init), .pi(n_input), .po(n));

    assign result = value[entry];

endmodule