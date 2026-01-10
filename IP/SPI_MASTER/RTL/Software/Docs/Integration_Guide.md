# SPI Master IP (Mode-0) – Integration Guide (VSDSquadron SoC)

This guide explains how to integrate the **SPI Master IP (Mode-0)** into a **VSDSquadron RISC-V SoC** design.  
It assumes the reader is familiar with VSDSquadron FPGA SoC integration and memory-mapped I/O, but not with the internal RTL of this IP.

---

## Required RTL Files

Copy the following RTL files into your SoC RTL project:
<details>
<summary>  SPI Master IP (click to expand)  </summary>
  
``` verilog
module SPI(
//Global clk and rst
    input clk,
    input rst,
//Control and data signals
    input sel,
    input w_en,
    input r_en,
    input [31:0] wdata,
    output reg [31:0] rdata,
    input [1:0] offset,
//SPI Master signals
    output reg sclk,
    output reg mosi,
    input miso,
    output reg cs_n
    );

//register file
localparam CNTRL=2'b00;
localparam TXDATA=2'b01;
localparam RXDATA=2'b10;
localparam STATUS=2'b11;

//control register fields
reg en;
reg start;
reg [7:0]clkdiv; 

//status reg
reg busy;
reg done;

//counter for clkddivider
reg [7:0]clk_cnt;


//bit counter for transfering 8 bits
reg [2:0]bit;

//Data registers
reg [7:0]tx;
reg [7:0]rx;
reg [7:0]rxdata; //rx data will be stored in done phase to avoid corruption
//REGISTER write 
always @(posedge clk) begin
    if(rst) begin
        en<=0;
        start<=0;
        clkdiv<=0;
        bit<=0;
        busy<=0;
        done<=0;
        clkdiv<=0;
        tx<=0;
        rx<=0;
        rxdata<=0;
        end
        
     else if(sel && w_en) begin
        case(offset) 
            CNTRL: begin en<=wdata[0];
                            clkdiv<=wdata[15:8];
                            if(~busy)
                                start<=wdata[1];
                   end
            TXDATA: begin tx<=wdata[7:0];
                    end
            STATUS: begin if(wdata[1])
                            done<=0;
                    end
         endcase
      end       
end
  
//FSM
reg [1:0]state;

localparam IDLE=2'b00;
localparam  DATA_STATE=2'b01;
localparam DONE=2'b10;


always @(posedge clk) begin
    if(rst) begin
            state   <= IDLE;
            sclk    <= 1'b0;
            cs_n    <= 1'b1;
            mosi    <= 1'b0;
            busy    <= 1'b0;
            done    <= 1'b0;
            clk_cnt <= 8'd0;
            bit <= 3'd0;
            rx<= 8'd0;
            rxdata  <= 8'd0;
        end
        
      
     else begin
        case(state)
            IDLE:begin sclk<=1'b0;
                        cs_n<=1'b1;
                        busy<=1'b0;
                        if(en && start && ~busy) begin
                            cs_n<=1'b0;
                            busy<=1'b1;
                            clk_cnt<=8'd0;
                            bit<=3'd7;
                            mosi<=tx[7];
                            rx<=0;
                            done<=1'b0;
                            state<=DATA_STATE;
                         end                             
                   end
      DATA_STATE: begin if(clk_cnt == clkdiv)begin
                            clk_cnt<=8'd0;
                            sclk<=~sclk;
                          //Sample MISO at falling eddge according to mode 0  
                            if(sclk == 1'b0)
                                rx<={rx[6:0],miso};
                         //Shift at Rising Edge       
                            else begin 
                                    if(bit != 0) begin
                                        bit<=bit - 1;
                                        mosi<=tx[bit - 1];
                                    end
                                    else state<=DONE;
                            end
                         end
                         else clk_cnt<=clk_cnt + 1;                                                       
                    end
            DONE: begin cs_n<=1'b1;
                        sclk<=1'b0;
                        busy<=1'b0;
                        done<=1'b1;
                        rxdata<=rx;
                        state<=IDLE;
                    end    
         default: state<=IDLE;
        endcase
    end
end

//READ
always @(*) begin
    if(sel && r_en) begin
        case(offset)
            CNTRL: rdata = {16'd0,clkdiv , 6'd0, start, en};
            TXDATA: rdata = {24'd0, tx};
            RXDATA: rdata = {24'd0,rxdata};
            STATUS: rdata = {29'd0, 1'b1, done, busy};
            default: rdata= 32'b0;
         endcase
      end
end             
endmodule
```
</details>

Below is SoC Top level RTL 
<details>
<summary>  SoC (click to expand)  </summary>
  
