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
output logic    [WIDTH-1:0]     entry1_data,  
output logic                    entry1_valid, 
output logic    [WIDTH-1:0]     entry2_data,  
output logic                    entry2_valid, 
output logic    [WIDTH-1:0]     entry3_data,  
output logic                    entry3_valid, 
output logic                    clk,          
output logic                    reset_n,      
                                       
// dut output                              
input logic    [WIDTH-1:0]     sout_data,    
input logic                    sout_valid,   
input logic                    freeze_inputs
);

// driven
logic    [WIDTH-1:0]     entry1_data_d;
logic                    entry1_valid_d;
logic    [WIDTH-1:0]     entry2_data_d;
logic                    entry2_valid_d;
logic    [WIDTH-1:0]     entry3_data_d;
logic                    entry3_valid_d;

// sampled
logic    [WIDTH-1:0]     sout_data_s;   
logic                    sout_valid_s;  
logic                    freeze_inputs_s;

parameter CLK_PERIOD = 50;
parameter SAMPLE_SKEW = 5;
parameter DRIVE_SKEW = 5;

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
    entry1_data     = 0; 
    entry1_valid    = 0;
    entry2_data     = 0; 
    entry2_valid    = 0;
    entry3_data     = 0; 
    entry3_valid    = 0;
    clk             = 0;         
    reset_n         = 0;     
endtask

task reset();
    reset_n = 0;
    @(posedge clk);
    reset_n = 1;
    @(posedge clk);
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
    sout_data_s     = sout_data;    
    sout_valid_s    = sout_valid;   
    freeze_inputs_s = freeze_inputs;
endtask

task drive();
    entry1_data     = entry1_data_d;  
    entry1_valid    = entry1_valid_d; 
    entry2_data     = entry2_data_d;  
    entry2_valid    = entry2_valid_d; 
    entry3_data     = entry3_data_d;  
    entry3_valid    = entry3_valid_d; 
endtask


task test_sequence();
    reset();
    repeat(1) @(posedge clk);
    for(int i = 1; i < 10*3+1; i = i + 3) begin
        entry1_data_d = i;
        entry2_data_d = i+1;
        entry3_data_d = i+2;
        
        entry1_valid_d = 1'b1;
        entry2_valid_d = 1'b1;
        entry3_valid_d = 1'b1;
        
        @(posedge drive_clk);
        
        @(posedge sample_clk);
        wait(freeze_inputs_s === 'b0);
    end
    
    entry1_data_d = 0;
    entry2_data_d = 0;
    entry3_data_d = 0;
    
    entry1_valid_d = 1'b0;
    entry2_valid_d = 1'b0;
    entry3_valid_d = 1'b0;
        
    @(posedge drive_clk);
    
    @(posedge sample_clk);
    wait(freeze_inputs_s === 'b0);
    
    for(int i = 1; i < 10*3+1; i = i + 3) begin
        entry1_data_d = i;
        entry2_data_d = i+1;
        entry3_data_d = i+2;
        
        entry1_valid_d = 1'b1;
        entry2_valid_d = 1'b1;
        entry3_valid_d = 1'b0;
        
        @(posedge drive_clk);
        
        @(posedge sample_clk);
        wait(freeze_inputs_s === 'b0);
    end
    
    entry1_data_d = 0;
    entry2_data_d = 0;
    entry3_data_d = 0;
    
    entry1_valid_d = 1'b0;
    entry2_valid_d = 1'b0;
    entry3_valid_d = 1'b0;
        
    @(posedge drive_clk);
    
    @(posedge sample_clk);
    wait(freeze_inputs_s === 'b0);
    
    for(int i = 1; i < 10*3+1; i = i + 3) begin
        entry1_data_d = i;
        entry2_data_d = i+1;
        entry3_data_d = i+2;
        
        entry1_valid_d = 1'b1;
        entry2_valid_d = 1'b0;
        entry3_valid_d = 1'b0;
        
        @(posedge drive_clk);
        
        @(posedge sample_clk);
        wait(freeze_inputs_s === 'b0);
    end
    
    repeat(1) @(posedge drive_clk);
    
endtask

endprogram

module tb;

parameter WIDTH = 8;
 
// inputs
logic    [WIDTH-1:0]     entry1_data;
logic                    entry1_valid;
logic    [WIDTH-1:0]     entry2_data;
logic                    entry2_valid;
logic    [WIDTH-1:0]     entry3_data;
logic                    entry3_valid;
logic                    clk;
logic                    reset_n;     

// output
logic    [WIDTH-1:0]     sout_data;   
logic                    sout_valid;  
logic                    freeze_inputs;

main_program #(.WIDTH(WIDTH)) prog(.*);
port_rw_serializer #(.WIDTH(WIDTH)) dut (.*);

initial begin
    $dumpfile("wave.vcd");  
    $dumpvars(0, tb);
end


endmodule
