`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/15/2022 02:23:07 AM
// Design Name:
// Module Name: bank_out_arb
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


module bank_out_arb(
        input   wire    [15:0]      rw1_data,
        input   wire    [15:0]      rw2_data,
        input   wire    [15:0]      rw3_data,

        input   wire                rw1_valid,
        input   wire                rw2_valid,
        input   wire                rw3_valid,

        input   wire    [1:0]       rw1_req_tag,
        input   wire    [1:0]       rw2_req_tag,
        input   wire    [1:0]       rw3_req_tag,

        input   wire    [15:0]      r1_data,
        input   wire    [15:0]      r2_data,
        input   wire    [15:0]      r3_data,

        input   wire                r1_valid,
        input   wire                r2_valid,
        input   wire                r3_valid,

        input   wire    [1:0]       r1_req_tag,
        input   wire    [1:0]       r2_req_tag,
        input   wire    [1:0]       r3_req_tag,


        output  wire    [15:0]      port1_data,
        output  wire    [15:0]      port2_data,
        output  wire    [15:0]      port3_data,

        output  wire                port1_valid,
        output  wire                port2_valid,
        output  wire                port3_valid,

        output  wire    [1:0]       port1_req_tag,
        output  wire    [1:0]       port2_req_tag,
        output  wire    [1:0]       port3_req_tag

    );

    wire [18:0] rw1_in;
    wire [18:0] rw2_in;
    wire [18:0] rw3_in;

    assign rw1_in   = {rw1_valid, rw1_data, rw1_req_tag};
    assign rw2_in   = {rw2_valid, rw2_data, rw2_req_tag};
    assign rw3_in   = {rw3_valid, rw3_data, rw3_req_tag};

    wire [18:0] r1_in;
    wire [18:0] r2_in;
    wire [18:0] r3_in;

    assign r1_in    = {r1_valid, r1_data, r1_req_tag};
    assign r2_in    = {r2_valid, r2_data, r2_req_tag};
    assign r3_in    = {r3_valid, r3_data, r3_req_tag};

    reg [18:0] port1_out;
    reg [18:0] port2_out;
    reg [18:0] port3_out;

    assign {port1_valid, port1_data, port1_req_tag} = port1_out;
    assign {port2_valid, port2_data, port2_req_tag} = port2_out;
    assign {port3_valid, port3_data, port3_req_tag} = port3_out;

    always @ (*) begin

        case ({rw1_valid, r1_valid})        
            2'b01 : begin
                port1_out = r1_in;
            end
            
            2'b10 : begin
                port1_out = rw1_in;
            end    

            2'b11: begin
                port1_out = r1_in;
            end

            default : begin
                port1_out = 0;
            end
        endcase

        case ({rw2_valid, r2_valid})
            2'b01 : begin
                port2_out = r2_in;
            end
            
            2'b10 : begin
                port2_out = rw2_in;
            end    

            2'b11: begin
                port2_out = r2_in;
            end

            default : begin
                port2_out = 0;
            end
        endcase

        case ({rw3_valid, r3_valid})
            2'b01 : begin
                port3_out = r3_in;
            end
            
            2'b10 : begin
                port3_out = rw3_in;
            end    

            2'b11: begin
                port3_out = r3_in;
            end

            default: begin
                port3_out = 0;
            end
        endcase

    end

endmodule
