`timescale 1ns / 1ps

/*
Note: The port*_valid inputs to all other banks must be gated by NOR of "freeze_inputs" for all banks
    This prevents unwanted bank activations for the other banks. If "freeze_inputs" == 1, 
    the inputs to all other banks will be zero (invalid)
*/

module memory_bank_logic (
    input   wire    [1:0]       BANK_ID,

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

    output  wire                freeze_inputs,

    // from srams
    input   wire    [15:0]      sram_rw_dout,
    input   wire    [15:0]      sram_r_dout,

    // to srams
    output  wire    [9:0]       postrs_addr,
    output  wire                postrs_valid,
    output  wire    [9:0]       postrws_addr, // post rw_serializer
    output  wire    [15:0]      postrws_data_in,
    output  wire                postrws_valid,
    output  wire                postrws_w_en
);


wire    [1:0]       masked_port1_req_tag_in;
wire    [1:0]       masked_port2_req_tag_in;
wire    [1:0]       masked_port3_req_tag_in;
wire    [9:0]       masked_port1_addr;
wire    [9:0]       masked_port2_addr;
wire    [9:0]       masked_port3_addr;
wire    [15:0]      masked_port1_data_in;
wire    [15:0]      masked_port2_data_in;
wire    [15:0]      masked_port3_data_in;
wire    [0:0]       masked_port1_wen;
wire    [0:0]       masked_port2_wen;
wire    [0:0]       masked_port3_wen;
wire    [0:0]       masked_port1_valid;
wire    [0:0]       masked_port2_valid;
wire    [0:0]       masked_port3_valid;


wire [1:0]  port1_id;
wire [1:0]  port2_id;
wire [1:0]  port3_id;

// wires connecting validity filter and queue steerer
wire    [1:0]       postvf_port1_req_tag;
wire    [1:0]       postvf_port2_req_tag;
wire    [1:0]       postvf_port3_req_tag;
wire    [9:0]       postvf_port1_addr;
wire    [9:0]       postvf_port2_addr;
wire    [9:0]       postvf_port3_addr;
wire    [15:0]      postvf_port1_data_in;
wire    [15:0]      postvf_port2_data_in;
wire    [15:0]      postvf_port3_data_in;
wire    [0:0]       postvf_port1_wen;
wire    [0:0]       postvf_port2_wen;
wire    [0:0]       postvf_port3_wen;
wire    [0:0]       postvf_port1_valid;
wire    [0:0]       postvf_port2_valid;
wire    [0:0]       postvf_port3_valid;

// wires connecting queue steerer to rw and r serializers
wire     [9:0]      postqs_rw1_addr;
wire     [9:0]      postqs_rw2_addr;
wire     [9:0]      postqs_rw3_addr;
wire     [9:0]      postqs_r1_addr;
wire     [9:0]      postqs_r2_addr;
wire     [15:0]     postqs_rw1_datain;
wire     [15:0]     postqs_rw2_datain;
wire     [15:0]     postqs_rw3_datain;
wire     [15:0]     postqs_r1_datain;
wire     [15:0]     postqs_r2_datain;
wire     [0:0]      postqs_rw1_wen;
wire     [0:0]      postqs_rw2_wen;
wire     [0:0]      postqs_rw3_wen;
wire     [0:0]      postqs_r1_wen;
wire     [0:0]      postqs_r2_wen;
wire     [0:0]      postqs_rw1_valid;
wire     [0:0]      postqs_rw2_valid;
wire     [0:0]      postqs_rw3_valid;
wire     [0:0]      postqs_r1_valid;
wire     [0:0]      postqs_r2_valid;
wire     [1:0]      postqs_rw1_port_id;
wire     [1:0]      postqs_rw2_port_id;
wire     [1:0]      postqs_rw3_port_id;
wire     [1:0]      postqs_r1_port_id;
wire     [1:0]      postqs_r2_port_id;
wire     [1:0]      postqs_rw1_req_tag;
wire     [1:0]      postqs_rw2_req_tag;
wire     [1:0]      postqs_rw3_req_tag;
wire     [1:0]      postqs_r1_req_tag;
wire     [1:0]      postqs_r2_req_tag;

// wires between serializers and srams
wire    [1:0]       postrs_req_tag; // request tag
wire    [1:0]       postrs_port_id;

wire    [1:0]       postrws_req_tag; // request tag
wire    [1:0]       postrws_port_id;


wire rs_freeze_inputs;
wire rws_freeze_inputs;

// connects sram reconvergence flop to rw deserializer
reg     [1:0]       postpf_r_req_tag;
reg     [1:0]       postpf_r_port_id;
reg                 postpf_r_valid;
reg     [1:0]       postpf_rw_req_tag;
reg     [1:0]       postpf_rw_port_id;
reg                 postpf_rw_valid;

// connects deserializers to arbiter
wire    [1:0]       postrwds_port1_req_tag;
wire    [15:0]      postrwds_port1_dout;
wire                postrwds_port1_valid;
wire    [1:0]       postrwds_port2_req_tag;
wire    [15:0]      postrwds_port2_dout;
wire                postrwds_port2_valid;
wire    [1:0]       postrwds_port3_req_tag;
wire    [15:0]      postrwds_port3_dout;
wire                postrwds_port3_valid;


wire    [1:0]       postrds_port1_req_tag;
wire    [15:0]      postrds_port1_dout;
wire                postrds_port1_valid;
wire    [1:0]       postrds_port2_req_tag;
wire    [15:0]      postrds_port2_dout;
wire                postrds_port2_valid;
wire    [1:0]       postrds_port3_req_tag;
wire    [15:0]      postrds_port3_dout;
wire                postrds_port3_valid;

// coneects bank_out_arb to output ports
wire    [1:0]       postboa_port1_req_tag_out;
wire    [1:0]       postboa_port2_req_tag_out;
wire    [1:0]       postboa_port3_req_tag_out;
wire    [15:0]      postboa_port1_data_out;
wire    [15:0]      postboa_port2_data_out;
wire    [15:0]      postboa_port3_data_out;
wire                postboa_port1_valid_out;
wire                postboa_port2_valid_out;
wire                postboa_port3_valid_out;

assign freeze_inputs = rws_freeze_inputs | rs_freeze_inputs;

validity_mask vld_mask(
    .BANK_ID(BANK_ID),
    .port1_req_tag_in(port1_req_tag_in),
    .port2_req_tag_in(port2_req_tag_in),
    .port3_req_tag_in(port3_req_tag_in),
    .port1_addr(port1_addr),
    .port2_addr(port2_addr),
    .port3_addr(port3_addr),
    .port1_data_in(port1_data_in),
    .port2_data_in(port2_data_in),
    .port3_data_in(port3_data_in),
    .port1_wen(port1_wen),
    .port2_wen(port2_wen),
    .port3_wen(port3_wen),
    .port1_valid(port1_valid),
    .port2_valid(port2_valid),
    .port3_valid(port3_valid),

    //outputs
    .masked_port1_req_tag_in(masked_port1_req_tag_in),
    .masked_port2_req_tag_in(masked_port2_req_tag_in),
    .masked_port3_req_tag_in(masked_port3_req_tag_in),
    .masked_port1_addr(masked_port1_addr),
    .masked_port2_addr(masked_port2_addr),
    .masked_port3_addr(masked_port3_addr),
    .masked_port1_data_in(masked_port1_data_in),
    .masked_port2_data_in(masked_port2_data_in),
    .masked_port3_data_in(masked_port3_data_in),
    .masked_port1_wen(masked_port1_wen),
    .masked_port2_wen(masked_port2_wen),
    .masked_port3_wen(masked_port3_wen),
    .masked_port1_valid(masked_port1_valid),
    .masked_port2_valid(masked_port2_valid),
    .masked_port3_valid(masked_port3_valid) 

);

validity_filter #(.WIDTH(27)) vld_filter (
    .port1_in ({masked_port1_addr, masked_port1_data_in, masked_port1_wen}),
    .port2_in ({masked_port2_addr, masked_port2_data_in, masked_port2_wen}),
    .port3_in ({masked_port3_addr, masked_port3_data_in, masked_port3_wen}),
    .port1_req_tag_in (masked_port1_req_tag_in),
    .port2_req_tag_in (masked_port2_req_tag_in),
    .port3_req_tag_in (masked_port3_req_tag_in),
    .port1_in_valid (masked_port1_valid),
    .port2_in_valid (masked_port2_valid),
    .port3_in_valid (masked_port3_valid),

    // outputs
    .port1_id (port1_id),
    .port2_id (port2_id),
    .port3_id (port3_id),
    .port1_req_tag_out (postvf_port1_req_tag),
    .port2_req_tag_out (postvf_port2_req_tag),
    .port3_req_tag_out (postvf_port3_req_tag),
    .port1_out ({postvf_port1_addr, postvf_port1_data_in, postvf_port1_wen}),
    .port2_out ({postvf_port2_addr, postvf_port2_data_in, postvf_port2_wen}),
    .port3_out ({postvf_port3_addr, postvf_port3_data_in, postvf_port3_wen}),
    .port1_out_valid (postvf_port1_valid),
    .port2_out_valid (postvf_port2_valid),
    .port3_out_valid (postvf_port3_valid)
);

queue_steerer qs (
    .port1_req_tag_in (postvf_port1_req_tag),
    .port2_req_tag_in (postvf_port2_req_tag),
    .port3_req_tag_in (postvf_port3_req_tag),
    .port1_id (port1_id),
    .port2_id (port2_id),
    .port3_id (port3_id),
    .port1_addr (postvf_port1_addr),
    .port2_addr (postvf_port2_addr),
    .port3_addr (postvf_port3_addr),
    .port1_datain (postvf_port1_data_in),
    .port2_datain (postvf_port2_data_in),
    .port3_datain (postvf_port3_data_in),
    .port1_wen (postvf_port1_wen),
    .port2_wen (postvf_port2_wen),
    .port3_wen (postvf_port3_wen),
    .port1_valid (postvf_port1_valid),
    .port2_valid (postvf_port2_valid),
    .port3_valid (postvf_port3_valid),

    // outupts
    .rw1_addr (postqs_rw1_addr),
    .rw2_addr (postqs_rw2_addr),
    .rw3_addr (postqs_rw3_addr),

    .r1_addr (postqs_r1_addr),
    .r2_addr (postqs_r2_addr),

    .rw1_datain (postqs_rw1_datain),
    .rw2_datain (postqs_rw2_datain),
    .rw3_datain (postqs_rw3_datain),

    .r1_datain (),
    .r2_datain (),

    .rw1_wen (postqs_rw1_wen),
    .rw2_wen (postqs_rw2_wen),
    .rw3_wen (postqs_rw3_wen),

    .r1_wen (postqs_r1_wen),
    .r2_wen (postqs_r2_wen),

    .rw1_valid (postqs_rw1_valid),
    .rw2_valid (postqs_rw2_valid),
    .rw3_valid (postqs_rw3_valid),

    .r1_valid (postqs_r1_valid),
    .r2_valid (postqs_r2_valid),

    .rw1_port_id (postqs_rw1_port_id),
    .rw2_port_id (postqs_rw2_port_id),
    .rw3_port_id (postqs_rw3_port_id),

    .r1_port_id (postqs_r1_port_id),
    .r2_port_id (postqs_r2_port_id),

    .rw1_req_tag_out (postqs_rw1_req_tag),
    .rw2_req_tag_out (postqs_rw2_req_tag),
    .rw3_req_tag_out (postqs_rw3_req_tag),

    .r1_req_tag_out (postqs_r1_req_tag),
    .r2_req_tag_out (postqs_r2_req_tag)
);

// fanout buffer
wire reset_n_fa;
buf(reset_n_fa, reset_n);

port_r_serializer #(.WIDTH(14)) r_serializer (
    .entry1_data ({postqs_r1_req_tag, postqs_r1_port_id, postqs_r1_addr}),
    .entry2_data ({postqs_r2_req_tag, postqs_r2_port_id, postqs_r2_addr}),
    .entry1_valid (postqs_r1_valid & ~freeze_inputs),
    .entry2_valid (postqs_r2_valid & ~freeze_inputs),
    .clk (clk),
    .reset_n (reset_n_fa),

    .sout_data ({postrs_req_tag, postrs_port_id, postrs_addr}),
    .sout_valid (postrs_valid),
    .freeze_inputs  (rs_freeze_inputs)
);

port_rw_serializer #(.WIDTH (31)) rw_serializer (
    .entry1_data ({postqs_rw1_req_tag, postqs_rw1_port_id, postqs_rw1_addr, postqs_rw1_datain, postqs_rw1_wen}),
    .entry2_data ({postqs_rw2_req_tag, postqs_rw2_port_id, postqs_rw2_addr, postqs_rw2_datain, postqs_rw2_wen}),
    .entry3_data ({postqs_rw3_req_tag, postqs_rw3_port_id, postqs_rw3_addr, postqs_rw3_datain, postqs_rw3_wen}),
    .entry1_valid (postqs_rw1_valid & ~freeze_inputs),
    .entry2_valid (postqs_rw2_valid & ~freeze_inputs),
    .entry3_valid (postqs_rw3_valid & ~freeze_inputs),
    .clk (clk),
    .reset_n (reset_n_fa),

    .sout_data ({postrws_req_tag, postrws_port_id, postrws_addr, postrws_data_in, postrws_w_en}),
    .sout_valid (postrws_valid),
    .freeze_inputs  (rws_freeze_inputs)
);

wire reset_n_fb;
buf(reset_n_fb, reset_n);

// sram reconvergence flop
always @ (posedge clk, negedge reset_n_fb) begin
    if(!reset_n_fb) begin
        postpf_r_req_tag    <= 0;
        postpf_r_port_id    <= 0;
        postpf_r_valid      <= 0;
        postpf_rw_req_tag   <= 0;    
        postpf_rw_port_id   <= 0;    
        postpf_rw_valid     <= 0;
    end 
    else begin
        postpf_r_req_tag    <= postrs_req_tag;
        postpf_r_port_id    <= postrs_port_id;
        postpf_r_valid      <= postrs_valid;
        postpf_rw_req_tag   <= postrws_req_tag;    
        postpf_rw_port_id   <= postrws_port_id;    
        postpf_rw_valid     <= postrws_valid & ~postrws_w_en;
    end
end

port_deserializer #(.WIDTH(18)) r_deserializer (
    .sin_data ({postpf_r_req_tag, sram_r_dout}),
    .sin_valid (postpf_r_valid),
    .entry_id (postpf_r_port_id),

    .port1_data  ({postrds_port1_req_tag, postrds_port1_dout}),
    .port2_data  ({postrds_port2_req_tag, postrds_port2_dout}),
    .port3_data  ({postrds_port3_req_tag, postrds_port3_dout}),
    .port1_valid (postrds_port1_valid),
    .port2_valid (postrds_port2_valid ),
    .port3_valid (postrds_port3_valid)
);

port_deserializer #(.WIDTH(18)) rw_deserializer (
    .sin_data ({postpf_rw_req_tag, sram_rw_dout}),
    .sin_valid (postpf_rw_valid),
    .entry_id (postpf_rw_port_id),
    
    .port1_data  ({postrwds_port1_req_tag, postrwds_port1_dout}),
    .port2_data  ({postrwds_port2_req_tag, postrwds_port2_dout}),
    .port3_data  ({postrwds_port3_req_tag, postrwds_port3_dout}),
    .port1_valid (postrwds_port1_valid),
    .port2_valid (postrwds_port2_valid),
    .port3_valid (postrwds_port3_valid)
);

bank_out_arb output_arb (
  .rw1_data (postrwds_port1_dout),
  .rw2_data (postrwds_port2_dout),
  .rw3_data (postrwds_port3_dout),
  .rw1_valid (postrwds_port1_valid),
  .rw2_valid (postrwds_port2_valid),
  .rw3_valid (postrwds_port3_valid),
  .rw1_req_tag (postrwds_port1_req_tag),
  .rw2_req_tag (postrwds_port2_req_tag),
  .rw3_req_tag (postrwds_port3_req_tag),
  .r1_data (postrds_port1_dout),
  .r2_data (postrds_port2_dout),
  .r3_data (postrds_port3_dout),
  .r1_valid (postrds_port1_valid),
  .r2_valid (postrds_port2_valid),
  .r3_valid (postrds_port3_valid),
  .r1_req_tag (postrds_port1_req_tag),
  .r2_req_tag (postrds_port2_req_tag),
  .r3_req_tag (postrds_port3_req_tag),

  .port1_data    (postboa_port1_data_out),
  .port2_data    (postboa_port2_data_out),
  .port3_data    (postboa_port3_data_out ),
  .port1_valid   (postboa_port1_valid_out),
  .port2_valid   (postboa_port2_valid_out),
  .port3_valid   (postboa_port3_valid_out),
  .port1_req_tag (postboa_port1_req_tag_out),
  .port2_req_tag (postboa_port2_req_tag_out),
  .port3_req_tag (postboa_port3_req_tag_out)
);

// output flop
always @ (posedge clk, negedge reset_n_fb) begin
    if(~reset_n_fb) begin
        port1_req_tag_out   <=  0;
        port2_req_tag_out   <=  0;
        port3_req_tag_out   <=  0;
        port1_data_out      <=  0;
        port2_data_out      <=  0;
        port3_data_out      <=  0;
        port1_valid_out     <=  0;
        port2_valid_out     <=  0;
        port3_valid_out     <=  0;
    end
    else begin
        port1_req_tag_out   <=  postboa_port1_req_tag_out;
        port2_req_tag_out   <=  postboa_port2_req_tag_out;
        port3_req_tag_out   <=  postboa_port3_req_tag_out;
        port1_data_out      <=  postboa_port1_data_out;
        port2_data_out      <=  postboa_port2_data_out;
        port3_data_out      <=  postboa_port3_data_out;
        port1_valid_out     <=  postboa_port1_valid_out;
        port2_valid_out     <=  postboa_port2_valid_out;
        port3_valid_out     <=  postboa_port3_valid_out;
    end
end

endmodule