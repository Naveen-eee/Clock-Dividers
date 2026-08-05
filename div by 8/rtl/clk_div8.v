module clk_div8(
    input clk,reset,
    output reg clk_out
);

reg [1:0]count;

always @(posedge clk or posedge reset)
begin
    if(reset)begin
        clk_out<=1'b0;
        count<=2'b00;end
    else
    begin
        if(count==2'b11)begin
            count<=2'b00;
            clk_out<=~clk_out;
        end
        else
            count<=count+1'b1;
    end
end
endmodule

