`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/27 10:22:02
// Design Name: 
// Module Name: TOP_UART_SENSOR_TIMER
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


module TOP_UART_SENSOR_TIMER(
    input clk,
    input rst,

    input [2:0] btn, // btn[0] run, btn[2] clear, 
                    //  btn[0] hour, btn[1] min , btn[2] sec
    input btnD,

    input [1:0] sw_mode ,// 0 : stopwatch, 1 : Clock, 2: ultrasonic, 3: sensor
    input sw ,// 시,분과 초,밀리초 나누기기

    input rx,

    input echo,

    output tx,
    output ultra_start,
    output [3:0] fnd_comm,
    output [7:0] fnd_font,

    output [3:0] led_A,
    output led_B,


    inout dht_io
    );


    // 버튼 선

    wire w_btn_run, w_btn_clear;
    wire w_btn_hour, w_btn_min;
    wire w_btn_ultra, w_btn_dht;

    // 데이터 선


    wire [7:0] w_data_1_10, w_data_100_1000, w_data_1_10_2, w_data_100_1000_2;

    wire [7:0] w_c_msec, w_c_sec, w_c_min, w_c_hour,
               w_s_msec, w_s_sec, w_s_min, w_s_hour,
               w_distance, w_humidity_int, w_humidity_dec, 
               w_temperature_int, w_temperature_dec;

    wire [7:0] dist_low = w_distance[7:0] % 100;
    wire [7:0] dist_high = w_distance[7:0] / 100;


    // uart 선


    wire w_tick_uart, w_rx_done;
    wire [7:0] w_rx_data;
    wire [7:0] w_FIFO_data;
    wire w_rx_empty;
    wire w_tx_empty, w_tx_full;
    wire [7:0] w_tx_data;
    wire w_tx_done;

    // uart cu 선
    wire w_uart_run, w_uart_clear;
    wire w_uart_sec, w_uart_min, w_uart_hour;
    wire w_uart_ultra, w_uart_dht;

    // ultra 선

    wire pulse_done;
    wire w_sonic_we;
    wire [7:0] w_sonic_data;

    // dht 선


    wire w_dht_tick;
    wire w_led_checksum;
    wire [7:0] w_dht_data;
    wire w_dht_we;

    //

    wire [7:0] w_FIFO_last_data;
    wire w_FIFO_last_wr;





assign w_FIFO_last_data = ((sw_mode == 2'b10) || (w_FIFO_data == 8'h55) || (w_FIFO_data == 8'h75)) ? w_sonic_data : 
                                                                ((sw_mode == 2'b11) || (w_FIFO_data == 8'h44) || (w_FIFO_data == 8'h64)) ? w_dht_data : w_FIFO_data;

                                                                
assign w_FIFO_last_wr = ((sw_mode == 2'b10) || (w_FIFO_data == 8'h55) || (w_FIFO_data == 8'h75)) ? w_sonic_we : 
                                                                ((sw_mode == 2'b11) || (w_FIFO_data == 8'h44) || (w_FIFO_data == 8'h64)) ? w_dht_we : ~w_rx_empty;



//버튼 디바운싱 모듈
Top_button_Ctrl U_top_button_ctrl(
    .sw_mode(sw_mode), // 0 스톱워치 1 시계
    .clk(clk),
    .rst(rst),
    .btn(btn),
    .btnD(btnD),
    .btn_run(w_btn_run), 
    .btn_clear(w_btn_clear),
    .btn_sec(w_btn_sec), 
    .btn_min(w_btn_min), 
    .btn_hour(w_btn_hour),
    .btn_ultra(w_btn_ultra), 
    .btn_dht(w_btn_dht)
);






// UART 
UART_RX U_RX(
    .clk(clk),
    .rst(rst),
    .tick(w_tick_uart),
    .rx(rx),
    .rx_done(w_rx_done),
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
    .rd(~w_tx_full), // 수정
    .rdata(w_FIFO_data),
    .empty(w_rx_empty)
    );

fifo U_FIFO_TX(
    .clk(clk),
    .rst(rst),
    //write
    
    .wdata(w_FIFO_last_data),
    .wr(w_FIFO_last_wr),
    .full(w_tx_full),

    //read
    .rd(~w_tx_done), // 기본 알아서 빠져나가기 
    .rdata(w_tx_data),
    .empty(w_tx_empty)
    );

UART_TX U_TX(
    .clk(clk),
    .rst(rst),
    .tick(w_tick_uart),
    .start_trigger(~w_tx_empty),
    .data_in(w_tx_data),
    .o_tx(tx), 
    .o_tx_done(w_tx_done)
);


baud_tick_genp U_BAUD_tick_Gen(
    .clk(clk),
    .rst(rst),
    .baud_tick(w_tick_uart)
);


uart_ctrl U_uart_cu(
    .clk(clk),
    .reset(rst),
    .rx_data(w_rx_data),
    .rx_done(w_rx_done),
    .run(w_uart_run),
    .clear(w_uart_clear),
    .sec(w_uart_sec),
    .min(w_uart_min),
    .hour(w_uart_hour),
    .ultra(w_uart_ultra),
    .dht(w_uart_dht)
);


//Clock
top_clock U_top_Clock(
    .clk(clk),
    .rst(rst),
    .btn_hour(w_btn_hour || w_uart_hour),
    .btn_min(w_btn_min || w_uart_min),
    .btn_sec(w_btn_sec || w_uart_sec),
    .o_msec(w_c_msec),
    .o_sec(w_c_sec),
    .o_min(w_c_min),
    .o_hour(w_c_hour)
    );

top_stopwatch U_top_stopwatch(
    .clk(clk),
    .rst(rst),
    .i_btn_clear(w_btn_clear || w_uart_clear),
    .i_btn_run(w_btn_run || w_uart_run),
    .msec(w_s_msec),
    .sec(w_s_sec),
    .min(w_s_min),
    .hour(w_s_hour)
    );




top_sonic_sensor U_top_sonic_sensor(
    .clk(clk),
    .reset(rst),
    .w_tick(w_tick_uart),
    .i_btn(w_btn_ultra || w_uart_ultra),
    .echo(echo), // sonic data
    .start_trigger(ultra_start), // sonic start_trigger 
    .distance(w_distance),  // out distance
    .sonic_data(w_sonic_data),
    .sonic_we(w_sonic_we)
 );




dht_tick_gen U_dht_tick_gen(
    .clk(clk),
    .reset(rst),
    .tick(w_dht_tick)
    );

top_dht11 U_dht11(
    .clk(clk),          // 100mhz on fpga oscillator
    .reset(rst),        // reset btn
    .btn_start(w_btn_dht || w_uart_dht),    // start trigger
    .tick(w_dht_tick),         // 1us tick
    .tick_uart(w_tick_uart),
    .dht_io(dht_io),       // 1-wire data path
    .humidity_int(w_humidity_int),
    .humidity_dec(w_humidity_dec),
    .temperature_int(w_temperature_int),
    .temperature_dec(w_temperature_dec),
    .led(),
    .dht_data(w_dht_data),
    .dht_we(w_dht_we)
);


mux U_mux(
    .sel(sw_mode),

    // clock
    .c_msec(w_c_msec),
    .c_sec(w_c_sec),
    .c_min(w_c_min),
    .c_hour(w_c_hour),

    // stopawtch
    .s_msec(w_s_msec),
    .s_sec(w_s_sec),
    .s_min(w_s_min),
    .s_hour(w_s_hour),

    // ultra_SENSOR
    .u_data_1_10(dist_low),                 // 거리 데이터
    .u_data_100_1000(dist_high),
    .u_data_1_10_2(0),
    .u_data_100_1000_2(0), 

    // DHT_11
    .d_data_1_10(w_humidity_dec),                 // 습도 소수점
    .d_data_100_1000(w_humidity_int),         // 습도 정수
    .d_data_1_10_2(w_temperature_dec),             // 소수점
    .d_data_100_1000_2(w_temperature_int),     // 습도 정수
    
    // output
    .data_1_10(w_data_1_10),
    .data_100_1000(w_data_100_1000),
    .data_1_10_2(w_data_1_10_2),
    .data_100_1000_2(w_data_100_1000_2)
);



fnd_controller U_FND(
    .clk(clk),
    .rst(rst),
    .sw_mode(sw), // 시분초
    .dot_mode(sw_mode), // 시계모드일떄만
    .data_1_10(w_data_1_10),
    .data_100_1000(w_data_100_1000),
    .data_1_10_2(w_data_1_10_2),
    .data_100_1000_2(w_data_100_1000_2),
    .fnd_font(fnd_font),
    .fnd_comm(fnd_comm)
);

LED_Indicator U_LED(
    .sw_mode(sw_mode),
    .sw(sw),
    .led_A(led_A),
    .led_B(led_B)
    );


endmodule



/*
module uart_ctrl (
    input clk,
    input [7:0] rx_data,
    output reg run,clear,
    output reg sec,min,hour,
    output reg ultra,dht
);

    parameter R = 8'h52, r = 8'h72, C = 8'h43, c = 8'h63, 
              S = 8'h53, s = 8'h73, M = 8'h4D, m = 8'h6D, H = 8'h48, h = 8'h68,
              U = 8'h55, u = 8'h75, D = 8'h44, d = 8'h64 ;

    assign run = (rx_data == R) ? 1'b1 : (rx_data == r) ? 1'b1 : 0;
    assign clear = (rx_data == C) ? 1'b1 : (rx_data == c) ? 1'b1 : 0;
    assign sec = (rx_data == S) ? 1'b1 : (rx_data == s) ? 1'b1 : 0;
    assign min = (rx_data == M) ? 1'b1 : (rx_data == m) ? 1'b1 : 0;
    assign hour = (rx_data == H) ? 1'b1 : (rx_data == h) ? 1'b1 : 0;
    assign ultra = (rx_data == U) ? 1'b1 : (rx_data == u) ? 1'b1 : 0;
    assign dht = (rx_data == D) ? 1'b1 : (rx_data == d) ? 1'b1 : 0;
    
endmodule
*/

module uart_ctrl (
    input clk,
    input reset,
    input rx_done,
    input [7:0] rx_data,
    output reg run,clear,
    output reg sec,min,hour,
    output reg ultra,dht
);

    parameter R = 8'h52, r = 8'h72, C = 8'h43, c = 8'h63, 
              S = 8'h53, s = 8'h73, M = 8'h4D, m = 8'h6D, H = 8'h48, h = 8'h68,
              U = 8'h55, u = 8'h75, D = 8'h44, d = 8'h64 ;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            run <= 0; clear <= 0; 
            sec <= 0; min <= 0; hour <= 0; 
            ultra <= 0; dht <= 0;
        end else begin
            if(rx_done == 1) begin
                run   <= (rx_data == R || rx_data == r);
                clear <= (rx_data == C || rx_data == c);
                sec   <= (rx_data == S || rx_data == s);
                min   <= (rx_data == M || rx_data == m);
                hour  <= (rx_data == H || rx_data == h);
                ultra <= (rx_data == U || rx_data == u);
                dht   <= (rx_data == D || rx_data == d);
            end
            else begin
            run <= 0; 
            clear <= 0; 
            sec <= 0; 
            min <= 0; 
            hour <= 0; 
            ultra <= 0; 
            dht <= 0;
            end
        end
    end

endmodule