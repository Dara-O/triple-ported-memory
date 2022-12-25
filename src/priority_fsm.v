`timescale 1ns/1ps

`include "shared_params.vh"

module priority_fsm(
    input   wire            port1_valid,
    input   wire            port2_valid,
    input   wire            port3_valid,

    input   wire            clk,
    input   wire            reset_n,
    input   wire            halt, 

    output  reg     [2:0]   port_priority
);

reg [2:0]  port_priority_nxt;

always @ (posedge clk, negedge reset_n) begin
    if(~reset_n) begin
        port_priority <= PRIORITY_123;
    end
    else if(~halt) begin
        port_priority <= port_priority_nxt;
    end
end

// determine the next priority
always @ (*) begin
    case({port1_valid, port2_valid, port3_valid})
        3'b000, 3'b111: begin
            port_priority_nxt = port_priority;
        end
        
        3'b001 :  begin
            case(port_priority)
                PRIORITY_123, PRIORITY_132, PRIORITY_312  :  port_priority_nxt = PRIORITY_312;
                PRIORITY_213, PRIORITY_231, PRIORITY_321 :  port_priority_nxt = PRIORITY_321;
                default : port_priority_nxt = port_priority;
            endcase
        end
        
        3'b010 : begin
            case(port_priority)
                PRIORITY_123, PRIORITY_132, PRIORITY_213  : port_priority_nxt = PRIORITY_213;
                PRIORITY_231, PRIORITY_321, PRIORITY_312 : port_priority_nxt = PRIORITY_231;
                default : port_priority_nxt = port_priority;
            endcase
        end
        
        3'b100 : begin
            case(port_priority)
                PRIORITY_123, PRIORITY_213, PRIORITY_231  : port_priority_nxt = PRIORITY_123;
                PRIORITY_132, PRIORITY_312, PRIORITY_321 : port_priority_nxt = PRIORITY_132;
                default : port_priority_nxt = port_priority;
            endcase
        end
        
        3'b110 : begin
            case(port_priority)
                PRIORITY_123, PRIORITY_312, PRIORITY_132 : port_priority_nxt = PRIORITY_123;
                PRIORITY_213, PRIORITY_321, PRIORITY_231 : port_priority_nxt = PRIORITY_213; 
                default : port_priority_nxt = port_priority;
            endcase
        end
        
        3'b101 : begin
            case(port_priority)
                PRIORITY_123, PRIORITY_132, PRIORITY_213 : port_priority_nxt = PRIORITY_132;
                PRIORITY_231, PRIORITY_321, PRIORITY_312 : port_priority_nxt = PRIORITY_312; 
                default : port_priority_nxt = port_priority;
            endcase
        end
        
        3'b011 : begin
            case(port_priority)
                PRIORITY_231, PRIORITY_213, PRIORITY_123 : port_priority_nxt = PRIORITY_231;
                PRIORITY_321, PRIORITY_312, PRIORITY_132 : port_priority_nxt = PRIORITY_321; 
                default : port_priority_nxt = port_priority;
            endcase
        end
        
        default : port_priority_nxt = port_priority;
    endcase
end

endmodule