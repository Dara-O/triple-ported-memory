`timescale 1ns / 1ps

program main_program(
    // dut inputs 
    output   reg     [15:0]      rw1_data,
    output   reg     [15:0]      rw2_data,
    output   reg     [15:0]      rw3_data,

    output   reg                 rw1_valid,
    output   reg                 rw2_valid,
    output   reg                 rw3_valid,

    output   reg     [1:0]       rw1_req_tag,
    output   reg     [1:0]       rw2_req_tag,
    output   reg     [1:0]       rw3_req_tag,

    output   reg     [15:0]      r1_data,
    output   reg     [15:0]      r2_data,
    output   reg     [15:0]      r3_data,

    output   reg                 r1_valid,
    output   reg                 r2_valid,
    output   reg                 r3_valid,

    output   reg     [1:0]       r1_req_tag,
    output   reg     [1:0]       r2_req_tag,
    output   reg     [1:0]       r3_req_tag,

    // dut outputs
    input    reg     [15:0]      port1_data,
    input    reg     [15:0]      port2_data,
    input    reg     [15:0]      port3_data,

    input    reg                 port1_valid,
    input    reg                 port2_valid,
    input    reg                 port3_valid,

    input    reg     [1:0]       port1_req_tag,
    input    reg     [1:0]       port2_req_tag,
    input    reg     [1:0]       port3_req_tag
);

    // driven
    logic    [15:0]      rw1_data_d;
    logic    [15:0]      rw2_data_d;
    logic    [15:0]      rw3_data_d;
    logic                rw1_valid_d;
    logic                rw2_valid_d;
    logic                rw3_valid_d;
    logic    [1:0]       rw1_req_tag_d;
    logic    [1:0]       rw2_req_tag_d;
    logic    [1:0]       rw3_req_tag_d;
    logic    [15:0]      r1_data_d;
    logic    [15:0]      r2_data_d;
    logic    [15:0]      r3_data_d;
    logic                r1_valid_d;
    logic                r2_valid_d;
    logic                r3_valid_d;
    logic    [1:0]       r1_req_tag_d;
    logic    [1:0]       r2_req_tag_d;
    logic    [1:0]       r3_req_tag_d;

    // sample
    logic    [15:0]      port1_data_s;
    logic    [15:0]      port2_data_s;
    logic    [15:0]      port3_data_s;
    logic                port1_valid_s;
    logic                port2_valid_s;
    logic                port3_valid_s;
    logic    [1:0]       port1_req_tag_s;
    logic    [1:0]       port2_req_tag_s;
    logic    [1:0]       port3_req_tag_s;

    parameter CLK_PERIOD = 50;
    parameter SAMPLE_SKEW = 5;
    parameter DRIVE_SKEW = 5;

    int seed;

    logic clk;
    logic drive_clk;
    logic sample_clk;
    logic simulation_complete;

initial begin
    simulation_complete = 0;
    
    if($value$plusargs("SEED=%d", seed)) $display("SEED %d", seed);

    init();
    fork : fork_block
        clock_gen();
        test_sequence();
    join_any
    disable fork;
            
    simulation_complete = 1;
    $finish;
end

task test_sequence();
    $urandom(seed);
    repeat(1) @(posedge clk);
    for(int i = 0; i < 10; i = i + 1) begin
        rw1_data_d    = 'd11;
        rw2_data_d    = 'd12;
        rw3_data_d    = 'd13;
        rw1_req_tag_d = 'd1;
        rw2_req_tag_d = 'd2;
        rw3_req_tag_d = 'd3;
        r1_data_d     = 'd14;
        r2_data_d     = 'd15;
        r3_data_d     = 'd16;
        r1_req_tag_d  = 'd4;
        r2_req_tag_d  = 'd5;
        r3_req_tag_d  = 'd6;

        rw1_valid_d = $urandom_range(0, 1);
        rw2_valid_d = $urandom_range(0, 1);
        rw3_valid_d = $urandom_range(0, 1); 
        
        r1_valid_d  = $urandom_range(0, 1);
        r2_valid_d  = $urandom_range(0, 1);
        r3_valid_d  = $urandom_range(0, 1); 

        @(posedge drive_clk);
    end
    repeat(1) @(posedge drive_clk);    
endtask

task init();
    rw1_data    = 'd11;
    rw2_data    = 'd12;
    rw3_data    = 'd13;
    rw1_valid   = 0;
    rw2_valid   = 0;
    rw3_valid   = 0;
    rw1_req_tag = 'd1;
    rw2_req_tag = 'd2;
    rw3_req_tag = 'd3;
    r1_data     = 'd14;
    r2_data     = 'd15;
    r3_data     = 'd16;
    r1_valid    = 0;
    r2_valid    = 0;
    r3_valid    = 0;
    r1_req_tag  = 'd4;
    r2_req_tag  = 'd5;
    r3_req_tag  = 'd6;
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
    port2_data_s    = port2_data;
    port3_data_s    = port3_data;
    port1_valid_s   = port1_valid;
    port2_valid_s   = port2_valid;
    port3_valid_s   = port3_valid;
    port1_req_tag_s = port1_req_tag;
    port2_req_tag_s = port2_req_tag;
    port3_req_tag_s = port3_req_tag;
endtask

task drive();
    rw1_data        = rw1_data_d;
    rw2_data        = rw2_data_d;
    rw3_data        = rw3_data_d;
    rw1_valid       = rw1_valid_d;
    rw2_valid       = rw2_valid_d;
    rw3_valid       = rw3_valid_d;
    rw1_req_tag     = rw1_req_tag_d;
    rw2_req_tag     = rw2_req_tag_d;
    rw3_req_tag     = rw3_req_tag_d;
    r1_data         = r1_data_d;
    r2_data         = r2_data_d;
    r3_data         = r3_data_d;
    r1_valid        = r1_valid_d;
    r2_valid        = r2_valid_d;
    r3_valid        = r3_valid_d;
    r1_req_tag      = r1_req_tag_d;
    r2_req_tag      = r2_req_tag_d;
    r3_req_tag      = r3_req_tag_d;
endtask

endprogram

module tb;

reg    [15:0]      rw1_data;
reg    [15:0]      rw2_data;
reg    [15:0]      rw3_data;
reg                rw1_valid;
reg                rw2_valid;
reg                rw3_valid;
reg    [1:0]       rw1_req_tag;
reg    [1:0]       rw2_req_tag;
reg    [1:0]       rw3_req_tag;
reg    [15:0]      r1_data;
reg    [15:0]      r2_data;
reg    [15:0]      r3_data;
reg                r1_valid;
reg                r2_valid;
reg                r3_valid;
reg    [1:0]       r1_req_tag;
reg    [1:0]       r2_req_tag;
reg    [1:0]       r3_req_tag;
reg    [15:0]      port1_data;
reg    [15:0]      port2_data;
reg    [15:0]      port3_data;
reg                port1_valid;
reg                port2_valid;
reg                port3_valid;
reg    [1:0]       port1_req_tag;
reg    [1:0]       port2_req_tag;
reg    [1:0]       port3_req_tag;


main_program main(.*);
bank_out_arb dut(.*);

initial begin
    $dumpfile("wave.vcd");  
    $dumpvars(0, tb);
end

endmodule
