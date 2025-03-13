`timescale 1ns / 1ps

module top_stopwatch(
    input clk,rst,
    input i_btn_clear,i_btn_run,
    output [6:0] msec,
    output [5:0] sec,min,
    output [4:0] hour
    );

    wire w_btn_clear, w_btn_run;

stopwatch_dp U_StopWatch_DP(
    .clk(clk),
    .rst(rst),
    .run(w_btn_run),
    .clear(w_btn_clear),
    .msec(msec),
    .sec(sec),
    .min(min),
    .hour(hour)
    );


stopwatch_cu U_StopWatch_CU(
    .clk(clk),
    .rst(rst), 
    .i_btn_run(i_btn_run), 
    .i_btn_clear(i_btn_clear), 
    .o_run(w_btn_run),
    .o_clear(w_btn_clear)
    );





endmodule

