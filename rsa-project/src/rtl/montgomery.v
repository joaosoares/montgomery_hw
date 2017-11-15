`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:15:43 11/14/2016 
// Design Name: 
// Module Name:    add_ddp 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////


// This is an example "compute" module that computes an addition of two operands

module montgomery(clk, resetn, start, a, b, m, c, done);
input clk;
input resetn;		// reset 
input start;	// start signal for an addition

input [511:0] a, b, m;	// input operands
output [513:0] c;	// output result
output done;		// done is 1 when an addition complets

// Parameters
parameter WIDTH = 512;

// Declare state register
reg [2:0] state, nextstate;

// Declare states
parameter START = 0,
    LOOP_START = 1,
    LOOP_ADD_M = 2,
    LOOP_SHIFT = 3,
    SUB_COND = 4,
    DONE = 5;

// Datapath control in signals
wire c0;

// Datapath control out signals
reg start_c, 
    cond_add_b,
    cond_add_m,
    shift_c,
    cond_sub_c;

// Temporary registers
reg [513:0] c_reg;
reg [11:0] counter;

// Next state update
always @(posedge clk)
begin
	if(!resetn)
		state <= 2'd0;
	else 
		state <= nextstate;
end		


// example state machine for computation flow 
always @(*)
begin
	case(state)
	START:
        begin        // Idle state; Here the FSM waits for the start signal
            start_c <= 1'b1;
            cond_add_b <= 1'b0;
            cond_add_m <= 1'b0;
            shift_c <= 1'b0;
            cond_sub_c <= 1'b0;
        end
 	LOOP_START:
        begin        // Idle state; Here the FSM waits for the start signal
            start_c <= 1'b0;
            cond_add_b <= 1'b1;
            cond_add_m <= 1'b0;
            shift_c <= 1'b0;
            cond_sub_c <= 1'b0;
        end		
 	LOOP_ADD_M:
        begin        // Idle state; Here the FSM waits for the start signal
            start_c <= 1'b0;
            cond_add_b <= 1'b0;
            cond_add_m <= 1'b1;
            shift_c <= 1'b0;
            cond_sub_c <= 1'b0;
        end
     LOOP_SHIFT:
        begin        // Idle state; Here the FSM waits for the start signal
            start_c <= 1'b0;
            cond_add_b <= 1'b0;
            cond_add_m <= 1'b0;
            shift_c <= 1'b1;
            cond_sub_c <= 1'b0;
        end        
 	SUB_COND:
        begin        // Idle state; Here the FSM waits for the start signal
            start_c <= 1'b0;
            cond_add_b <= 1'b0;
            cond_add_m <= 1'b0;
            shift_c <= 1'b0;
            cond_sub_c <= 1'b1;
        end
     DONE:
        begin        // Idle state; Here the FSM waits for the start signal
            start_c <= 1'b0;
            cond_add_b <= 1'b0;
            cond_add_m <= 1'b0;
            shift_c <= 1'b0;
            cond_sub_c <= 1'b0;
            end        
	default: begin		
            start_c <= 1'b0;
            cond_add_b <= 1'b0;
            cond_add_m <= 1'b0;
            shift_c <= 1'b0;
            cond_sub_c <= 1'b0;
        end			
	endcase
end

// nextstate logic
always @(*)
begin
	case(state)
	START: begin
       if (start)
           nextstate <= LOOP_START;
       else
           nextstate <= START;
    end
    LOOP_START: begin
        if (c0 == 0)
            nextstate <= LOOP_SHIFT;
        else
            nextstate <= LOOP_ADD_M;
        end
    LOOP_ADD_M:
        nextstate <= LOOP_SHIFT;
    LOOP_SHIFT: begin
        if (counter < WIDTH-1)
            nextstate <= LOOP_START;
        else
            nextstate <= SUB_COND;
        end
    SUB_COND:
        nextstate <= DONE;
    DONE:
        nextstate <= DONE;
	default: nextstate <= START;	
	endcase
end


// Datapath
always @(posedge clk)
begin
	if(start_c) begin
		c_reg <= {WIDTH{1'd0}};
		counter <= 12'd0;
    end
	else if (cond_add_b) begin
	   if (a[counter]) begin
	   
	   end
	   else begin
	       
	   end
	end
		
	else
		c <= c;
end

assign done = (state==DONE) ? 1'b1 : 1'b0;
assign c0 = c[0];
	
endmodule

