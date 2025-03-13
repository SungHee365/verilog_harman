`timescale 1ns / 1ps

module tb_stopwatch;

    reg clk, rst;
    reg [1:0]sw_mode;
    reg [2:0] btn;
    wire [3:0] o_led;
    wire [3:0] fnd_comm;
    wire [7:0] fnd_font;


    always #5 clk = ~clk;
/*
    initial begin
    
        clk = 0; 
        sw_mode = 0;
        rst = 1; 
        # 30 

        rst = 0;
        sw_mode[1] = 0;
        btn = 3'b100;
        #100000000
        btn = 3'b001;
        #100
        btn = 3'b010;
        #100000000
        btn = 3'b000;
        #100000000
        sw_mode[1] = 1;
        #100000000
        btn = 3'b100;
        #100000000
        btn = 3'b010;
        #100000000
        btn = 3'b001;
        

    end
*/
    initial begin
    
        clk = 0; 
        sw_mode = 0;
        rst = 1; 
        # 30 

        rst = 0;
        sw_mode[1] = 0;
        btn = 3'b100;
        #100000000
        btn = 3'b001;
        #100000000
        btn = 3'b010;
        #100000000
        btn = 3'b001;
        #100000000
        btn = 3'b000;
        #100000000
        btn = 3'b001;
        #100000000
        btn = 3'b000;
       #100000000
        btn = 3'b001;
        #100000000
        btn = 3'b000;
                #100000000
        btn = 3'b001;
        #100000000
        btn = 3'b000;        #100000000
        btn = 3'b001;
        #100000000
        btn = 3'b000;        #100000000
        btn = 3'b001;
        #100000000
        btn = 3'b000;        #100000000
        btn = 3'b001;
        #100000000
        btn = 3'b000;        #100000000
        btn = 3'b001;
        #100000000
        btn = 3'b000;        #100000000
        btn = 3'b001;
        #100000000
        btn = 3'b000;        #100000000
        btn = 3'b001;
        #100000000
        btn = 3'b000;       #100000000
        btn = 3'b001;
        #100000000
        btn = 3'b000;       #100000000
        btn = 3'b001;
        #100000000
        btn = 3'b000;       #100000000
        btn = 3'b001;
        #100000000
        btn = 3'b000;

    end



top_stopwatch_clock dut(
    .clk(clk),
    .rst(rst),
    .btn(btn),
    .msec_min_mode(sw_mode[0]), 
    .stopwatch_clock_mode(sw_mode[1]),
    .o_led(o_led),
    .fnd_comm(fnd_comm),
    .fnd_font(fnd_font)
    );



endmodule
