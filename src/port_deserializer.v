`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/14/2022 10:15:11 PM
// Design Name: 
// Module Name: port_deserializer
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


module port_deserializer #(parameter WIDTH=8) (
    input   wire    [WIDTH-1:0]     sin_data,
    input   wire                    sin_valid,
    input   wire    [1:0]           entry_id,

    output  reg    [WIDTH-1:0]     port1_data,
    output  reg                    port1_valid,
    output  reg    [WIDTH-1:0]     port2_data,
    output  reg                    port2_valid,
    output  reg    [WIDTH-1:0]     port3_data,
    output  reg                    port3_valid
);

// playing around with defines
`define PORT_ID_1       1
`define PORT_ID_2       2    
`define PORT_ID_3       3
`define PORT_ID_INVALID 0

always @ (*) begin
    casez (entry_id)
        `PORT_ID_1 : begin
            port1_data  = sin_data;
            port1_valid = sin_valid;
            port2_data  = 0;
            port2_valid = 0;
            port3_data  = 0;
            port3_valid = 0;
        end

        `PORT_ID_2 : begin
            port1_data  = 0;
            port1_valid = 0;
            port2_data  = sin_data;
            port2_valid = sin_valid;
            port3_data  = 0;
            port3_valid = 0;
        end

        `PORT_ID_3 : begin
            port1_data  = 0;
            port1_valid = 0;
            port2_data  = 0;
            port2_valid = 0;
            port3_data  = sin_data;
            port3_valid = sin_valid;
        end

        default: begin
            port1_data  = 0;
            port1_valid = 0;
            port2_data  = 0;
            port2_valid = 0;
            port3_data  = 0;
            port3_valid = 0;
        end
    endcase
end

endmodule

`undef PORT_ID_1      
`undef PORT_ID_2      
`undef PORT_ID_3      
`undef PORT_ID_INVALID
