`timescale 1ns / 1ps

module sonic_sensor_cu (
    input clk,
    input reset,
    input i_btn,
    input echo,
    output start_trigger,
    output pulse_done,
    output [8:0] distance,
    output [3:0] led,
    output error
);

    wire w_tick;

    sonic_sensor_dp U_DP(
        .clk(clk),
        .reset(reset),
        .btn(i_btn),
        .echo(echo),
        .tick(w_tick),
        .start_trigger(start_trigger),
        .dist(distance),
        .pulse_done(pulse_done),
        .led(led),
        .error(error)
    );

    tick_gen U_Tick_Gen(
        .clk(clk),
        .reset(reset),
        .tick(w_tick)
    );
    
endmodule

module sonic_sensor_dp(
    input clk,
    input reset,
    input btn,
    input echo,
    input tick,
    output start_trigger,
    output [8:0] dist,
    output pulse_done,
    output [3:0] led,
    output error
    );

    parameter IDLE=0, START=1, BURST=2, WAIT=3, DONE=4, ERROR=5;

    reg start_trigger_next, start_trigger_reg;
    reg pulse_done_next, pulse_done_reg;
    reg error_next, error_reg;
    reg [15:0] usec_cnt_next, usec_cnt_reg, dist_next, dist_reg;
    reg [3:0] led_next, led_reg;

    assign start_trigger = start_trigger_reg;
    assign pulse_done = pulse_done_reg;
    assign dist = dist_reg;
    assign led = led_reg;
    assign error = error_reg;

    reg [2:0] state, next;
    reg [3:0] trigger_cnt_next, trigger_cnt_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= 0;
            start_trigger_reg <= 0;
            pulse_done_reg <= 0;
            usec_cnt_reg <= 0;
            trigger_cnt_reg <= 0;
            dist_reg <= 0;
            led_reg <= 0;
            error_reg <= 0;
        end else begin
            state <= next;
            start_trigger_reg <= start_trigger_next;
            pulse_done_reg <= pulse_done_next;
            usec_cnt_reg <= usec_cnt_next;
            trigger_cnt_reg <= trigger_cnt_next;
            dist_reg <= dist_next;
            led_reg <= led_next;
            error_reg <= error_next;
        end
    end

    always @(*) begin
        next = state;
        usec_cnt_next = usec_cnt_reg;
        trigger_cnt_next = trigger_cnt_reg;
        dist_next = dist_reg;
        start_trigger_next = start_trigger_reg;
        pulse_done_next = pulse_done_reg;
        led_next = led_reg;
        error_next = error_reg;
        case (state)
            IDLE: begin
                start_trigger_next = 0;
                pulse_done_next = 0;
                error_next = 0;
                usec_cnt_next = 0;
                trigger_cnt_next = 0;
                if (btn) next = START;
            end
            START: begin
                led_next = 4'b0001;
                if (tick) begin
                    trigger_cnt_next = trigger_cnt_next + 1;
                    start_trigger_next = 1;
                end else if (trigger_cnt_next == 11) begin
                    next = BURST;
                end
            end
            BURST: begin
                start_trigger_next = 0;
                if (echo) next = WAIT;
            end
            WAIT: begin
                led_next = 4'b0010;
                if (!echo) begin
                    next = DONE;
                end else begin
                    if (tick) begin
                        usec_cnt_next = usec_cnt_next + 1;
                    end else if (usec_cnt_next == 25000) begin
                        next = ERROR;
                    end
                end
            end
            DONE: begin
                led_next = 4'b0100;
                dist_next = usec_cnt_next / 58;
                pulse_done_next = 1;
                if (tick) begin
                    next = IDLE;
                end
            end
            ERROR: begin
                led_next = 4'b1000;
                pulse_done_next = 1;
                error_next = 1;
                if (tick) begin
                    next = IDLE;
                end
            end
        endcase
    end
    
endmodule

module tick_gen #(
    TICK_COUNT = 100
) (
    input clk,
    input reset,
    output reg tick
);

    reg [$clog2(TICK_COUNT)-1:0] cnt;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tick <= 0;
            cnt <= 0;
        end else begin
            if (cnt == TICK_COUNT-1) begin
                tick <= 1;
                cnt <= 0;
            end else begin
                tick <= 0;
                cnt <= cnt + 1;
            end
        end
    end
endmodule