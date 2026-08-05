module baud_9600(
    input clk,reset,
    output reg baud_out
);

reg[13:0] count;

always @(posedge clk or posedge reset)
begin
    if(reset) begin
        count<=14'b0;
        baud_out<=1'b0;
    end
    else if(count==14'd10415)begin   //baud divisor value 
        count<=14'b0;
        baud_out<=1'b1;
    end
    else begin
        count<=count+1'b1;
        baud_out<=1'b0;
    end
end
endmodule

