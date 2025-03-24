`timescale 1ns / 1ps


// dp = datapath
module stopwatch_dp (
    input clk,
    rst,
    input run,
    input clear,
    output [6:0] msec,
    output [6:0] sec,
    output [6:0] min,
    output [4:0] hour
);
    wire w_clk_100hz;
    wire w_msec_tick, w_sec_tick, w_min_tick;

    time_counter #(
        .TICK_COUNT(100),
        .BIT_WIDTH (7)
    ) U_time_counter_msec (
        .clk(clk),
        .rst(rst),
        .tick(w_clk_100hz),
        .clear(clear),
        .o_time(msec),
        .o_tick(w_msec_tick)
    );

    time_counter #(
        .TICK_COUNT(60),
        .BIT_WIDTH (7)
    ) U_time_counter_sec (
        .clk(clk),
        .rst(rst),
        .tick(w_msec_tick),
        .clear(clear),
        .o_time(sec),
        .o_tick(w_sec_tick)
    );

    time_counter #(
        .TICK_COUNT(60),
        .BIT_WIDTH (7)
    ) U_time_counter_min (
        .clk(clk),
        .rst(rst),
        .tick(w_sec_tick),
        .clear(clear),
        .o_time(min),
        .o_tick(w_min_tick)
    );

    time_counter #(
        .TICK_COUNT(60),
        .BIT_WIDTH (5)
    ) U_time_counter_hour (
        .clk(clk),
        .rst(rst),
        .tick(w_min_tick),
        .clear(clear),
        .o_time(hour),
        .o_tick()
    );


    clk_div_100 U_clk_div_100 (
        .clk  (clk),
        .rst(rst),
        .run  (run),
        .clear(clear),
        .o_clk(w_clk_100hz)
    );

endmodule

module time_counter #(
    parameter TICK_COUNT = 100,
    BIT_WIDTH = 7
) (
    input clk,
    input rst,
    input tick,
    input clear,
    output [BIT_WIDTH-1:0] o_time,
    output o_tick
);
    reg [$clog2(TICK_COUNT)-1:0] count_reg, count_next;
    reg tick_reg, tick_next;

    assign o_time = count_reg;
    assign o_tick = tick_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count_reg <= 0;
            tick_reg  <= 0;
        end else begin
            count_reg <= count_next;
            tick_reg  <= tick_next;
        end

    end

    always @(*) begin
        count_next = count_reg;
        tick_next  =1'b0;
        if (clear==1'b1)begin
            count_next=0;
        end
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

endmodule

module clk_div_100 (
    input  clk,
    rst,
    input  run,
    clear,
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
        if (run == 1'b1) begin
            if (count_reg == FCOUNT - 1) begin
                count_next = 0;
                clk_next   = 1'b1;  // 출력 high
            end else begin
                count_next = count_reg + 1;
                clk_next   = 1'b0;
            end
        end 
        else begin
            if (clear == 1'b1) begin
                count_next = 0;
                clk_next   = 0;
            end
        end
    end
endmodule
