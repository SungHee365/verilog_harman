`timescale 1ns / 1ps

module LED_Indicator(
    input [1:0]sw_mode,
    output reg [3:0]led
    );

    always @(sw_mode) begin
        case (sw_mode)
           2'b00 : led = 4'b1001;
           2'b01 : led = 4'b1010;
           2'b10 : led = 4'b0101;
           2'b11 : led = 4'b0110;
            default: led = 2'b0000;
        endcase
    end 
endmodule
