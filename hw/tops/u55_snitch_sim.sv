// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// Description: Xilinx FPGA top-level
// Author: Florian Zaruba <zarubaf@iis.ee.ethz.ch>
`include "axi_typedef.svh"
`include "hbm_axi.svh"

module snitch_u55_sim (
    input                 sys_clk_p       , // 100 MHz Clock for PCIe
    input                 sys_clk_n       , // 100 MHz Clock for PCIE
    input  logic          prst_n          , //reset
    input                 HBM_ref_clk_p   ,
    input                 HBM_ref_clk_n   ,
    output wire [7:0]     pci_exp_txp     ,
    output wire [7:0]     pci_exp_txn     ,
    input  wire [7:0]     pci_exp_rxp     ,
    input  wire [7:0]     pci_exp_rxn     ,
    input  logic          uart_rx         ,
    output logic          uart_tx
);

localparam BOOT_ADDR        = 32'h0000_0000;
localparam CORE_NUMBER      = 1;
localparam CLUSTER_NUMBER   = 1;
localparam PERIF_NUMBER     = 3; // uart, timer, plic
localparam DRAM_CH_NUMBER   = CORE_NUMBER; // snitch clusters
localparam AxiAddrWidth     = snitch_cluster_pkg::AddrWidth;            // 32
localparam AxiDataWidth     = snitch_cluster_pkg::NarrowDataWidth;      // 64
localparam AxiIdWidthCore = snitch_cluster_pkg::NarrowIdWidthIn;      // 4 
localparam AxiIdWidthToUncore = AxiIdWidthCore + $clog2(3 * CORE_NUMBER);  // 4 + 2 (each core exposes 3 channels)
localparam AxiIdWidthToPerifs = AxiIdWidthToUncore + $clog2(CLUSTER_NUMBER); 
localparam AxiUserWidth     = snitch_cluster_pkg::NarrowUserWidth;

// xbar config
localparam axi_pkg::xbar_cfg_t xbar_cfg = '{
    NoSlvPorts:         3,
    NoMstPorts:         4,
    MaxMstTrans:        16,
    MaxSlvTrans:        16,
    FallThrough:        1'b0,
    LatencyMode:        axi_pkg::CUT_ALL_AX,
    PipelineStages:     1,
    AxiIdWidthSlvPorts: AxiIdWidthCore,
    AxiIdUsedSlvPorts:  2,
    UniqueIds:          '0,
    AxiAddrWidth:       AxiAddrWidth,
    AxiDataWidth:       AxiDataWidth,
    NoAddrRules:        4
};
// peripherals xbar setting
localparam axi_pkg::xbar_cfg_t perif_xbar_cfg = '{
    NoSlvPorts:         CLUSTER_NUMBER,
    NoMstPorts:         PERIF_NUMBER,
    MaxMstTrans:        16,
    MaxSlvTrans:        16,
    FallThrough:        1'b0,
    LatencyMode:        axi_pkg::CUT_ALL_AX,
    PipelineStages:     1,
    AxiIdWidthSlvPorts: AxiIdWidthToUncore,
    AxiIdUsedSlvPorts:  AxiIdWidthToUncore,
    UniqueIds:          '0,
    AxiAddrWidth:       AxiAddrWidth,
    AxiDataWidth:       AxiDataWidth,
    NoAddrRules:        PERIF_NUMBER
};

// generate the address map
typedef axi_pkg::xbar_rule_32_t  rule_t;
function rule_t [3:0] addr_map_gen ();
    // rom address 0x0 -> 0xffff
    addr_map_gen[0] = rule_t'{
    idx:        unsigned'(0),
    start_addr: 32'h0000_0000,
    end_addr:   32'h0001_0000,
    default:    '0
    };
    // dram address 0x8000000 -> 0x8000000 + clog2(size)
    addr_map_gen[1] = rule_t'{
    idx:        unsigned'(1),
    start_addr: 32'h8000_0000,
    end_addr:   32'h8000_0000 + 32'h2000_0000, // 512MB per core here
    default:    '0
    };
    // Perif (PLIC UART TIMER ... )
    addr_map_gen[2] = rule_t'{
    idx:        unsigned'(2),
    start_addr: 32'h1000_0000,
    end_addr:   32'h8000_0000,
    default:    '0
    };
    // CLINT (Pulp Specs RISC-V privilege spec 1.11 compatible CLINT )
    addr_map_gen[3] = rule_t'{
    idx:        unsigned'(3),
    start_addr: 32'h0200_0000,
    end_addr:   32'h0200_C000,
    default:    '0
    };
