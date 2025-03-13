`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/12 12:23:51
// Design Name: 
// Module Name: top_stopwatch_clock
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_stopwatch_clock(
    input clk,rst,
    input [2:0] btn,
    input msec_min_mode, stopwatch_clock_mode,
    output [3:0] o_led,
    output [3:0] fnd_comm,
    output [7:0] fnd_font
    );

    wire w_btn_run, w_btn_clear, w_btn_sec, w_btn_min, w_btn_hour;

    wire [6:0] w_msec, w_stop_msec, w_clock_msec;
    wire [5:0] w_sec, w_min, w_stop_sec, w_stop_min, w_clock_sec, w_clock_min;
    wire [4:0] w_hour, w_stop_hour, w_clock_hour;




Top_button_Ctrl U_Top_Button_Ctrl(
    .sw_mode(stopwatch_clock_mode),
    .clk(clk),
    .rst(rst),
    .btn(btn),
    .btn_run(w_btn_run),
    .btn_clear(w_btn_clear),
    .btn_sec(w_btn_sec), 
    .btn_min(w_btn_min), 
    .btn_hour(w_btn_hour)
);
// 이상없음음


top_stopwatch U_Top_Stopwatch(
    .clk(clk),
    .rst(rst),
    .i_btn_clear(w_btn_clear),
    .i_btn_run(w_btn_run),
    .msec(w_stop_msec),
    .sec(w_stop_sec),
    .min(w_stop_min),
    .hour(w_stop_hour)
    );

top_clock U_Top_Clock(
    .clk(clk),
    .rst(rst),
    .btn_hour(w_btn_hour),
    .btn_min(w_btn_min),
    .btn_sec(w_btn_sec),
    .o_msec(w_clock_msec),
    .o_sec(w_clock_sec), 
    .o_min(w_clock_min),
    .o_hour(w_clock_hour)
    );



select_mode U_Select_Mode(
    .sw_mode(stopwatch_clock_mode), 
    .stop_msec(w_stop_msec),
    .stop_sec(w_stop_sec), 
    .stop_min(w_stop_min), 
    .stop_hour(w_stop_hour), 
    .clock_msec(w_clock_msec),
    .clock_sec(w_clock_sec),
    .clock_min(w_clock_min),
    .clock_hour(w_clock_hour),
    .msec(w_msec),
    .sec(w_sec),
    .min(w_min),
    .hour(w_hour)
);




fnd_controller U_Fnd_Ctrl(
    .clk(clk), 
    .rst(rst), 
    .sw_mode(msec_min_mode),
    .msec(w_msec), 
    .sec(w_sec), 
    .min(w_min), 
    .hour(w_hour), 
    .fnd_font(fnd_font), 
    .fnd_comm(fnd_comm)
);

LED_Indicator U_LED_Indicator(
    .sw_mode({stopwatch_clock_mode, msec_min_mode}),
    .led(o_led)
    );


endmodule


module select_mode(
    input sw_mode, 
    input [6:0] stop_msec, clock_msec,
    input [5:0] stop_sec, clock_sec,
    input [5:0] stop_min, clock_min,
    input [4:0] stop_hour, clock_hour,
    output [6:0]msec,
    output [5:0]sec,min,
    output [4:0]hour
);

    assign msec = (sw_mode==1'b0) ? stop_msec : clock_msec;
    assign sec = (sw_mode==1'b0) ? stop_sec : clock_sec;
    assign min = (sw_mode==1'b0) ? stop_min : clock_min;
    assign hour = (sw_mode==1'b0) ? stop_hour : clock_hour;
    

    
endmodule








/* 래치생김 
    always @(*) begin
        btn_

        if(sw_mode) begin
            btn_run = btn[2];
            btn_clear = btn[0];
        end
        else begin
            btn_sec = btn[2];
            btn_min = btn[1];
            btn_hour = btn[0];
        end
        
    end
*/
