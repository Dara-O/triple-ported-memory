`ifndef _SHARED_PARAMS_
`define _SHARED_PARAMS_
// PARAMETERS FOR THE DIFFERENT PORT PRIORITIES
parameter [2:0] PRIORITY_123 = 0;
parameter [2:0] PRIORITY_132 = 1;
parameter [2:0] PRIORITY_213 = 2;
parameter [2:0] PRIORITY_231 = 3;
parameter [2:0] PRIORITY_312 = 4;
parameter [2:0] PRIORITY_321 = 5;

// PARAMETERS FOR IDENTIFYING THE ORIGINAL PORT OF A REORDERED PRIORITY PORT
parameter [1:0] ORIG_PORT_1_ID = 1;
parameter [1:0] ORIG_PORT_2_ID = 2;
parameter [1:0] ORIG_PORT_3_ID = 3;
`endif