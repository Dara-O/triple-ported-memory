`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/14/2022 04:29:22 PM
// Design Name:
// Module Name: queue_steerer
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


module queue_steerer(
    input   wire    [1:0]       port1_req_tag_in,
    input   wire    [1:0]       port2_req_tag_in,
    input   wire    [1:0]       port3_req_tag_in,

    input   wire    [1:0]       port1_id,
    input   wire    [1:0]       port2_id,
    input   wire    [1:0]       port3_id,

    input   wire    [9:0]       port1_addr,
    input   wire    [9:0]       port2_addr,
    input   wire    [9:0]       port3_addr,

    input   wire    [15:0]      port1_datain,
    input   wire    [15:0]      port2_datain,
    input   wire    [15:0]      port3_datain,

    input   wire    [0:0]       port1_wen,
    input   wire    [0:0]       port2_wen,
    input   wire    [0:0]       port3_wen,

    input   wire    [0:0]       port1_valid,
    input   wire    [0:0]       port2_valid,
    input   wire    [0:0]       port3_valid,


    output  wire     [9:0]       rw1_addr,
    output  wire     [9:0]       rw2_addr,
    output  wire     [9:0]       rw3_addr,
    output  wire     [9:0]       r1_addr,
    output  wire     [9:0]       r2_addr,

    output  wire     [15:0]      rw1_datain,
    output  wire     [15:0]      rw2_datain,
    output  wire     [15:0]      rw3_datain,
    output  wire     [15:0]      r1_datain,
    output  wire     [15:0]      r2_datain,

    output  wire     [0:0]      rw1_wen,
    output  wire     [0:0]      rw2_wen,
    output  wire     [0:0]      rw3_wen,
    output  wire     [0:0]      r1_wen,
    output  wire     [0:0]      r2_wen,

    output  wire     [0:0]      rw1_valid,
    output  wire     [0:0]      rw2_valid,
    output  wire     [0:0]      rw3_valid,
    output  wire     [0:0]      r1_valid,
    output  wire     [0:0]      r2_valid,

    output  reg      [1:0]      rw1_port_id,
    output  reg      [1:0]      rw2_port_id,
    output  reg      [1:0]      rw3_port_id,
    output  reg      [1:0]      r1_port_id,
    output  reg      [1:0]      r2_port_id,

    output  wire     [1:0]      rw1_req_tag_out,
    output  wire     [1:0]      rw2_req_tag_out,
    output  wire     [1:0]      rw3_req_tag_out,
    output  wire     [1:0]      r1_req_tag_out,
    output  wire     [1:0]      r2_req_tag_out
  );

  wire [29:0] port1_in;
  wire [29:0] port2_in;
  wire [29:0] port3_in;

  assign port1_in = {port1_addr, port1_datain, port1_wen, port1_valid, port1_req_tag_in};
  assign port2_in = {port2_addr, port2_datain, port2_wen, port2_valid, port2_req_tag_in};
  assign port3_in = {port3_addr, port3_datain, port3_wen, port3_valid, port3_req_tag_in};

  reg [29:0] rw1_out;
  reg [29:0] rw2_out;
  reg [29:0] rw3_out;

  reg [29:0] r1_out;
  reg [29:0] r2_out;

  assign {rw1_addr, rw1_datain, rw1_wen, rw1_valid, rw1_req_tag_out}   = rw1_out;
  assign {rw2_addr, rw2_datain, rw2_wen, rw2_valid, rw2_req_tag_out}   = rw2_out;
  assign {rw3_addr, rw3_datain, rw3_wen, rw3_valid, rw3_req_tag_out}   = rw3_out;

  assign {r1_addr, r1_datain, r1_wen, r1_valid, r1_req_tag_out}       = r1_out;
  assign {r2_addr, r2_datain, r2_wen, r2_valid, r2_req_tag_out}       = r2_out;

  always @ (*)
  begin

    case({
             port1_wen,
             port2_wen,
             port3_wen
           })

      // if everything is read or port1 is write and the rest are read
      3'b000 :
      begin
        rw1_out         = port1_in;
        rw1_port_id     = port1_id;
        rw2_out         = 0;
        rw2_port_id     = 0;
        rw3_out         = 0;
        rw3_port_id     = 0;

        r1_out          = port2_in;
        r1_port_id      = port2_id;
        r2_out          = port3_in;
        r2_port_id      = port3_id;
      end

      3'b100 :
      begin
        rw1_out         = port1_in;
        rw1_port_id     = port1_id;
        rw2_out         = 0;
        rw2_port_id     = 0;
        rw3_out         = 0;
        rw3_port_id     = 0;

        r1_out          = port2_in;
        r1_port_id      = port2_id;
        r2_out          = port3_in;
        r2_port_id      = port3_id;
      end

      // if port3 is write
      3'b001 :
      begin
        rw1_out         = port3_in;
        rw1_port_id     = port3_id;
        rw2_out         = 0;
        rw2_port_id     = 0;
        rw3_out         = 0;
        rw3_port_id     = 0;

        r1_out          = port1_in;
        r1_port_id      = port1_id;
        r2_out          = port2_in;
        r2_port_id      = port2_id;
      end

      // if port2 is write
      3'b010 :
      begin
        rw1_out         = port2_in;
        rw1_port_id     = port2_id;
        rw2_out         = 0;
        rw2_port_id     = 0;
        rw3_out         = 0;
        rw3_port_id     = 0;

        r1_out          = port1_in;
        r1_port_id      = port1_id;
        r2_out          = port3_in;
        r2_port_id      = port3_id;
      end

      // if port2 and port3 are write
      3'b011 :
      begin
        rw1_out         = port2_in;
        rw1_port_id     = port2_id;
        rw2_out         = port3_in;
        rw2_port_id     = port3_id;
        rw3_out         = 0;
        rw3_port_id     = 0;

        r1_out          = port1_in;
        r1_port_id      = port1_id;
        r2_out          = 0;
        r2_port_id      = 0;
      end

      // if port1 and port3 are write
      3'b101 :
      begin
        rw1_out         = port1_in;
        rw1_port_id     = port1_id;
        rw2_out         = port3_in;
        rw2_port_id     = port3_id;
        rw3_out         = 0;
        rw3_port_id     = 0;

        r1_out          = port2_in;
        r1_port_id      = port2_id;
        r2_out          = 0;
        r2_port_id      = 0;
      end

      // if port1 and port2 are write
      3'b110 :
      begin
        rw1_out         = port1_in;
        rw1_port_id     = port1_id;
        rw2_out         = port2_in;
        rw2_port_id     = port2_id;
        rw3_out         = 0;
        rw3_port_id     = 0;

        r1_out          = port3_in;
        r1_port_id      = port3_id;
        r2_out          = 0;
        r2_port_id      = 0;
      end

      3'b111 :
      begin
        rw1_out         = port1_in;
        rw1_port_id     = port1_id;
        rw2_out         = port2_in;
        rw2_port_id     = port2_id;
        rw3_out         = port3_in;
        rw3_port_id     = port3_id;

        r1_out          = 0;
        r1_port_id      = 0;
        r2_out          = 0;
        r2_port_id      = 0;
      end

      default:
      begin
        rw1_out         = 0;
        rw1_port_id     = 0;
        rw2_out         = 0;
        rw2_port_id     = 0;
        rw3_out         = 0;
        rw3_port_id     = 0;

        r1_out          = 0;
        r1_port_id      = 0;
        r2_out          = 0;
        r2_port_id      = 0;
      end

    endcase
  end

endmodule
