module clk_div4(
    input  wire clk,
    input  wire reset,
    output reg  clk_out
);

reg count;

always @(posedge clk or posedge reset)
begin
    if (reset)
    begin
        count   <= 1'b0;
        clk_out <= 1'b0;
    end
    else
    begin
        if (count == 1'b1)
        begin
            count   <= 1'b0;
            clk_out <= ~clk_out;
        end
        else
        begin
            count <= count + 1'b1;
        end
    end
end

endmodule