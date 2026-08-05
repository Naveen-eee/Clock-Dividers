module clk_div4_tb;
    reg clk,reset;
    wire clk_out;

clk_div4 dut(
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
