
module u55_xilinx_hbm_bd (
  input                sys_clk_p       ,  // 100 MHz Clock for PCIe
  input                sys_clk_n       ,  // 100 MHz Clock for PCIE
  input  logic         prst_n          , //reset
  input                HBM_ref_clk_p   ,
  input                HBM_ref_clk_n   ,
  output wire [7:0]    pci_exp_txp     ,
  output wire [7:0]    pci_exp_txn     ,
  input  wire [7:0]    pci_exp_rxp     ,
  input  wire [7:0]    pci_exp_rxn     ,
  input  logic         uart_rx         ,
  output logic         uart_tx
);

// ----------------------------------
// CLK and RESET_N
// ----------------------------------

// core clock
logic clk;
// reset out of the hbm_interface
logic master_areset;
// core reset_n
logic core_areset_n;
// uncore reset_n
logic uncore_areset_n;
assign uncore_areset_n = core_areset_n;

// ----------------------------------
// HBM
// ----------------------------------
logic HBM_REF_CLK, sys_clk, sys_clk_gt, sys_rst_n_c;

    hbm_interface i_hbm_interface (
        .HBM_REF_CLK_0_0    (HBM_REF_CLK),
        .S00_AXI_0_araddr   (),   
        .S00_AXI_0_arburst  (),
        .S00_AXI_0_arcache  (),
        .S00_AXI_0_arid     (),
        .S00_AXI_0_arlen    (),
        .S00_AXI_0_arlock   (),
        .S00_AXI_0_arprot   (),
        .S00_AXI_0_arqos    (),
        .S00_AXI_0_arready  (),
        .S00_AXI_0_arsize   (),
        .S00_AXI_0_arvalid  (),
        .S00_AXI_0_awaddr   (),   
        .S00_AXI_0_awburst  (),
        .S00_AXI_0_awcache  (),
        .S00_AXI_0_awid     (),
        .S00_AXI_0_awlen    (),
        .S00_AXI_0_awlock   (),
        .S00_AXI_0_awprot   (),
        .S00_AXI_0_awqos    (),
        .S00_AXI_0_awready  (),
        .S00_AXI_0_awsize   (),
        .S00_AXI_0_awvalid  (),
        .S00_AXI_0_bid      (),
        .S00_AXI_0_bready   (),
        .S00_AXI_0_bresp    (),
        .S00_AXI_0_bvalid   (),
        .S00_AXI_0_rdata    (),
        .S00_AXI_0_rid      (),
        .S00_AXI_0_rlast    (),
        .S00_AXI_0_rready   (),
        .S00_AXI_0_rresp    (),
        .S00_AXI_0_rvalid   (),
        .S00_AXI_0_wdata    (),
        .S00_AXI_0_wlast    (),
        .S00_AXI_0_wready   (),
        .S00_AXI_0_wstrb    (),
        .S00_AXI_0_wvalid   (),
        .axi_clk_ariane_0   (clk),
        .pcie_mgt_0_rxn     (pci_exp_rxn),
        .pcie_mgt_0_rxp     (pci_exp_rxp),
        .pcie_mgt_0_txn     (pci_exp_txn),
        .pcie_mgt_0_txp     (pci_exp_txp),
        .sys_clk_0          (sys_clk),
        .sys_clk_gt_0       (sys_clk_gt),
        .sys_rst_n_0        (sys_rst_n_c),
        .usr_irq_req_0      ('0),
        .master_areset_o_0(master_areset)
    );

// -------------------------
// Clocking system and RESET
// -------------------------
    logic REF_CLK, SOC_REF_CLK, pll_locked;
    IBUF    sys_reset_n_ibuf (
        .O(sys_rst_n_c), 
        .I(prst_n)
    );
    IBUFDS  hbm_ref_clk_ibuf (
        .I(HBM_ref_clk_p), 
        .IB(HBM_ref_clk_n),
        .O(REF_CLK)
    );
    BUFG    hbm_ref_clk_bufg (
        .I(REF_CLK), 
        .O(HBM_REF_CLK)
    );
    BUFG    soc_ref_clk_bufg (
        .I(REF_CLK), 
        .O(SOC_REF_CLK)
    );

    // we need to switch reset polarity for core reset
    logic clock_reset;
    assign clock_reset = ~sys_rst_n_c;

    xlnx_clk_gen_solo i_xlnx_clk_gen (
        .clk_out1 ( clk             ), // 100 MHz
        .clk_out2 (),
        .clk_out3 (),
        .reset    ( clock_reset     ),
        .locked   ( pll_locked      ),
        .clk_in1  ( SOC_REF_CLK      ) // 100 Mhz ref clk
    );

    IBUFDS_GTE4 #(
        .REFCLK_HROW_CK_SEL ( 2'b00 )
    ) IBUFDS_GTE4_inst (
        .O     ( sys_clk_gt ),
        .ODIV2 ( sys_clk    ),
        .CEB   ( 1'b0            ),
        .I     ( sys_clk_p       ),
        .IB    ( sys_clk_n       )
    );

    // core_areset_n is driven high when pll locks and the board releases his external reset
    // then the logic can be resetted from the hbm_xdma_interface
    // register the reset as a cdc mitigation
    logic master_areset_reg;
    always @(posedge clk) begin 
        master_areset_reg <= master_areset;
    end
    assign core_areset_n = !master_areset_reg;
// -----------------
// END
// -----------------

endmodule