`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.12.2025 14:30:59
// Design Name: 
// Module Name: gpio_ip
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

//This file contains the RTL for GPIO_IP module


module gpio_ip(input clk,
input rst,
input sel, //(is IO & mem_wordaddr[IO_gpio_bit])
input write_en, //mem_writestrobe
input [31:0]wdata,
output reg [31:0]gpio_out, //gpio output 
input read_en,
output reg [31:0]rdata
);
always @(posedge clk) begin
    if (rst)
        gpio_out<=0;
    else if(sel && write_en)
        gpio_out<=wdata;  // write data into gpio regster when write_en is 1
end    
always @(*)begin
    if(read_en && sel)
        rdata<=gpio_out;
    else
        rdata<=0;
end
endmodule
