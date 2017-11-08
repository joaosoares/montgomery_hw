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

module compute_ddp(clk, rst, start, a, b, c, done);
input clk;
input rst;		// reset 
input start;	// start signal for an addition

input [3:0] a, b;	// input operands
output [4:0] c;	// output result
output done;		// done is 1 when an addition complets

reg [1:0] state, nextstate;

wire [4:0] c_wire;
reg [4:0] c;
reg c_en;

always @(posedge clk)
begin
	if(rst)
		state <= 2'd0;
	else 
		state <= nextstate;
end		

assign c_wire = a + b;

always @(posedge clk)
begin
	if(rst)
		c <= 5'd0;
	else if (c_en)
		c <= c_wire;
	else
		c <= c;
end

// example state machine for computation flow 
always @(*)
begin
	case(state)
	2'd0: begin		// Idle state; Here the FSM waits for the start signal
				c_en <= 1'b0;
			end		
	2'd1: begin		// write result in c
				c_en <= 1'b1;
			end
	2'd2: begin		// set 'done' high
				c_en <= 1'b0;
			end
	default: begin		
				c_en <= 1'b0;
			end			
	endcase
end

// nextstate logic
always @(*)
begin
	case(state)
	2'd0: begin
				if(start)
					nextstate <= 2'd1;
				else
					nextstate <= 2'd0;
			end
	
	2'd1: nextstate <= 2'd2;
	2'd2: nextstate <= 2'd0;
	default: nextstate <= 2'd0;	
	endcase
end

assign done = (state==2'd2) ? 1'b1 : 1'b0;
	
endmodule

