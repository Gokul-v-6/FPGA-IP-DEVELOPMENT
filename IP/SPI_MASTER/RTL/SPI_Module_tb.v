`timescale 1ns / 1ps
`default_nettype none

module tb_spi_master_ip;

    /* -----------------------------
       Clock and reset
       ----------------------------- */
    reg clk;
    reg rst;

    always #5 clk = ~clk;   // 100 MHz clock

    /* -----------------------------
       Bus interface
       ----------------------------- */
    reg         sel;
    reg         w_en;
    reg         r_en;
    reg [1:0]   offset;
    reg [31:0]  wdata;
    wire [31:0] rdata;

    /* -----------------------------
       SPI signals
       ----------------------------- */
    wire sclk;
    wire mosi;
    wire miso;
    wire cs_n;

    /* -----------------------------
       DUT
       ----------------------------- */
    SPI dut (
        .clk     (clk),
        .rst     (rst),
        .sel     (sel),
        .w_en(w_en),
        .r_en (r_en),
        .offset  (offset),
        .wdata   (wdata),
        .rdata   (rdata),
        .sclk    (sclk),
        .mosi    (mosi),
        .miso    (miso),
        .cs_n    (cs_n)
    );

    /* -----------------------------
       Loopback: MISO = MOSI
       ----------------------------- */
    assign miso = mosi;

    /* -----------------------------
       Register offsets
       ----------------------------- */
    localparam CTRL   = 2'b00;
    localparam TXDATA = 2'b01;
    localparam RXDATA = 2'b10;
    localparam STATUS = 2'b11;

    /* -----------------------------
       Bus tasks
       ----------------------------- */
    task write_reg(input [1:0] off, input [31:0] val);
        begin
            @(posedge clk);
            sel      <= 1'b1;
            w_en <= 1'b1;
            r_en  <= 1'b0;
            offset   <= off;
            wdata    <= val;

            @(posedge clk);
            sel      <= 1'b0;
            w_en <= 1'b0;
            wdata    <= 32'd0;
        end
    endtask

    task read_reg(input [1:0] off, output [31:0] val);
        begin
            @(posedge clk);
            sel      <= 1'b1;
            r_en  <= 1'b1;
            w_en <= 1'b0;
            offset   <= off;

            @(posedge clk);
            val = rdata;

            sel     <= 1'b0;
            r_en <= 1'b0;
        end
    endtask

    /* -----------------------------
       Test sequence
       ----------------------------- */
    reg [31:0] status;
    reg [31:0] rxdata;

    initial begin
        /* Init */
        clk = 0;
        rst = 1;
        sel = 0;
        w_en = 0;
        r_en = 0;
        offset = 0;
        wdata = 0;

        /* Reset */
        repeat (5) @(posedge clk);
        rst = 0;

        $display("---- SPI MASTER TEST START ----");

        /* Enable SPI + CLKDIV = 4 */
        write_reg(CTRL, (1 << 0) | (4 << 8));

        /* Write TXDATA = 0xA5 */
        write_reg(TXDATA, 32'h000000A5);

        /* START transfer */
        write_reg(CTRL, (1 << 1) | (1 << 0));

        /* Poll DONE */
        while (status[1] == 1'b0) begin
            read_reg(STATUS, status);
        end

        $display("DONE asserted");

        /* Read RXDATA */
        read_reg(RXDATA, rxdata);

        if (rxdata[7:0] == 8'hA5)
            $display("PASS: RXDATA = 0x%02h", rxdata[7:0]);
        else
            $display("FAIL: RXDATA = 0x%02h", rxdata[7:0]);

        $display("---- SPI MASTER TEST END ----");

        #200;
        $finish;
    end

endmodule
