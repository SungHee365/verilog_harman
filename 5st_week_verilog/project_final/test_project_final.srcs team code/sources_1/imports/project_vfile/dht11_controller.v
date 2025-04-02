

`timescale 1ns/1ns

module top_dht11(
    input clk,          // 100mhz on fpga oscillator
    input reset,
    input btn_start,
    input tick,
    input tick_uart,
    inout [7:0] dht_io,
    output [7:0] humidity_int,
    output [7:0] humidity_dec,
    output [7:0] temperature_int,
    output [7:0] temperature_dec,
    output led,
    output [7:0] dht_data,
    output dht_we
);



wire [7:0] w_humidity_int,w_humidity_dec;
wire [7:0] w_temperature_int,w_temperature_dec;

wire [7:0] w_hum_int1, w_hum_int10, w_hum_dec1, w_hum_dec10;
wire [7:0] w_tem_int1, w_tem_int10, w_tem_dec1, w_tem_dec10;

wire [7:0] o_hum_int1, o_hum_int10, o_hum_dec1, o_hum_dec10;
wire [7:0] o_tem_int1, o_tem_int10, o_tem_dec1, o_tem_dec10;


assign humidity_int = w_humidity_int;
assign humidity_dec = w_humidity_dec;
assign temperature_int = w_temperature_int;
assign temperature_dec = w_temperature_dec;

dht11_controller U_dht_ctrl(
    .clk(clk),          // 100mhz on fpga oscillator
    .reset(reset),        // reset btn
    .btn_start(btn_start),    // start trigger
    .tick(tick),         // 1us tick
    .dht_io(dht_io),       // 1-wire data path

    .humidity_int(w_humidity_int),
    .humidity_dec(w_humidity_dec),
    .temperature_int(w_temperature_int),
    .temperature_dec(w_temperature_dec),
    .led(), 
    .led_checksum(w_error),
    .pulse_done(w_pulse_done)
);

digit_splitter_dht U_hum_int(
    .clk(clk),
    .rst(rst),
    .bcd(w_humidity_int),
    .digit_1(w_hum_int1),
    .digit_10(w_hum_int10)
);

digit_splitter_dht U_hum_dec(
    .clk(clk),
    .rst(rst),
    .bcd(w_humidity_dec),
    .digit_1(w_hum_dec1),
    .digit_10(w_hum_dec10)
);

digit_splitter_dht U_tem_int(
    .clk(clk),
    .rst(rst),
    .bcd(w_temperature_int),
    .digit_1(w_tem_int1),
    .digit_10(w_tem_int10)
);

digit_splitter_dht U_tem_dec(
    .clk(clk),
    .rst(rst),
    .bcd(w_temperature_dec),
    .digit_1(w_tem_dec1),
    .digit_10(w_tem_dec10)
);



    send_num_data_dht U_Send_Num(
        .clk(clk),
        .reset(reset),
        .tick(tick_uart),
        .pulse_done(w_pulse_done),
        .error(w_error),
        .hum_int1(o_hum_int1), 
        .hum_int10(o_hum_int10), 
        .hum_dec1(o_hum_dec1), 
        .hum_dec10(o_hum_dec10),
        .tem_int1(o_tem_int1), 
        .tem_int10(o_tem_int10), 
        .tem_dec1(o_tem_dec1), 
        .tem_dec10(o_tem_dec10),
        .rx_data(dht_data),
        .we(dht_we) // tx fifo 쓰기기
    );

test_dht U_hum_int_t(
    .clk(clk),
    .rst(rst),
    .w_digit_1(w_hum_int1),
    .w_digit_10(w_hum_int10),
    .o_digit_1(o_hum_int1),
    .o_digit_10(o_hum_int10)
);

test_dht U_hum_dec_t(
    .clk(clk),
    .rst(rst),
    .w_digit_1(w_hum_dec1),
    .w_digit_10(w_hum_dec10),
    .o_digit_1(o_hum_dec1),
    .o_digit_10(o_hum_dec10)
);

test_dht U_tem_int_t(
    .clk(clk),
    .rst(rst),
    .w_digit_1(w_tem_int1),
    .w_digit_10(w_tem_int10),
    .o_digit_1(o_tem_int1),
    .o_digit_10(o_tem_int10)
);

test_dht U_tem_dec_t(
    .clk(clk),
    .rst(rst),
    .w_digit_1(w_tem_dec1),
    .w_digit_10(w_tem_dec10),
    .o_digit_1(o_tem_dec1),
    .o_digit_10(o_tem_dec10)
);


endmodule







module dht11_controller(
    input clk,          // 100mhz on fpga oscillator
    input reset,        // reset btn
    input btn_start,    // start trigger
    input tick,         // 1us tick
    inout dht_io,       // 1-wire data path

    output [7:0] humidity_int,
    output [7:0] humidity_dec,
    output [7:0] temperature_int,
    output [7:0] temperature_dec,
    output [3:0] led, // state 변화 확인을 위한 led
    output led_checksum,
    output pulse_done
);
    parameter   SEND            = 1800, // FPGA to DHT11 trigger send
                WAIT_RESPONSE   = 3 ,   // wait for responce from dht11
                SYNC            = 8,    // wait for transieve
                DATA_COMMON     = 5,  // common low with s  
                DATA_STANDARD   = 4,  // 40us 기준  -> 짧으면 0, 길면 1
                STOP            = 5,  // 데이터 다 받고 다시 high 상태 가기전 대기시간
                BIT_DHT11       = 40, // 40비트 데이터비트
                TIME_OUT        = 2000;

    // 1. state definition
    localparam  IDLE            = 0, // 초기상태
                START           = 1, // 입력 trigger
                WAIT            = 2, // 응답 대기
            //  READ    = 3;
                SYNC_LOW        = 3, // dht11로 부터 응답 받음
                SYNC_HIGH       = 4, // 데이터 송수신전 대기
                DATA_SYNC       = 5, // 온습도 데이터(40bit) 송수신
                DATA_DECISION   = 6, // 통신 종료후 다시 high로로
                DONE            = 7; // 데이터 송수신 종료 후 다시 PULL UP HIGH 상태로로

    // register for CU
    reg [2:0] state, next;
    reg [$clog2(TIME_OUT)-1:0] count_reg, count_next;
    
    reg io_out_reg, io_out_next;    // 
    reg io_oe_reg, io_oe_next;      // for 3-state buffer enable 
    reg led_ind_reg, led_ind_next;  // led indicator for check appropriate

    reg [5:0] bit_count_reg, bit_count_next;  // for count 40 bit 
    reg [39:0] data_reg, data_next; // store data register

    reg led_check_reg, led_check_next;
    assign led_checksum = led_check_reg;

    reg pulse_done_reg, pulse_done_next;
    assign pulse_done = pulse_done_reg;

    // out 3 state on/off
    assign dht_io = (io_oe_reg) ? io_out_reg :1'bz;

    // led for configure state
    assign led  = {led_ind_reg,state};

    // assign humidity , temperature
    assign humidity_int = data_reg [39:32]; // data 중 습도 정수부분
    assign humidity_dec = data_reg [31:24];
    assign temperature_int = data_reg [23:16]; // data 중 온도 정수 부분
    assign temperature_dec = data_reg [15:8];


    // 2. for continue next state
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            state               <= IDLE;
            count_reg           <= 0;
            bit_count_reg       <= 0;  
            data_reg            <= 0;  
            io_out_reg          <= 1'b1;
            io_oe_reg           <= 0;
            led_ind_reg         <= 0;
            led_check_reg       <= 1'b0;
            pulse_done_reg      <= 1'b0;
        end
        else begin
            state               <= next;
            count_reg           <= count_next;
            bit_count_reg       <= bit_count_next;  
            data_reg            <= data_next; 
            io_out_reg          <= io_out_next;
            io_oe_reg           <= io_oe_next;
            led_ind_reg         <= led_ind_next;
            led_check_reg       <= led_check_next;
            pulse_done_reg      <= pulse_done_next;
        end
    end
    
    // 3. output combinational logic
    always @(*) begin
        next                 = state;
        count_next           = count_reg;
        io_out_next          = io_out_reg;
        io_oe_next           = io_oe_reg;
        bit_count_next       = bit_count_reg;
        data_next            = data_reg;
        led_ind_next         = 0;
        led_check_next       = 1'b0;
        pulse_done_next     = 1'b0;

        case (state)
            IDLE : begin // 0
                led_check_next = 1'b0;
                io_out_next = 1'b1;
                io_oe_next  = 1'b1;
                pulse_done_next = 1'b0;

                if (btn_start == 1'b1) begin
                    next       = START;
                    count_next = 0;
                end
            end

            START : begin // 1
                io_out_next = 1'b0;

                if(tick == 1'b1)begin
                    if(count_reg == SEND -1) begin                        
                        next       = WAIT;
                        count_next = 0;
                    end
                    else begin                     
                        count_next = count_reg + 1;
                    end
                end
            end

            WAIT : begin // 2
                io_out_next = 1'b1;

                if(tick == 1'b1) begin
                    if(count_reg == WAIT_RESPONSE - 1) begin
                        next       = SYNC_LOW;
                        io_oe_next = 1'b0;
                        count_next = 0;
                    end
                    else begin
                        count_next = count_reg + 1;
                    end
                end
            end
/* for middle testbench
            READ : begin
                // io oe change
                // output open - high z
                io_oe_next = 1'b0;

                if(tick == 1'b1) begin
                    if(count_reg == TIME_OUT) begin
                        next       = IDLE;
                        count_next = 0;
                    end
                    else begin
                        count_next = count_reg +1;
                    end
                end

                if (dht_io == 1'b0) begin
                    led_ind_next = 1'b1;
                end
                else begin
                    led_ind_next = 1'b0;
                end
                
            end
*/
            SYNC_LOW : begin // 3
                if(tick == 1'b1) begin
                    if(count_reg == 1) begin
                        if(dht_io == 1'b1) begin
                            next = SYNC_HIGH;
                        end
                    count_next = 0;
                    end
                    else begin
                        count_next = count_reg + 1;
                    end
                end
            end

            SYNC_HIGH : begin // 4
                if(tick == 1'b1) begin
                    if(count_reg == 1) begin
                        if(dht_io == 1'b0) begin
                            next = DATA_SYNC;
                        end
                    count_next = 0;
                    end
                    else begin
                        count_next = count_reg + 1;
                    end
                end
            end
            
            DATA_SYNC : begin // 5
                if(tick == 1'b1) begin
                    if(count_reg == 1) begin
                        if(dht_io == 1'b1) begin
                            next = DATA_DECISION;
                        end
                    count_next = 0;
                    end
                    else begin
                        count_next = count_reg + 1;
                    end
                end
            end

           DATA_DECISION: begin // 6
                if (tick == 1'b1) begin 
                    if (dht_io == 1'b1) begin
                        count_next = count_reg + 1;  // HIGH 지속 시간 측정\
                        led_ind_next = 1'b1;
                    end
                    else begin
                        led_ind_next = 1'b0;
                        if (count_reg <= DATA_STANDARD - 1) begin
                            data_next = {data_reg[38:0], 1'b0};  // 40µs보다 짧으면 0
                        end
                        else begin
                            data_next = {data_reg[38:0], 1'b1};  // 40µs보다 길면 1
                        end

                        bit_count_next = bit_count_reg + 1;
                        count_next = 0;  // 다음 비트를 위해 카운터 초기화

                        if (bit_count_reg == BIT_DHT11 - 1) begin
                            next = DONE;  // 40비트 수집 완료 후 DONE 상태로 이동
                            bit_count_next = 0;
                        end
                        else begin
                            next = DATA_SYNC;  // 다음 비트 수집을 위해 DATA_SYNC로 다시 이동
                        end
                    end
                end
            end

            DONE : begin // 7
                if (tick == 1'b1) begin
                    if(count_reg == STOP - 1) begin
                        if ((data_reg[39:32] + data_reg[31:24] + data_reg[23:16] + data_reg[15:8]) == data_reg[7:0]) begin
                            next = IDLE;
                            io_out_next = 1'b1;
                            io_oe_next = 1'b1;  // pull-up 유지
                            count_next = 0;
                            led_check_next = 1'b0;
                            pulse_done_next = 1'b1;
                        end 
                        else begin
                            next = IDLE;
                            io_out_next = 1'b1;
                            io_oe_next = 1'b1;  // pull-up 유지
                            count_next = 0;
                            led_check_next = 1'b1;
                            pulse_done_next = 1'b1;
                        end
                    end
                    else begin
                        count_next = count_reg + 1;
                    end
                end
            end
        endcase        
    end
endmodule




module send_num_data_dht (
    input clk,
    input reset,
    input tick,
    input pulse_done,
    input error,
    input [7:0] hum_int1, hum_int10, hum_dec1, hum_dec10,
    input [7:0] tem_int1, tem_int10, tem_dec1, tem_dec10,
    output [7:0] rx_data,
    output we
);
    parameter IDLE=0, p_hum_int1=1, p_hum_int10=2, p_hum_dec1=3, p_hum_dec10=5 , p_tem_int1=6 , p_tem_int10=7 , p_tem_dec1=8 , p_tem_dec10=9 , C=10, h=11, E=12, R1=13, R2=14, O=15, R3=16, CR=17, LF=18, dot = 19, dotw = 20;
    reg [4:0] state, next;
    reg [7:0] rx_data_reg, rx_data_next;
    reg we_next, we_reg;

    assign rx_data = rx_data_reg;
    assign we = we_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= 0;
            rx_data_reg <= 0;
            we_reg <= 0;
        end else begin
            state <= next;
            rx_data_reg <= rx_data_next;
            we_reg <= we_next;
        end
    end

    always @(*) begin
        next = state;
        rx_data_next = rx_data_reg;
        we_next = we_reg;
        case (state)
            IDLE: begin
                we_next = 0;

             //   if (error) begin
             //       next = E;
            //    end
            //    else begin
                    if (pulse_done) begin
                        next = p_hum_int10;
                    end
           //     end
            end
            p_hum_int10: begin
                we_next = 0;
                if (tick) begin
                    //if(hum_int10 != 0) begin 
                        rx_data_next = hum_int10;
                    //end
                    next = p_hum_int1;
                    we_next = 1;
                end
            end
            p_hum_int1: begin
                we_next = 0;
                if (tick) begin
                    //if(hum_int1 != 0) begin 
                        rx_data_next = hum_int1;
                    //end
                    next = dot;
                    we_next = 1;
                end
            end
            dot : begin
                we_next = 0;
                if (tick) begin
                    rx_data_next = 8'h2E;
                    next = p_hum_dec10;
                    we_next = 1;
                end
            end
            p_hum_dec10: begin
                we_next = 0;
                if (tick) begin
                    //if(hum_dec10 != 0) begin 
                        rx_data_next = hum_dec10;
                    //end
                    next = p_hum_dec1;
                    we_next = 1;
                end
            end
            p_hum_dec1: begin
                we_next = 0;
                if (tick) begin
                    //if(hum_dec1 != 0) begin 
                        rx_data_next = hum_dec1;
                    //end
                    next = h;
                    we_next = 1;
                end
            end
            p_tem_int10: begin
                we_next = 0;
                if (tick) begin
                    //if(tem_int10 != 0) begin 
                        rx_data_next = tem_int10;
                    //end
                    next = p_tem_int1;
                    we_next = 1;
                end
            end
            p_tem_int1: begin
                we_next = 0;
                if (tick) begin
                    //if(tem_int1 != 0) begin 
                        rx_data_next = tem_int1;
                    //end
                    next = dotw;
                    we_next = 1;
                end
            end
            dotw : begin
                we_next = 0;
                if (tick) begin
                    rx_data_next = 8'h2E;
                    next = p_tem_dec10;
                    we_next = 1;
                end
            end
            p_tem_dec10: begin
                we_next = 0;
                if (tick) begin
                    //if(tem_dec10 != 0) begin 
                        rx_data_next = tem_dec10;
                    //end
                    next = p_tem_dec1;
                    we_next = 1;
                end
            end
            p_tem_dec1: begin
                we_next = 0;
                if (tick) begin
                    //if(tem_dec1 != 0) begin 
                        rx_data_next = tem_dec1;
                    //end
                    next = C;
                    we_next = 1;
                end
            end
            C: begin
                we_next = 0;
                if (tick) begin
                    rx_data_next = 8'h63;
                    next = CR;
                    we_next = 1;
                end
            end
            h: begin
                we_next = 0;
                if (tick) begin
                    rx_data_next = 8'h25;
                    next = p_tem_int10;
                    we_next = 1;
                end
            end
 /*           
            E: begin
                we_next = 0;
                if (tick) begin
                    rx_data_next = 8'h45;
                    next = R1;
                    we_next = 1;
                end
            end
            R1: begin
                we_next = 0;
                if (tick) begin
                    rx_data_next = 8'h52;
                    next = R2;
                    we_next = 1;
                end
            end
            R2: begin
                we_next = 0;
                if (tick) begin
                    rx_data_next = 8'h52;
                    next = O;
                    we_next = 1;
                end
            end
            O: begin
                we_next = 0;
                if (tick) begin
                    rx_data_next = 8'h4F;
                    next = R3;
                    we_next = 1;
                end
            end
            R3: begin
                we_next = 0;
                if (tick) begin
                    rx_data_next = 8'h52;
                    next = CR;
                    we_next = 1;
                end
            end
     */       
            CR: begin
                we_next = 0;
                if (tick) begin
                    //if(error==0) begin
                        rx_data_next = 8'h0D;
                        next = LF;
                        we_next = 1;
                    //end
                end
            end
            LF: begin
                we_next = 0;
                if (tick) begin
                    //if(error==0) begin
                        rx_data_next = 8'h0A;
                        next = IDLE;
                        we_next = 1;
                    //end
                end
            end
        endcase
    end
endmodule



module digit_splitter_dht (
    input clk,rst,
    input [8:0] bcd,
    output reg [7:0] digit_1,
    output reg [7:0] digit_10
);
    reg [8:0] bcd_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) 
        begin
            bcd_reg <= 0;
            digit_1 <= 0;
            digit_10 <= 0;
        end 
        else 
        begin
            bcd_reg <= bcd;
            digit_1 <= (bcd_reg % 10) + 48;
            digit_10 <= ((bcd_reg / 10) % 10) + 48;
        end
    end
endmodule

module test_dht(
    input clk,rst,
    input [7:0] w_digit_1,w_digit_10,
    output reg [7:0] o_digit_1,o_digit_10
);

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            o_digit_1 <= 0;
            o_digit_10 <= 0;
        end
        else begin
            o_digit_1 <= w_digit_1;
            o_digit_10 <= w_digit_10;
        end
        
    end
    
endmodule