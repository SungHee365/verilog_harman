`timescale 1ns / 1ps

module uart_cu(
    input clk,rst,
    input [7:0] data_in,
    input ctrl_data,
    output reg uart_run, uart_clear,
    output reg uart_special,
    output reg uart_sec, uart_min, uart_hour
);
    parameter STOP = 0, RUN = 1 , CLEAR = 2;

    reg [1:0] state,next;


// sec min hour
always @(*) begin;
    uart_sec = 1'b0;
    uart_min = 1'b0;
    uart_hour = 1'b0;
    uart_run = 1'b0;
    uart_clear = 1'b0;
    uart_special = 1'b0;
    if(ctrl_data) begin
    case (data_in)
        8'h53, 8'h73: uart_sec = 1'b1;
        8'h4D, 8'h6D: uart_min = 1'b1;
        8'h48, 8'h68: uart_hour = 1'b1;
        8'h52, 8'h72: uart_run = 1'b1;
        8'h43, 8'h63: uart_clear= 1'b1;
        8'h49, 8'h69: uart_special = 1'b1;
    endcase
    end
end

endmodule

