`timescale 1ns / 1ps

module fsm_state(
    input clk,rst,
    input [2:0] sw,
    output [2:0]led

    );

    parameter IDLE = 0 , st1 = 1 , st2 = 2, st3 = 3, st4 = 4;

    reg [2:0] state,next,r_led;



    assign led = r_led;


    always @(posedge clk, posedge rst) begin
        if (rst) state = 0 ;
        else state<=next;
    end


//무어
    always @(*) begin
        next = state;
        case (state)
            IDLE: if(sw == 3'b001) next = st1 ;
                    else if (sw == 3'b010) next = st2;
                    else next = state;
            st1: if(sw == 3'b010) next = st2;
            st2: if(sw == 3'b100) next = st3;
            st3: if(sw == 3'b000) next = IDLE;
                else if(sw == 3'b111) next = st4;
                else if(sw == 3'b001) next = st1;
                else next = state;
            st4: if(sw == 3'b100) next = st3;
            default: next = state;
        endcase
    end

/*
    always @(*) begin
        case (state)
            IDLE: r_led = 3'b000;
            st1: r_led = 3'b001;
            st2: r_led = 3'b010;
            st3: r_led = 3'b100;
            st4: r_led = 3'b111;
            default: r_led = 0;
        endcase
    end
*/
    always @(*) begin
        case (state)
            IDLE: if(sw == 3'b001) r_led = 3'b001;
                    else if(sw == 3'b010) r_led = 3'b010;
                    else r_led = 3'b000;
            st1: if(sw == 3'b010) r_led = 3'b010;
                else r_led = 3'b001;
            st2: if(sw == 3'b100) r_led = 3'b100;
                else r_led = 3'b010;
            st3: if(sw == 3'b000) r_led = 3'b000;
                else if(sw == 3'b001) r_led = 3'b001;
                else if(sw == 3'b111) r_led = 3'b111;
                else r_led = 3'b100;
            st4: if(sw == 3'b100) r_led = 3'b100;
                    else r_led = 3'b111;
            default: r_led = 0;
        endcase
    end

//밀리
/*    always @(*) begin
        next = state;
        r_led = led;
        case (state)
            IDLE: if(sw == 3'b001) begin next = st1; r_led = 3'b001; end
                    else if (sw == 3'b010) begin next = st2; r_led = 3'b010;  end
                    else begin next = state; r_led = 3'b000; end
            st1: if(sw == 3'b010) begin next = st2; r_led = 3'b010; end
            st2: if(sw == 3'b100) begin next = st3; r_led = 3'b100; end
            st3: if(sw == 3'b000) begin next = IDLE; r_led = 3'b000; end
                else if(sw == 3'b111) begin next = st4; r_led = 3'b111; end
                else if(sw == 3'b001) begin next = st1; r_led = 3'b001; end
                else next = state;
            st4: if(sw == 3'b100) begin next = st3; r_led = 3'b100; end
            default: next = state;
        endcase
    end
*/




endmodule
