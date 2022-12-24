`timescale 1ns / 1ps

module validity_mask(
    input   wire    [1:0]       BANK_ID,

    input   wire    [1:0]       port1_req_tag_in,
    input   wire    [1:0]       port2_req_tag_in,
    input   wire    [1:0]       port3_req_tag_in,

    input   wire    [11:0]      port1_addr,
    input   wire    [11:0]      port2_addr,
    input   wire    [11:0]      port3_addr,

    input   wire    [15:0]      port1_data_in,
    input   wire    [15:0]      port2_data_in,
    input   wire    [15:0]      port3_data_in,

    input   wire    [0:0]       port1_wen,
    input   wire    [0:0]       port2_wen,
    input   wire    [0:0]       port3_wen,

    input   wire    [0:0]       port1_valid,
    input   wire    [0:0]       port2_valid,
    input   wire    [0:0]       port3_valid,


    output  reg     [1:0]       masked_port1_req_tag_in,
    output  reg     [1:0]       masked_port2_req_tag_in,
    output  reg     [1:0]       masked_port3_req_tag_in,

    output  reg     [9:0]       masked_port1_addr,
    output  reg     [9:0]       masked_port2_addr,
    output  reg     [9:0]       masked_port3_addr,

    output  reg     [15:0]      masked_port1_data_in,
    output  reg     [15:0]      masked_port2_data_in,
    output  reg     [15:0]      masked_port3_data_in,

    output  reg     [0:0]       masked_port1_wen,
    output  reg     [0:0]       masked_port2_wen,
    output  reg     [0:0]       masked_port3_wen,

    output  reg     [0:0]       masked_port1_valid,
    output  reg     [0:0]       masked_port2_valid,
    output  reg     [0:0]       masked_port3_valid
);

assign masked_port1_req_tag_in = port1_req_tag_in;
assign masked_port2_req_tag_in = port2_req_tag_in;
assign masked_port3_req_tag_in = port3_req_tag_in;

wire port1_match = (port1_addr[1:0] === BANK_ID) & port1_valid;
wire port2_match = (port2_addr[1:0] === BANK_ID) & port2_valid;
wire port3_match = (port3_addr[1:0] === BANK_ID) & port3_valid;


always @ (*) begin
    
    case (port1_match)
        1'b1        :   begin
            masked_port1_addr       = port1_addr[11:2];   
            masked_port1_data_in    = port1_data_in;
            masked_port1_wen        = port1_wen;
            masked_port1_valid      = port1_valid;  
        end    

        default     :   begin
            masked_port1_addr       = 0;
            masked_port1_data_in    = 0;
            masked_port1_wen        = 0;
            masked_port1_valid      = 0;
        end 
        
    endcase

    case (port2_match)
        1'b1        :   begin
            masked_port2_addr       = port2_addr[11:2];   
            masked_port2_data_in    = port2_data_in;
            masked_port2_wen        = port2_wen;
            masked_port2_valid      = port2_valid;  
        end    

        default     :   begin
            masked_port2_addr       = 0;
            masked_port2_data_in    = 0;
            masked_port2_wen        = 0;
            masked_port2_valid      = 0;
        end 
        
    endcase

    case (port3_match)
        1'b1        :   begin
            masked_port3_addr       = port3_addr[11:2];   
            masked_port3_data_in    = port3_data_in;
            masked_port3_wen        = port3_wen;
            masked_port3_valid      = port3_valid;  
        end    

        default     :   begin
            masked_port3_addr       = 0;
            masked_port3_data_in    = 0;
            masked_port3_wen        = 0;
            masked_port3_valid      = 0;
        end 
        
    endcase

end
    
endmodule