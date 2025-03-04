`timescale 1ns / 1ps
module fnd_controller(
    input [1:0] d_in,
    input [8:0] bcd,
    output [7:0] seg, 
    output[3:0] seg_com
    );

    wire [3:0] w_digit_1, w_digit_10, w_digit_100, w_digit_1000;
    wire [3:0] mux_bcd;
    decoder U_decoder( .d_in(d_in), .d_out(seg_com));
    digit_splitter U_digit( .bcd(bcd), .digit_1(w_digit_1), .digit_10(w_digit_10), .digit_100(w_digit_100), .digit_1000(w_digit_1000));
    mux_4x1 mux_4x1( .sel(d_in), .digit_1(w_digit_1), .digit_10(w_digit_10), .digit_100(w_digit_100), .digit_1000(w_digit_1000), .bcd(mux_bcd));
    BCD_to_seg U_bcdtoseg( .bcd(mux_bcd), .seg(seg));



endmodule


module decoder(
    input [1:0] d_in,
    output reg [3:0] d_out
    );

        always @(d_in) begin
            case(d_in)
            2'b00 : d_out = 4'b1110;
            2'b01 : d_out = 4'b1101;
            2'b10 : d_out = 4'b1011;
            2'b11 : d_out = 4'b0111;
            default : d_out = 4'b1111;
            endcase            
        end

endmodule


module digit_splitter (
    input [8:0] bcd,
    output [3:0] digit_1, digit_10, digit_100, digit_1000


);
    assign digit_1 = bcd % 10;
    assign digit_10 = bcd / 10 % 10;
    assign digit_100 = bcd / 100 % 10;
    assign digit_1000 = bcd / 1000 % 10;

endmodule

module mux_4x1(
    input [1:0] sel,
    input [3:0] digit_1, digit_10, digit_100, digit_1000,
    output reg [3:0] bcd
);
    
    always @(*) begin
        case (sel)
            2'b00: bcd = digit_1;
            2'b01: bcd = digit_10;
            2'b10: bcd = digit_100;
            2'b11: bcd = digit_1000;
            default: bcd = 4'bx;
        endcase
    end


endmodule


module BCD_to_seg(
    input [3:0] bcd,
    output reg [7:0]seg


);


    always @(bcd) begin
        case (bcd)
            4'h0 : seg = 8'hc0;
            4'h1 : seg = 8'hf9;
            4'h2 : seg = 8'ha4;
            4'h3 : seg = 8'hb0;
            4'h4 : seg = 8'h99;
            4'h5 : seg = 8'h92;
            4'h6 : seg = 8'h82;
            4'h7 : seg = 8'hf8;
            4'h8 : seg = 8'h80;
            4'h9 : seg = 8'h90;
            4'ha : seg = 8'h88;
            4'hb : seg = 8'h83;
            4'hc : seg = 8'hc6;
            4'hd : seg = 8'ha1;
            4'he : seg = 8'h86;
            4'hf : seg = 8'h8e;
            default: seg = 8'hff;
        endcase
        


    end


endmodule