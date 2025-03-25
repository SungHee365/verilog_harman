`timescale 1ns / 1ps


module TOP_Ultrasonic(
    input clk,
    input rst,
    input btn,
    input echo,
    input sw_mode,
    output start_trigger,
    output [7:0] fnd_font,
    output [3:0] fnd_comm,
    output [3:0] LED,
    output echo_LED

    );
    wire w_tick_1us;
    wire w_time_done;
    wire w_btn;
    wire [8:0] w_dist_cm;
    wire [1:0] w_state;


    assign echo_LED = echo;


btn_debounce U_btn_DB(
    .clk(clk),
    .rst(rst),
    .i_btn(btn),
    .o_btn(w_btn)
    );

Ultrasonic_dp U_Ultrasonic_dp(
    .clk(clk),
    .rst(rst),
    .tick_1us(w_tick_1us),
    .btn(w_btn),
    .echo(echo),
    .start_trigger(start_trigger),
    .time_done(w_time_done),
    .o_state(w_state)
);

dist_calculator U_dist(
    .clk(clk),
    .rst(rst),
    .tick(w_tick_1us),
    .echo(echo),
    .time_done(w_time_done),
    .dist_cm(w_dist_cm)
);




tick_genp_1Mhz U_tick_genp(
    .clk(clk),
    .rst(rst),
    .tick_1us(w_tick_1us)
);

fnd_controller U_FND(
    .clk(clk),
    .rst(rst),
    .sw_mode(sw_mode),
    .dist_cm(w_dist_cm),
    .fnd_font(fnd_font),
    .fnd_comm(fnd_comm)
);


LED_Indicator U_LED(
    .state(w_state),
    .led(LED)
    );


endmodule