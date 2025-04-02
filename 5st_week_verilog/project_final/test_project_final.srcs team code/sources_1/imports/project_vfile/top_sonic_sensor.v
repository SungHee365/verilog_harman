`timescale 1ns / 1ps

module top_sonic_sensor(
    input clk,
    input reset,
    input i_btn,
    input echo,
    input w_tick,
    output start_trigger,
    output [8:0] distance,
    output [7:0]sonic_data,
    output sonic_we
//    output [7:0] fnd_font,
 //   output [3:0] fnd_comm,
 //   output [3:0] led,
 //   output error
    );


    wire [8:0] w_distance;
    wire w_pulse_done;
    wire w_error;


    wire [7:0] w_digit_1, w_digit_10, w_digit_100;
    wire [7:0] o_digit_1, o_digit_10, o_digit_100;

    assign distance = w_distance;


    sonic_sensor_cu U_CU(
        .clk(clk),
        .reset(reset),
        .i_btn(i_btn),
        .echo(echo),
        .start_trigger(start_trigger),
        .distance(w_distance),
        .pulse_done(w_pulse_done),
        .led(),
        .error(w_error)
    );



    digit_splitter2 U_num_data(
        .clk(clk),
        .rst(reset),
        .bcd(w_distance),
        .digit_1(w_digit_1),
        .digit_10(w_digit_10),
        .digit_100(w_digit_100)
    );

    test U_test_sonic(
    .clk(clk),
    .rst(rst),
    .w_digit_1(w_digit_1),
    .w_digit_10(w_digit_10),
    .w_digit_100(w_digit_100),
    .o_digit_1(o_digit_1),
    .o_digit_10(o_digit_10),
    .o_digit_100(o_digit_100)
);

    send_num_data U_Send_Num(
        .clk(clk),
        .reset(reset),
        .tick(w_tick),
        .pulse_done(w_pulse_done),
        .error(w_error),
        .digit_1(o_digit_1),
        .digit_10(o_digit_10),
        .digit_100(o_digit_100),
        .rx_data(sonic_data),
        .we(sonic_we) // tx fifo 쓰기기
    );
endmodule




module test (
    input clk,rst,
    input [7:0] w_digit_1,w_digit_10,w_digit_100,
    output reg [7:0] o_digit_1,o_digit_10,o_digit_100
);

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            o_digit_1 <= 0;
            o_digit_10 <= 0;
            o_digit_100 <= 0;
        end
        else begin
            o_digit_1 <= w_digit_1;
            o_digit_10 <= w_digit_10;
            o_digit_100 <= w_digit_100;
        end
        
    end
    
endmodule