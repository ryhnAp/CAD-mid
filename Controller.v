`timescale 1ns/1ns
module Controller (
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
    poping 
);

    input clk, rst;
    input start;
    input updated;
    input done;
    input backtrack;
    input cal_update;

    output reg load_init;
    output reg updater;
    output reg alu;
    output reg cal_res;
    output reg res_updater;
    output reg poping;

    parameter [3:0] 
        Start = 4'd0,
        Idle = 4'd1,
        Initer = 4'd2,
        Mult = 4'd3,
        Stack = 4'd4,
        ALU = 4'd5,
        Back = 4'd6,
        Pop = 4'd7,
        Poper = 4'd10,
        Update = 4'd8,
        Done = 4'd9;

    reg [3:0] ps, ns;


    always @(posedge clk, posedge rst) begin
        if(rst)begin
            ps <= Start;
        end
        else
            ps <= ns;
    end

    always @(ps, start, updated, done, backtrack, cal_update) begin
        case (ps)
            Start:      ns = start ? Idle : Start;
            Idle:       ns = Initer;
            Initer:     ns = Mult;
            Mult:       ns = Stack;
            Stack:      ns = updated ? ALU : Stack;
            ALU:        ns = Back;
            Back:       ns = backtrack ? Pop : Update;
            Pop:        ns = done ? Done : Poper;
            Poper:      ns = Pop;
            Update:     ns = Mult;
            Done:       ns = Start;

            default: ns = Start;
        endcase
    end

    always @(ps) begin
        {load_init, updater, alu, cal_res, res_updater, poping} = 0;
        case (ps)
            Start: begin

            end
            Idle: begin
                load_init = 1'b1;
            end
            Initer: begin
                
            end
            Mult: begin

            end
            Stack: begin
                updater = 1'b1;
            end
            ALU: begin
                alu = 1'b1;
            end
            Back: begin
                
            end
            Pop: begin
                cal_res = 1'b1;
            end
            Poper: begin
                poping = 1'b1;
            end
            Update: begin
                res_updater = 1'b1;
            end
            Done: begin

            end
        endcase
    end


endmodule