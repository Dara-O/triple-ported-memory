`timescale 1ns/1ps

`include "shared_params.vh"

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


    output  reg     [WIDTH-1:0]     port1_data_out,
    output  reg     [WIDTH-1:0]     port2_data_out,
    output  reg     [WIDTH-1:0]     port3_data_out,

    output  reg                     port1_valid_out,
    output  reg                     port2_valid_out,
    output  reg                     port3_valid_out
);

    always @ (*) begin
        case ({port1_orig_id, port2_orig_id, port3_orig_id})
            {ORIG_PORT_1_ID, ORIG_PORT_2_ID, ORIG_PORT_3_ID} : begin
                port1_data_out  <=  port1_data_in;
                port2_data_out  <=  port2_data_in;
                port3_data_out  <=  port3_data_in;

                port1_valid_out <=  port1_valid_in;
                port2_valid_out <=  port2_valid_in;
                port3_valid_out <=  port3_valid_in;
            end 
            
            {ORIG_PORT_1_ID, ORIG_PORT_3_ID, ORIG_PORT_2_ID} : begin
                port1_data_out  <=  port1_data_in;
                port2_data_out  <=  port3_data_in;
                port3_data_out  <=  port2_data_in;

                port1_valid_out <=  port1_valid_in;
                port2_valid_out <=  port3_valid_in;
                port3_valid_out <=  port2_valid_in;
            end

            {ORIG_PORT_2_ID, ORIG_PORT_1_ID, ORIG_PORT_3_ID} : begin
                port1_data_out  <=  port2_data_in;
                port2_data_out  <=  port1_data_in;
                port3_data_out  <=  port3_data_in;

                port1_valid_out <=  port2_valid_in;
                port2_valid_out <=  port1_valid_in;
                port3_valid_out <=  port3_valid_in;
            end

            {ORIG_PORT_2_ID, ORIG_PORT_3_ID, ORIG_PORT_1_ID} : begin
                port1_data_out  <=  port2_data_in;
                port2_data_out  <=  port3_data_in;
                port3_data_out  <=  port1_data_in;

                port1_valid_out <=  port2_valid_in;
                port2_valid_out <=  port3_valid_in;
                port3_valid_out <=  port1_valid_in;
            end

            {ORIG_PORT_3_ID, ORIG_PORT_1_ID, ORIG_PORT_2_ID} : begin
                port1_data_out  <=  port3_data_in;
                port2_data_out  <=  port1_data_in;
                port3_data_out  <=  port2_data_in;

                port1_valid_out <=  port3_valid_in;
                port2_valid_out <=  port1_valid_in;
                port3_valid_out <=  port2_valid_in;
            end

            {ORIG_PORT_3_ID, ORIG_PORT_2_ID, ORIG_PORT_1_ID} : begin
                port1_data_out  <=  port3_data_in;
                port2_data_out  <=  port2_data_in;
                port3_data_out  <=  port1_data_in;

                port1_valid_out <=  port3_valid_in;
                port2_valid_out <=  port2_valid_in;
                port3_valid_out <=  port1_valid_in;
            end

            default: begin
                port1_data_out  <= 0;
                port2_data_out  <= 0;
                port3_data_out  <= 0;
                port1_valid_out <= 0;
                port2_valid_out <= 0;
                port3_valid_out <= 0;
            end
        endcase
    end

endmodule