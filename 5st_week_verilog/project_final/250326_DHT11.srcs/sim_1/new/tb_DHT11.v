`timescale 1ns / 1ps


module tb_DHT11();

    reg clk;
    reg rst;
    reg btn;



    //
    reg dht_sensor_data;
    reg io_oe;


    wire [3:0] led;
    wire dht_io;


    integer  i;

    assign dht_io = (io_oe) ? dht_sensor_data : 1'bz;

    always #5 clk = ~clk;


    initial begin
        clk = 0;
        rst = 1;
        io_oe = 0;
        #100;
        rst = 0;
        #100;
        btn = 1;
        #100;
        btn = 0;
        wait(dht_io);
        #30000;
        io_oe = 1;
        dht_sensor_data = 1'b0;
        #80000;


        dht_sensor_data = 1'b1;
        #80000;


        dht_sensor_data = 1'b0;
        #50000;


        dht_sensor_data = 1'b1;
        #30000; // 30us '0'

        for(i=0;i<40;i=i+1) begin
        dht_sensor_data = 1'b0;
        #50000;
        dht_sensor_data = 1'b1;
        #70000; // 70us '1'
        end

        #100;
        btn = 1;
        #100;
        btn = 0;
        wait(dht_io);
        #30000;
        io_oe = 1;
        dht_sensor_data = 1'b0;
        #80000;


        dht_sensor_data = 1'b1;
        #80000;


        dht_sensor_data = 1'b0;
        #50000;


        dht_sensor_data = 1'b1;
        #30000; // 30us '0'

        for(i=0;i<40;i=i+1) begin
        dht_sensor_data = 1'b0;
        #50000;
        dht_sensor_data = 1'b1;
        #70000; // 70us '1'
        end





        $stop;



    end




DHT11 dut(
    .clk(clk),
    .rst(rst),
    .btn(btn),
    .dht_io(dht_io),
    .led_m(led)
);



endmodule

