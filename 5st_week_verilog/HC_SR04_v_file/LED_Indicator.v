`timescale 1ns / 1ps

module LED_Indicator(
    input [1:0]state,
    output reg [3:0]led
    );

    always @(state) begin
        case (state)
           0 : led = 4'b0001;
           1 : led = 4'b0010;
           2 : led = 4'b0100;
           3 : led = 4'b1000;
            default: led = 2'b0000;
        endcase
    end 
endmodule
