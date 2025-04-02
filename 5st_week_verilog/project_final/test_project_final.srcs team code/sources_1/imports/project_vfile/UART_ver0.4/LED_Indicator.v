`timescale 1ns / 1ps

module LED_Indicator(
    input [1:0]sw_mode,
    input sw,
    output reg [3:0]led_A,
    output reg led_B
    );

    always @(sw_mode) begin
        case (sw_mode)
           2'b00 : led_A = 4'b1000;
           2'b01 : led_A = 4'b0100;
           2'b10 : led_A = 4'b0010;
           2'b11 : led_A = 4'b0001;
            default: led_A = 4'b0000;
        endcase
    end 

    always @(sw) begin
        case (sw)
           1'b0 : led_B = 1'b0; 
           1'b1 : led_B = 1'b1;
            default: led_B = 1'b0;
        endcase
    end
endmodule
