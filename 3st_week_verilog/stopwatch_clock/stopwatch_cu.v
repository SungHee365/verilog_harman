`timescale 1ns / 1ps

module stopwatch_cu(
    input clk, rst,
    input i_btn_run, i_btn_clear, 
    output reg o_run, o_clear
    );


    //fsm 구조로 CU를 설계
    parameter STOP = 0, RUN = 1 , CLEAR = 2;
    
    reg[1:0] state, next;



    // state register
    always @(posedge clk, posedge rst) begin
        if(rst) state <= 0;
        else state <= next;
    end


    always @(*) begin
        next = state;
        case (state)
            STOP : if(i_btn_run) next = RUN;
                   else if(i_btn_clear) next = CLEAR;
                   else next = next;
            RUN : if(i_btn_run) next = STOP;
            CLEAR : if(i_btn_clear) next = STOP;
        endcase
    end

    always @(*) begin
        o_run = 1'b0;
        o_clear = 1'b0;
        case (state)
            STOP : begin o_run = 1'b0; o_clear = 1'b0; end
            RUN : begin o_run = 1'b1; o_clear = 1'b0; end
            CLEAR : o_clear = 1'b1;
        endcase
    end


endmodule
