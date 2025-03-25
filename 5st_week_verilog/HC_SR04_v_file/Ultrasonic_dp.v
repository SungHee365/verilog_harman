`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/25 10:18:06
// Design Name: 
// Module Name: Ultrasonic_dp
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


module Ultrasonic_dp(
    input clk,
    input rst,
    input tick_1us,
    input btn,
    input echo,
    output start_trigger,
    output time_done,
    output [1:0] o_state
);

    parameter IDLE = 0, START = 1, WAIT = 2, DATA = 3;

    reg time_next, time_reg;
    reg [3:0] cnt_next, cnt_reg;
    reg [1:0] state,next;
    reg start_next, start_reg;


    assign start_trigger = start_reg;
    assign o_state = state;
    assign time_done = time_reg;

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            cnt_reg <= 0;
            start_reg <= 0;
            state <= 0;
            time_reg <= 0;
        end
        else begin
            cnt_reg <= cnt_next;
            start_reg <= start_next;
            state <= next;
            time_reg <= time_next;
        end
    end

    always @(*) begin
        cnt_next = cnt_reg;
        start_next = start_reg;
        next = state;
        time_next = time_reg;
        case (state)
           IDLE : begin  time_next = 0;
                    if(btn) begin 
                     next = START;
                    end
           end
           START : if(tick_1us == 1) begin
                    if(cnt_reg == 9) begin
                        start_next = 0;
                        cnt_next = 0;
                        next = WAIT;
                    end
                    else begin
                        cnt_next = cnt_reg + 1;
                        start_next = 1;
                        next = START;
                    end
           end
           WAIT : if(tick_1us == 1) begin
            if(echo == 1) begin
                next = DATA;
            end
            else begin
                next = WAIT;
            end
           end
           DATA : if(tick_1us == 1) begin
            if(echo == 0) begin
                next = IDLE;
                time_next = 1;
            end
            else begin
                next = DATA;
            end
           end
        endcase
        
    end


endmodule



module tick_genp_1Mhz(
    input clk,
    input rst,
    output tick_1us
);


    reg [$clog2(100)-1:0] cnt_next, cnt_reg;
    reg tick_next, tick_reg;


    assign tick_1us = tick_reg;

    always @(posedge clk, posedge rst) begin
        if(rst) begin 
            cnt_reg <= 0;
            tick_reg <=0;
        end
        else begin
            cnt_reg <= cnt_next;
            tick_reg <= tick_next;
        end
    end

    always @(*) begin
        cnt_next = cnt_reg;
        tick_next = tick_reg;
        if(cnt_reg == 100-1) begin
            cnt_next = 0;
            tick_next = 1;
        end
        else begin
            cnt_next = cnt_reg +1;
            tick_next = 0;
        end 
    end

endmodule

module dist_calculator(
    input clk,
    input rst,
    input tick,
    input echo,
    input time_done,
    output [8:0]dist_cm
);

    reg [15:0]cnt_reg,cnt_next;
    reg [15:0]time_reg, time_next;

    always @( posedge clk, posedge rst) begin
        if(rst) begin
            cnt_reg <= 0;
            time_reg <= 0;
        end
        else begin
            cnt_reg <= cnt_next;
            time_reg <= time_next;
        end
    end


    always @(*) begin
        cnt_next = cnt_reg;
        time_next = time_reg;
        if(time_done == 1) begin
            cnt_next = 0;
            time_next = cnt_reg;
        end
        if(tick == 1'b1) begin
            if(echo == 1) begin
                cnt_next = cnt_reg + 1;
            end
        end
    end

    assign dist_cm = time_reg/58;


endmodule
