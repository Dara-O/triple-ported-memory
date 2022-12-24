`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/26/2022 01:50:12 PM
// Design Name: 
// Module Name: tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


program main_program #(parameter WIDTH=8)(
// dut inputs
output   logic    [WIDTH-1:0]     port1_in,
output   logic                    port1_in_valid,
output   logic    [WIDTH-1:0]     port2_in,
output   logic                    port2_in_valid,
output   logic    [WIDTH-1:0]     port3_in,
output   logic                    port3_in_valid,

// dut outputs
input    logic     [WIDTH-1:0]     port1_out,
input    logic                     port1_out_valid,
input    logic     [WIDTH-1:0]     port2_out,
input    logic                     port2_out_valid,
input    logic     [WIDTH-1:0]     port3_out,
input    logic                     port3_out_valid
);

// driven
logic    [WIDTH-1:0]     port1_in_d;
logic                    port1_in_valid_d;
logic    [WIDTH-1:0]     port2_in_d;
logic                    port2_in_valid_d;
logic    [WIDTH-1:0]     port3_in_d;
logic                    port3_in_valid_d;

// sampled
logic    [WIDTH-1:0]     port1_out_s;
logic                    port1_out_valid_s;
logic    [WIDTH-1:0]     port2_out_s;
logic                    port2_out_valid_s;
logic    [WIDTH-1:0]     port3_out_s;
logic                    port3_out_valid_s;

localparam CLK_PERIOD = 50;
localparam SAMPLE_SKEW = 1;
localparam DRIVE_SKEW = 1;

logic drive_clk;
logic sample_clk;
logic ref_clk;
logic simulation_complete;

initial begin

    simulation_complete = 0;
    init();
    fork
        clock_gen();
        test_sequence();
    join_any
    disable fork;
    
    simulation_complete = 1;
    $finish;
end

task init();
    port1_in = 0;     
    port1_in_valid = 0;
    port2_in = 0;     
    port2_in_valid = 0;
    port3_in = 0;     
    port3_in_valid = 0;     
endtask

task clock_gen(); 
    forever begin
        ref_clk <= 0;
        sample_clk <= 0;
        drive_clk <= 0;
        
        #(CLK_PERIOD/2 - SAMPLE_SKEW);
        sample_clk <= 1;
        sample();
        #(SAMPLE_SKEW);
        
        ref_clk <= 1;
        
        #(DRIVE_SKEW);
        drive_clk <= 1;
        drive();
        #(CLK_PERIOD/2 - DRIVE_SKEW);
    end
endtask

task sample();               
    port1_out_s         = port1_out;      
    port1_out_valid_s   = port1_out_valid;
    port2_out_s         = port2_out;      
    port2_out_valid_s   = port2_out_valid;
    port3_out_s         = port3_out;      
    port3_out_valid_s   = port3_out_valid;
endtask

task drive();
    port1_in            = port1_in_d;
    port1_in_valid      = port1_in_valid_d;
    port2_in            = port2_in_d;
    port2_in_valid      = port2_in_valid_d;
    port3_in            = port3_in_d;
    port3_in_valid      = port3_in_valid_d; 
endtask


task test_sequence();
    
    for(int i = 0; i < 8; i = i + 1) begin
        port1_in_d          = i*3 + 8'h1;      
        port2_in_d          = i*3 + 8'h2;
        port3_in_d          = i*3 + 8'h3;
        
        port1_in_valid_d    = i[2];
        port2_in_valid_d    = i[1];
        port3_in_valid_d    = i[0];
        @(posedge drive_clk);
        
    end
    repeat(3) @(posedge drive_clk);
    
endtask

endprogram

module tb;

parameter WIDTH = 8;
 
logic    [WIDTH-1:0]     port1_in;
logic                    port1_in_valid;
logic    [WIDTH-1:0]     port2_in;
logic                    port2_in_valid;
logic    [WIDTH-1:0]     port3_in;
logic                    port3_in_valid;

logic    [WIDTH-1:0]     port1_out;
logic                    port1_out_valid;
logic    [WIDTH-1:0]     port2_out;
logic                    port2_out_valid;
logic    [WIDTH-1:0]     port3_out;
logic                    port3_out_valid;

main_program #(.WIDTH(WIDTH)) prog(.*);
validity_filter #(.WIDTH(WIDTH)) dut (.*);

initial begin
    $dumpfile("wave.vcd");  
    $dumpvars(0, tb);
end


endmodule
