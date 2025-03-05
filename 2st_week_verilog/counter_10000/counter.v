
module Upcounter(
    input clk,rst,run,
    output [7:0] seg,
	output [3:0] seg_com
);

    wire [13:0] w_cnt;
    wire clk_10hz;


    clock_divider_10 U_clk_10( .clk(clk), .rst(rst), .clk_10hz(clk_10hz));
    counter_10000 U_counter( .clk(clk_10hz), .rst(rst), .cnt(w_cnt));
    fnd_controller U_fnd_ctrl(.clk(clk), .run(run), .rst(rst), .bcd(w_cnt), .seg(seg), .seg_com(seg_com));

endmodule



module counter_10000(
    input clk,rst,run_stop,
    output reg [13:0] cnt

    );


    always@( posedge clk, posedge rst, posedge run_stop) begin
        if (rst) cnt <= 0;
        else if (run_stop) cnt = cnt;
        else if(cnt == 10000-1) cnt <= 0;
        else cnt <= cnt+1;
    end
endmodule

module clock_divider_10(
    input clk,rst,
    output reg clk_10hz
);

// $clog2 를 사용하면 비트수 계산 가능
// 예) $clog2(5) -> 3
// basys 는 기본 100Mhz
    reg [$clog2(10000000):0] cnt;

    always @(posedge clk, posedge rst) begin
        if (rst) begin cnt <= 0; clk_10hz <=0; end
        else if (cnt == 10000000-1) begin  cnt <= 0; clk_10hz <= ~clk_10hz; end
        else if (cnt == 5000000-1) begin cnt <= cnt+1; clk_10hz <= ~clk_10hz; end
        else cnt <= cnt+1;
    end

endmodule