module full_adder(
    input a,b,c_in,
    output c_out,s

    );
    wire c_w1,c_w2,s_w;
    
    half_adder HA0( .a(a), .b(b), .s(s_w), .c(c_w1));
    half_adder HA1( .a(s_w), .b(c_in), .s(s), .c(c_w2));
    
    assign c_out = c_w1 | c_w2;
    
    
endmodule
