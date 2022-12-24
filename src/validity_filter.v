`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/10/2022 01:34:57 AM
// Design Name: 
// Module Name: validity_filter
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


module validity_filter #(parameter WIDTH=8) (
    input   wire    [WIDTH-1:0]     port1_in,
    input   wire    [1:0]           port1_req_tag_in,
    input   wire                    port1_in_valid,
    input   wire    [WIDTH-1:0]     port2_in,
    input   wire    [1:0]           port2_req_tag_in,
    input   wire                    port2_in_valid,
    input   wire    [WIDTH-1:0]     port3_in,
    input   wire    [1:0]           port3_req_tag_in,
    input   wire                    port3_in_valid,
    
    output  reg     [1:0]           port1_id,
    output  reg     [1:0]           port1_req_tag_out,                 
    output  reg     [WIDTH-1:0]     port1_out,
    output  reg                     port1_out_valid,
    output  reg     [1:0]           port2_id,
    output  reg     [1:0]           port2_req_tag_out,
    output  reg     [WIDTH-1:0]     port2_out,
    output  reg                     port2_out_valid,
    output  reg     [1:0]           port3_id,
    output  reg     [1:0]           port3_req_tag_out,
    output  reg     [WIDTH-1:0]     port3_out,
    output  reg                     port3_out_valid    
);

localparam PORT_ID_1       = 1;
localparam PORT_ID_2       = 2;    
localparam PORT_ID_3       = 3;
localparam PORT_ID_INVALID = 0;
    
    always @ (*) begin
        casez({port1_in_valid, port2_in_valid, port3_in_valid})
            3'b1??  :   begin
                port1_out           = port1_in;
                port1_out_valid     = port1_in_valid;
                port1_id            = PORT_ID_1;
                port1_req_tag_out   = port1_req_tag_in;
            end
            3'b01?  : begin
                port1_out           = port2_in;
                port1_out_valid     = port2_in_valid;
                port1_id            = PORT_ID_2;
                port1_req_tag_out   = port2_req_tag_in;
            end
            3'b001 : begin
                port1_out           = port3_in;
                port1_out_valid     = port3_in_valid;
                port1_id            = PORT_ID_3;
                port1_req_tag_out   = port3_req_tag_in;
            end
            default : begin
                port1_out           = port1_in;
                port1_out_valid     = port1_in_valid;
                port1_id            = PORT_ID_1;
                port1_req_tag_out   = port1_req_tag_in;
            end    
        endcase
        
        casez({port1_in_valid & port2_in_valid, port3_in_valid})
            2'b1?  :   begin
                port2_out           = port2_in;
                port2_out_valid     = port2_in_valid;
                port2_id            = PORT_ID_2;
                port2_req_tag_out   = port2_req_tag_in;
            end
            2'b01  : begin
                port2_out           = port3_in;
                port2_out_valid     = port3_in_valid;
                port2_id            = PORT_ID_3;
                port2_req_tag_out   = port3_req_tag_in;
            end
            default : begin
                port2_out       = port2_in;
                port2_out_valid = port2_in_valid;
                port2_id        = PORT_ID_2;
                port2_req_tag_out   = port2_req_tag_in;
            end    
        endcase
        
        port3_out = port3_in;
        port3_id  = PORT_ID_3;
        port3_out_valid = &({port1_in_valid, port2_in_valid, port3_in_valid}) ? port3_in_valid : 0;
        port3_req_tag_out   = port3_req_tag_in;
    end

endmodule