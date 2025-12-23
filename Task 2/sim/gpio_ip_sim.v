`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.12.2025 10:19:27
// Design Name: 
// Module Name: gpio_ip_sim
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

//A test bench simulating gpio_ip.v

module gpio_ip_sim();

// DUT signals
reg clk;
reg rst;
reg sel;
reg write_en;
reg read_en;
reg [31:0] wdata;
wire [31:0] gpio_out;
wire [31:0] rdata;

// Instantiate DUT
gpio_ip d(
    .clk(clk),
    .rst(rst),
    .sel(sel),
    .write_en(write_en),
    .wdata(wdata),
    .gpio_out(gpio_out),
    .read_en(read_en),
    .rdata(rdata)
);

// Clock generation 10ns period
always #5 clk = ~clk;

initial begin
    
    clk = 0;
    rst = 1;
    sel = 0;
    write_en = 0;
    read_en = 0;
    wdata = 0;

    // Apply reset
    #10;
    rst = 0;

    // WRITE TEST 
    #10;
    sel = 1;
    write_en = 1;
    wdata = 32'h00000005;   // write 5
    #10;
    write_en = 0;

    //READ TEST
    #10;
    read_en = 1;
    #10;
    read_en = 0;

    //INVALID ACCESS TEST (sel=0)
    #10;
    sel = 0;
    write_en = 1;
    wdata = 32'hAAAAAAAA;
    #10;
    write_en = 0;

    #10;
    read_en = 1;
    #10;
    read_en = 0;

    #20;
end

endmodule


    
