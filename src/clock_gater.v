`timescale 1ns/1ps

module clock_gater(
    input clk, 
    input enable,
    
    output gated_clock
);

    reg clock_prop;

    always @(*) begin
        if(~clk) begin
            clock_prop = enable;
        end
    end

    assign gated_clock = clk & clock_prop;

endmodule