```verilog
module SOC (
   //  input 	     CLK,  // system clock 
    input 	     RESET,// reset button
    inout [4:0] LEDS, // GPIO pins
    input 	     RXD,  // UART receive
    output 	     TXD,   // UART transmit
    
);

   wire clk;
   wire resetn;

   wire [31:0] mem_addr;
   wire [31:0] mem_rdata;
   wire mem_rstrb;
   wire [31:0] mem_wdata;
   wire [3:0]  mem_wmask;

   Processor CPU(
      .clk(clk),
      .resetn(resetn),		 
      .mem_addr(mem_addr),
      .mem_rdata(mem_rdata),
      .mem_rstrb(mem_rstrb),
      .mem_wdata(mem_wdata),
      .mem_wmask(mem_wmask)
   );
   
   wire [31:0] RAM_rdata;
   wire [29:0] mem_wordaddr = mem_addr[31:2];
   wire isIO  = mem_addr[22];
   wire isRAM = !isIO;
   wire mem_wstrb = |mem_wmask;
   
   Memory RAM(
      .clk(clk),
      .mem_addr(mem_addr),
      .mem_rdata(RAM_rdata),
      .mem_rstrb(isRAM & mem_rstrb),
      .mem_wdata(mem_wdata),
      .mem_wmask({4{isRAM}}&mem_wmask)
   );


   // Memory-mapped IO in IO page, 1-hot addressing in word address.   
   localparam IO_gpio_bit      = 0;  // gpio ip 
   localparam IO_UART_DAT_bit  = 1;  // W data to send (8 bits) 
   localparam IO_UART_CNTL_bit = 2;  // R status. bit 9: busy sending
   


   wire uart_valid = isIO & mem_wstrb & mem_wordaddr[IO_UART_DAT_bit];
   wire uart_ready;
   
   corescore_emitter_uart #(
      .clk_freq_hz(12*1000000),
      .baud_rate(9600)
      //   .baud_rate(1000000)
   ) UART(
      .i_clk(clk),
      .i_rst(!resetn),
      .i_data(mem_wdata[7:0]),
      .i_valid(uart_valid),
      .o_ready(uart_ready),
      .o_uart_tx(TXD)      			       
   );

   wire [31:0] gpio_out;
   wire [31:0] gpio_rdata; // reads the data stored in gpio register in case of read op
   gpio_ip GPIO(
      .clk(clk),
      .rst(!resetn),
      .sel(isIO & mem_wordaddr[IO_gpio_bit]),
      .write_en(mem_wstrb),
      .wdata(mem_wdata),
      .gpio_pins(LEDS),
      .read_en(mem_rstrb),
      .rdata(gpio_rdata),
      .offset(mem_wordaddr[4:3])
   );




   wire [31:0] IO_rdata = 
	       mem_wordaddr[IO_UART_CNTL_bit] ? { 22'b0, !uart_ready, 9'b0}
	                                       : mem_wordaddr[IO_gpio_bit] ? gpio_rdata
                                                                        : mem_addr[12] ? spi_rdata : 32'b0;
   
   assign mem_rdata = isRAM ? RAM_rdata :
	                      IO_rdata ;
   
   
`ifdef BENCH
   always @(posedge clk) begin
      if(uart_valid) begin
	 $write("%c", mem_wdata[7:0] );
	 $fflush(32'h8000_0001);
      end
   end
`endif   
   
   wire clk_int;

   SB_HFOSC #(
   .CLKHF_DIV("0b10") // 12 MHz
   ) hfosc (
      .CLKHFPU(1'b1),
      .CLKHFEN(1'b1),
      .CLKHF(clk_int)
   );



   // Gearbox and reset circuitry.
   Clockworks CW(
     .CLK(clk_int),
     .RESET(RESET),
     .clk(clk),
     .resetn(resetn)
   );

endmodule
```
</details>
  
---
## Where to Instantiate the IP

Instantiate the SPI IP inside the SoC top-level module where memory-mapped peripherals are connected  

Typically, instantiate it alongside GPIO/UART in the **Memory-Mapped IO (IO page)** section.
 
Use the following instantiation template inside the SoC top:
```verilog
wire [31:0] spi_rdata;

SPI SPI (
  .clk      (clk),
  .rst      (!resetn),
  .sel      (isIO & mem_addr[12]),
  .w_en     (mem_wstrb),
  .r_en     (mem_rstrb),
  .offset   (mem_addr[3:2]),
  .wdata    (mem_wdata),
  .rdata    (spi_rdata),

  // SPI pins
  .sclk     (sclk),
  .mosi     (mosi),
  .miso     (miso),
  .cs_n     (cs_n)
);
```

Update Read MUX
```verilog
   wire [31:0] IO_rdata = 
	       mem_wordaddr[IO_UART_CNTL_bit] ? { 22'b0, !uart_ready, 9'b0}
	                                       : mem_wordaddr[IO_gpio_bit] ? gpio_rdata
                                                                        : mem_addr[12] ? spi_rdata : 32'b0;
```

---
