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

module montgomery(clk, resetn, start, in_a, in_b, in_m, result, done);
	input clk;
	input resetn; // reset 
	input start; // start signal for an addition

	input [511:0] in_a, in_b, in_m; // input operands
	output [513:0] result; // output result
	output done; // done is 1 when an addition complets

	// Parameters
	parameter WIDTH = 512;

	// Declare state register
	reg [3:0] state, nextstate;

	// Declare states
	parameter START = 0,
	LOOP_START = 1,
	LOOP_ADD_B = 2,
	LOOP_ADD_B_WAIT = 3,
	LOOP_ADD_B_RESULT = 4,
	LOOP_ADD_M = 5,
	LOOP_ADD_M_WAIT = 6,
	LOOP_ADD_M_RESULT = 7,
	LOOP_SHIFT = 8,
	CHECK_SUB_COND = 9,
	SUB_COND = 10,
	SUB_COND_WAIT = 11,
	DONE = 12;

	// Datapath control in signals
	wire c0,
	adder_b_done,
	adder_m_done,
	subtractor_done,
	resetn_badd,
	resetn_madd,
	resetn_sub,
	cur_a;

	// Datapath control out signals
	reg start_c,
	cond_add_b,
	cond_add_m,
	shift_c,
	cond_sub_c,
    should_resetn_badd,
    should_resetn_madd,
    should_resetn_sub;

	// Wires
	// Temporary registers
	reg [513:0] c_reg, b_reg, m_reg;
	reg [11:0] counter;
	wire [514:0] adder_b_res,
	adder_m_res,
	subtractor_res;

	adder adder_b(
		clk,
		resetn_badd,
		cond_add_b,
		1'b0,
		1'b0,
		c_reg,
		b_reg,
		adder_b_res,
		adder_b_done
	);

	adder adder_m(
		clk,
		resetn_madd,
		cond_add_m,
		1'b0,
		1'b0,
		c_reg,
		m_reg,
		adder_m_res,
		adder_m_done
	);

	adder subtractor(
		clk,
		resetn_sub,
		cond_sub_c,
		1'b1,
		1'b0,
		c_reg,
		m_reg,
		subtractor_res,
		subtractor_done
	);
	// Next state update
	always @(posedge clk)
	begin
		if(!resetn)
			state <= START;
		else
			state <= nextstate;
	end

	// example state machine for computation flow 
	always @(*)
	begin
		case(state)
			START:
			begin // Idle state; Here the FSM waits for the start signal
				start_c <= 1'b1;
				cond_add_b <= 1'b0;
				cond_add_m <= 1'b0;
				shift_c <= 1'b0;
				cond_sub_c <= 1'b0;
                should_resetn_badd <= 1'b0;
                should_resetn_madd <= 1'b0;
                should_resetn_sub <= 1'b0;
			end
			LOOP_ADD_B:
			begin // Idle state; Here the FSM waits for the start signal
				start_c <= 1'b0;
				cond_add_b <= 1'b1;
				cond_add_m <= 1'b0;
				shift_c <= 1'b0;
				cond_sub_c <= 1'b0;
                should_resetn_badd <= 1'b0;
                should_resetn_madd <= 1'b0;
                should_resetn_sub <= 1'b0;
			end
            LOOP_ADD_B_RESULT:
            begin // Idle state; Here the FSM waits for the start signal
                start_c <= 1'b0;
                cond_add_b <= 1'b1;
                cond_add_m <= 1'b0;
                shift_c <= 1'b0;
                cond_sub_c <= 1'b0;
                should_resetn_badd <= 1'b1;
                should_resetn_madd <= 1'b0;
                should_resetn_sub <= 1'b0;
            end
			LOOP_ADD_M:
			begin // Idle state; Here the FSM waits for the start signal
				start_c <= 1'b0;
				cond_add_b <= 1'b0;
				cond_add_m <= 1'b1;
				shift_c <= 1'b0;
				cond_sub_c <= 1'b0;
                should_resetn_badd <= 1'b0;
                should_resetn_madd <= 1'b0;
                should_resetn_sub <= 1'b0;
			end
			LOOP_ADD_M_RESULT:
			begin // Idle state; Here the FSM waits for the start signal
				start_c <= 1'b0;
				cond_add_b <= 1'b0;
				cond_add_m <= 1'b1;
				shift_c <= 1'b0;
				cond_sub_c <= 1'b0;
                should_resetn_badd <= 1'b0;
                should_resetn_madd <= 1'b1;
                should_resetn_sub <= 1'b0;
			end
			LOOP_SHIFT:
			begin // Idle state; Here the FSM waits for the start signal
				start_c <= 1'b0;
				cond_add_b <= 1'b0;
				cond_add_m <= 1'b0;
				shift_c <= 1'b1;
				cond_sub_c <= 1'b0;
                should_resetn_badd <= 1'b0;
                should_resetn_madd <= 1'b0;
                should_resetn_sub <= 1'b0;
			end
			SUB_COND:
			begin // Idle state; Here the FSM waits for the start signal
				start_c <= 1'b0;
				cond_add_b <= 1'b0;
				cond_add_m <= 1'b0;
				shift_c <= 1'b0;
				cond_sub_c <= 1'b1;
                should_resetn_badd <= 1'b0;
                should_resetn_madd <= 1'b0;
                should_resetn_sub <= 1'b0;
			end
			DONE:
			begin // Idle state; Here the FSM waits for the start signal
				start_c <= 1'b0;
				cond_add_b <= 1'b0;
				cond_add_m <= 1'b0;
				shift_c <= 1'b0;
				cond_sub_c <= 1'b0;
                should_resetn_badd <= 1'b0;
                should_resetn_madd <= 1'b0;
                should_resetn_sub <= 1'b1;
			end
			default: begin
				start_c <= 1'b0;
				cond_add_b <= 1'b0;
				cond_add_m <= 1'b0;
				shift_c <= 1'b0;
				cond_sub_c <= 1'b0;
                should_resetn_badd <= 1'b0;
                should_resetn_madd <= 1'b0;
                should_resetn_sub <= 1'b0;
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
			    if(cur_a == 1'b1) 
				    nextstate <= LOOP_ADD_B;
				else
				    nextstate <= LOOP_ADD_B_RESULT;
			end
			LOOP_ADD_B:
			     nextstate <= LOOP_ADD_B_WAIT;
			LOOP_ADD_B_WAIT: begin
				if (!adder_b_done)
					nextstate <= LOOP_ADD_B_WAIT;
				else begin
					nextstate <= LOOP_ADD_B_RESULT;
				end
			end
			LOOP_ADD_B_RESULT: begin
			     if (c0 == 0)
			         nextstate <= LOOP_ADD_M_RESULT;
			     else
			         nextstate <= LOOP_ADD_M;
			end
			LOOP_ADD_M:
				nextstate <= LOOP_ADD_M_WAIT;
			LOOP_ADD_M_WAIT: begin
				if(!adder_m_done)
					nextstate <= LOOP_ADD_M_WAIT;
				else
					nextstate <= LOOP_ADD_M_RESULT;
			end
			LOOP_ADD_M_RESULT:
				nextstate <= LOOP_SHIFT;
			LOOP_SHIFT: begin
				if (counter < WIDTH-1)
					nextstate <= LOOP_START;
				else
					nextstate <= CHECK_SUB_COND;
			end
			CHECK_SUB_COND:
				if (c_reg >= m_reg)
					nextstate <= SUB_COND;
				else
					nextstate <= DONE;
			SUB_COND:
			nextstate <= SUB_COND_WAIT;
			SUB_COND_WAIT: begin
				if (!subtractor_done)
					nextstate <= SUB_COND_WAIT;
				else
					nextstate <= DONE;
			end
			DONE:
			nextstate <= DONE;
			default: nextstate <= START;
		endcase
	end

	// Datapath
	always @(posedge clk)
	begin
		// C reg modifications
		if(start_c) begin
			c_reg <= {WIDTH{1'd0}};
			b_reg <= {2'b0, in_b};
			m_reg <= {2'b0, in_m};
			counter <= 12'd0;
		end
		else if (shift_c) begin
			// Shift C to divide by 2
			c_reg <= c_reg >> 1;
			// Increment counter
			counter <= counter + 1;
		end
		else if (adder_b_done) begin
			c_reg <= adder_b_res;
		end
		else if (adder_m_done) begin
			c_reg <= adder_m_res;
		end
		else if (subtractor_done) begin
			c_reg <= subtractor_res;
		end
		else
			c_reg <= c_reg;

	end

	assign done = (state==DONE) ? 1'b1 : 1'b0;
	assign cur_a = in_a[counter];
	assign c0 = c_reg[0];
	assign result = c_reg;
	
	// Reset for adders
	assign resetn_badd = resetn && ~should_resetn_badd;
	assign resetn_madd = resetn && ~should_resetn_madd;
	assign resetn_sub  = resetn && ~should_resetn_sub;
endmodule

