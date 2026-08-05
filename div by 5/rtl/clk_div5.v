module clk_div5(
    input clk,reset,
    output reg clk_out
);

reg[2:0] count;

always @(posedge clk or posedge reset)
begin
    if(reset)begin
        count<=3'b000;
        clk_out<=1'b0;
    end
    else if(count==3'b100)begin
        count<=3'b000;
        clk_out<=1'b0;
    end
    else if(count==3'b011)begin
        clk_out<=1'b0;
        count<=count+1'b1;
    end
    else begin
        count<=count+1'b1;
        clk_out<=1'b1;
    end
end

endmodule


