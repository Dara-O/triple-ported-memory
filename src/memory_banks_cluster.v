`timescale 1ns/1ps

module mask #(parameter WIDTH=8) (
    input   wire    [WIDTH-1:0]     data_in,
    input   wire                    force_zero, // 1 means output is forced to zero

    output  wire    [WIDTH-1:0]     data_out
);
    
    assign data_out = data_in & {WIDTH{~force_zero}};

endmodule

module memory_banks_cluster (
    input   wire    [1:0]       port1_req_tag_in,
    input   wire    [1:0]       port2_req_tag_in,
    input   wire    [1:0]       port3_req_tag_in,
    
    input   wire    [11:0]      port1_addr,
    input   wire    [11:0]      port2_addr,
    input   wire    [11:0]      port3_addr,

    input   wire    [15:0]      port1_data_in,
    input   wire    [15:0]      port2_data_in,
    input   wire    [15:0]      port3_data_in,

    input   wire    [0:0]       port1_wen,
    input   wire    [0:0]       port2_wen,
    input   wire    [0:0]       port3_wen,

    input   wire    [0:0]       port1_valid,
    input   wire    [0:0]       port2_valid,
    input   wire    [0:0]       port3_valid,

    input   wire                clk,
    input   wire                reset_n,

    output  reg     [1:0]       port1_req_tag_out,
    output  reg     [1:0]       port2_req_tag_out,
    output  reg     [1:0]       port3_req_tag_out,

    output  reg     [15:0]      port1_data_out,
    output  reg     [15:0]      port2_data_out,
    output  reg     [15:0]      port3_data_out,

    output  reg     [0:0]       port1_valid_out,
    output  reg     [0:0]       port2_valid_out,
    output  reg     [0:0]       port3_valid_out,

    output  wire                freeze_inputs
);
    
    wire    [1:0]       masked_port1_req_tag_in;
    wire    [1:0]       masked_port2_req_tag_in;
    wire    [1:0]       masked_port3_req_tag_in;
    wire    [11:0]      masked_port1_addr;
    wire    [11:0]      masked_port2_addr;
    wire    [11:0]      masked_port3_addr;
    wire    [15:0]      masked_port1_data_in;
    wire    [15:0]      masked_port2_data_in;
    wire    [15:0]      masked_port3_data_in;
    wire    [0:0]       masked_port1_wen;
    wire    [0:0]       masked_port2_wen;
    wire    [0:0]       masked_port3_wen;
    wire    [0:0]       masked_port1_valid;
    wire    [0:0]       masked_port2_valid;
    wire    [0:0]       masked_port3_valid;

    mask #(.WIDTH(32)) port1_mask (
        .data_in({port1_req_tag_in, port1_addr, port1_data_in, port1_wen, port1_valid}),
        .force_zero(freeze_inputs),

        .data_out({masked_port1_req_tag_in, masked_port1_addr, masked_port1_data_in, masked_port1_wen, masked_port1_valid})
    );

    mask #(.WIDTH(32)) port2_mask (
        .data_in({port2_req_tag_in, port2_addr, port2_data_in, port2_wen, port2_valid}),
        .force_zero(freeze_inputs),

        .data_out({masked_port2_req_tag_in, masked_port2_addr, masked_port2_data_in, masked_port2_wen, masked_port2_valid})
    );

    mask #(.WIDTH(32)) port3_mask (
        .data_in({port3_req_tag_in, port3_addr, port3_data_in, port3_wen, port3_valid}),
        .force_zero(freeze_inputs),

        .data_out({masked_port3_req_tag_in, masked_port3_addr, masked_port3_data_in, masked_port3_wen, masked_port3_valid})
    );
    

    assign freeze_inputs = |postb_freeze_inputs;

    localparam NUM_BANKS = 4;

    /* Using Array instantiation */
    // connect memory_bank_logic to port bank selector
    wire    [NUM_BANKS*2-1:0]  bank_ids = {2'b00, 2'b01, 2'b10, 2'b11};
    wire    [NUM_BANKS*2-1:0]  postb_port1_req_tag_out;
    wire    [NUM_BANKS*2-1:0]  postb_port2_req_tag_out;
    wire    [NUM_BANKS*2-1:0]  postb_port3_req_tag_out;

    wire    [NUM_BANKS*16-1:0] postb_port1_data_out;
    wire    [NUM_BANKS*16-1:0] postb_port2_data_out;
    wire    [NUM_BANKS*16-1:0] postb_port3_data_out;

    wire    [NUM_BANKS*1-1:0]  postb_port1_valid_out;
    wire    [NUM_BANKS*1-1:0]  postb_port2_valid_out;
    wire    [NUM_BANKS*1-1:0]  postb_port3_valid_out;

    wire    [0:3]   postb_freeze_inputs;

    // connect memory_bank_logic to srams
    wire    [NUM_BANKS*10-1:0] postrs_addr;
    wire    [NUM_BANKS*1-1:0]  postrs_valid;
    wire    [NUM_BANKS*10-1:0] postrws_addr;
    wire    [NUM_BANKS*16-1:0] postrws_data_in;
    wire    [NUM_BANKS*1-1:0]  postrws_valid;
    wire    [NUM_BANKS*1-1:0]  postrws_w_en;

    // connect srams to memory_bank logic
    wire    [NUM_BANKS*16-1:0]  sram_r_dout;
    wire    [NUM_BANKS*16-1:0]  sram_rw_dout;

    memory_bank_logic bank [3:0] (
        .BANK_ID(bank_ids),
        .port1_req_tag_in (masked_port1_req_tag_in),
        .port2_req_tag_in (masked_port2_req_tag_in),
        .port3_req_tag_in (masked_port3_req_tag_in),
        .port1_addr (masked_port1_addr),
        .port2_addr (masked_port2_addr),
        .port3_addr (masked_port3_addr),
        .port1_data_in (masked_port1_data_in),
        .port2_data_in (masked_port2_data_in),
        .port3_data_in (masked_port3_data_in),
        .port1_wen (masked_port1_wen),
        .port2_wen (masked_port2_wen),
        .port3_wen (masked_port3_wen),
        .port1_valid (masked_port1_valid),
        .port2_valid (masked_port2_valid),
        .port3_valid (masked_port3_valid),

        .clk (clk ),
        .reset_n (reset_n ),

        .port1_req_tag_out (postb_port1_req_tag_out),
        .port2_req_tag_out (postb_port2_req_tag_out),
        .port3_req_tag_out (postb_port3_req_tag_out),
        .port1_data_out (postb_port1_data_out),
        .port2_data_out (postb_port2_data_out),
        .port3_data_out (postb_port3_data_out),
        .port1_valid_out (postb_port1_valid_out),
        .port2_valid_out (postb_port2_valid_out),
        .port3_valid_out (postb_port3_valid_out),
        .freeze_inputs (postb_freeze_inputs),

        // from srams
        .sram_rw_dout (sram_rw_dout),
        .sram_r_dout (sram_r_dout),
        // to srams
        .postrs_addr (postrs_addr),
        .postrs_valid (postrs_valid),
        .postrws_addr (postrws_addr),
        .postrws_data_in (postrws_data_in),
        .postrws_valid (postrws_valid),
        .postrws_w_en  (postrws_w_en)
        
    );

    sram_1024x16_1rw1r sram [3:0] (
        .clk (clk),

        // r port
        .r_addr (postrs_addr ),
        .r_valid (postrs_valid ),

        .r_data_out (sram_r_dout ),

        // rw port
        .rw_addr (postrws_addr ),
        .rw_data_in (postrws_data_in),
        .rw_w_en (postrws_w_en),
        .rw_valid (postrws_valid),

        .rw_data_out  (sram_rw_dout)
      
    );

    // for each port select only the valid bank output
    /// port1
    always @ (*) begin
        case ({postb_port1_valid_out})

            4'b0000:    begin
                port1_req_tag_out   =   2'h0;
                port1_data_out      =   16'h0;
                port1_valid_out     =   1'h0;
            end

            4'b0001:    begin // select the fourth bank
                port1_req_tag_out   =   postb_port1_req_tag_out[(NUM_BANKS-3)*2-1 -: 2];
                port1_data_out      =   postb_port1_data_out[(NUM_BANKS-3)*16-1 -: 16];
                port1_valid_out     =   postb_port1_valid_out[(NUM_BANKS-3)*1-1 -: 1];
            end

            4'b0010:    begin // select the third bank
                port1_req_tag_out   =   postb_port1_req_tag_out[(NUM_BANKS-2)*2-1 -: 2];
                port1_data_out      =   postb_port1_data_out[(NUM_BANKS-2)*16-1 -: 16];
                port1_valid_out     =   postb_port1_valid_out[(NUM_BANKS-2)*1-1 -: 1];
            end

            4'b0100:    begin // select the second bank
                port1_req_tag_out   =   postb_port1_req_tag_out[(NUM_BANKS-1)*2-1 -: 2];
                port1_data_out      =   postb_port1_data_out[(NUM_BANKS-1)*16-1 -: 16];
                port1_valid_out     =   postb_port1_valid_out[(NUM_BANKS-1)*1-1 -: 1];
            end

            4'b1000:    begin // select the first bank
                port1_req_tag_out   =   postb_port1_req_tag_out[(NUM_BANKS-0)*2-1 -: 2];
                port1_data_out      =   postb_port1_data_out[(NUM_BANKS-0)*16-1 -: 16];
                port1_valid_out     =   postb_port1_valid_out[(NUM_BANKS-0)*1-1 -: 1];
            end

            default: begin
                port1_req_tag_out   =   2'h0;
                port1_data_out      =   16'h0;
                port1_valid_out     =   1'h0;
            end
        endcase
    end
  

    /// port2
    always @ (*) begin
        case ({postb_port2_valid_out})

            4'b0000:    begin
                port2_req_tag_out   =   2'h0;
                port2_data_out      =   16'h0;
                port2_valid_out     =   1'h0;
            end

            4'b0001:    begin // select the fourth bank
                port2_req_tag_out   =   postb_port2_req_tag_out[(NUM_BANKS-3)*2-1 -: 2];
                port2_data_out      =   postb_port2_data_out[(NUM_BANKS-3)*16-1 -: 16];
                port2_valid_out     =   postb_port2_valid_out[(NUM_BANKS-3)*1-1 -: 1];
            end

            4'b0010:    begin // select the third bank
                port2_req_tag_out   =   postb_port2_req_tag_out[(NUM_BANKS-2)*2-1 -: 2];
                port2_data_out      =   postb_port2_data_out[(NUM_BANKS-2)*16-1 -: 16];
                port2_valid_out     =   postb_port2_valid_out[(NUM_BANKS-2)*1-1 -: 1];
            end

            4'b0100:    begin // select the second bank
                port2_req_tag_out   =   postb_port2_req_tag_out[(NUM_BANKS-1)*2-1 -: 2];
                port2_data_out      =   postb_port2_data_out[(NUM_BANKS-1)*16-1 -: 16];
                port2_valid_out     =   postb_port2_valid_out[(NUM_BANKS-1)*1-1 -: 1];
            end

            4'b1000:    begin // select the first bank
                port2_req_tag_out   =   postb_port2_req_tag_out[(NUM_BANKS-0)*2-1 -: 2];
                port2_data_out      =   postb_port2_data_out[(NUM_BANKS-0)*16-1 -: 16];
                port2_valid_out     =   postb_port2_valid_out[(NUM_BANKS-0)*1-1 -: 1];
            end

            default: begin
                port2_req_tag_out   =   2'h0;
                port2_data_out      =   16'h0;
                port2_valid_out     =   1'h0;
            end
        endcase
    end

    /// port3
    always @ (*) begin
        case ({postb_port3_valid_out})

            4'b0000:    begin
                port3_req_tag_out   =   2'h0;
                port3_data_out      =   16'h0;
                port3_valid_out     =   1'h0;
            end

            4'b0001:    begin // select the fourth bank
                port3_req_tag_out   =   postb_port3_req_tag_out[(NUM_BANKS-3)*2-1 -: 2];
                port3_data_out      =   postb_port3_data_out[(NUM_BANKS-3)*16-1 -: 16];
                port3_valid_out     =   postb_port3_valid_out[(NUM_BANKS-3)*1-1 -: 1];
            end

            4'b0010:    begin // select the third bank
                port3_req_tag_out   =   postb_port3_req_tag_out[(NUM_BANKS-2)*2-1 -: 2];
                port3_data_out      =   postb_port3_data_out[(NUM_BANKS-2)*16-1 -: 16];
                port3_valid_out     =   postb_port3_valid_out[(NUM_BANKS-2)*1-1 -: 1];
            end

            4'b0100:    begin // select the second bank
                port3_req_tag_out   =   postb_port3_req_tag_out[(NUM_BANKS-1)*2-1 -: 2];
                port3_data_out      =   postb_port3_data_out[(NUM_BANKS-1)*16-1 -: 16];
                port3_valid_out     =   postb_port3_valid_out[(NUM_BANKS-1)*1-1 -: 1];
            end

            4'b1000:    begin // select the first bank
                port3_req_tag_out   =   postb_port3_req_tag_out[(NUM_BANKS-0)*2-1 -: 2];
                port3_data_out      =   postb_port3_data_out[(NUM_BANKS-0)*16-1 -: 16];
                port3_valid_out     =   postb_port3_valid_out[(NUM_BANKS-0)*1-1 -: 1];
            end

            default: begin
                port3_req_tag_out   =   2'h0;
                port3_data_out      =   16'h0;
                port3_valid_out     =   1'h0;
            end
        endcase
    end
endmodule
