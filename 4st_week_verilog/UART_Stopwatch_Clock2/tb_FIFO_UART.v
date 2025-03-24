`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/20 11:39:55
// Design Name: 
// Module Name: tb_FIFO_UART
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


module tb_FIFO_UART();


reg clk,rst;
reg rx; // pc in rx
reg btn;
reg [1:0] sw;
wire tx; // pc out tx

wire o_led;
wire fnd_comm;
wire fnd_font;

integer i;


TOP_UART_Stopwatch_Clock DUT(
    // uart
    .clk(clk),
    .rst(rst),
    .rx(rx), // pc in rx


    // stopwatch_clock
    .btn(btn),
    .msec_min_mode(sw[0]), 
    .stopwatch_clock_mode(sw[1]),
    .tx(tx), // pc out tx
    .o_led(),
    .fnd_comm(),
    .fnd_font()
    
    );

    always #5 clk = ~clk;


    initial begin
        clk = 1'b0;
        rst = 1'b1;
        rx = 1;
        sw[0] = 0;
        sw[1] = 1;
        #50;
        rst = 0;
        #10000;


        //수신
        send_data(8'h52);
        #100;
        send_data(8'h52);
        #100;
        send_data(8'h52);
        #100;
        send_data(8'h52);
        #100;        send_data(8'h52);
        #100;
        send_data(8'h52);
        #100;
        send_data(8'h52);
        #100;
        send_data(8'h52);
        #100;        send_data(8'h52);
        #100;
        send_data(8'h52);
        #100;
        send_data(8'h52);
        #100;
        send_data(8'h52);
        #100;        send_data(8'h52);
        #100;
        send_data(8'h52);
        #100;
        send_data(8'h52);
        #100;
        send_data(8'h52);
        #100;        send_data(8'h52);
        #100;
        send_data(8'h52);
        #100;
        send_data(8'h52);
        #100;
        send_data(8'h52);
        #100;        send_data(8'h52);
        #100;
        send_data(8'h52);
        #100;
        send_data(8'h52);
        #100;
        send_data(8'h52);
        #100;        send_data(8'h52);
        #100;
        send_data(8'h52);
        #100;
        send_data(8'h52);
        #100;
        send_data(8'h52);
        #100;        send_data(8'h52);
        #100;
        send_data(8'h52);
        #100;
        send_data(8'h52);
        #100;
        send_data(8'h52);
        #100;        send_data(8'h52);
        #100;
        send_data(8'h52);
        #100;
        send_data(8'h52);
        #100;
        send_data(8'h52);
        #100;        send_data(8'h52);
        #100;
        send_data(8'h52);
        #100;
        send_data(8'h52);
        #100;
        send_data(8'h52);
        #100;        send_data(8'h52);
        #100;
        send_data(8'h52);
        #100;
        send_data(8'h52);
        #100;
        send_data(8'h52);
        #100;



    end

// task : 데이터 송신 시뮬레이션 (tx -> rx loopback)
    task send_data(input [7:0] data);

        integer i;

        begin
            $display("Sending data: %h", data);


            //Start bit (Low)
            rx = 0;
            #(10 * 10417); // baud rate에 따른 시간 지연(9600bps 기준)

            // Data bits(LSB first)
            for(i=0; i<8; i = i + 1) begin
                rx = data [i];
                #(10 * 10417);
            end


            // stop bit(High)
            rx = 1;
            #(10*10417);

            $display("Data sent: %h", data);
        end


    endtask






endmodule
