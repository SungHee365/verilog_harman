`timescale 1ns / 1ps


module Top_button_Ctrl(
    //btn
    input sw_mode,clk,rst,
    input [2:0] btn,
    output btn_run, btn_clear,
    output btn_sec, btn_min, btn_hour

);

    wire [2:0] w_btn;

btn_debounce U_Btn_DB_L(
    .clk(clk),
    .rst(rst),
    .i_btn(btn[0]),
    .o_btn(w_btn[0])
    );

btn_debounce U_Btn_DB_U(
    .clk(clk),
    .rst(rst),
    .i_btn(btn[1]),
    .o_btn(w_btn[1])
    );

btn_debounce U_Btn_DB_R(
    .clk(clk),
    .rst(rst),
    .i_btn(btn[2]),
    .o_btn(w_btn[2])
    );

button_mode_s U_button_mode(
    .sw_mode(sw_mode),
    .clk(clk),
    .rst(rst),
    .btn(w_btn),
    .btn_run(btn_run), 
    .btn_clear(btn_clear),
    .btn_sec(btn_sec), 
    .btn_min(btn_min), 
    .btn_hour(btn_hour)
);


endmodule







/*

module button_mode_s(
    input sw_mode,clk,rst,
    input [2:0] btn,
    output reg btn_run, btn_clear,
    output reg btn_sec, btn_min, btn_hour
);

    always @(posedge clk, posedge rst) begin
        if(rst) begin btn_run <= 0;
                      btn_clear <= 0;
                      btn_sec <= 0;
                      btn_min <= 0;
                      btn_hour <= 0;
        end 
        else begin
            if(!sw_mode) begin
                btn_run <= btn[0];
                btn_clear <= btn[2];
            end
            else begin
                btn_sec <= btn[2];
                btn_min <= btn[1];
                btn_hour <= btn[0];
            end
        end 
        
    end
endmodule
*/
module button_mode_s(
    input sw_mode,clk,rst,
    input [2:0] btn,
    output btn_run, btn_clear,
    output btn_sec, btn_min, btn_hour
);
/*
    reg run;

    always @(posedge clk, posedge rst) begin
        if(rst) begin run <= 0;
        end 
        else begin
            if(!sw_mode)
            run <= btn[0];
        end
    end
*/
  //  assign btn_run = run;
    assign btn_run = (sw_mode == 0) ? btn[0] : 1'b0;
    assign btn_clear = (sw_mode == 0) ? btn[2] : 1'b0;
    assign btn_sec = (sw_mode == 1) ? btn[2] : 1'b0;
    assign btn_min = (sw_mode == 1) ? btn[1] : 1'b0;
    assign btn_hour = (sw_mode == 1) ? btn[0] : 1'b0;


endmodule

