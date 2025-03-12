`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/12 13:45:28
// Design Name: 
// Module Name: top_clock
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


module top_clock(
    input clk,rst,
    input btn_hour,btn_min,btn_sec,
    output [6:0] o_msec,
    output [5:0] o_sec, o_min,
    output [4:0] o_hour
    );




clock_dp U_clock_dp(
    .clk(clk),
    .rst(rst),
    .btn_hour(btn_hour), 
    .btn_min(btn_min),
    .btn_sec(btn_sec),
    .msec(o_msec),
    .sec(o_sec),
    .min(o_min),
    .hour(o_hour)
);




endmodule
