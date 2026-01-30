// module that checks for the iniatialization complete signal from the dma
module axi4_boot_check #(
    parameter DATA_WIDTH = 512,
    parameter ADDR_WIDTH = 64,
    parameter ID_WIDTH = 4
)(
    // Global signals
    input wire aclk,
    input wire aresetn,
    // AXI Master Interface
    input wire [ADDR_WIDTH-1:0] s_axi_awaddr,
    input wire [DATA_WIDTH-1:0] s_axi_wdata,
    input wire s_axi_wvalid,
    // start the core
    output wire start_o
);

    reg start;
    integer counter;
    assign start_o = start;
    
    always @(posedge aclk, negedge aresetn) begin
        if (!aresetn) begin
            start <= 1'b0;
            counter <= 0;
        end else if (aclk) begin
            if (counter < 100 && start) begin
                counter <= counter + 1;
            end
            if (counter == 100 && start) begin
                start <= 0;
                counter <= 0;
            end else if (s_axi_wdata[63 : 0] == 64'hffffffff_ffffffff & s_axi_awaddr == 64'h0 & s_axi_wvalid & start == 0) begin
                start <= 1'b1;
                counter <= 0;
            end
        end
    end

endmodule
