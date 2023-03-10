`timescale 1ns/1ps

module sram_1024x16_1rw1r (
    input               clk,

    // r port signals
    input   [9:0]       r_addr,
    input               r_valid,

    output  [15:0]      r_data_out,

    // rw port signals 
    input   [9:0]       rw_addr,
    input   [15:0]      rw_data_in,
    input               rw_w_en, 
    input               rw_valid,

    output  [15:0]      rw_data_out
);
    
    sky130_sram_1kbytes_1rw1r_8x1024_8 sram_high(
        // rw port
        .clk0(clk),
        .csb0 (~rw_valid),
        .web0 (~rw_w_en),
        .addr0 (rw_addr),
        .din0 (rw_data_in[15:8]),

        .dout0 (rw_data_out[15:8]),

        
        // r port
        .clk1 (clk),
        .csb1 (~r_valid),
        .addr1 (r_addr),

        .dout1 (r_data_out[15:8])
    );

    sky130_sram_1kbytes_1rw1r_8x1024_8 sram_low(
        // rw port
        .clk0(clk),
        .csb0 (~rw_valid),
        .web0 (~rw_w_en),
        .addr0 (rw_addr),
        .din0 (rw_data_in[7:0]),

        .dout0 (rw_data_out[7:0]),

        
        // r port
        .clk1 (clk),
        .csb1 (~r_valid),
        .addr1 (r_addr),

        .dout1 (r_data_out[7:0])
    );
  

endmodule