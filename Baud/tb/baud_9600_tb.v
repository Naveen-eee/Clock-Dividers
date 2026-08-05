`timescale 1ns/1ps
module baud_9600_tb;
    reg clk,reset;
    wire baud_out;

baud_9600 dut(
    .clk(clk),
    .reset(reset),
    .baud_out(baud_out)
);


initial
    clk=0;

always #5 clk = ~clk;

initial
begin
    reset=1;
    #10;
    reset=0;
    #110000;
    $finish;
end

always @(posedge baud_out)
begin
    $display("Baud pulse at time = %0t ns", $time);
end
endmodule
