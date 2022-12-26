`timescale 1ns/1ps

program main_program(
    output  logic    [11:0]      port1_addr,
    output  logic    [11:0]      port2_addr,
    output  logic    [11:0]      port3_addr,

    output  logic    [15:0]      port1_data_in,
    output  logic    [15:0]      port2_data_in,
    output  logic    [15:0]      port3_data_in,

    output  logic                port1_wen, // active high write enable
    output  logic                port2_wen,
    output  logic                port3_wen,

    output  logic                port1_valid_in,
    output  logic                port2_valid_in,
    output  logic                port3_valid_in,

    output  logic                clk,
    output  logic                reset_n,
    output  logic                halt,

    input   logic    [15:0]      port1_data_out,
    input   logic    [15:0]      port2_data_out,
    input   logic    [15:0]      port3_data_out,    

    input   logic                port1_valid_out,
    input   logic                port2_valid_out,
    input   logic                port3_valid_out,

    input   logic                freeze_inputs
);

    // driven
    logic    [11:0]     port1_addr_d;
    logic    [11:0]     port2_addr_d;
    logic    [11:0]     port3_addr_d;
    logic    [15:0]     port1_data_in_d;
    logic    [15:0]     port2_data_in_d;
    logic    [15:0]     port3_data_in_d;
    logic               port1_wen_d;
    logic               port2_wen_d;
    logic               port3_wen_d;
    logic               port1_valid_in_d;
    logic               port2_valid_in_d;
    logic               port3_valid_in_d;
    logic               reset_n_d;
    logic               halt_d;

    // sampled
    logic    [15:0]     port1_data_out_s;
    logic    [15:0]     port2_data_out_s;
    logic    [15:0]     port3_data_out_s;
    logic               port1_valid_out_s;
    logic               port2_valid_out_s;
    logic               port3_valid_out_s;
    logic               freeze_inputs_s;


    localparam CLK_PERIOD = 50;
    localparam SAMPLE_SKEW = 5;
    localparam DRIVE_SKEW = 5;
    localparam MAX_CYCLES = 100;

    logic drive_clk;
    logic sample_clk;
    logic dut_clk;
    logic simulation_complete;

    assign clk = dut_clk;


    initial begin
        simulation_complete = 0;
        init();
    
        fork
            clock_gen();
            test_sequence();
            watch_dog();
        join_any
        disable fork;
    
        simulation_complete = 1;
        $finish;
    end

    task test_sequence();
        reset();
        
        // same_bank_conflict(
        //     1'h1, 1'h1, 1'h1, 
        //     16'd8,
        //     2'd2
        // );

        // rolling_bank_conflict(
        //     1'h1, 1'h0, 1'h1, 
        //     16'd8
        // );

        // dynamic_priority_test();

        // no_rolling_bank_conflict(
        //     1'b1, 1'b1, 1'b1
        // );

        no_same_bank_conflict(
            1'b1, 1'b1, 1'b1,
            2'd0
        );

        repeat(10) @(posedge drive_clk);

    endtask

    task no_same_bank_conflict(
        input   logic           port1_valid,
        input   logic           port2_valid,
        input   logic           port3_valid,
        input   logic   [1:0]   bank_offset
    );
        int num_iters;
        num_iters = 8;
        
        // coarse-grain write then read
        for(int i = 0; i < num_iters*4; i = i+4) begin
            write_p123(
                'd0+i+bank_offset,    num_iters+'d1+i+bank_offset,    2*num_iters+'d2+i+bank_offset,
                'h11+i,     'h22+i,     'h33+i,
                port1_valid,port2_valid,port3_valid
            );

            @(posedge drive_clk);

            @(posedge sample_clk);
            wait(freeze_inputs_s == 'h0);
        end

        for(int i = 0; i < num_iters*4; i = i+4) begin
            read_p123(
                'd0+i+bank_offset,    num_iters+'d1+i+bank_offset,    2*num_iters+'d2+i+bank_offset,
                port1_valid,port2_valid,port3_valid
            );

            @(posedge drive_clk);

            @(posedge sample_clk);
            wait(freeze_inputs_s == 'h0);
        end

        // marker in simulation
        read_p123(  
            'h0,    'h0,        'h0, 
            'h0,    'h0,        'h0
        );

        repeat(2) @(posedge drive_clk);
        @(posedge sample_clk);
        wait(freeze_inputs_s == 'h0);

        // fine-grain write and read
        for(int i = num_iters*4; i < 2*num_iters*4; i = i+4) begin
            write_p123(
                'd0+i+bank_offset,    num_iters+'d1+i+bank_offset,    2*num_iters+'d2+i+bank_offset,
                'h11+i,     'h22+i,     'h33+i,
                port1_valid,port2_valid,port3_valid
            );

            @(posedge drive_clk);

            @(posedge sample_clk);
            wait(freeze_inputs_s == 'h0);
            
            read_p123(
                'd0+i+bank_offset,    num_iters+'d1+i+bank_offset,    2*num_iters+'d2+i+bank_offset,
                port1_valid,port2_valid,port3_valid
            );

            @(posedge drive_clk);

            @(posedge sample_clk);
            wait(freeze_inputs_s == 'h0);

        end

        // marker in simulation
        read_p123(  
            'h0,    'h0,        'h0, 
            'h0,    'h0,        'h0
        );

        repeat(2) @(posedge drive_clk);
        @(posedge sample_clk);
        wait(freeze_inputs_s == 'h0);
    endtask

    task no_rolling_bank_conflict(
        input   logic           port1_valid,
        input   logic           port2_valid,
        input   logic           port3_valid
    );
        int num_iters;
        num_iters = 8;

        for(int i = 0; i < num_iters; i = i+1) begin
            write_p123(
                'd0+i,    num_iters+'d1+i,    2*num_iters+'d2+i,
                'h11+i,     'h22+i,     'h33+i,
                port1_valid,port2_valid,port3_valid
            );

            @(posedge drive_clk);

            @(posedge sample_clk);
            wait(freeze_inputs_s == 'h0);
        end

        for(int i = 0; i < num_iters; i = i+1) begin
            read_p123(
                'd0+i,    num_iters+'d1+i,    2*num_iters+'d2+i,
                port1_valid,port2_valid,port3_valid
            );

            @(posedge drive_clk);

            @(posedge sample_clk);
            wait(freeze_inputs_s == 'h0);
        end

        // marker in simulation
        read_p123(  
            'h0,    'h0,        'h0, 
            'h0,    'h0,        'h0
        );

        repeat(2) @(posedge drive_clk);
        @(posedge sample_clk);
        wait(freeze_inputs_s == 'h0);
    endtask

    task rolling_bank_conflict(
        input   logic           port1_valid,
        input   logic           port2_valid,
        input   logic           port3_valid,
        input   logic   [15:0]  num_iters
    );

        for(int i = 0; i < num_iters; i = i+1) begin
            write_p123(
                'd0+i,    num_iters+'d4+i,    2*num_iters+'d8+i,
                'h11+i,     'h22+i,     'h33+i,
                port1_valid,port2_valid,port3_valid
            );

            @(posedge drive_clk);

            @(posedge sample_clk);
            wait(freeze_inputs_s == 'h0);
        end

        for(int i = 0; i < num_iters; i = i+1) begin
            read_p123(
                'd0+i,    num_iters+'d4+i,    2*num_iters+'d8+i,
                port1_valid,port2_valid,port3_valid
            );

            @(posedge drive_clk);

            @(posedge sample_clk);
            wait(freeze_inputs_s == 'h0);
        end

        // marker in simulation
        read_p123(  
            'h0,    'h0,        'h0, 
            'h0,    'h0,        'h0
        );

        repeat(2) @(posedge drive_clk);
        @(posedge sample_clk);
        wait(freeze_inputs_s == 'h0);

        for(int i = 4*num_iters; i < 5*num_iters; i = i+1) begin
            write_p123(
                'd0+i,    num_iters+'d4+i,    2*num_iters+'d8+i,
                'h11+i,     'h12+i,     'h13+i,
                port1_valid,port2_valid,port3_valid
            );

            @(posedge drive_clk);

            @(posedge sample_clk);
            wait(freeze_inputs_s == 'h0);

            read_p123(
                'd0+i,    num_iters+'d4+i,    2*num_iters+'d8+i,
                port1_valid,port2_valid,port3_valid
            );

            @(posedge drive_clk);

            @(posedge sample_clk);
            wait(freeze_inputs_s == 'h0);
        end

        // marker in simulation
        read_p123(  
            'h0,    'h0,        'h0, 
            'h0,    'h0,        'h0
        );

        repeat(2) @(posedge drive_clk);
        @(posedge sample_clk);
        wait(freeze_inputs_s == 'h0);

    endtask

    task same_bank_conflict(
        input   logic           port1_valid,
        input   logic           port2_valid,
        input   logic           port3_valid,
        input   logic   [15:0]  num_iters,
        input   logic   [1:0]   target_bank
    );
        
        // coarse-grain write then read
        for(int i = 0; i < num_iters*4; i = i +4) begin
            write_p123(
                'd0+i+target_bank,    num_iters*4+i+target_bank,    2*num_iters*4+i+target_bank,
                'h11+i,     'h12+i,     'h13+i,
                port1_valid,port2_valid,port3_valid
            );

            @(posedge drive_clk);

            @(posedge sample_clk);
            wait(freeze_inputs_s == 'h0);
        end

        for(int i = 0; i < num_iters*4; i = i +4) begin
            read_p123(
                'd0+i+target_bank,    num_iters*4+i+target_bank,    2*num_iters*4+i+target_bank,
                port1_valid,port2_valid,port3_valid
            );

            @(posedge drive_clk);

            @(posedge sample_clk);
            wait(freeze_inputs_s == 'h0);
        end

        // marker in simulation
        read_p123(  
            'h0,    'h0,        'h0, 
            'h0,    'h0,        'h0
        );

        repeat(2) @(posedge drive_clk);
        @(posedge sample_clk);
        wait(freeze_inputs_s == 'h0);

        // fine-grain write then read
        for(int i = 12*num_iters*4; i < 12*num_iters*4+num_iters*4; i = i +4) begin // needs refinement
            write_p123(
                'd0+i+target_bank,    num_iters*4+i+target_bank,    2*num_iters*4+i+target_bank,
                'h31+i,     'h32+i,     'h33+i,
                port1_valid,port2_valid,port3_valid
            );

            @(posedge drive_clk);

            @(posedge sample_clk);
            wait(freeze_inputs_s == 'h0);

            read_p123(
                'd0+i+target_bank,    num_iters*4+i+target_bank,    2*num_iters*4+i+target_bank,
                port1_valid,port2_valid,port3_valid
            );

            @(posedge drive_clk);

            @(posedge sample_clk);
            wait(freeze_inputs_s == 'h0);
        end

        // marker in simulation
        read_p123(  
            'h0,    'h0,        'h0, 
            'h0,    'h0,        'h0
        );

        repeat(2) @(posedge drive_clk);
        @(posedge sample_clk);
        wait(freeze_inputs_s == 'h0);

    endtask

    task dynamic_priority_test(
        
    );

        logic [2:0] port_priority_seq [0:8];
        port_priority_seq[0] = 3'b000; // 123
        port_priority_seq[1] = 3'b001; // 312
        port_priority_seq[2] = 3'b011; // 321
        port_priority_seq[3] = 3'b010; // 231
        port_priority_seq[4] = 3'b110; // 213
        port_priority_seq[5] = 3'b101; // 132

        write_p123(
            'd0, 'd4, 'd8, 
            'h11, 'h22, 'h33, 
            1'b1, 1'b1, 1'b1
        );

        @(posedge drive_clk);
        @(posedge sample_clk);
        wait(freeze_inputs_s === 1'h0);

        // marker in simulation
        read_p123(  
            'h0,    'h0,        'h0, 
            'h0,    'h0,        'h0
        );

        repeat(2) @(posedge drive_clk);

        for(int i = 0; i < 6; i = i+1) begin

            write_p123(
                'd9, 'd9, 'd9,
                'd0, 'd0, 'd0,  
                port_priority_seq[i][2], port_priority_seq[i][1], port_priority_seq[i][0]
            );

            @(posedge drive_clk);
            @(posedge sample_clk);
            wait(freeze_inputs_s === 1'h0);

            read_p123(
                'd0, 'd4, 'd8,  
                1'b1, 1'b1, 1'b1
            );

            @(posedge drive_clk);
            @(posedge sample_clk);
            wait(freeze_inputs_s === 1'h0);
            
        end

        // marker in simulation
        read_p123(  
            'h0,    'h0,        'h0, 
            'h0,    'h0,        'h0
        );

        repeat(2) @(posedge drive_clk);
        @(posedge sample_clk);
        wait(freeze_inputs_s == 'h0);

    endtask

    task read_p123(
        input   logic   [11:0]   p1_addr,
        input   logic   [11:0]   p2_addr,
        input   logic   [11:0]   p3_addr,

        input   logic           p1_valid,
        input   logic           p2_valid,
        input   logic           p3_valid
    );
        memory_access(
            p1_addr,
            p2_addr,
            p3_addr,

            16'h0,
            16'h0,
            16'h0,

            1'b0, // p1_w_en
            1'b0, // p2_w_en
            1'b0, // p3_w_en

            p1_valid,
            p2_valid,
            p3_valid
        );  


    endtask

    task write_p123(
        input   logic   [11:0]   p1_addr,
        input   logic   [11:0]   p2_addr,
        input   logic   [11:0]   p3_addr,

        input   logic   [15:0]  p1_data_in,
        input   logic   [15:0]  p2_data_in,
        input   logic   [15:0]  p3_data_in,

        input   logic           p1_valid,
        input   logic           p2_valid,
        input   logic           p3_valid
    );

        memory_access(
            p1_addr,
            p2_addr,
            p3_addr,

            p1_data_in,
            p2_data_in,
            p3_data_in,

            1'b1, // p1_w_en
            1'b1, // p2_w_en
            1'b1, // p3_w_en

            p1_valid,
            p2_valid,
            p3_valid
        );    

    endtask

    task memory_access(
        input   logic       [11:0]  p1_addr,
        input   logic       [11:0]  p2_addr,
        input   logic       [11:0]  p3_addr,

        input   logic       [15:0]  p1_data_in,
        input   logic       [15:0]  p2_data_in,
        input   logic       [15:0]  p3_data_in,

        input   logic               p1_wen,
        input   logic               p2_wen,
        input   logic               p3_wen,
        
        input   logic               p1_valid,
        input   logic               p2_valid,
        input   logic               p3_valid
    );

        port1_addr_d    = p1_addr;
        port2_addr_d    = p2_addr;
        port3_addr_d    = p3_addr;
        port1_data_in_d = p1_data_in;
        port2_data_in_d = p2_data_in;
        port3_data_in_d = p3_data_in;
        port1_wen_d     = p1_wen;
        port2_wen_d     = p2_wen;
        port3_wen_d     = p3_wen;
        port1_valid_in_d   = p1_valid;
        port2_valid_in_d   = p2_valid;
        port3_valid_in_d   = p3_valid;

    endtask

    task reset();
        reset_n_d = 0;
        @(posedge drive_clk);

        reset_n_d = 1;
        repeat(2) @(posedge drive_clk);
    endtask

    task clock_gen(); 
        forever begin
            dut_clk <= 0;
            sample_clk <= 0;
            drive_clk <= 0;
            
            #(CLK_PERIOD/2 - SAMPLE_SKEW);
            sample_clk <= 1;
            sample();
            #(SAMPLE_SKEW);
            
            dut_clk <= 1;
            
            #(DRIVE_SKEW);
            drive_clk <= 1;
            drive();
            #(CLK_PERIOD/2 - DRIVE_SKEW);
        end
    endtask 

    task sample();
        port1_data_out_s    <= port1_data_out;
        port2_data_out_s    <= port2_data_out;
        port3_data_out_s    <= port3_data_out;
        port1_valid_out_s   <= port1_valid_out;
        port2_valid_out_s   <= port2_valid_out;
        port3_valid_out_s   <= port3_valid_out;
        freeze_inputs_s     <= freeze_inputs;
    endtask

    task drive();

        port1_addr          <= port1_addr_d;
        port2_addr          <= port2_addr_d;
        port3_addr          <= port3_addr_d;
        port1_data_in       <= port1_data_in_d;
        port2_data_in       <= port2_data_in_d;
        port3_data_in       <= port3_data_in_d;
        port1_wen           <= port1_wen_d;
        port2_wen           <= port2_wen_d;
        port3_wen           <= port3_wen_d;
        port1_valid_in      <= port1_valid_in_d;
        port2_valid_in      <= port2_valid_in_d;
        port3_valid_in      <= port3_valid_in_d;
        reset_n             <= reset_n_d;
        halt                <= halt_d;
    endtask

    task init();
        port1_addr          = 0;
        port2_addr          = 0;
        port3_addr          = 0;
        port1_data_in       = 0;
        port2_data_in       = 0;
        port3_data_in       = 0;
        port1_wen           = 0;
        port2_wen           = 0;
        port3_wen           = 0;
        port1_valid_in      = 0;
        port2_valid_in      = 0;
        port3_valid_in      = 0;
        reset_n = 0;
        halt = 0;

        port1_addr_d          = 0;
        port2_addr_d          = 0;
        port3_addr_d          = 0;
        port1_data_in_d       = 0;
        port2_data_in_d       = 0;
        port3_data_in_d       = 0;
        port1_wen_d           = 0;
        port2_wen_d           = 0;
        port3_wen_d           = 0;
        port1_valid_in_d      = 0;
        port2_valid_in_d      = 0;
        port3_valid_in_d      = 0;

        reset_n_d = 0;
        halt_d = 0;
    endtask

    task watch_dog();
        repeat(MAX_CYCLES) @(posedge dut_clk);
    endtask
    
endprogram


module tb;

    logic    [11:0]      port1_addr;
    logic    [11:0]      port2_addr;
    logic    [11:0]      port3_addr;
    logic    [15:0]      port1_data_in;
    logic    [15:0]      port2_data_in;
    logic    [15:0]      port3_data_in;
    logic                port1_wen;
    logic                port2_wen;
    logic                port3_wen;
    logic                port1_valid_in;
    logic                port2_valid_in;
    logic                port3_valid_in;

    logic                clk;
    logic                reset_n;
    logic                halt;

    logic    [15:0]      port1_data_out;
    logic    [15:0]      port2_data_out;
    logic    [15:0]      port3_data_out;    
    logic                port1_valid_out;
    logic                port2_valid_out;
    logic                port3_valid_out;
    logic                freeze_inputs;

    
    triple_ported_memory dut(.*);
    main_program main(.*);
    
    initial begin
        $dumpfile("wave.vcd");  
        $dumpvars(0, tb);
    end
endmodule