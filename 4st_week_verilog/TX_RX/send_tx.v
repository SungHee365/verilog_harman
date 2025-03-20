`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/14 14:39:59
// Design Name: 
// Module Name: send_tx
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


module send_tx(
    input clk,
    input rst,
    input btn_start,
    output tx,
    output o_tx_done
    );

    parameter IDLE = 0, START = 1, SEND = 2;
    
    reg[1:0] state, next;  // send char fsm state
    reg [3:0] send_cnt_reg, send_cnt_next; // cnt char 15
    reg [7:0] send_tx_data_reg, send_tx_data_next; // ASCII data
    reg send_reg, send_next; // start trigger 출력

    wire w_btn_start;


btn_debounce U_btn_DB(
    .clk(clk),
    .rst(rst),
    .i_btn(btn_start),
    .o_btn(w_btn_start)
    );


uart U_uart(
    .clk(clk),
    .rst(rst),
    .btn_start(send_reg/*{w_btn_start | sesnd_reg}*/),
    .tx_data_in(send_tx_data_reg),
    .tx(tx),
    .tx_done(o_tx_done)
    );



    // send tx ascii to PC
    

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            send_tx_data_reg <= "0";
            state <= IDLE;
            send_cnt_reg <= 0;
            send_reg <= 0;
        end
        else begin
            send_tx_data_reg <= send_tx_data_next;
            state <= next;
            send_cnt_reg <= send_cnt_next;
            send_reg <= send_next;
        end
    end


    always @(*) begin
        send_tx_data_next = send_tx_data_reg;
        send_next = 0;
        send_cnt_next = send_cnt_reg;
        next = state;
        case (state)
            IDLE: begin
                send_next = 1'b0;
                send_cnt_next = 0;
                if (w_btn_start == 1'b1) begin 
                    next = START;
                    send_next = 1;
                end
            end 
            START: begin
                send_next = 1'b0;
                if(o_tx_done == 1'b1) begin
                    next = SEND;
                end
            end
            SEND: begin
                if(o_tx_done == 1'b0) begin
                    send_next = 1'b1; // send 1 tick
                    send_cnt_next = send_cnt_reg + 1;
                    if(send_cnt_reg == 15)begin
                        next = IDLE;
                    end
                    else begin
                        next = START;
                    end
                    // tx_done 이 low로 떨어진 다음에 1번만 증가시키기 위함.
                    if(send_tx_data_reg == "z") begin
                        send_tx_data_next = "0";
                    end
                    else begin
                        send_tx_data_next = send_tx_data_reg + 1; // ascii code value + 1
                    end


                end
            end
        endcase
    end
        




endmodule
