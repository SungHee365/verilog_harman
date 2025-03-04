
module bit_full_adder(
    input [3:0] a,b,
    input c_in,
    output [3:0] s,
    output c_out
);
    
    wire c1, c2, c3;
    full_adder U0( .a(a[0]), .b(b[0]), .c_in(c_in), .s(s[0]), .c_out(c1));
    full_adder U1( .a(a[1]), .b(b[1]), .c_in(c1), .s(s[1]), .c_out(c2));
    full_adder U2( .a(a[2]), .b(b[2]), .c_in(c2), .s(s[2]), .c_out(c3));
    full_adder U3( .a(a[3]), .b(b[3]), .c_in(c3), .s(s[3]), .c_out(c_out));
       
endmodule



module adder_8(
    input [7:0] a, b,
    output [7:0] s,
    output c_out
);
    wire c;

    bit_full_adder U_fa_4_lower( .a(a[3:0]), .b(b[3:0]), .s(s[3:0]), .c_out(c));
    bit_full_adder U_fa_4_upper( .a(a[7:4]), .b(b[7:4]), .s(s[7:4]), .c_out(c_out));

endmodule  