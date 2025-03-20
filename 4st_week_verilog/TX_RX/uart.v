`timescale 1ns / 1ps
module TOP_UART (
    input clk,
    input rst,
    input rx,
    output tx
);


    wire w_rx_done;
    wire [7:0] w_rx_data;


uart U_UART(
    .clk(clk),
    .rst(rst),
    .btn_start(w_rx_done),
    .tx_data_in(w_rx_data),
    .tx_done(),
    .tx(tx),
    .rx(rx),
    .rx_done(w_rx_done),
    .rx_data(w_rx_data)

    );
    
endmodule






module uart(
    input clk,
    input rst,
    input [7:0] tx_data_in,
    input btn_start,
    output tx,
    output tx_done,

    input        rx,
    output       rx_done,
    output [7:0] rx_data

    );

    wire w_tick;

uart_tx U_UART_TX(
    .clk(clk),
    .rst(rst),
    .tick(w_tick),
    .start_trigger(btn_start),
    .data_in(tx_data_in),
    .o_tx(tx),
    .o_tx_done(tx_done)
);

baud_tick_genp U_BAUD_Tock_Gen(
    .clk(clk),
    .rst(rst),
    .baud_tick(w_tick)
);

uart_rx U_UART_RX(
    .clk(clk),
    .rst(rst),
    .tick(w_tick),
    .rx(rx),
    .rx_done(rx_done),
    .rx_data(rx_data)
);





endmodule



module uart_tx(
    input clk,
    input rst,
    input tick,
    input start_trigger,
    input [7:0] data_in,
    output o_tx, o_tx_done
);

    parameter IDLE = 0, SEND = 1, START = 2, D = 3,
              STOP = 4;


    reg tx_reg, tx_next, tx_done_reg, tx_done_next;
    reg [2:0] bit_cnt_reg, bit_cnt_next;
    reg [3:0] state, next;  
    reg [3:0] tick_cnt_reg, tick_cnt_next ;

    assign o_tx = tx_reg;
    assign o_tx_done = tx_done_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= 0;
            tx_reg <= 1'b1; // 초기값
            tx_done_reg <= 0;
            bit_cnt_reg <= 0;
            tick_cnt_reg <= 0;
        end
        else begin
            state <= next;
            tx_reg <= tx_next;
            tx_done_reg <= tx_done_next;
//            cnt_reg <= cnt_next;
            bit_cnt_reg <= bit_cnt_next;
            tick_cnt_reg <= tick_cnt_next;
        end
    end

    //next

    always @(*) begin
        next = state;
        tx_next = tx_reg;
        tx_done_next = tx_done_reg;
        bit_cnt_next = bit_cnt_reg;
        tick_cnt_next = tick_cnt_reg;
 //       cnt_next = cnt_reg;
        case (state)
            IDLE : begin
                tx_next = 1'b1; // high
                tx_done_next = 1'b0; // 초기값
                tick_cnt_next = 4'h0; // 초기값
                if(start_trigger) begin 
                    next = START;
                end
            end
            SEND : begin
                if(tick == 1'b1) begin
                    next = START;
                end
            end
            START : begin
                tx_done_next = 1'b1;
                tx_next = 1'b0; // 출력을 0으로 유지.
                if(tick == 1'b1) begin
                    if(tick_cnt_reg == 15) begin
                        next = D;
                        tick_cnt_next = 1'b0;
                        bit_cnt_next = 1'b0; // bit_cnt 초기화
                    end
                    else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            D : begin 
                tx_next = data_in[bit_cnt_reg]; //UART LSB first
                if(tick) begin
                    if(tick_cnt_reg == 15) begin
                        tick_cnt_next = 0;
                        if(bit_cnt_reg == 7) begin
                            next = STOP;
                        end
                        else begin 
                            next = D;
                            bit_cnt_next = bit_cnt_reg + 1; // bit count 증가
                        end
                    end 
                    else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
                /*
                if(tick == 1'b1) begin
                    tx_next = data_in[cnt_reg];
                    cnt_next = cnt_next + 1;
                    if(bit_cnt_next == 7) begin
                         next = STOP;
                         cnt_next = 0;
                    end
                end
                */
            end
            STOP : begin
                tx_next = 1'b1;
                if(tick == 1'b1) begin
                    if(tick_cnt_reg == 15) begin
                        next = IDLE;
                        tick_cnt_next = 1'b0;
                    end
                    else begin 
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
        endcase
    end


endmodule


// UART RX
module uart_rx (
    input clk,
    input rst,
    input tick,
    input rx,
    output rx_done,
    output [7:0] rx_data
);

    localparam IDLE = 0, START = 1, DATA = 2, STOP =3;

    reg rx_done_reg, rx_done_next;
    reg [1:0] state,next;
    reg [2:0] bit_cnt_reg, bit_cnt_next;
    reg [4:0] tick_cnt_reg, tick_cnt_next;
    reg [7:0] rx_data_reg, rx_data_next;

    assign rx_done = rx_done_reg;
    assign rx_data = rx_data_reg;

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            state           <= 0;
            rx_done_reg     <= 0;
            bit_cnt_reg     <= 0;
            tick_cnt_reg    <= 0;
            rx_data_reg     <= 0;
        end
        else begin
            state           <= next;
            rx_done_reg     <= rx_done_next;
            bit_cnt_reg     <= bit_cnt_next;
            tick_cnt_reg    <= tick_cnt_next;
            rx_data_reg     <= rx_data_next;
        end
    end


    always @(*) begin
        next = state;
        tick_cnt_next = tick_cnt_reg;
        bit_cnt_next = bit_cnt_reg;
        rx_done_next = 1'b0;
        rx_data_next = rx_data_reg;
        case (state)
            IDLE: begin
                tick_cnt_next = 0;
                bit_cnt_next = 0;
                rx_done_next = 1'b0;
                if(rx==1'b0) begin
                    next = START;
                end
            end
            START: begin
                if(tick == 1'b1) begin
                    if(tick_cnt_reg == 7) begin
                        next = DATA;
                        tick_cnt_next = 0;
                    end
                    else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            DATA: begin
                if(tick == 1'b1) begin
                    if(tick_cnt_reg == 15 ) begin
                        //read data
                        rx_data_next [bit_cnt_reg] = rx;
                        if(bit_cnt_reg == 7) begin
                            next = STOP;
                            bit_cnt_next = 0;
                            tick_cnt_next = 0; // tick cnt 초기화
                        end
                        else begin
                            next = DATA;
                            bit_cnt_next = bit_cnt_reg + 1;
                            tick_cnt_next = 0;
                        end
                    end
                    else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            STOP: begin
                if(tick) begin
                    if(tick_cnt_reg == 23) begin
                        rx_done_next = 1'b1;
                        next = IDLE;
                    end
                    else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end  
        endcase
        
    end
        

    
endmodule



module baud_tick_genp (
    input clk,
    input rst,
    output baud_tick
);

    parameter BAUD_RATE = 9600; //BAUD_RATE_19200 = 19200, ;
    localparam BAUD_COUNT = (100_000_000/BAUD_RATE)/16;
    reg [$clog2(BAUD_COUNT)-1:0] cnt_reg, cnt_next;
    reg tick_reg, tick_next;

    assign baud_tick = tick_reg;


    always @(posedge clk, posedge rst) begin

        if(rst) begin
            tick_reg <= 0;
            cnt_reg <= 0;
        end
        else begin
            cnt_reg <= cnt_next;
            tick_reg <= tick_next;
        end 
    end

    always @(*) begin
        cnt_next = cnt_reg;
        tick_next = tick_reg;
        if(cnt_reg == BAUD_COUNT-1) begin
            cnt_next = 0;
            tick_next = 1'b1; 
        end
        else begin
            cnt_next = cnt_reg + 1;
            tick_next = 1'b0;
        end
    end



endmodule