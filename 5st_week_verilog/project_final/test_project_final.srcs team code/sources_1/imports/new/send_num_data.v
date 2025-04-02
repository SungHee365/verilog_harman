`timescale 1ns / 1ps
module send_num_data (
    input clk,
    input reset,
    input tick,
    input pulse_done,
    input error,
    input [7:0] digit_1,
    input [7:0] digit_10,
    input [7:0] digit_100,
    output [7:0] rx_data,
    output we
);
    parameter IDLE=0, DIGIT_1=1, DIGIT_10=2, DIGIT_100=3, C=4, M=5, E=6, R1=7, R2=8, O=9, R3=10, CR=11, LF=12;
    reg [4:0] state, next;
    reg [7:0] rx_data_reg, rx_data_next;
    reg we_next, we_reg;

    assign rx_data = rx_data_reg;
    assign we = we_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= 0;
            rx_data_reg <= 0;
            we_reg <= 0;
        end else begin
            state <= next;
            rx_data_reg <= rx_data_next;
            we_reg <= we_next;
        end
    end

    always @(*) begin
        next = state;
        rx_data_next = rx_data_reg;
        we_next = we_reg;
        case (state)
            IDLE: begin
                we_next = 0;
                if (error) begin
                    next = E;
                end else if (pulse_done) begin
                    next = DIGIT_100;
                end
            end
            DIGIT_100: begin
                we_next = 0;
                if (tick) begin
                    if(digit_100 != 0) begin 
                        rx_data_next = digit_100;
                    end
                    next = DIGIT_10;
                    we_next = 1;
                end
            end
            DIGIT_10: begin
                we_next = 0;
                if (tick) begin
                    if(digit_10 != 0) begin 
                        rx_data_next = digit_10;
                    end
                    next = DIGIT_1;
                    we_next = 1;
                end
            end
            DIGIT_1: begin
                we_next = 0;
                if (tick) begin
                    rx_data_next = digit_1;
                    next = C;
                    we_next = 1;
                end
            end
            C: begin
                we_next = 0;
                if (tick) begin
                    rx_data_next = 8'h63;
                    next = M;
                    we_next = 1;
                end
            end
            M: begin
                we_next = 0;
                if (tick) begin
                    rx_data_next = 8'h6D;
                    next = CR;
                    we_next = 1;
                end
            end
            E: begin
                we_next = 0;
                if (tick) begin
                    rx_data_next = 8'h45;
                    next = R1;
                    we_next = 1;
                end
            end
            R1: begin
                we_next = 0;
                if (tick) begin
                    rx_data_next = 8'h52;
                    next = R2;
                    we_next = 1;
                end
            end
            R2: begin
                we_next = 0;
                if (tick) begin
                    rx_data_next = 8'h52;
                    next = O;
                    we_next = 1;
                end
            end
            O: begin
                we_next = 0;
                if (tick) begin
                    rx_data_next = 8'h4F;
                    next = R3;
                    we_next = 1;
                end
            end
            R3: begin
                we_next = 0;
                if (tick) begin
                    rx_data_next = 8'h52;
                    next = CR;
                    we_next = 1;
                end
            end
            CR: begin
                we_next = 0;
                if (tick) begin
                    if(error==0) begin
                        rx_data_next = 8'h0D;
                        next = LF;
                        we_next = 1;
                    end
                end
            end
            LF: begin
                we_next = 0;
                if (tick) begin
                    if(error==0) begin
                        rx_data_next = 8'h0A;
                        next = IDLE;
                        we_next = 1;
                    end
                end
            end
        endcase
    end
endmodule



module digit_splitter2 (
    input clk,rst,
    input [8:0] bcd,
    output reg [7:0] digit_1,
    output reg [7:0] digit_10,
    output reg [7:0] digit_100
);
    reg [8:0] bcd_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) 
        begin
            bcd_reg <= 0;
            digit_1 <= 0;
            digit_10 <= 0;
            digit_100 <= 0;
        end 
        else 
        begin
            bcd_reg <= bcd;
            digit_1 <= (bcd_reg % 10) + 48;
            digit_10 <= ((bcd_reg / 10) % 10) + 48;
            digit_100 <= ((bcd_reg / 100) % 10) + 48;
        end
    end
endmodule