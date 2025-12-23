//Soc test  bench taken from vsdfpga labs
`timescale 1ns/1ps
`define BENCH


// Simple model for SB_HFOSC to provide a clock in simulation
module SB_HFOSC (input CLKHFPU, input CLKHFEN, output CLKHF);
  reg clk_reg = 0;
  initial begin
    clk_reg = 0;
    forever #5 clk_reg = ~clk_reg; // 100MHz-ish for simulation
  end
  assign CLKHF = clk_reg;
endmodule

// Simple stub for SB_PLL40_CORE used in femtoPLL for simulation
module SB_PLL40_CORE(
  input REFERENCECLK,
  input RESETB,
  input BYPASS,
  output PLLOUTCORE
);
  // pass-through clock for simulation
  assign PLLOUTCORE = REFERENCECLK;
endmodule

module tb();
  reg RESET;
  wire [4:0] LEDS;
  wire TXD;
  reg RXD;

  SOC soc(.RESET(RESET), .LEDS(LEDS), .RXD(RXD), .TXD(TXD));

  initial begin
    $dumpfile("tb_soc.vcd");
    $dumpvars(0,tb);
    RESET = 1;
    RXD = 0;
    #100;
    RESET = 0;
    #700000; // run long enough for reset counter to expire
    $display("Final LEDS = %b", LEDS);
    $finish;
  end

  initial begin
    $monitor("%0t LEDS=%b", $time, LEDS);
  end
endmodule
