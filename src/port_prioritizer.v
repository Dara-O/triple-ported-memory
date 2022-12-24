`timescale 1ns/1ps

`include "shared_params.vh"

// reorders ports based on port_priority 
module port_prioritizer #(parameter WIDTH=8) (
    input   wire    [WIDTH-1:0]     port1_data,
    input   wire                    port1_valid,
    input   wire    [WIDTH-1:0]     port2_data,
    input   wire                    port2_valid,
    input   wire    [WIDTH-1:0]     port3_data,
    input   wire                    port3_valid,

    input   wire    [2:0]           port_priority,

    output  reg     [WIDTH-1:0]     priority1_data,
    output  reg                     priority1_valid,
    output  reg     [1:0]           priority1_orig_pid, // original port id
    output  reg     [WIDTH-1:0]     priority2_data,
    output  reg                     priority2_valid,
    output  reg     [1:0]           priority2_orig_pid, 
    output  reg     [WIDTH-1:0]     priority3_data,
    output  reg                     priority3_valid,
    output  reg     [1:0]           priority3_orig_pid
);


always @ (*) begin
    case (port_priority)
        PRIORITY_123 : begin
            priority1_data = port1_data;
            priority1_valid = port1_valid;
            priority1_orig_pid = ORIG_PORT_1_ID;

            priority2_data = port2_data;
            priority2_valid = port2_valid;
            priority2_orig_pid = ORIG_PORT_2_ID;

            priority3_data = port3_data;
            priority3_valid = port3_valid;
            priority3_orig_pid = ORIG_PORT_3_ID;
        end
        
        PRIORITY_132 : begin
            priority1_data = port1_data;
            priority1_valid = port1_valid;
            priority1_orig_pid = ORIG_PORT_1_ID;

            priority2_data = port3_data;
            priority2_valid = port3_valid;
            priority2_orig_pid = ORIG_PORT_3_ID;

            priority3_data = port2_data;
            priority3_valid = port2_valid;
            priority3_orig_pid = ORIG_PORT_2_ID;
        end
        
        PRIORITY_213 : begin
            priority1_data = port2_data;
            priority1_valid = port2_valid;
            priority1_orig_pid = ORIG_PORT_2_ID;

            priority2_data = port1_data;
            priority2_valid = port1_valid;
            priority2_orig_pid = ORIG_PORT_1_ID;

            priority3_data = port3_data;
            priority3_valid = port3_valid;
            priority3_orig_pid = ORIG_PORT_3_ID;
        end 

        PRIORITY_231 : begin
            priority1_data = port2_data;
            priority1_valid = port2_valid;
            priority1_orig_pid = ORIG_PORT_2_ID;

            priority2_data = port3_data;
            priority2_valid = port3_valid;
            priority2_orig_pid = ORIG_PORT_3_ID;

            priority3_data = port1_data;
            priority3_valid = port1_valid;
            priority3_orig_pid = ORIG_PORT_1_ID;

        end 

        PRIORITY_312 : begin
            priority1_data = port3_data;
            priority1_valid = port3_valid;
            priority1_orig_pid = ORIG_PORT_3_ID;

            priority2_data = port1_data;
            priority2_valid = port1_valid;
            priority2_orig_pid = ORIG_PORT_1_ID;

            priority3_data = port2_data;
            priority3_valid = port2_valid;
            priority3_orig_pid = ORIG_PORT_2_ID;
        end 

        PRIORITY_321 : begin
            priority1_data = port3_data;
            priority1_valid = port3_valid;
            priority1_orig_pid = ORIG_PORT_3_ID;

            priority2_data = port2_data;
            priority2_valid = port2_valid;
            priority2_orig_pid = ORIG_PORT_2_ID;

            priority3_data = port1_data;
            priority3_valid = port1_valid;
            priority3_orig_pid = ORIG_PORT_1_ID;
        end 

        default : begin
            priority1_data = port1_data;
            priority1_valid = port1_valid;
            priority1_orig_pid = ORIG_PORT_1_ID;

            priority2_data = port2_data;
            priority2_valid = port2_valid;
            priority2_orig_pid = ORIG_PORT_2_ID;

            priority3_data = port3_data;
            priority3_valid = port3_valid;
            priority3_orig_pid = ORIG_PORT_3_ID;
        end
        
    endcase
end


endmodule