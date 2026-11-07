@@ -0,0 +1,55 @@
module tb;
    logic clk=0, rst=1, load=0, fault_en=0;
    logic [1:0] fault_reg;
    logic [2:0] fault_bit;
    logic [7:0] data_in=8'b10110110, data_out;
    logic error;

    seu_system dut(.*);

    always #5 clk=~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0,tb);

        repeat(2) @(posedge clk);
        @(negedge clk) rst=0; load=1;
        @(negedge clk) load=0;

        // Test R1, bit 2
        fault_reg=0; fault_bit=2;
        fault_en=1;
        @(negedge clk);
        #1;
        $display("R1 FAULT: error=%b",error);
        fault_en=0;
        @(negedge clk);
        #1;
        $display("R1 RECOVERY: error=%b output=%b",error,data_out);

        // Test R2, bit 5
        fault_reg=1; fault_bit=5;
        fault_en=1;
        @(negedge clk);
        #1;
        $display("R2 FAULT: error=%b",error);
        fault_en=0;
        @(negedge clk);
        #1;
        $display("R2 RECOVERY: error=%b output=%b",error,data_out);

        // Test R3, bit 0
        fault_reg=2; fault_bit=0;
        fault_en=1;
        @(negedge clk);
        #1;
        $display("R3 FAULT: error=%b",error);
        fault_en=0;
        @(negedge clk);
        #1;
        $display("R3 RECOVERY: error=%b output=%b",error,data_out);

        $finish;
    end
endmodule
