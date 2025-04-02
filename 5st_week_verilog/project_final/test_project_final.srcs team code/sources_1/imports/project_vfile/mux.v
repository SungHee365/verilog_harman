`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/27 11:56:06
// Design Name: 
// Module Name: mux
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mux(
    input  [1:0] sel,
    // clock
    input  [7:0] c_msec,
    input  [7:0] c_sec,
    input  [7:0] c_min,
    input  [7:0] c_hour,
    // stopawtch
    input  [7:0] s_msec,
    input  [7:0] s_sec,
    input  [7:0] s_min,
    input  [7:0] s_hour,
    // ultra_SENSOR
    input  [7:0] u_data_1_10,
    input  [7:0] u_data_100_1000,
    input  [7:0] u_data_1_10_2,
    input  [7:0] u_data_100_1000_2,    
    // DHT_11
    input  [7:0] d_data_1_10,
    input  [7:0] d_data_100_1000,
    input  [7:0] d_data_1_10_2,
    input  [7:0] d_data_100_1000_2,  
    // output
    output reg [7:0] data_1_10,
    output reg [7:0] data_100_1000,
    output reg [7:0] data_1_10_2,
    output reg [7:0] data_100_1000_2
);
   
    always @(*) begin
        case (sel)
            2'b00 : begin
                    data_1_10 = s_msec;
                    data_100_1000 = s_sec;
                    data_1_10_2 = s_min;
                    data_100_1000_2 = s_hour;
            end
            2'b01 :begin
                    data_1_10 = c_msec;
                    data_100_1000 = c_sec;
                    data_1_10_2 = c_min;
                    data_100_1000_2 = c_hour;
            end
            2'b10 :begin
                    data_1_10 = u_data_1_10;
                    data_100_1000 = u_data_100_1000;
                    data_1_10_2 = u_data_1_10_2;
                    data_100_1000_2 = u_data_100_1000_2;
            end
            2'b11 :begin
                    data_1_10 = d_data_1_10;
                    data_100_1000 = d_data_100_1000;
                    data_1_10_2 = d_data_1_10_2;
                    data_100_1000_2 = d_data_100_1000_2;
            end
            default: begin
                    data_1_10 = 0;
                    data_100_1000 = 0;
                    data_1_10_2 = 0;
                    data_100_1000_2 = 0;
            end
        endcase
    end

endmodule