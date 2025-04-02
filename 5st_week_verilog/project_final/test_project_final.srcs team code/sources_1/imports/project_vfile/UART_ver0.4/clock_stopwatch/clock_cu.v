`timescale 1ns / 1ps

module clock_cu(
    input clk, rst,
    input i_btn_sec, i_btn_min, i_btn_hour, 
    output reg o_btn_sec, o_btn_min, o_btn_hour
    );


    //fsm 구조로 CU를 설계
    parameter IDLE = 0, UP = 1;
    
    reg state, next;



    // state register
    always @(posedge clk, posedge rst) begin
        if(rst) state <= 0;
        else state <= next;
    end


    always @(*) begin
        next = state;
        case (state)
            IDLE : next = UP;
            UP : if(i_btn_sec || i_btn_min || i_btn_hour) next = IDLE;
        endcase
    end

    always @(*) begin
        o_btn_sec = 1'b0;
        o_btn_min = 1'b0;
        o_btn_hour = 1'b0;
        case (state)
            UP : begin 
                if(i_btn_sec == 1'b1) o_btn_sec = 1'b1;
                if(i_btn_min == 1'b1) o_btn_min = 1'b1;
                if(i_btn_hour == 1'b1) o_btn_hour = 1'b1;           
            end
            default : begin o_btn_sec = 1'b0;
                            o_btn_min = 1'b0;
                            o_btn_hour = 1'b0;
            end
        endcase
    end


endmodule
