`timescale 1ns / 1ps

module hweval_adder(
    input   clk,
    input   resetn,
    output  data_ok
);

    reg          start;
    reg          subtract;
    reg          shift;
    reg  [513:0] in_a;
    reg  [513:0] in_b;
    wire [514:0] result;
    wire         done;
       
    // Instantiate the adder    
    adder dut (
        .clk      (clk     ),
        .resetn   (resetn  ),
        .start    (start   ),
        .subtract (subtract),
        .shift    (shift   ),
        .in_a     (in_a    ),
        .in_b     (in_b    ),
        .result   (result  ),
        .done     (done    ));

    // Assign values to the inputs to the adder
    always @(posedge(clk))
    begin
        if (resetn==0)
        begin
            in_a     <= 0;
            in_b     <= 0;
            start    <= 0;
            subtract <= 0;
            shift    <= 0;
        end
        else
        begin
            in_a     <= in_a     ^ {515{1'b1}};
            in_b     <= in_b     ^ {515{1'b1}};
            start    <= start    ^ 1;
            subtract <= subtract ^ 1;
            shift    <= shift    ^ 1;
        end
    end
    
    assign data_ok = done & (result=={515{1'b0}});
    
endmodule