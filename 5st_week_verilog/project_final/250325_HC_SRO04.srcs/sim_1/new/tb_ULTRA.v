`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/25 11:36:29
// Design Name: 
// Module Name: tb_ULTRA
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


module tb_ULTRA();

    reg clk;
    reg rst;
    reg btn;
    reg echo;
    reg sw_mode;
    wire [7:0] fnd_font;
    wire [3:0] fnd_comm;
    wire start_trigger;
    wire [3:0] LED;
    wire echo_LED;

    always #5 clk = ~clk ;


    initial begin
        clk = 0;
        echo = 0;
        rst = 1;
        sw_mode = 0;

        #10;

        rst = 0;
        btn = 1;

        #1000;
        btn = 0;
        #1000000;
        echo = 1;
        #2000000;
        echo = 0;

    end



TOP_Ultrasonic DUT(
    .clk(clk),
    .rst(rst),
    .btn(btn),
    .echo(echo),
    .sw_mode(sw_mode),
    .start_trigger(start_trigger),
    .fnd_comm(fnd_comm),
    .fnd_font(fnd_font),
    .LED(LED),
    .echo_LED(echo_LED)
    );


endmodule


