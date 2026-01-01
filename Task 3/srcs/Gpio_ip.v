//This module contains modified gpio_ip for bidirectional operations.
module gpio_ip(input clk,
input rst,
input sel, //(is IO & mem_wordaddr[IO_gpio_bit])
input write_en, //mem_writestrobe
input [31:0]wdata,
 input read_en,
output reg [31:0]rdata,
               //mem_wordaddr[4:3]
input [1:0]offset,
//GPIO Registers
inout [4:0]gpio_pins // PINS on fpga
);
localparam data=2'b00;
localparam dir=2'b01;
localparam read=2'b10;

reg [31:0]gpio_data;
reg [31:0]gpio_dir;

always @(posedge clk) begin
    if(rst)begin
        gpio_data<=0;
        gpio_dir<=0;
    end
    else if(sel && write_en) begin
    case(offset)
        data : begin gpio_data<=wdata; end        
        
        dir  : begin gpio_dir<=wdata; end
        
        default : ;
    endcase
    end 
    end
    
//output selection
assign gpio_pins = gpio_dir ? gpio_data : 5'bz;
//assigns data in gpio_data if output pin, lets input drive if input pin


//read
wire [31:0]gpio_read = {27'b0,gpio_pins}; //read gpio bits
always @(*) begin
    if(sel & read_en) begin
    case(offset)
          read  :  rdata<=gpio_read;
          data  :  rdata<=gpio_data;
          dir   :  rdata<=gpio_dir;
          default : rdata<=0;
    endcase      
    end
    else rdata<=0;
    
end
  
endmodule
