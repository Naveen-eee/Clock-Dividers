module clk_div3(
    input clk,reset,
    output reg clk_out
);

reg[1:0] count;

always @(posedge clk or posedge reset)
begin
    if(reset)begin
        clk_out<=1'b0;
        count<=2'b00;
    end
    else if(count==2'b10)begin   //33 percent duty cycle 1 on 2 off cycle
        clk_out<=1'b1;
        count<=2'b00;
    end
    else begin
        clk_out<=1'b0;
        count<=count+1'b1;
    end
end
endmodule

