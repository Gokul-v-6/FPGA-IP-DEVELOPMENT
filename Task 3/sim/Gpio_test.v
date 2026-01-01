`timescale 1ns / 1ps

module tb_gpio_ip;

    // Clock & reset
    reg clk;
    reg rst;

    // Bus interface
    reg sel;
    reg write_en;
    reg read_en;
    reg [31:0] wdata;
    reg [1:0] offset;
    wire [31:0] rdata;

    // GPIO
    wire [4:0] gpio_pins;
    reg  [4:0] ext_gpio_drive;
    reg        ext_drive_en;

    // Address offsets (must match DUT)
    localparam DATA = 2'b00;
    localparam DIR  = 2'b01;
    localparam READ = 2'b10;

    // External device driving GPIO pins
    assign gpio_pins = ext_drive_en ? ext_gpio_drive : 5'bz;

    // DUT
    gpio_ip dut (
        .clk(clk),
        .rst(rst),
        .sel(sel),
        .write_en(write_en),
        .wdata(wdata),
        .read_en(read_en),
        .rdata(rdata),
        .offset(offset),
        .gpio_pins(gpio_pins)
    );

    // Clock generation (10 ns period)
    always #5 clk = ~clk;

    initial begin
        // Initial values
        clk = 0;
        rst = 1;
        sel = 0;
        write_en = 0;
        read_en = 0;
        wdata = 0;
        offset = 0;
        ext_gpio_drive = 0;
        ext_drive_en = 0;

        // Apply reset
        #20;
        rst = 0;

        // -------------------------
        // Write GPIO_DIR (outputs)
        // -------------------------
        @(posedge clk);
        sel = 1;
        write_en = 1;
        offset = DIR;
        wdata = 32'h0000001F; // enable GPIO as output

        @(posedge clk);
        write_en = 0;

        // -------------------------
        // Write GPIO_DATA
        // -------------------------
        @(posedge clk);
        write_en = 1;
        offset = DATA;
        wdata = 32'h00000015; // 10101

        @(posedge clk);
        write_en = 0;

        // -------------------------
        // Read GPIO_DATA
        // -------------------------
        @(posedge clk);
        read_en = 1;
        offset = DATA;

        @(posedge clk);
        $display("READ GPIO_DATA = %b", rdata[4:0]);
        read_en = 0;

        // -------------------------
        // Read GPIO_DIR
        // -------------------------
        @(posedge clk);
        read_en = 1;
        offset = DIR;

        @(posedge clk);
        $display("READ GPIO_DIR  = %b", rdata[4:0]);
        read_en = 0;

        // -------------------------
        // Configure GPIO as input
        // -------------------------
        @(posedge clk);
        write_en = 1;
        offset = DIR;
        wdata = 32'h00000000;

        @(posedge clk);
        write_en = 0;

        // External device drives pins
        ext_drive_en = 1;
        ext_gpio_drive = 5'b11010;

        // -------------------------
        // Read GPIO_READ
        // -------------------------
        @(posedge clk);
        read_en = 1;
        offset = READ;

        @(posedge clk);
        $display("READ GPIO_PINS = %b", rdata[4:0]);
        read_en = 0;

        // Finish
        #20;
        $finish;
    end

endmodule
