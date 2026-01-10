`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.01.2026 19:31:12
// Design Name: 
// Module Name: SPI
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
