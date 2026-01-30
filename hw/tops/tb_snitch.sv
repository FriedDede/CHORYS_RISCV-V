
timeunit 1ns;
timeprecision 1ns;

module snicth_tb;

    localparam int unsigned CLOCK_PERIOD = 10ns;
    localparam int unsigned CLOCK_PERIOD_XDMA = 4ns;
    // toggle with RTC period
    localparam int unsigned RTC_CLOCK_PERIOD = 30.517us;

    localparam NUM_WORDS = 2**25;
    logic clk_i;
    logic clk_xdma;
    logic rst_ni;
    logic rtc_i;
    logic uart_rx;
    logic uart_tx;

    longint unsigned cycles;
    longint unsigned max_cycles;

    logic [31:0] exit_o;

    string binary = "";
    
    cva6_u55_sim #() dut (
    //snitch_u55_sim dut (
        .sys_clk_p(clk_i), //100Mhz
        .sys_clk_n(~clk_i), //100Mhz
        .prst_n(rst_ni),
        .HBM_ref_clk_p(clk_i),
        .HBM_ref_clk_n(~clk_i),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx)
    );

    // Clock process
    initial begin
        clk_i = 1'b0;
        
        rst_ni = 1'b1;

        repeat(100) begin
            #(CLOCK_PERIOD/2) clk_i = ~clk_i;
        end  

        rst_ni = 1'b0;

        repeat(100) begin
            #(CLOCK_PERIOD/2) clk_i = ~clk_i;
        end

        rst_ni = 1'b1;
        forever begin
            #(CLOCK_PERIOD/2) clk_i = 1'b1;
            #(CLOCK_PERIOD/2) clk_i = 1'b0;
        end
    end
       
    initial begin
        forever begin
            #(CLOCK_PERIOD_XDMA/2) clk_xdma = 1'b1;
            #(CLOCK_PERIOD_XDMA/2) clk_xdma = 1'b0;
        end
    end
endmodule
