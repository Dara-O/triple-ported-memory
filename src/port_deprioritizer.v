`timescale 1ns/1ps

`include "shared_params.vh"

/* 
    NOTE: The module assumes that port1_orig_id != port2_orig_id != port3_orig_id (unless they are all 0) 
*/
module port_deprioritizer #(parameter WIDTH = 8) (
    input   wire    [1:0]           port1_orig_id,
    input   wire    [1:0]           port2_orig_id,
    input   wire    [1:0]           port3_orig_id,

    input   wire    [WIDTH-1:0]     port1_data_in,
    input   wire    [WIDTH-1:0]     port2_data_in,
    input   wire    [WIDTH-1:0]     port3_data_in,

    input   wire                    port1_valid_in,
    input   wire                    port2_valid_in,
    input   wire                    port3_valid_in,


    output  wire    [WIDTH-1:0]     port1_data_out,
    output  wire    [WIDTH-1:0]     port2_data_out,
    output  wire    [WIDTH-1:0]     port3_data_out,

    output  wire                    port1_valid_out,
    output  wire                    port2_valid_out,
    output  wire                    port3_valid_out
);

    reg [WIDTH-1:0] pre_port1_data_from_pid1; // port1 driven by port1_orig_id
    reg [WIDTH-1:0] pre_port2_data_from_pid1; // port2 driven by port1_orig_id
    reg [WIDTH-1:0] pre_port3_data_from_pid1; // port3 driven by port1_orig_id
    reg pre_port1_valid_from_pid1;
    reg pre_port2_valid_from_pid1;
    reg pre_port3_valid_from_pid1;

    always @(*) begin
        case (port1_orig_id) 
        ORIG_PORT_1_ID : begin
            pre_port1_data_from_pid1    = port1_data_in;
            pre_port2_data_from_pid1    = 0;
            pre_port3_data_from_pid1    = 0;

            pre_port1_valid_from_pid1   = port1_valid_in;
            pre_port2_valid_from_pid1   = 0;
            pre_port3_valid_from_pid1   = 0;
        end 

        ORIG_PORT_2_ID : begin
            pre_port1_data_from_pid1    = 0;
            pre_port2_data_from_pid1    = port1_data_in;
            pre_port3_data_from_pid1    = 0;

            pre_port1_valid_from_pid1   = 0;
            pre_port2_valid_from_pid1   = port1_valid_in;
            pre_port3_valid_from_pid1   = 0;
        end 

        ORIG_PORT_3_ID : begin
            pre_port1_data_from_pid1    = 0;
            pre_port2_data_from_pid1    = 0;
            pre_port3_data_from_pid1    = port1_data_in;

            pre_port1_valid_from_pid1   = 0;
            pre_port2_valid_from_pid1   = 0;
            pre_port3_valid_from_pid1   = port1_valid_in;
        end 

        ORIG_PORT_INVALID_ID : begin
            pre_port1_data_from_pid1    = 0;
            pre_port2_data_from_pid1    = 0;
            pre_port3_data_from_pid1    = 0;

            pre_port1_valid_from_pid1   = 0;
            pre_port2_valid_from_pid1   = 0;
            pre_port3_valid_from_pid1   = 0;
        end 

        default : begin
            pre_port1_data_from_pid1    = 0;
            pre_port2_data_from_pid1    = 0;
            pre_port3_data_from_pid1    = 0;

            pre_port1_valid_from_pid1   = 0;
            pre_port2_valid_from_pid1   = 0;
            pre_port3_valid_from_pid1   = 0;
        end
        endcase
    end

    reg [WIDTH-1:0] pre_port1_data_from_pid2; // port1 driven by port2_orig_id
    reg [WIDTH-1:0] pre_port2_data_from_pid2; // port2 driven by port2_orig_id
    reg [WIDTH-1:0] pre_port3_data_from_pid2; // port3 driven by port2_orig_id
    reg pre_port1_valid_from_pid2;
    reg pre_port2_valid_from_pid2;
    reg pre_port3_valid_from_pid2;

    always @(*) begin
        case (port2_orig_id) 
        ORIG_PORT_1_ID : begin
            pre_port1_data_from_pid2    = port2_data_in;
            pre_port2_data_from_pid2    = 0;
            pre_port3_data_from_pid2    = 0;

            pre_port1_valid_from_pid2   = port2_valid_in;
            pre_port2_valid_from_pid2   = 0;
            pre_port3_valid_from_pid2   = 0;
        end 

        ORIG_PORT_2_ID : begin
            pre_port1_data_from_pid2    = 0;
            pre_port2_data_from_pid2    = port2_data_in;
            pre_port3_data_from_pid2    = 0;

            pre_port1_valid_from_pid2   = 0;
            pre_port2_valid_from_pid2   = port2_valid_in;
            pre_port3_valid_from_pid2   = 0;
        end 

        ORIG_PORT_3_ID : begin
            pre_port1_data_from_pid2    = 0;
            pre_port2_data_from_pid2    = 0;
            pre_port3_data_from_pid2    = port2_data_in;

            pre_port1_valid_from_pid2   = 0;
            pre_port2_valid_from_pid2   = 0;
            pre_port3_valid_from_pid2   = port2_valid_in;
        end 

        ORIG_PORT_INVALID_ID : begin
            pre_port1_data_from_pid2    = 0;
            pre_port2_data_from_pid2    = 0;
            pre_port3_data_from_pid2    = 0;

            pre_port1_valid_from_pid2   = 0;
            pre_port2_valid_from_pid2   = 0;
            pre_port3_valid_from_pid2   = 0;
        end 

        default : begin
            pre_port1_data_from_pid2    = 0;
            pre_port2_data_from_pid2    = 0;
            pre_port3_data_from_pid2    = 0;

            pre_port1_valid_from_pid2   = 0;
            pre_port2_valid_from_pid2   = 0;
            pre_port3_valid_from_pid2   = 0;
        end
        endcase
    end

    reg [WIDTH-1:0] pre_port1_data_from_pid3; // port1 driven by port3_orig_id
    reg [WIDTH-1:0] pre_port2_data_from_pid3; // port2 driven by port3_orig_id
    reg [WIDTH-1:0] pre_port3_data_from_pid3; // port3 driven by port3_orig_id
    reg pre_port1_valid_from_pid3;
    reg pre_port2_valid_from_pid3;
    reg pre_port3_valid_from_pid3;

    always @(*) begin
        case (port3_orig_id) 
        ORIG_PORT_1_ID : begin
            pre_port1_data_from_pid3    = port3_data_in;
            pre_port2_data_from_pid3    = 0;
            pre_port3_data_from_pid3    = 0;

            pre_port1_valid_from_pid3   = port3_valid_in;
            pre_port2_valid_from_pid3   = 0;
            pre_port3_valid_from_pid3   = 0;
        end 

        ORIG_PORT_2_ID : begin
            pre_port1_data_from_pid3    = 0;
            pre_port2_data_from_pid3    = port3_data_in;
            pre_port3_data_from_pid3    = 0;

            pre_port1_valid_from_pid3   = 0;
            pre_port2_valid_from_pid3   = port3_valid_in;
            pre_port3_valid_from_pid3   = 0;
        end 

        ORIG_PORT_3_ID : begin
            pre_port1_data_from_pid3    = 0;
            pre_port2_data_from_pid3    = 0;
            pre_port3_data_from_pid3    = port3_data_in;

            pre_port1_valid_from_pid3   = 0;
            pre_port2_valid_from_pid3   = 0;
            pre_port3_valid_from_pid3   = port3_valid_in;
        end 

        ORIG_PORT_INVALID_ID : begin
            pre_port1_data_from_pid3    = 0;
            pre_port2_data_from_pid3    = 0;
            pre_port3_data_from_pid3    = 0;

            pre_port1_valid_from_pid3   = 0;
            pre_port2_valid_from_pid3   = 0;
            pre_port3_valid_from_pid3   = 0;
        end 

        default : begin
            pre_port1_data_from_pid3    = 0;
            pre_port2_data_from_pid3    = 0;
            pre_port3_data_from_pid3    = 0;

            pre_port1_valid_from_pid3   = 0;
            pre_port2_valid_from_pid3   = 0;
            pre_port3_valid_from_pid3   = 0;
        end
        endcase
    end

    assign port1_data_out = pre_port1_data_from_pid1 | pre_port1_data_from_pid2 | pre_port1_data_from_pid3;
    assign port2_data_out = pre_port2_data_from_pid1 | pre_port2_data_from_pid2 | pre_port2_data_from_pid3; 
    assign port3_data_out = pre_port3_data_from_pid1 | pre_port3_data_from_pid2 | pre_port3_data_from_pid3; 

    assign port1_valid_out = pre_port1_valid_from_pid1 | pre_port1_valid_from_pid2 | pre_port1_valid_from_pid3;
    assign port2_valid_out = pre_port2_valid_from_pid1 | pre_port2_valid_from_pid2 | pre_port2_valid_from_pid3;
    assign port3_valid_out = pre_port3_valid_from_pid1 | pre_port3_valid_from_pid2 | pre_port3_valid_from_pid3;

endmodule