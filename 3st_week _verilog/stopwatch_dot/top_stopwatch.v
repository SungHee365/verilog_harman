`timescale 1ns / 1ps

module top_stopwatch(
    input clk,rst,
    input i_btn_clear,i_btn_run,sw_mode,
    output [3:0] fnd_comm,
    output [7:0] fnd_font
    );

    wire clear,run;
    wire w_btn_clear, w_btn_run;
    wire [6:0] msec;
    wire [5:0] sec,min;
    wire [4:0] hour;


stopwatch_dp U_StopWatch_DP(
    .clk(clk),
    .rst(rst),
    .run(run),
    .clear(clear),
    .msec(msec),
    .sec(sec),
    .min(min),
    .hour(hour)
    );


stopwatch_cu U_StopWatch_CU(
    .clk(clk),
    .rst(rst), 
    .i_btn_run(w_btn_run), 
    .i_btn_clear(w_btn_clear), 
    .o_run(run),
    .o_clear(clear)
    );


btn_debounce U_Btn_DB_RUN(
    .clk(clk),
    .rst(rst),
    .i_btn(i_btn_run),
    .o_btn(w_btn_run)
    );


btn_debounce U_Btn_DB_CLEAR(
    .clk(clk),
    .rst(rst),
    .i_btn(i_btn_clear),
    .o_btn(w_btn_clear)
    );


fnd_controller U_Fnd_Ctrl(
    .clk(clk), 
    .rst(rst), 
    .sw_mode(sw_mode),
    .msec(msec), 
    .sec(sec), 
    .min(min), 
    .hour(hour), 
    .fnd_font(fnd_font), 
    .fnd_comm(fnd_comm)
);


endmodule