endfunction

function rule_t [PERIF_NUMBER - 1 : 0] addr_map_perif_gen ();
    // PLIC
    addr_map_perif_gen[0] = rule_t'{
    idx:        unsigned'(0),
    start_addr: 32'h1000_0000,
    end_addr:   32'h1400_0000,
    default:    '0
    };
    // Uart
    addr_map_perif_gen[1] = rule_t'{
    idx:        unsigned'(1),
    start_addr: 32'h1400_0000,
    end_addr:   32'h1400_1000,
    default:    '0
    };
    // Timer
    addr_map_perif_gen[2] = rule_t'{
    idx:        unsigned'(2),
    start_addr: 32'h1400_1000,
    end_addr:   32'h1400_2000,
    default:    '0
    };

endfunction

localparam rule_t [3:0] AddrMapUncore = addr_map_gen();
localparam rule_t [PERIF_NUMBER - 1 : 0] AddrMapPerif = addr_map_perif_gen();
AXI_BUS #(
    .AXI_ADDR_WIDTH ( AxiAddrWidth     ),
    .AXI_DATA_WIDTH ( AxiDataWidth     ),
    .AXI_ID_WIDTH   ( AxiIdWidthToUncore ),
    .AXI_USER_WIDTH ( AxiUserWidth     )
) axi_dram[DRAM_CH_NUMBER-1:0]();
AXI_BUS #(
    .AXI_ADDR_WIDTH ( AxiAddrWidth     ),
    .AXI_DATA_WIDTH ( AxiDataWidth     ),
    .AXI_ID_WIDTH   ( AxiIdWidthToUncore ),
    .AXI_USER_WIDTH ( AxiUserWidth     )
) axi_uncore2pxbar[CLUSTER_NUMBER-1:0]();
AXI_BUS #(
    .AXI_ADDR_WIDTH ( AxiAddrWidth     ),
    .AXI_DATA_WIDTH ( AxiDataWidth     ),
    .AXI_ID_WIDTH   ( AxiIdWidthToPerifs ),
    .AXI_USER_WIDTH ( AxiUserWidth     )
) axi_peripherals[PERIF_NUMBER - 1:0]();

// interrupt handling bus
snitch_pkg::interrupts_t [CORE_NUMBER - 1 : 0] core_irq_i;

