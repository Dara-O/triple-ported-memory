`timescale 1ns/1ps

module triple_ported_memory (
    input   wire    [11:0]      port1_addr,
    input   wire    [11:0]      port2_addr,
    input   wire    [11:0]      port3_addr,

    input   wire    [15:0]      port1_data_in,
    input   wire    [15:0]      port2_data_in,
    input   wire    [15:0]      port3_data_in,

    input   wire                port1_wen, // active high write enable
    input   wire                port2_wen,
    input   wire                port3_wen,

    input   wire                port1_valid_in,
    input   wire                port2_valid_in,
    input   wire                port3_valid_in,

    input   wire                clk,
    input   wire                reset_n,

    output  wire    [15:0]      port1_data_out,
    output  wire    [15:0]      port2_data_out,
    output  wire    [15:0]      port3_data_out,    

    output  wire                port1_valid_out,
    output  wire                port2_valid_out,
    output  wire                port3_valid_out,

    output  wire                freeze_inputs
);

// input flop
reg    [11:0]      port1_addr_reg;
reg    [11:0]      port2_addr_reg;
reg    [11:0]      port3_addr_reg;
reg    [15:0]      port1_data_in_reg;
reg    [15:0]      port2_data_in_reg;
reg    [15:0]      port3_data_in_reg;
reg                port1_wen_reg; 
reg                port2_wen_reg;
reg                port3_wen_reg;
reg                port1_valid_in_reg;
reg                port2_valid_in_reg;
reg                port3_valid_in_reg;

always @ (posedge clk, negedge reset_n) begin
    if(~reset_n) begin
        port1_addr_reg      <= 0;
        port2_addr_reg      <= 0;
        port3_addr_reg      <= 0;
        port1_data_in_reg   <= 0;
        port2_data_in_reg   <= 0;
        port3_data_in_reg   <= 0;
        port1_wen_reg       <= 0; 
        port2_wen_reg       <= 0;
        port3_wen_reg       <= 0;
        port1_valid_in_reg  <= 0;
        port2_valid_in_reg  <= 0;
        port3_valid_in_reg  <= 0;
    end
    else if(~postbc_freeze_inputs) begin
        port1_addr_reg      <= port1_addr;
        port2_addr_reg      <= port2_addr;
        port3_addr_reg      <= port3_addr;

        port1_data_in_reg   <= port1_data_in;
        port2_data_in_reg   <= port2_data_in;
        port3_data_in_reg   <= port3_data_in;

        port1_wen_reg       <= port1_wen;
        port2_wen_reg       <= port2_wen;
        port3_wen_reg       <= port3_wen;

        port1_valid_in_reg  <= port1_valid_in;
        port2_valid_in_reg  <= port2_valid_in;
        port3_valid_in_reg  <= port3_valid_in;
    end
end

// connect priority_generator to prioritizer
wire [2:0] port_priority;

priority_fsm priority_generator(
    .port1_valid(port1_valid_in_reg),
    .port2_valid(port2_valid_in_reg),
    .port3_valid(port3_valid_in_reg),

    .clk(clk),
    .reset_n(reset_n),

    .port_priority(port_priority)
);

// connect prioritizer to memory_bank_cluster
wire    [11:0]      postp_port1_addr;
wire    [11:0]      postp_port2_addr;
wire    [11:0]      postp_port3_addr;
wire    [15:0]      postp_port1_data_in;
wire    [15:0]      postp_port2_data_in;
wire    [15:0]      postp_port3_data_in;
wire                postp_port1_wen; 
wire                postp_port2_wen;
wire                postp_port3_wen;
wire                postp_port1_valid_in;
wire                postp_port2_valid_in;
wire                postp_port3_valid_in;

wire    [1:0]       port1_original_pid;
wire    [1:0]       port2_original_pid;
wire    [1:0]       port3_original_pid;

port_prioritizer #(.WIDTH(29)) prioritizer (
    .port1_data({port1_addr_reg, port1_data_in_reg, port1_wen_reg}),
    .port1_valid(port1_valid_in_reg),
    .port2_data({port2_addr_reg, port2_data_in_reg, port2_wen_reg}),
    .port2_valid(port2_valid_in_reg),
    .port3_data({port3_addr_reg, port3_data_in_reg, port3_wen_reg}),
    .port3_valid(port3_valid_in_reg),

    .priority1_data({postp_port1_addr, postp_port1_data_in, postp_port1_wen}),
    .priority1_valid(postp_port1_valid_in),
    .priority1_orig_pid(port1_original_pid),

    .priority2_data({postp_port2_addr, postp_port2_data_in, postp_port2_wen}),
    .priority2_valid(postp_port2_valid_in),
    .priority2_orig_pid(port2_original_pid),

    .priority3_data({postp_port3_addr, postp_port3_data_in, postp_port3_wen}),
    .priority3_valid(postp_port3_valid_in),
    .priority3_orig_pid(port3_original_pid)

);

// connect bank_cluster to deprioritiver
wire    [1:0]       postbc_port1_orig_id;
wire    [1:0]       postbc_port2_orig_id;
wire    [1:0]       postbc_port3_orig_id;
wire    [15:0]      postbc_port1_data;
wire    [15:0]      postbc_port2_data;
wire    [15:0]      postbc_port3_data;
wire                postbc_port1_valid;
wire                postbc_port2_valid;
wire                postbc_port3_valid;


// connect bank_cluster to input flop
wire    postbc_freeze_inputs;
assign freeze_inputs = postbc_freeze_inputs;

memory_banks_cluster bank_cluster(
    .port1_req_tag_in(port1_original_pid),
    .port2_req_tag_in(port2_original_pid),
    .port3_req_tag_in(port3_original_pid),

    .port1_addr(postp_port1_addr),
    .port2_addr(postp_port2_addr),
    .port3_addr(postp_port3_addr),

    .port1_data_in(postp_port1_data_in),
    .port2_data_in(postp_port2_data_in),
    .port3_data_in(postp_port3_data_in),

    .port1_wen(postp_port1_wen),
    .port2_wen(postp_port2_wen),
    .port3_wen(postp_port3_wen),

    .port1_valid(postp_port1_valid_in),
    .port2_valid(postp_port2_valid_in),
    .port3_valid(postp_port3_valid_in),

    .clk(clk),
    .reset_n(reset_n),

    .port1_req_tag_out(postbc_port1_orig_id),
    .port2_req_tag_out(postbc_port2_orig_id),
    .port3_req_tag_out(postbc_port3_orig_id),
    .port1_data_out(postbc_port1_data),
    .port2_data_out(postbc_port2_data),
    .port3_data_out(postbc_port3_data),
    .port1_valid_out(postbc_port1_valid),
    .port2_valid_out(postbc_port2_valid),
    .port3_valid_out(postbc_port3_valid),
    .freeze_inputs(postbc_freeze_inputs)
);  

port_deprioritizer #(.WIDTH(16)) deprioritizer(
    .port1_orig_id (postbc_port1_orig_id),
    .port2_orig_id (postbc_port2_orig_id),
    .port3_orig_id (postbc_port3_orig_id),

    .port1_data_in (postbc_port1_data),
    .port2_data_in (postbc_port2_data),
    .port3_data_in (postbc_port3_data),
    .port1_valid_in (postbc_port1_valid),
    .port2_valid_in (postbc_port2_valid),
    .port3_valid_in (postbc_port3_valid),

    .port1_data_out (port1_data_out),
    .port2_data_out (port2_data_out),
    .port3_data_out (port3_data_out),
    .port1_valid_out (port1_valid_out),
    .port2_valid_out (port2_valid_out),
    .port3_valid_out (port3_valid_out)
);


endmodule