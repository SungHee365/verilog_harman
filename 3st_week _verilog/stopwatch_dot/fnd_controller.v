`timescale 1ns / 1ps

module fnd_controller (
    input clk,
    input rst,
    input sw_mode,
    input [6:0] msec,
    input [5:0] sec,min,
    input [4:0] hour,
    output [7:0] fnd_font,
    output [3:0] fnd_comm
);
    wire dot;
    wire [3:0] w_bcd, 
               w_digit_1_msec, w_digit_10_msec, 
               w_digit_1_sec, w_digit_10_sec,
               w_digit_1_min, w_digit_10_min,
               w_digit_1_hour, w_digit_10_hour;

    wire w_clk_100hz,w_clk_5;
    wire [2:0] w_seg_sel;
    wire [3:0] w_msec_sec, w_min_hour;
    
    clk_divider U_Clk_Divider (
        .clk(clk),
        .rst(rst),
        .o_clk(w_clk_100hz)
    );



    
    counter_8 U_Counter_8 (
        .clk  (w_clk_100hz),
        .rst(rst),
        .o_sel(w_seg_sel)
    );

    decoder_3x8 U_decoder_3x8 (
        .seg_sel (w_seg_sel),
        .seg_comm(fnd_comm)
    );

    digit_splitter #(.BIT_WIDTH(7)) U_Digit_Splitter_msec (
        .bcd(msec),
        .digit_1(w_digit_1_msec),
        .digit_10(w_digit_10_msec)
    );
    
    digit_splitter #(.BIT_WIDTH(6)) U_Digit_Splitter_sec (
        .bcd(sec),
        .digit_1(w_digit_1_sec),
        .digit_10(w_digit_10_sec)
    );

    digit_splitter #(.BIT_WIDTH(6)) U_Digit_Splitter_min (
        .bcd(min),
        .digit_1(w_digit_1_min),
        .digit_10(w_digit_10_min)
    );

    digit_splitter #(.BIT_WIDTH(5)) U_Digit_Splitter_hour (
        .bcd(hour),
        .digit_1(w_digit_1_hour),
        .digit_10(w_digit_10_hour)
    );

    dot_blinker dot_blinker(
    .clk(clk),       
    .rst(rst),     
    .dot(dot)   
    );


    mux_8x1 U_Mux_8x1_stopwatch(
        .sel(w_seg_sel),
        .digit_0(w_digit_1_msec), // 숫자 표시 위한 4자리
        .digit_1(w_digit_10_msec),
        .digit_2(w_digit_1_sec),
        .digit_3(w_digit_10_sec),
        .digit_4(4'hf),  // dot 를 뿌리기 위한 4자리
        .digit_5(4'hf),
        .digit_6(dot ? 4'he : 4'hf),
        .digit_7(4'hf),    
        .bcd(w_msec_sec)
    );

     mux_8x1 U_Mux_8x1_clock(
        .sel(w_seg_sel),
        .digit_0(w_digit_1_min), // 숫자 표시 위한 4자리
        .digit_1(w_digit_10_min),
        .digit_2(w_digit_1_hour),
        .digit_3(w_digit_10_hour),
        .digit_4(4'hf),  // dot 를 뿌리기 위한 4자리
        .digit_5(4'hf),
        .digit_6(dot ? 4'he : 4'hf),
        .digit_7(4'hf),    
        .bcd(w_min_hour)
    );

    mux_2x1 U_mux_2x1_stopwatch_clock(
        .sw_mode(sw_mode),
        .msec_sec(w_msec_sec),
        .min_hour(w_min_hour),
        .bcd(w_bcd)
    );

    bcdtoseg U_bcdtoseg(
        .bcd(w_bcd), 
        .seg(fnd_font)
    );

endmodule

// horizental frame 
module clk_divider (
    input  clk,
    input  rst,
    output o_clk
);
    parameter FCOUNT = 100_000 ;// 이름을 상수화하여 사용.
    // $clog2 : 수를 나타내는데 필요한 비트수 계산
    reg [$clog2(FCOUNT)-1:0] r_counter;
    reg r_clk;
    assign o_clk = r_clk;

    always @(posedge clk, posedge rst) begin
        if (rst) begin  // 
            r_counter <= 0;  // 리셋상태
            r_clk <= 1'b0;
        end else begin
            // clock divide 계산, 100Mhz -> 200hz
            if (r_counter == FCOUNT - 1) begin
                r_counter <= 0;
                r_clk <= 1'b1;  // r_clk : 0->1
            end else begin
                r_counter <= r_counter + 1;
                r_clk <= 1'b0;  // r_clk : 0으로 유지.;
            end
        end
    end

endmodule

module counter_8 (
    input        clk,
    input        rst,
    output [2:0] o_sel
);

    reg [2:0] r_counter;
    assign o_sel = r_counter;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_counter <= 0;
        end else begin
            r_counter <= r_counter + 1;
        end
    end


endmodule

module decoder_3x8 (
    input [2:0] seg_sel,
    output reg [3:0] seg_comm
);

    always @(seg_sel) begin
        case (seg_sel)
            3'b000:   seg_comm = 4'b1110;
            3'b001:   seg_comm = 4'b1101;
            3'b010:   seg_comm = 4'b1011;
            3'b011:   seg_comm = 4'b0111;
            3'b100:   seg_comm = 4'b1110;
            3'b101:   seg_comm = 4'b1101;
            3'b110:   seg_comm = 4'b1011;
            3'b111:   seg_comm = 4'b0111;
            default:  seg_comm = 4'b1111;
        endcase
    end

endmodule

module digit_splitter #(parameter BIT_WIDTH = 7) (
    input  [BIT_WIDTH -1:0] bcd,
    output [3:0] digit_1,
    output [3:0] digit_10
);
    assign digit_1 = bcd % 10;  // 10의 1의 자리
    assign digit_10 = bcd / 10 % 10;  // 10의 10의 자리
endmodule

module mux_8x1 (
    input  [2:0] sel,
    input  [3:0] digit_0,
    input  [3:0] digit_1,
    input  [3:0] digit_2,
    input  [3:0] digit_3,
    input  [3:0] digit_4,
    input  [3:0] digit_5,
    input  [3:0] digit_6,
    input  [3:0] digit_7,    
    output reg [3:0] bcd
);
   
    // * : input 모두 감시, 아니면 개별 입력 선택 할 수 있다.
    // alwasys : 항상 감시한다 @이벤트 이하를 ()의 변화가 있으면, begin - end를 수행해라.
    always @(*) begin
        case (sel)
            3'b000 : bcd = digit_0;
            3'b001 : bcd = digit_1;
            3'b010 : bcd = digit_2;
            3'b011 : bcd = digit_3;
            3'b100 : bcd = digit_4;
            3'b101 : bcd = digit_5;
            3'b110 : bcd = digit_6;
            3'b111 : bcd = digit_7;
            default: bcd = 4'hx;
        endcase
    end

endmodule

module mux_2x1(
    input sw_mode,
    input [3:0] msec_sec,
    input [3:0] min_hour,
    output reg [3:0] bcd
);
    always @(*) begin
        case(sw_mode)
            1'b0 : bcd = msec_sec; 
            1'b1 : bcd = min_hour;
            default : bcd = 4'hf;
        endcase
    end
endmodule

/*
module mux_4x1 (
    input  [1:0] sel,
    input  [3:0] digit_1,
    input  [3:0] digit_10,
    input  [3:0] digit_100,
    input  [3:0] digit_1000,
    output [3:0] bcd
);
    reg [3:0] r_bcd;
    assign bcd = r_bcd;
    // * : input 모두 감시, 아니면 개별 입력 선택 할 수 있다.
    // alwasys : 항상 감시한다 @이벤트 이하를 ()의 변화가 있으면, begin - end를 수행해라.
    always @(sel, digit_1, digit_10, digit_100, digit_1000) begin
        case (sel)
            2'b00:   r_bcd = digit_1;
            2'b01:   r_bcd = digit_10;
            2'b10:   r_bcd = digit_100;
            2'b11:   r_bcd = digit_1000;
            default: r_bcd = 4'bx;
        endcase
    end

endmodule
*/
module bcdtoseg (
    input [3:0] bcd,  // [3:0] sum 값 
    output reg [7:0] seg
);
    // always 구문 출력으로 reg type을 가져야 한다.
    always @(bcd) begin

        case (bcd)
            4'h0: seg = 8'hc0;
            4'h1: seg = 8'hF9;
            4'h2: seg = 8'hA4;
            4'h3: seg = 8'hB0;
            4'h4: seg = 8'h99;
            4'h5: seg = 8'h92;
            4'h6: seg = 8'h82;
            4'h7: seg = 8'hf8;
            4'h8: seg = 8'h80;
            4'h9: seg = 8'h90;
            4'hA: seg = 8'h88;
            4'hB: seg = 8'h83;
            4'hC: seg = 8'hc6;
            4'hD: seg = 8'ha1;
            4'hE: seg = 8'hef;
            4'hF: seg = 8'hff;
            default: seg = 8'hff;
        endcase
    end
endmodule


module dot_blinker(
    input clk,       
    input rst,     
    output dot  
);

    reg [24:0] cnt; 
    reg r_dot;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            cnt <= 0;
            r_dot <= 0;
        end else if (cnt == 50_000_000 - 1) begin
            cnt <= 0;
            r_dot <= ~r_dot;
        end else begin
            cnt <= cnt + 1;
            r_dot <= r_dot;
        end
    end

    assign dot = r_dot;
endmodule

