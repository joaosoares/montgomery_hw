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
	LOOP_START_WAIT = 2,
	LOOP_ADD_M = 3,
	LOOP_ADD_M_WAIT = 4,
	LOOP_SHIFT = 5,
	SUB_COND = 6,
	SUB_COND_WAIT = 7,
	DONE = 8;

	// Datapath control in signals
	wire c0,
	adder_b_done,
	adder_m_done,
	subtractor_done,
	cur_a;

	// Datapath control out signals
	reg start_c,
	cond_add_b,
	cond_add_m,
	shift_c,
	cond_sub_c,
	should_add_b,
	should_add_m,
	should_subtract;

	// Wires
	// Temporary registers
	reg [513:0] c_reg, b_reg, m_reg;
	reg [11:0] counter;
	wire [514:0] adder_b_res,
			    adder_m_res,
			    subtractor_res;

	adder adder_b(
		clk,
		resetn,
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
		resetn,
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
		resetn,
		cond_sub_s,
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
				should_add_m <= 1'b0;
			end
			LOOP_START:
			begin // Idle state; Here the FSM waits for the start signal
				start_c <= 1'b0;
				cond_add_b <= 1'b1;
				cond_add_m <= 1'b0;
				shift_c <= 1'b0;
				cond_sub_c <= 1'b0;
				should_add_m <= 1'b0;
			end
			LOOP_START_WAIT:
			begin // Idle state; Here the FSM waits for the start signal
				start_c <= 1'b0;
				cond_add_b <= 1'b0;
				cond_add_m <= 1'b0;
				shift_c <= 1'b0;
				cond_sub_c <= 1'b0;
				should_add_m <= 1'b0;
			end
			LOOP_ADD_M:
			begin // Idle state; Here the FSM waits for the start signal
				start_c <= 1'b0;
				cond_add_b <= 1'b0;
				cond_add_m <= 1'b1;
				shift_c <= 1'b0;
				cond_sub_c <= 1'b0;
                should_add_m <= 1'b0;
			end
			LOOP_ADD_M_WAIT:
			begin // Idle state; Here the FSM waits for the start signal
				start_c <= 1'b0;
				cond_add_b <= 1'b0;
				cond_add_m <= 1'b0;
				shift_c <= 1'b0;
				cond_sub_c <= 1'b0;
				should_add_m <= 1'b1;
			end
			LOOP_SHIFT:
			begin // Idle state; Here the FSM waits for the start signal
				start_c <= 1'b0;
				cond_add_b <= 1'b0;
				cond_add_m <= 1'b0;
				shift_c <= 1'b1;
				cond_sub_c <= 1'b0;
				should_add_m <= 1'b0;
			end
			SUB_COND:
			begin // Idle state; Here the FSM waits for the start signal
				start_c <= 1'b0;
				cond_add_b <= 1'b0;
				cond_add_m <= 1'b0;
				shift_c <= 1'b0;
				cond_sub_c <= 1'b1;
				should_add_m <= 1'b0;
			end
			SUB_COND_WAIT:
			begin // Idle state; Here the FSM waits for the start signal
				start_c <= 1'b0;
				cond_add_b <= 1'b0;
				cond_add_m <= 1'b0;
				shift_c <= 1'b0;
				cond_sub_c <= 1'b0;
				should_add_m <= 1'b0;
			end
			DONE:
			begin // Idle state; Here the FSM waits for the start signal
				start_c <= 1'b0;
				cond_add_b <= 1'b0;
				cond_add_m <= 1'b0;
				shift_c <= 1'b0;
				cond_sub_c <= 1'b0;
				should_add_m <= 1'b0;
			end
			default: begin
				start_c <= 1'b0;
				cond_add_b <= 1'b0;
				cond_add_m <= 1'b0;
				shift_c <= 1'b0;
				cond_sub_c <= 1'b0;
				should_add_m <= 1'b0;
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
				nextstate <= LOOP_START_WAIT;
			end
			LOOP_START_WAIT: begin
				if (!adder_b_done)
					nextstate <= LOOP_START_WAIT;
				else begin
					if (c0 == 0)
						nextstate <= LOOP_SHIFT;
					else
						nextstate <= LOOP_ADD_M;
				end
			end
			LOOP_ADD_M:
			nextstate <= LOOP_ADD_M_WAIT;
			LOOP_ADD_M_WAIT: begin
				if(!adder_m_done)
					nextstate <= LOOP_ADD_M_WAIT;
				else
					nextstate <= LOOP_SHIFT;
			end
			LOOP_SHIFT: begin
				if (counter < WIDTH-1)
					nextstate <= LOOP_START;
				else
					nextstate <= SUB_COND;
			end
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
          // Drive down should_add_b
          should_add_b <= 0;
        end
        else if (adder_b_done && should_add_b) begin
          c_reg <= adder_b_res;
        end
        else if (adder_m_done && should_add_m) begin
          c_reg <= adder_m_res;
        end
        else
            c_reg <= c_reg;

        if (cond_add_b) begin
          should_add_b <= cur_a;
        end

        if (cond_sub_c) begin
          should_subtract <= c_reg >= m_reg;
        end
	end
    
	assign done = (state==DONE) ? 1'b1 : 1'b0;
	assign cur_a = in_a[counter];
	assign c0 = c_reg[0];
	assign result = c_reg;
	
endmodule

