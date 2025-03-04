`timescale 1ns / 1ps

module calculator(
    input [7:0] a,b,
    input [1:0] btn,
    output [7:0] seg,
	output [3:0] seg_com
);

    wire [7:0]sum;
    wire c_out;



    adder_8 U_fa8( .a(a), .b(b), .s(sum), .c_out(c_out));
    fnd_controller U_fnd_ctrl(.d_in(btn), .bcd({c_out, sum}), .seg(seg), .seg_com(seg_com));

    

endmodule

