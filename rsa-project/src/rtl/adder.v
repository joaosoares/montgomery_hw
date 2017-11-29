`timescale 1ns / 1ps

module adder(
    input  wire         clk,
    input  wire         resetn,
    input  wire         start,
    input  wire         subtract,
    input  wire         shift,
    input  wire [513:0] in_a,
    input  wire [513:0] in_b,
    output wire [514:0] result,
    output wire         done    
    );
    
    reg [513:0] a, b;
    wire [513:0] inv_b;
//    reg b_neg_4;
//    reg [127:0] b_neg_3, b_neg_2, b_neg_1, b_neg_0;
    reg [514:0] reg_result;
    wire [514:0] bitmask_sub;
    reg c;
    wire [104:0] add_out;
    wire [104:0] sub_out;
    reg [3:0] counter;
    reg done_sig;
    reg in_execution;
    
    // What impact does a 513-bit add operation have on the critical path of the design? 
    
    assign add_out = a[103:0] + b[103:0] + c;
    assign inv_b = ~b;
    assign sub_out = a[103:0] + inv_b[103:0] + c;
       
    always @(posedge clk, negedge resetn) begin
        if (resetn==1'b0)
        begin
            reg_result <= 0;
            c <= 0;
            a <= 0;
            b <= 0;
            counter <= 0;
            done_sig <= 0;
            in_execution <= 0;
        end
        else
        begin
            if (start == 1'b1)
            begin
                a <= in_a;
                b <= in_b;
                reg_result <= 0;
                counter <= 0;
                done_sig <= 0;
                c <= subtract;
                in_execution <= 1;
            end
            else if (in_execution == 1'b1)
            begin
                if (counter != 4) begin
                    if (subtract == 1'b0) begin
                        reg_result <= {add_out[103:0], reg_result[513:104]};
                        c <= add_out[104];
                    end
                    else begin
                        reg_result <= {sub_out[103:0], reg_result[513:104]};
                        c <= sub_out[104];
                    end
                end
                else begin
                    if (subtract == 1'b0) begin
                        reg_result <= {add_out[98:0], reg_result[513:98]};
                        c <= add_out[99];
                    end
                    else begin
                        reg_result <= {sub_out[98:0], reg_result[513:98]};
                        c <= sub_out[99];
                    end
                end
               
                a <= a>>104;
                b <= b>>104;
                if (counter == 4)
                    done_sig <= 1;
                else
                    counter <= counter + 1;
            end
        end
    end
    assign result = reg_result;
    assign done = done_sig;

endmodule