logic clk;
logic rtc;
logic core_areset_n;
logic uncore_areset_n;
assign uncore_areset_n = core_areset_n;
// ---------------
// Core
// ---------------
    
    for ( genvar i=0; i<CORE_NUMBER; ++i) begin

        snitch_cluster_pkg::narrow_out_req_t    axi_icache_snitch_req;
        snitch_cluster_pkg::narrow_out_resp_t   axi_icache_snitch_resp;
        snitch_cluster_pkg::narrow_out_req_t    [1:0]axi_data_snitch_req;
        snitch_cluster_pkg::narrow_out_resp_t   [1:0]axi_data_snitch_resp;

        snitch_core_axi #(
            .AddrWidth          (AxiAddrWidth),
            .DataWidth          (AxiDataWidth),
            .IdWidthIn          (AxiIdWidthCore),
            .BootAddr           (BOOT_ADDR),
            .SnitchPMACfg       (snitch_cluster_pkg::SnitchPMACfg)
        ) i_snitch(
            .clk_i              (clk),
            .rst_ni             (core_areset_n),
            .hart_id_i          (i),
            .irq_i              (core_irq_i[i]),
            // icache
            .inst_out_req_o         (axi_icache_snitch_req     ),
            .inst_out_resp_i        (axi_icache_snitch_resp    ),
            // integer core
            .data_core_out_req_o    (axi_data_snitch_req    [0]),
            .data_core_out_resp_i   (axi_data_snitch_resp   [0]),
            // fpu
            .data_fpu_out_req_o     (axi_data_snitch_req    [1]),
            .data_fpu_out_resp_i    (axi_data_snitch_resp   [1])
        );

        AXI_BUS #(
            .AXI_ADDR_WIDTH ( AxiAddrWidth     ),
            .AXI_DATA_WIDTH ( AxiDataWidth     ),
            .AXI_ID_WIDTH   ( AxiIdWidthCore ),
            .AXI_USER_WIDTH ( AxiUserWidth     )
        ) axi_snitch2mux[2:0]();
        AXI_BUS #(
           .AXI_ADDR_WIDTH ( AxiAddrWidth     ),
           .AXI_DATA_WIDTH ( AxiDataWidth     ),
           .AXI_ID_WIDTH   ( AxiIdWidthToUncore),
           .AXI_USER_WIDTH ( AxiUserWidth     )
         ) axi_xbar2uncore[3:0]();
        AXI_BUS #(
            .AXI_ADDR_WIDTH ( AxiAddrWidth     ),
            .AXI_DATA_WIDTH ( AxiDataWidth     ),
            .AXI_ID_WIDTH   ( AxiIdWidthToUncore ),
            .AXI_USER_WIDTH ( AxiUserWidth     )
        ) axi_rom();
        AXI_BUS #(
            .AXI_ADDR_WIDTH ( AxiAddrWidth     ),
            .AXI_DATA_WIDTH ( AxiDataWidth     ),
            .AXI_ID_WIDTH   ( AxiIdWidthToUncore ),
            .AXI_USER_WIDTH ( AxiUserWidth     )
        ) axi_clint();
        
        // integer core lsu
        `AXI_ASSIGN_FROM_REQ (axi_snitch2mux[0], axi_data_snitch_req[0])
        `AXI_ASSIGN_TO_RESP  (axi_data_snitch_resp[0], axi_snitch2mux[0])
        // fpu lsu
        `AXI_ASSIGN_FROM_REQ (axi_snitch2mux[1], axi_data_snitch_req[1])
        `AXI_ASSIGN_TO_RESP  (axi_data_snitch_resp[1], axi_snitch2mux[1])
        // icache 
        `AXI_ASSIGN_FROM_REQ (axi_snitch2mux[2], axi_icache_snitch_req)
        `AXI_ASSIGN_TO_RESP  (axi_icache_snitch_resp, axi_snitch2mux[2])


        axi_xbar_intf #(
            .AXI_USER_WIDTH(AxiUserWidth),
            .Cfg(xbar_cfg),
            .rule_t(rule_t)
        ) i_axi_xbar_intf (
            .clk_i(clk),
            .rst_ni(core_areset_n),
            .test_i('0),
            .slv_ports(axi_snitch2mux),
            .mst_ports(axi_xbar2uncore),
            .addr_map_i(AddrMapUncore),
            .en_default_mst_port_i('0),
            .default_mst_port_i('0)
        );

        `AXI_ASSIGN(axi_rom, axi_xbar2uncore[0])
        `AXI_ASSIGN(axi_dram[i], axi_xbar2uncore[1])
        `AXI_ASSIGN(axi_uncore2pxbar[i], axi_xbar2uncore[2])
        `AXI_ASSIGN(axi_clint, axi_xbar2uncore[3])

        axi_clint #(
            .AddrWidth(AxiDataWidth),
            .DataWidth(AxiDataWidth),
            .IdWidthIn(AxiIdWidthToUncore),
            .UserWidth(AxiUserWidth),
            .NR_CORES(1)
        ) axi_clint_instance(
            .clk_i(clk),
            .rst_ni(uncore_areset_n),
            .testmode_i('0),
            .clint(axi_clint),
            .rtc_i(rtc),
            .timer_irq_o(core_irq_i[i].mtip),
            .ipi_o(core_irq_i[i].msip)
        );
        
        // ROM
        logic                    rom_req;
        logic [AxiAddrWidth-1:0] rom_addr;
        logic [AxiDataWidth-1:0] rom_rdata;
        logic                    rom_rvalid;

        axi_to_mem_intf #(
            .ADDR_WIDTH ( AxiAddrWidth),
            .DATA_WIDTH ( AxiDataWidth),
            .ID_WIDTH   ( AxiIdWidthToUncore),
            .USER_WIDTH ( AxiUserWidth),
            .NUM_BANKS  ( 1)
        ) i_axi_to_mem (
            .clk_i       ( clk),
            .rst_ni      ( uncore_areset_n),
            .busy_o      ( ),
            .slv         ( axi_rom),
            .mem_req_o   ( rom_req),
            .mem_gnt_i   ( '1),
            .mem_addr_o  ( rom_addr),
            .mem_wdata_o ( ),
            .mem_strb_o  ( ),
            .mem_atop_o  ( ),
            .mem_we_o    ( ),
            .mem_rvalid_i( rom_rvalid),
            .mem_rdata_i ( rom_rdata)
        );

        bootrom i_bootrom (
            .clk_i      ( clk       ),
            .req_i      ( rom_req   ),
            .addr_i     ( rom_addr  ),
            .rdata_o    ( rom_rdata ),
            .rvalid_o   (rom_rvalid )
        );

    end
// ----------------
// MEMORY SUBSYSTEM
// ----------------
for ( genvar i=0; i<CORE_NUMBER; ++i) begin: dram_gen
    axi_bram_ctrl_0 bram(
    .s_axi_aclk     (clk),
    .s_axi_aresetn  (uncore_areset_n),
    .s_axi_awid     ( axi_dram[i].aw_id),
    .s_axi_awaddr   ( axi_dram[i].aw_addr[18:0]),
    .s_axi_awlen    ( axi_dram[i].aw_len    ),
    .s_axi_awsize   ( axi_dram[i].aw_size   ),
    .s_axi_awburst  ( axi_dram[i].aw_burst  ),
    .s_axi_awlock   ( axi_dram[i].aw_lock   ),
    .s_axi_awcache  ( axi_dram[i].aw_cache  ),
    .s_axi_awprot   ( axi_dram[i].aw_prot   ),
    .s_axi_awvalid  ( axi_dram[i].aw_valid  ),
    .s_axi_awready  ( axi_dram[i].aw_ready  ),
    .s_axi_wdata    ( axi_dram[i].w_data    ),
    .s_axi_wstrb    ( axi_dram[i].w_strb    ),
    .s_axi_wlast    ( axi_dram[i].w_last    ),
    .s_axi_wvalid   ( axi_dram[i].w_valid   ),
    .s_axi_wready   ( axi_dram[i].w_ready   ),
    .s_axi_bid      ( axi_dram[i].b_id),
    .s_axi_bresp    ( axi_dram[i].b_resp    ),
    .s_axi_bvalid   ( axi_dram[i].b_valid   ),
    .s_axi_bready   ( axi_dram[i].b_ready   ),
    .s_axi_arid     ( axi_dram[i].ar_id),
    .s_axi_araddr   ( axi_dram[i].ar_addr[18:0]),
    .s_axi_arlen    ( axi_dram[i].ar_len    ),
    .s_axi_arsize   ( axi_dram[i].ar_size   ),
    .s_axi_arburst  ( axi_dram[i].ar_burst  ),
    .s_axi_arlock   ( axi_dram[i].ar_lock   ),
    .s_axi_arcache  ( axi_dram[i].ar_cache  ),
    .s_axi_arprot   ( axi_dram[i].ar_prot   ),
    .s_axi_arvalid  ( axi_dram[i].ar_valid  ),
    .s_axi_arready  ( axi_dram[i].ar_ready  ),
    .s_axi_rid      ( axi_dram[i].r_id),
    .s_axi_rdata    ( axi_dram[i].r_data    ),
    .s_axi_rresp    ( axi_dram[i].r_resp    ),
    .s_axi_rlast    ( axi_dram[i].r_last    ),
    .s_axi_rvalid   ( axi_dram[i].r_valid   ),
    .s_axi_rready   ( axi_dram[i].r_ready   )
    );

    assign axi_dram[i].b_user = '0;
    assign axi_dram[i].r_user = '0;

end
    // Must manually assign channels to each core dram bus
    //`AXI_ASSIGN_MASTER_TO_HBM_ARIANE(S00, dram[0])
    //`AXI_ASSIGN_MASTER_TO_HBM_ARIANE(S01, dram[1])
    //`AXI_ASSIGN_MASTER_TO_HBM_ARIANE(S02, dram[2])
    //`AXI_ASSIGN_MASTER_TO_HBM_ARIANE(S03, dram[3])
    // ... add other channels as needed

// ----------------
// ETHERNET SUBSYSTEM
// ----------------

// ----------------
// COMMON PERYPHERALS SUBSYSTEM 
// ----------------
    localparam int EXT_TIMERS = CLUSTER_NUMBER * 2; // 2 timers per core
    logic [(EXT_TIMERS *2) - 1 : 0] timer_irq;
    logic uart_irq;
    logic [CORE_NUMBER - 1  : 0] plic_irq_o;

    for (genvar i = 0; i < CORE_NUMBER; i++) begin : gen_irq
        assign core_irq_i[i].meip = plic_irq_o[i*2];
    end

    axi_xbar_intf #(
        .AXI_USER_WIDTH(AxiUserWidth),
        .Cfg(perif_xbar_cfg),
        .rule_t(rule_t)
    ) i_axi_xbar_intf_perif (
        .clk_i(clk),
        .rst_ni(uncore_areset_n),
        .test_i('0),
        .slv_ports(axi_uncore2pxbar),
        .mst_ports(axi_peripherals),
        .addr_map_i(AddrMapPerif),
        .en_default_mst_port_i('0),
        .default_mst_port_i('0)
    );
    axi_uart #(
        .AxiAddrWidth(AxiAddrWidth),
        .AxiDataWidth(AxiDataWidth),
        .AxiIdWidth(AxiIdWidthToPerifs),
        .AxiUserWidth(AxiUserWidth)
    ) axi_uart_instance(
        .clk_i(clk),
        .rst_ni(uncore_areset_n),
        .uart(axi_peripherals[1]),
        .uart_irq(uart_irq),
        .tx_o(uart_tx),
        .rx_i(uart_rx)
    );
    axi_plic #(
        .AxiAddrWidth(AxiAddrWidth),
        .AxiDataWidth(AxiDataWidth),
        .AxiIdWidth(AxiIdWidthToPerifs),
        .AxiUserWidth(AxiUserWidth),
        .NIrqSrcs((EXT_TIMERS *2) + 1), // 2 src per timer per core + uart
        .NHARTS(CLUSTER_NUMBER)
    ) axi_plic_instance(
        .clk_i(clk),
        .rst_ni(uncore_areset_n),
        .plic(axi_peripherals[0]),
        .plic_irq_i({uart_irq,timer_irq}),
        .plic_irq_o(plic_irq_o)
    );
    axi_timer #(
        .AxiAddrWidth(AxiAddrWidth),
        .AxiDataWidth(AxiDataWidth),
        .AxiIdWidth(AxiIdWidthToPerifs),
        .AxiUserWidth(AxiUserWidth),
        .TimerCount(EXT_TIMERS)
    ) axi_timer_instance(
        .clk_i(clk),
        .rst_ni(uncore_areset_n),
        .timer(axi_peripherals[2]),
        .timer_irq(timer_irq)
    );

// -------------------------
// Clocking system and RESET
// -------------------------
    logic pll_locked;

    logic sys_rst_n_c;
    IBUF sys_reset_n_ibuf (.O(sys_rst_n_c), .I(prst_n));

    IBUFDS hbm_ref_clk (
        .I(HBM_ref_clk_p),
        .IB(HBM_ref_clk_n),
        .O(REF_CLK)
    );
    BUFG hbm_ref_clk_bufg (
        .I(REF_CLK),
        .O(HBM_REF_CLK)
    );

    // we need to switch reset polarity for core reset
    logic clock_reset;
    assign clock_reset = ~sys_rst_n_c;

    xlnx_clk_gen_sim i_xlnx_clk_gen (
        .clk_out1 ( clk           ), // 50 MHz
        .clk_out2 ( hbm_apb_clk   ), // 100 MHz clock
        .clk_out3 ( rtc  ),          // 10 Mhz rtc clk
        .reset    ( clock_reset     ),
        .locked   ( pll_locked    ),
        .clk_in1  ( REF_CLK ) // 100 Mhz ref clk
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

    // ndmreset_n is driven high when pll locks and the board releases his external reset
    // then the logic can be resetted from the hbm_xdma_interface (unconnected in sim config)
    rstgen i_rstgen_main (
        .clk_i        ( REF_CLK                  ),
        .rst_ni       ( pll_locked & sys_rst_n_c ),
        .test_mode_i  ( '0                       ),
        .rst_no       ( core_areset_n            ),
        .init_no      (                          ) // keep open
    );

    logic hbm_apb_areset_n;

    proc_sys_reset_0 i_proc_sys_reset(
        .aux_reset_in(1'b1),
        .dcm_locked(1'b1),
        .mb_debug_sys_rst(1'b0),
        .slowest_sync_clk(hbm_apb_clk),
        .ext_reset_in(sys_rst_n_c),
        .peripheral_aresetn(hbm_apb_areset_n)
    );


    // -----------------
    // END
    // -----------------

endmodule
