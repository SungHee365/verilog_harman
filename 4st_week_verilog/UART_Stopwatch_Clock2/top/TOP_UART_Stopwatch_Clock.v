`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/21 10:46:11
// Design Name: 
// Module Name: TOP_UART_Stopwatch_Clock
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


module TOP_UART_Stopwatch_Clock(
    // uart
    input clk,rst,
    input rx, // pc in rx
    output tx, // pc out tx


    // stopwatch_clock
    input [2:0] btn,
    input msec_min_mode, stopwatch_clock_mode,
    output [3:0] o_led,
    output [3:0] fnd_comm,
    output [7:0] fnd_font
    
    );





wire w_tick;
wire w_rx_done, w_tx_done, w_ctrl_data;
wire w_rd_full, w_empty_wr;
wire w_empty_start;
wire w_uart_sepcial;
wire [7:0] w_rx_data, w_FIFO_data, w_Stopwatch_Clock_data, w_tx_data;




UART_RX U_RX(
    .clk(clk),
    .rst(rst),
    .tick(w_tick),
    .rx(rx),
    .rx_done(w_rx_done),
    .ctrl_data(w_ctrl_data),
    .rx_data(w_rx_data)
);

fifo U_FIFO_RX(
    .clk(clk),
    .rst(rst),   

    //write
    .wdata(w_rx_data),
    .wr(w_rx_done),
    .full(),

    //read
    .rd(~w_rd_full), // 수정
    .rdata(w_FIFO_data),
    .empty(w_empty_wr)
    );


top_stopwatch_clock U_Top_Stopwatch_Clock(
    .clk(clk),
    .rst(rst),
    .btn(btn),
    .data_in(w_FIFO_data),
    .ctrl_data(w_ctrl_data),
    .msec_min_mode(msec_min_mode), 
    .stopwatch_clock_mode(stopwatch_clock_mode),
    .o_led(o_led),
    .fnd_comm(fnd_comm),
    .fnd_font(fnd_font),
    .data_out(w_Stopwatch_Clock_data),
    .o_uart_special(w_uart_sepcial)
    );




fifo U_FIFO_TX(
    .clk(clk),
    .rst(rst),
    //write
    
    .wdata(w_Stopwatch_Clock_data),
    .wr(~w_empty_wr),
    .full(w_rd_full),

    //read
    .rd(~w_tx_done), // 기본 알아서 빠져나가기 
    .rdata(w_tx_data),
    .empty(w_empty_start)
    );

UART_TX U_TX(
    .clk(clk),
    .rst(rst),
    .tick(w_tick),
    .start_trigger(~w_empty_start),
    .data_in(w_tx_data),
    .o_tx(tx), 
    .o_tx_done(w_tx_done)
);




baud_tick_genp U_BAUD_Tock_Gen(
    .clk(clk),
    .rst(rst),
    .baud_tick(w_tick)
);

endmodule
