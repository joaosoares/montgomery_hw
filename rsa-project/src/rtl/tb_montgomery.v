`timescale 1ns / 1ps
`define RESET_TIME 25
`define CLK_PERIOD 10
`define CLK_HALF 5

module tb_montgomery();
    
    reg          clk;
    reg          resetn;
    reg          start;
    reg  [511:0] in_a;
    reg  [511:0] in_b;
    reg  [511:0] in_m;
    wire [511:0] result;
    wire         done;

    reg  [511:0] expected;
    
    //Instantiating montgomery module
    montgomery montgomery_instance( .clk    (clk    ),
                                    .resetn (resetn ),
                                    .start  (start  ),
                                    .in_a   (in_a   ),
                                    .in_b   (in_b   ),
                                    .in_m   (in_m   ),
                                    .result (result ),
                                    .done   (done   ));

    //Generate a clock
    initial begin
        clk = 0;
        forever #`CLK_HALF clk = ~clk;
    end
    
    //Reset
    initial begin
        resetn = 0;
        #`RESET_TIME resetn = 1;
    end
    
    //Test data
    initial begin

        #`RESET_TIME
        
        // You can generate your own with test vector generator python script
        in_a     <= 512'hb4d6d951f6532ac13ec6a44addbb552b3eca8fef9a81a1fd095485063c7ee4f89dcf19acf884fa9d0b6ce9c148e6b85af88024189c1da60e534acc6c7969363b;
        in_b     <= 512'h86eb6f8babc25f0986ba7460e46ffd91f34532c114485075f85ff900d4cf71d918be9ef170e1b84bca67755131efcbb767a2e069ad68c321a1cb985909098399;
        in_m     <= 512'h7e93fee7fd5d369339166e57cf5f773c1698c44b91a9f9a4be462bee6a82552d982845cd2787e90bc0245b4e781b9e1be10c615e2c814b3d85b78e358fa2c393;
        expected <= 512'h3a7f6990206bd360ebdac2ed9f9555fcd07240832bc5b927610f279b803a35b623cd2b09c6d6650ad5614271ffea2c70310a1e401543f306d0c99a3dc6b89078;
        
        start<=1;
        #`CLK_PERIOD;
        start<=0;
        
        wait (done==1);
        
        $display("result calculated=%x", result);
        $display("result expected  =%x", expected);
        $display("error            =%x", expected-result);
        
        #`CLK_PERIOD;
        
        $finish;
    end
           
endmodule
