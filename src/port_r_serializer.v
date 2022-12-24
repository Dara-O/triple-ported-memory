`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/10/2022 12:54:58 AM
// Design Name: 
// Module Name: port_r_serializer
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


module port_r_serializer #(parameter WIDTH=8)(
    input   wire    [WIDTH-1:0]     entry1_data,
    input   wire                    entry1_valid,
    input   wire    [WIDTH-1:0]     entry2_data,
    input   wire                    entry2_valid,
    input   wire                    clk,
    input   wire                    reset_n,                 
    
    output  reg     [WIDTH-1:0]     sout_data,
    output  reg                     sout_valid,
    output  reg                     freeze_inputs // NOTE: None of the inputs should be combinatorially dependent on freeze_inputs.    
);

// using macros as parameters
`define _STATE_FREE     0
`define _STATE_OCCUPIED 1 

reg     [WIDTH-1:0] queue1_data;
reg                 queue1_valid;

reg [0:0] state;
reg [0:0] state_nxt;

always @ (posedge clk, negedge reset_n) begin
    if(~reset_n) begin
        queue1_data     <= 0;
        queue1_valid    <= 0;
    end
    else if (state === `_STATE_FREE & state_nxt === `_STATE_OCCUPIED) begin // load
        queue1_data     <= entry2_data;
        queue1_valid    <= entry2_valid;
    end
    else if (state === `_STATE_OCCUPIED) begin // shift
        queue1_data     <= 0;
        queue1_valid    <= 0;
    end
    else begin
        queue1_data     <= 0;
        queue1_valid    <= 0;
    end
end

////////// OUTPUT MUX   /////////
always @ (*) begin
    case(state) 
        `_STATE_FREE : begin
            sout_data = entry1_data;
            sout_valid = entry1_valid;
            
            freeze_inputs = 0; //(state_nxt === `_STATE_OCCUPIED) ? 1 : 0;
        end
        `_STATE_OCCUPIED : begin                     
            sout_data = queue1_data;
            sout_valid = queue1_valid;
            
            freeze_inputs = 1; //(state_nxt === `_STATE_OCCUPIED) ? 1 : 0;                     
        end
        
        default : begin
            sout_data = entry1_data;
            sout_valid = entry1_valid;
            
            freeze_inputs = 0;//(state_nxt === `_STATE_OCCUPIED) ? 1 : 0;
        end 
    endcase
end

//////////      FSM     /////////
always @ (posedge clk, negedge reset_n) begin
    if(~reset_n) begin
        state <= 0;
    end
    else begin
        state <= state_nxt;
    end
end


always @ (*) begin
    case(state) 
        `_STATE_FREE : begin
            state_nxt = entry2_valid ? `_STATE_OCCUPIED : `_STATE_FREE;             
        end
        `_STATE_OCCUPIED : begin
            state_nxt = `_STATE_FREE;          
        end
        
        default : state_nxt = `_STATE_FREE;
    endcase
end


`undef _STATE_FREE
`undef _STATE_OCCUPIED 


endmodule
