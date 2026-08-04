`timescale 1ns/1ps
module clk_div2_tb;

    reg clk,reset;
    wire clk_out;

clk_div2 dut(
    .clk(clk),
    .reset(reset),
    .clk_out(clk_out)
);

initial 
    clk=0;

always #5 clk = ~clk;


initial
begin
    reset=1;
    #10;
    reset=0;
    #100;
    $finish;
end

endmodule