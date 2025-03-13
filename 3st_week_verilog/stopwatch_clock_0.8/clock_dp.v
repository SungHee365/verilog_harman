`timescale 1ns / 1ps


// dp = datapath
module clock_dp (
    input clk,rst,
    input btn_hour, btn_min, btn_sec,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour
);
    wire w_clk_100hz;
    wire w_msec_tick, w_sec_tick, w_min_tick;

    clock_time_counter #(
        .TICK_COUNT(100),
        .BIT_WIDTH (7),
        .CLOCK(0)
    ) U_time_counter_msec (
        .clk(clk),
        .rst(rst),
        .btn_up(btn_sec),
        .tick(w_clk_100hz),
        .o_time(msec),
        .o_tick(w_msec_tick)
    );

    clock_time_counter #(
        .TICK_COUNT(60),
        .BIT_WIDTH (7),
        .CLOCK(0)
    ) U_time_counter_sec (
        .clk(clk),
        .rst(rst),
        .btn_up(btn_min),
        .tick(w_msec_tick),
        .o_time(sec),
        .o_tick(w_sec_tick)
    );

    clock_time_counter #(
        .TICK_COUNT(60),
        .BIT_WIDTH (7),
        .CLOCK(0)
    ) U_time_counter_min (
        .clk(clk),
        .rst(rst),
        .btn_up(btn_hour),
        .tick(w_sec_tick),
        .o_time(min),
        .o_tick(w_min_tick)
    );

    clock_time_counter #(
        .TICK_COUNT(60),
        .BIT_WIDTH (5),
        .CLOCK(12)
    ) U_time_counter_hour (
        .clk(clk),
        .rst(rst),
        .btn_up(1'b0),
        .tick(w_min_tick),
        .o_time(hour),
        .o_tick()
    );


    clock_clk_div_100 U_clk_div_100 (
        .clk  (clk),
        .rst(rst),
        .o_clk(w_clk_100hz)
    );

endmodule

module clock_time_counter #(
    parameter TICK_COUNT = 100,
    BIT_WIDTH = 7, CLOCK = 0
) (
    input clk,
    input rst,
    input tick,
    input btn_up,
    output [BIT_WIDTH-1:0] o_time,
    output o_tick
);
    reg [$clog2(TICK_COUNT)-1:0] count_reg, count_next;
    reg tick_reg, tick_next;

    assign o_time = count_reg;
    assign o_tick = tick_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count_reg <= CLOCK;
            tick_reg  <= 0;
        end else begin
            count_reg <= count_next;
            tick_reg  <= tick_next;
        end

    end

    always @(*) begin
        count_next = count_reg;
        tick_next  = 1'b0;
        if(btn_up) begin
            tick_next = 1'b1;
        end
        else begin
            if(tick==1'b1)begin
                if (count_reg == TICK_COUNT - 1) begin
                    count_next = 0;
                    tick_next  = 1'b1;
                end else begin
                    count_next = count_reg + 1;
                    tick_next  = 1'b0;
                end
            end
        end
    end

endmodule



module clock_clk_div_100 (
    input  clk,rst,
    output o_clk
);
    parameter FCOUNT = 1000000;
    reg [$clog2(FCOUNT)-1:0] count_reg, count_next;
    reg clk_reg, clk_next;  // 출력을 ff으로 내보내기 위해서 만듦.

    assign o_clk = clk_reg;  // 최종 출력. 

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count_reg <= 0;
            clk_reg   <= 0;
        end else begin
            count_reg <= count_next;
            clk_reg   <= clk_next;
        end
    end

    always @(*) begin
        count_next = count_reg;
        clk_next   = 1'b0;
        if (count_reg == FCOUNT - 1) begin
            count_next = 0;
            clk_next   = 1'b1;  // 출력 high
        end else begin
            count_next = count_reg + 1;
            clk_next   = 1'b0;
        end
    end
endmodule

