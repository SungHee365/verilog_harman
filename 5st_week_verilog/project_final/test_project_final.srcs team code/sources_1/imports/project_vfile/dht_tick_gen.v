`timescale 1ns/1ns

module dht_tick_gen(
    input clk,
    input reset,
    output tick
    );

    localparam TICK_COUNT = 1_000; // 10us tick gen
    
    reg [$clog2(TICK_COUNT)-1:0] cnt_reg, cnt_next;
    reg tick_reg, tick_next;

    assign tick = tick_reg;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            tick_reg <= 1'b0;
            cnt_reg <= 0;
        end
        else begin
            cnt_reg <= cnt_next;
            tick_reg <= tick_next;
        end 
    end

    always @(*) begin
        
        cnt_next = cnt_reg;
        tick_next = tick_reg;
        
        
        if(cnt_reg == TICK_COUNT-1) begin
            cnt_next = 0;
            tick_next = 1'b1; 
        end
        else begin
            cnt_next = cnt_reg + 1;
            tick_next = 1'b0;
        end
    end
endmodule