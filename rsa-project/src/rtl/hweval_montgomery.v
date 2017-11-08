`timescale 1ns / 1ps

module hweval_montgomery(
    output  wire data_ok,
    input   wire clk,
    input   wire resetn
    );
    
    reg          resetneg;
    reg          start;
    reg  [511:0] in_a;
    reg  [511:0] in_b;
    reg  [511:0] in_m;
    wire [511:0] result;
    wire         done;
    
    //Instantiating montgomery module
    montgomery montgomery_instance( .clk    (clk      ),
                                    .resetn (resetneg ),
                                    .start  (start    ),
                                    .in_a   (in_a     ),
                                    .in_b   (in_b     ),
                                    .in_m   (in_m     ),
                                    .result (result   ),
                                    .done   (done     ));
            
    always @(posedge(clk))
    begin
        if (resetn==0)
        begin
            in_a     = 512'h0000FF0000;
            in_b     = 512'h0FF0000000;
            in_m     = 512'h0000000FF0;
            resetneg = 0;
            start    = 0;
        end
        else
        begin
            resetneg = 1;
            start    = start ^ 1;
            in_a     = in_a ^ {512{1'b1}};
            in_b     = in_b ^ {512{1'b1}};
            in_m     = in_m ^ {512{1'b1}};
        end
    end
            
    assign data_ok = (done) & (result==512'h0);

endmodule
