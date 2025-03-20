`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/19 15:10:16
// Design Name: 
// Module Name: fifo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fifo #(parameter ADDR_WIDTH = 4, DATA_WIDTH = 8) (
    input clk,
    input rst,
    //write
    
    input [DATA_WIDTH-1:0] wdata,
    input wr,
    output full,

    //read
    input rd,
    output [DATA_WIDTH-1:0] rdata,
    output empty
    );

    wire [ADDR_WIDTH-1:0] waddr, raddr;

    //instance

fifo_control_unit U_FIFO_CU(
    .clk(clk),
    .rst(rst),

    .wr(wr),
    .waddr(waddr),
    .full(full),

    .rd(rd),
    .raddr(raddr),
    .empty(empty)
    );


register_file U_REG_FILE(
    .clk(clk),
    //write
    .waddr(waddr), // 4bit
    .wdata(wdata), // 8bit
    .wr({~full & wr}), // 수정
    //read
    .raddr(raddr), // 4bit
    .rdata(rdata) // 8bit
);





endmodule



module register_file (
    input clk,
    //write
    input [3:0] waddr,
    input [7:0] wdata,
    input wr,
    //read
    input [3:0] raddr,
    output [7:0] rdata
);
    reg [7:0] mem [0:15]; // 4bit address


    always @(posedge clk) begin
        if(wr) begin
            mem[waddr] <= wdata;
        end
    end

    assign rdata = mem[raddr];


    
endmodule





module fifo_control_unit #(parameter ADDR_WIDTH = 4, DATA_WIDTH = 8) (
    input clk,
    input rst,

    //write
    input wr,
    output [ADDR_WIDTH-1:0] waddr,
    output full,

    //read
    input rd,
    output [ADDR_WIDTH-1:0] raddr,
    output empty
    );

    //1bit 상태 출력
    reg full_reg, full_next;
    reg empty_reg, empty_next;

    // address 관리 
    reg [ADDR_WIDTH-1:0] w_ptr_reg, w_ptr_next;
    reg [ADDR_WIDTH-1:0] r_ptr_reg, r_ptr_next;


    assign waddr = w_ptr_reg;
    assign full = full_reg;

    assign raddr = r_ptr_reg;
    assign empty = empty_reg;



    always @(posedge clk, posedge rst) begin
        if(rst) begin
            full_reg <= 0;
            empty_reg <= 1;
            w_ptr_reg <= 0;
            r_ptr_reg <= 0;
        end
        else begin
            full_reg <= full_next;
            empty_reg <= empty_next;
            w_ptr_reg <= w_ptr_next;
            r_ptr_reg <= r_ptr_next;
        end
    end

    always @(*) begin
        full_next = full_reg;
        empty_next = empty_reg;
        w_ptr_next = w_ptr_reg;
        r_ptr_next = r_ptr_reg;
        case({wr,rd})
        2'b01 : begin // read            
            if(empty_reg == 1'b0) begin
                r_ptr_next = r_ptr_reg + 1;
                full_next = 1'b0;
                if(w_ptr_reg == r_ptr_next) begin
                    empty_next = 1'b1;
                end
            end
        end
        2'b10 : begin // write
            if(full_reg == 1'b0) begin
                w_ptr_next = w_ptr_reg + 1;
                empty_next = 1'b0;
                if(r_ptr_reg == w_ptr_next) begin
                    full_next = 1'b1;
                end
            end
        end
        2'b11 : begin
            if(empty_reg == 1'b1) begin
                w_ptr_next = w_ptr_reg + 1;
                empty_next = 1'b0;

            end
            else if (full_reg ==1'b1) begin
                r_ptr_next = r_ptr_reg + 1;
                full_next = 1'b0; 
            end

            else begin
                w_ptr_next = w_ptr_reg + 1;
                r_ptr_next = r_ptr_reg + 1;
            end
        end
        endcase    
    end
    

endmodule