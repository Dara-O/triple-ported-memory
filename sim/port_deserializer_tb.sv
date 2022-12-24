`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/14/2022 10:40:18 PM
// Design Name: 
// Module Name: port_deserializer_tb
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
    output  logic   [WIDTH-1:0]     sin_data,
    output  logic                   sin_valid,
    output  logic   [1:0]           entry_id,

    // dut output
    input   logic   [WIDTH-1:0]     port1_data,
    input   logic                   port1_valid,
    input   logic   [WIDTH-1:0]     port2_data,
    input   logic                   port2_valid,
    input   logic   [WIDTH-1:0]     port3_data,
    input   logic                   port3_valid
);

localparam PORT_ID_1       = 1;
localparam PORT_ID_2       = 2;   
localparam PORT_ID_3       = 3;
localparam PORT_ID_INVALID = 0;

    // driven
    logic   [WIDTH-1:0]     sin_data_d;
    logic                   sin_valid_d;
    logic   [1:0]           entry_id_d;

    // sampled
    logic   [WIDTH-1:0]     port1_data_s;
    logic                   port1_valid_s;
    logic   [WIDTH-1:0]     port2_data_s;
    logic                   port2_valid_s;
    logic   [WIDTH-1:0]     port3_data_s;
    logic                   port3_valid_s;

    parameter CLK_PERIOD = 50;
    parameter SAMPLE_SKEW = 5;
    parameter DRIVE_SKEW = 5;

    logic clk;
    logic drive_clk;
    logic sample_clk;
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
    sin_data  = 0;
    sin_valid = 0;
    entry_id  = 0;
    clk       = 0;         
endtask

task clock_gen(); 
    forever begin
        clk <= 0;
        sample_clk <= 0;
        drive_clk <= 0;
        
        #(CLK_PERIOD/2 - SAMPLE_SKEW);
        sample_clk <= 1;
        sample();
        #(SAMPLE_SKEW);
        
        clk <= 1;
        #(DRIVE_SKEW);
        drive_clk <= 1;
        drive();
        #(CLK_PERIOD/2 - DRIVE_SKEW);
    end
endtask

task sample();               
    port1_data_s    = port1_data;
    port1_valid_s   = port1_valid;
    port2_data_s    = port2_data;
    port2_valid_s   = port2_valid;
    port3_data_s    = port3_data;
    port3_valid_s   = port3_valid;
endtask

task drive();
    sin_data    = sin_data_d;
    sin_valid   = sin_valid_d;
    entry_id    = entry_id_d; 
endtask

task test_sequence();
    repeat(1) @(posedge clk);
    for(int i = 0; i < 10; i = i + 1) begin
        sin_data_d  = i+1;
        sin_valid_d = i % 2;
        entry_id    = i % 4;

        @(posedge drive_clk);
    end
    repeat(1) @(posedge drive_clk);
    
endtask

endprogram

module tb;

parameter WIDTH = 8;

logic   [WIDTH-1:0]     sin_data;
logic                   sin_valid;
logic   [1:0]           entry_id;

logic   [WIDTH-1:0]     port1_data;
logic                   port1_valid;
logic   [WIDTH-1:0]     port2_data;
logic                   port2_valid;
logic   [WIDTH-1:0]     port3_data;
logic                   port3_valid;

main_program #(.WIDTH(WIDTH)) prog(.*);
port_deserializer #(.WIDTH(WIDTH)) dut(.*);

initial begin
    $dumpfile("wave.vcd");  
    $dumpvars(0, tb);
end

endmodule
