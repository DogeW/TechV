`timescale 1ns/1ps
`include "../inc/defines.v"

module openmips_soc_tb();

reg clk_50M;
reg rst;

initial begin
    clk_50M = 1'b0;
    forever #10 clk_50M = ~clk_50M;
end

initial begin
    rst = `RstEnable;
    #195 rst = `RstDisable;
    #1000 $stop;
end

openmips_soc openmips_soc0(
    .clk(clk_50M),
    .rst(rst)
);

endmodule