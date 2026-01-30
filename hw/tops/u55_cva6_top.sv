
// Copyright 2024 Politecnico di Milano.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// Description: AMD u55c cva6 hbm cluster top-level
// Author: Andrea Motta 
`include "axi_typedef.svh"
`include "hbm_axi.svh"

module cva6_u55_xilinx_bd 
    import snitch_pkg::*; 
    import snitch_cluster_pkg::*;
    import axi_pkg::*;
(
  input                 sys_clk_p       ,   // 100 MHz Clock for PCIE
  input                 sys_clk_n       ,   // 100 MHz Clock for PCIE
  input  logic          prst_n          ,   //reset
  input                 HBM_ref_clk_p   ,   // 100 MHz Clock for HBM
  input                 HBM_ref_clk_n   ,   // 100 MHz Clock for HBM
  output wire [15:0]    pcie_x16_txp     ,
  output wire [15:0]    pcie_x16_txn     ,
  input  wire [15:0]    pcie_x16_rxp     ,
  input  wire [15:0]    pcie_x16_rxn     ,
  input  logic          uart_rx         ,
  output logic          uart_tx
);

// design parameter
localparam BOOT_ADDR            = 64'h0000_0000;
localparam CORE_NUMBER          = 1;
localparam CLUSTER_NUMBER       = 1;
localparam TOTAL_CORE_NUMBER     = CORE_NUMBER * CLUSTER_NUMBER;
localparam PERIF_NUMBER         = 3;            // uart, timer, plic
localparam DRAM_CH_NUMBER       = CLUSTER_NUMBER;  // snitch clusters

// axi paramenter
localparam AxiAddrWidth         = 32;           // 32
localparam AxiDataWidth         = 64;          // 64
localparam AxiPerifDataWidth    = 64;           // 64
localparam AxiIdWidthCore       = 4;            // 4 
localparam AxiIdWidthToUncore   = AxiIdWidthCore + $clog2(CORE_NUMBER);          // 4
localparam AxiIdWidthToPerifs   = AxiIdWidthToUncore + $clog2(CLUSTER_NUMBER); 
localparam AxiUserWidth         = 1;

// axi typedef
typedef logic [AxiAddrWidth-1:0]        addr_t;
typedef logic [AxiDataWidth-1:0]        data_t;
typedef logic [AxiDataWidth/8-1:0]      strb_t;
typedef logic [AxiUserWidth-1:0]        user_t;
typedef logic [AxiIdWidthCore-1:0]      narrow_in_id_t;
typedef logic [AxiIdWidthCore-1:0]      narrow_out_id_t;
`AXI_TYPEDEF_ALL(cva6_in, addr_t, narrow_in_id_t, data_t, strb_t, user_t)
`AXI_TYPEDEF_ALL(cva6_out, addr_t, narrow_out_id_t, data_t, strb_t, user_t)

// xbar config
localparam axi_pkg::xbar_cfg_t xbar_cfg = '{
    NoSlvPorts:         CORE_NUMBER,
    NoMstPorts:         4,          // bootrom + clint + dram + peripherals xbar
    MaxMstTrans:        16,
    MaxSlvTrans:        16,
    FallThrough:        1'b0,
    LatencyMode:        axi_pkg::CUT_ALL_PORTS,
    PipelineStages:     1,
    AxiIdWidthSlvPorts: AxiIdWidthCore,
    AxiIdUsedSlvPorts:  2,
    UniqueIds:          '0,
    AxiAddrWidth:       AxiAddrWidth,
    AxiDataWidth:       AxiDataWidth,
    NoAddrRules:        4           // bootrom + clint + dram + peripherals xbar
};
// peripherals xbar setting
localparam axi_pkg::xbar_cfg_t perif_xbar_cfg = '{
    NoSlvPorts:         CLUSTER_NUMBER,
    NoMstPorts:         PERIF_NUMBER,
    MaxMstTrans:        16,
    MaxSlvTrans:        16,
    FallThrough:        1'b0,
    LatencyMode:        axi_pkg::CUT_ALL_PORTS,
    PipelineStages:     1,
    AxiIdWidthSlvPorts: AxiIdWidthToUncore,
    AxiIdUsedSlvPorts:  AxiIdWidthToUncore,
    UniqueIds:          '0,
    AxiAddrWidth:       AxiAddrWidth,
    AxiDataWidth:       AxiPerifDataWidth,
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
        end_addr:   32'h8000_0000 + 32'h2000_0000, // 512MB per cluster here
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
    .AXI_ADDR_WIDTH ( AxiAddrWidth       ),
    .AXI_DATA_WIDTH ( AxiPerifDataWidth  ),
    .AXI_ID_WIDTH   ( AxiIdWidthToUncore ),
    .AXI_USER_WIDTH ( AxiUserWidth       )
) axi_uncore2pxbar[CLUSTER_NUMBER-1:0]();
AXI_BUS #(
    .AXI_ADDR_WIDTH ( AxiAddrWidth       ),
    .AXI_DATA_WIDTH ( AxiPerifDataWidth  ),
    .AXI_ID_WIDTH   ( AxiIdWidthToPerifs ),
    .AXI_USER_WIDTH ( AxiUserWidth       )
) axi_peripherals[PERIF_NUMBER - 1:0]();

// interrupt handling bus
logic [TOTAL_CORE_NUMBER - 1 : 0][1:0] plic_irq_o;

// clocking and reset declaration
logic clk;
logic master_areset;
logic core_areset_n;
logic uncore_areset_n;
assign uncore_areset_n = core_areset_n;
// ---------------
// Core
// ---------------
    
    for ( genvar i=0; i<CLUSTER_NUMBER; ++i) begin  : cluster_gen

        logic [CORE_NUMBER -1 : 0]timer_irq;
        logic [CORE_NUMBER -1 : 0]ipi;
        AXI_BUS #(
            .AXI_ADDR_WIDTH ( AxiAddrWidth     ),
            .AXI_DATA_WIDTH ( AxiDataWidth     ),
            .AXI_ID_WIDTH   ( AxiIdWidthCore   ),
            .AXI_USER_WIDTH ( AxiUserWidth     )
        ) axi_cva2xbar[CORE_NUMBER - 1 : 0]();
        
        for ( genvar j=0; j<CORE_NUMBER; ++j) begin  : core_gen 
            cva6_out_req_t   cva6_req;
            cva6_out_resp_t   cva6_resp;

            cva6 #(
                .noc_req_t(cva6_out_req_t),
                .noc_resp_t(cva6_out_resp_t)
            )cva6_instance(
                .clk_i(clk),
                .rst_ni(core_areset_n),
                .boot_addr_i(BOOT_ADDR),
                .hart_id_i(j),
                // meip
                .irq_i('0),
                // msip
                .ipi_i('0),
                // mtip
                .time_irq_i('0),
                .debug_req_i('0),
                .rvfi_probes_o(),
                .cvxif_req_o(),
                .cvxif_resp_i('0),
                .noc_req_o(cva6_req),
                .noc_resp_i(cva6_resp)
            );
            
            // shared core lsu
            `AXI_ASSIGN_FROM_REQ(axi_cva2xbar[j], cva6_req)
            `AXI_ASSIGN_TO_RESP(cva6_resp, axi_cva2xbar[j])
        
        end : core_gen

        AXI_BUS #(
           .AXI_ADDR_WIDTH ( AxiAddrWidth     ),
           .AXI_DATA_WIDTH ( AxiDataWidth     ),
           .AXI_ID_WIDTH   ( AxiIdWidthToUncore),
           .AXI_USER_WIDTH ( AxiUserWidth     )
         ) axi_xbar2uncore[3:0]();
        AXI_BUS #(
            .AXI_ADDR_WIDTH ( AxiAddrWidth     ),
            .AXI_DATA_WIDTH ( AxiPerifDataWidth     ),
            .AXI_ID_WIDTH   ( AxiIdWidthToUncore ),
            .AXI_USER_WIDTH ( AxiUserWidth     )
        ) axi_rom();
        AXI_BUS #(
            .AXI_ADDR_WIDTH ( AxiAddrWidth     ),
            .AXI_DATA_WIDTH ( AxiPerifDataWidth     ),
            .AXI_ID_WIDTH   ( AxiIdWidthToUncore ),
            .AXI_USER_WIDTH ( AxiUserWidth     )
        ) axi_clint(); 

        axi_xbar_intf #(
            .AXI_USER_WIDTH(AxiUserWidth),
            .Cfg(xbar_cfg),
            .rule_t(rule_t)
        ) i_axi_xbar_intf (
            .clk_i(clk),
            .rst_ni(core_areset_n),
            .test_i('0),
            .slv_ports(axi_cva2xbar),
            .mst_ports(axi_xbar2uncore),
            .addr_map_i(AddrMapUncore),
            .en_default_mst_port_i('0),
            .default_mst_port_i('0)
        );
        
        // To external peripherals (PLIC, UART, TIMER)
            
            `AXI_ASSIGN(axi_uncore2pxbar[i],axi_xbar2uncore[2])


        // CLINT

            `AXI_ASSIGN(axi_clint ,axi_xbar2uncore[3])


            logic rtc;
            always_ff @(posedge clk or negedge uncore_areset_n) begin
                if (~uncore_areset_n) begin
                    rtc <= 0;
                end else begin
                    rtc <= rtc ^ 1'b1;
                end
            end
            axi_clint #(
                .AddrWidth(AxiAddrWidth),
                .DataWidth(AxiPerifDataWidth),
                .IdWidthIn(AxiIdWidthToUncore),
                .UserWidth(AxiUserWidth),
                .NR_CORES(CORE_NUMBER)
            ) axi_clint_instance(
                .clk_i(clk),
                .rst_ni(uncore_areset_n),
                .testmode_i('0),
                .clint(axi_clint),
                .rtc_i(rtc),
                .timer_irq_o(timer_irq),
                .ipi_o(ipi)
            );
//            assign axi_clint.b_user = '0; 
//            assign axi_clint.r_user = '0;

        // ROM

            `AXI_ASSIGN(axi_rom ,axi_xbar2uncore[0])

            logic                           rom_req;
            logic [AxiAddrWidth-1:0]        rom_addr;
            logic [AxiPerifDataWidth-1:0]   rom_rdata;
            logic                           rom_rvalid;
            axi_to_mem_intf #(
                .ADDR_WIDTH ( AxiAddrWidth),
                .DATA_WIDTH ( AxiPerifDataWidth),
                .ID_WIDTH   ( AxiIdWidthToUncore),
                .USER_WIDTH ( AxiUserWidth),
                .NUM_BANKS  ( 1)
            ) i_axi_to_mem (
                .clk_i       ( clk),
                .rst_ni      ( core_areset_n),
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
                .rvalid_o   ( rom_rvalid)
            );
        
        // DRAM
        `AXI_ASSIGN(axi_dram[i],axi_xbar2uncore[1])
        // tie unused signal in bram channel to 0
        assign axi_dram[i].b_user = '0;
        assign axi_dram[i].r_user = '0;
    end : cluster_gen

// -----------------------
// MEMORY SUBSYSTEM
// -----------------------

    // @ DRAM_BASE b1000_0000_0000_0000_0000_0000_0000_0000 [31:0]
    // HBM gets    b 000_0000_0000_0000_0000_0000_0000_0000 [30:0]
    // This allows us to have 31bit addressing (2GB)
    logic HBM_REF_CLK, sys_clk, sys_clk_gt, sys_rst_n_c;
   hbm_interface i_hbm_interface (
        .HBM_REF_CLK_0_0    (HBM_REF_CLK),
        // cluster 0
        .S00_AXI_0_araddr   ({4'b00000, axi_dram[0].ar_addr[29:0]}),
        .S00_AXI_0_arburst  (axi_dram[0].ar_burst),
        .S00_AXI_0_arcache  (axi_dram[0].ar_cache),
        .S00_AXI_0_arid     (axi_dram[0].ar_id),
        .S00_AXI_0_arlen    (axi_dram[0].ar_len),
        .S00_AXI_0_arlock   (axi_dram[0].ar_lock),
        .S00_AXI_0_arprot   (axi_dram[0].ar_prot),
        .S00_AXI_0_arqos    (axi_dram[0].ar_qos),
        .S00_AXI_0_arready  (axi_dram[0].ar_ready),
        .S00_AXI_0_arsize   (axi_dram[0].ar_size),
        .S00_AXI_0_arvalid  (axi_dram[0].ar_valid),
        .S00_AXI_0_awaddr   ({4'b00000, axi_dram[0].aw_addr[29:0]}),
        .S00_AXI_0_awburst  (axi_dram[0].aw_burst),
        .S00_AXI_0_awcache  (axi_dram[0].aw_cache),
        .S00_AXI_0_awid     (axi_dram[0].aw_id),
        .S00_AXI_0_awlen    (axi_dram[0].aw_len),
        .S00_AXI_0_awlock   (axi_dram[0].aw_lock),
        .S00_AXI_0_awprot   (axi_dram[0].aw_prot),
        .S00_AXI_0_awqos    (axi_dram[0].aw_qos),
        .S00_AXI_0_awready  (axi_dram[0].aw_ready),
        .S00_AXI_0_awsize   (axi_dram[0].aw_size),
        .S00_AXI_0_awvalid  (axi_dram[0].aw_valid),
        .S00_AXI_0_bid      (axi_dram[0].b_id),
        .S00_AXI_0_bready   (axi_dram[0].b_ready),
        .S00_AXI_0_bresp    (axi_dram[0].b_resp),
        .S00_AXI_0_bvalid   (axi_dram[0].b_valid),
        .S00_AXI_0_rdata    (axi_dram[0].r_data),
        .S00_AXI_0_rid      (axi_dram[0].r_id),
        .S00_AXI_0_rlast    (axi_dram[0].r_last),
        .S00_AXI_0_rready   (axi_dram[0].r_ready),
        .S00_AXI_0_rresp    (axi_dram[0].r_resp),
        .S00_AXI_0_rvalid   (axi_dram[0].r_valid),
        .S00_AXI_0_wdata    (axi_dram[0].w_data),
        .S00_AXI_0_wlast    (axi_dram[0].w_last),
        .S00_AXI_0_wready   (axi_dram[0].w_ready),
        .S00_AXI_0_wstrb    (axi_dram[0].w_strb),
        .S00_AXI_0_wvalid   (axi_dram[0].w_valid),    
        // cluster 1
        .S01_AXI_0_araddr   ({4'b00001, axi_dram[1].ar_addr[29:0]}),
        .S01_AXI_0_arburst  (axi_dram[1].ar_burst),
        .S01_AXI_0_arcache  (axi_dram[1].ar_cache),
        .S01_AXI_0_arid     (axi_dram[1].ar_id),
        .S01_AXI_0_arlen    (axi_dram[1].ar_len),
        .S01_AXI_0_arlock   (axi_dram[1].ar_lock),
        .S01_AXI_0_arprot   (axi_dram[1].ar_prot),
        .S01_AXI_0_arqos    (axi_dram[1].ar_qos),
        .S01_AXI_0_arready  (axi_dram[1].ar_ready),
        .S01_AXI_0_arsize   (axi_dram[1].ar_size),
        .S01_AXI_0_arvalid  (axi_dram[1].ar_valid),
        .S01_AXI_0_awaddr   ({4'b00001, axi_dram[1].aw_addr[29:0]}),
        .S01_AXI_0_awburst  (axi_dram[1].aw_burst),
        .S01_AXI_0_awcache  (axi_dram[1].aw_cache),
        .S01_AXI_0_awid     (axi_dram[1].aw_id),
        .S01_AXI_0_awlen    (axi_dram[1].aw_len),
        .S01_AXI_0_awlock   (axi_dram[1].aw_lock),
        .S01_AXI_0_awprot   (axi_dram[1].aw_prot),
        .S01_AXI_0_awqos    (axi_dram[1].aw_qos),
        .S01_AXI_0_awready  (axi_dram[1].aw_ready),
        .S01_AXI_0_awsize   (axi_dram[1].aw_size),
        .S01_AXI_0_awvalid  (axi_dram[1].aw_valid),
        .S01_AXI_0_bid      (axi_dram[1].b_id),
        .S01_AXI_0_bready   (axi_dram[1].b_ready),
        .S01_AXI_0_bresp    (axi_dram[1].b_resp),
        .S01_AXI_0_bvalid   (axi_dram[1].b_valid),
        .S01_AXI_0_rdata    (axi_dram[1].r_data),
        .S01_AXI_0_rid      (axi_dram[1].r_id),
        .S01_AXI_0_rlast    (axi_dram[1].r_last),
        .S01_AXI_0_rready   (axi_dram[1].r_ready),
        .S01_AXI_0_rresp    (axi_dram[1].r_resp),
        .S01_AXI_0_rvalid   (axi_dram[1].r_valid),
        .S01_AXI_0_wdata    (axi_dram[1].w_data),
        .S01_AXI_0_wlast    (axi_dram[1].w_last),
        .S01_AXI_0_wready   (axi_dram[1].w_ready),
        .S01_AXI_0_wstrb    (axi_dram[1].w_strb),
        .S01_AXI_0_wvalid   (axi_dram[1].w_valid),    
//        // cluster 2
//        .S02_AXI_0_araddr   ({4'b00010, axi_dram[2].ar_addr[29:0]}),
//        .S02_AXI_0_arburst  (axi_dram[2].ar_burst),
//        .S02_AXI_0_arcache  (axi_dram[2].ar_cache),
//        .S02_AXI_0_arid     (axi_dram[2].ar_id),
//        .S02_AXI_0_arlen    (axi_dram[2].ar_len),
//        .S02_AXI_0_arlock   (axi_dram[2].ar_lock),
//        .S02_AXI_0_arprot   (axi_dram[2].ar_prot),
//        .S02_AXI_0_arqos    (axi_dram[2].ar_qos),
//        .S02_AXI_0_arready  (axi_dram[2].ar_ready),
//        .S02_AXI_0_arsize   (axi_dram[2].ar_size),
//        .S02_AXI_0_arvalid  (axi_dram[2].ar_valid),
//        .S02_AXI_0_awaddr   ({4'b00010, axi_dram[2].aw_addr[29:0]}),
//        .S02_AXI_0_awburst  (axi_dram[2].aw_burst),
//        .S02_AXI_0_awcache  (axi_dram[2].aw_cache),
//        .S02_AXI_0_awid     (axi_dram[2].aw_id),
//        .S02_AXI_0_awlen    (axi_dram[2].aw_len),
//        .S02_AXI_0_awlock   (axi_dram[2].aw_lock),
//        .S02_AXI_0_awprot   (axi_dram[2].aw_prot),
//        .S02_AXI_0_awqos    (axi_dram[2].aw_qos),
//        .S02_AXI_0_awready  (axi_dram[2].aw_ready),
//        .S02_AXI_0_awsize   (axi_dram[2].aw_size),
//        .S02_AXI_0_awvalid  (axi_dram[2].aw_valid),
//        .S02_AXI_0_bid      (axi_dram[2].b_id),
//        .S02_AXI_0_bready   (axi_dram[2].b_ready),
//        .S02_AXI_0_bresp    (axi_dram[2].b_resp),
//        .S02_AXI_0_bvalid   (axi_dram[2].b_valid),
//        .S02_AXI_0_rdata    (axi_dram[2].r_data),
//        .S02_AXI_0_rid      (axi_dram[2].r_id),
//        .S02_AXI_0_rlast    (axi_dram[2].r_last),
//        .S02_AXI_0_rready   (axi_dram[2].r_ready),
//        .S02_AXI_0_rresp    (axi_dram[2].r_resp),
//        .S02_AXI_0_rvalid   (axi_dram[2].r_valid),
//        .S02_AXI_0_wdata    (axi_dram[2].w_data),
//        .S02_AXI_0_wlast    (axi_dram[2].w_last),
//        .S02_AXI_0_wready   (axi_dram[2].w_ready),
//        .S02_AXI_0_wstrb    (axi_dram[2].w_strb),
//        .S02_AXI_0_wvalid   (axi_dram[2].w_valid),    
//        // cluster 3
//        .S03_AXI_0_araddr   ({4'b00011, axi_dram[3].ar_addr[29:0]}),
//        .S03_AXI_0_arburst  (axi_dram[3].ar_burst),
//        .S03_AXI_0_arcache  (axi_dram[3].ar_cache),
//        .S03_AXI_0_arid     (axi_dram[3].ar_id),
//        .S03_AXI_0_arlen    (axi_dram[3].ar_len),
//        .S03_AXI_0_arlock   (axi_dram[3].ar_lock),
//        .S03_AXI_0_arprot   (axi_dram[3].ar_prot),
//        .S03_AXI_0_arqos    (axi_dram[3].ar_qos),
//        .S03_AXI_0_arready  (axi_dram[3].ar_ready),
//        .S03_AXI_0_arsize   (axi_dram[3].ar_size),
//        .S03_AXI_0_arvalid  (axi_dram[3].ar_valid),
//        .S03_AXI_0_awaddr   ({4'b00011, axi_dram[3].aw_addr[29:0]}),
//        .S03_AXI_0_awburst  (axi_dram[3].aw_burst),
//        .S03_AXI_0_awcache  (axi_dram[3].aw_cache),
//        .S03_AXI_0_awid     (axi_dram[3].aw_id),
//        .S03_AXI_0_awlen    (axi_dram[3].aw_len),
//        .S03_AXI_0_awlock   (axi_dram[3].aw_lock),
//        .S03_AXI_0_awprot   (axi_dram[3].aw_prot),
//        .S03_AXI_0_awqos    (axi_dram[3].aw_qos),
//        .S03_AXI_0_awready  (axi_dram[3].aw_ready),
//        .S03_AXI_0_awsize   (axi_dram[3].aw_size),
//        .S03_AXI_0_awvalid  (axi_dram[3].aw_valid),
//        .S03_AXI_0_bid      (axi_dram[3].b_id),
//        .S03_AXI_0_bready   (axi_dram[3].b_ready),
//        .S03_AXI_0_bresp    (axi_dram[3].b_resp),
//        .S03_AXI_0_bvalid   (axi_dram[3].b_valid),
//        .S03_AXI_0_rdata    (axi_dram[3].r_data),
//        .S03_AXI_0_rid      (axi_dram[3].r_id),
//        .S03_AXI_0_rlast    (axi_dram[3].r_last),
//        .S03_AXI_0_rready   (axi_dram[3].r_ready),
//        .S03_AXI_0_rresp    (axi_dram[3].r_resp),
//        .S03_AXI_0_rvalid   (axi_dram[3].r_valid),
//        .S03_AXI_0_wdata    (axi_dram[3].w_data),
//        .S03_AXI_0_wlast    (axi_dram[3].w_last),
//        .S03_AXI_0_wready   (axi_dram[3].w_ready),
//        .S03_AXI_0_wstrb    (axi_dram[3].w_strb),
//        .S03_AXI_0_wvalid   (axi_dram[3].w_valid),   
        .axi_clk_ariane_0   (clk),
        .pcie_mgt_0_rxn     (pcie_x16_rxn),
        .pcie_mgt_0_rxp     (pcie_x16_rxp),
        .pcie_mgt_0_txn     (pcie_x16_txn),
        .pcie_mgt_0_txp     (pcie_x16_txp),
        .sys_clk_0          (sys_clk),
        .sys_clk_gt_0       (sys_clk_gt),
        .sys_rst_n_0        (sys_rst_n_c),
        .usr_irq_req_0      ('0),
        .master_areset_o_0(master_areset)
    );

    // Must manually assign channels to each core dram bus
    //`AXI_ASSIGN_MASTER_TO_HBM_ARIANE(S00, dram[0])
    //`AXI_ASSIGN_MASTER_TO_HBM_ARIANE("S01", dram[1])
    //`AXI_ASSIGN_MASTER_TO_HBM_ARIANE("S02", dram[2])
    //`AXI_ASSIGN_MASTER_TO_HBM_ARIANE("S03", dram[3])
    // ... add other channels as needed

// -----------------------
// ETHERNET SUBSYSTEM
// -----------------------

// -----------------------
// PERYPHERALS SUBSYSTEM 
// -----------------------
    localparam int EXT_TIMERS = 2; // 2 timers per core
    logic [(EXT_TIMERS *2) - 1 : 0] ext_timer_irq;
    logic uart_irq;
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
        .AxiDataWidth(AxiPerifDataWidth),
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
        .AxiDataWidth(AxiPerifDataWidth),
        .AxiIdWidth(AxiIdWidthToPerifs),
        .AxiUserWidth(AxiUserWidth),
        .NIrqSrcs((EXT_TIMERS *2) + 1), // 2 src per timer per core + uart
        .NHARTS(TOTAL_CORE_NUMBER)
    ) axi_plic_instance(
        .clk_i(clk),
        .rst_ni(uncore_areset_n),
        .plic(axi_peripherals[0]),
        .plic_irq_i({uart_irq,ext_timer_irq}),
        .plic_irq_o(plic_irq_o)
    );
    axi_timer #(
        .AxiAddrWidth(AxiAddrWidth),
        .AxiDataWidth(AxiPerifDataWidth),
        .AxiIdWidth(AxiIdWidthToPerifs),
        .AxiUserWidth(AxiUserWidth),
        .TimerCount(EXT_TIMERS)
    ) axi_timer_instance(
        .clk_i(clk),
        .rst_ni(uncore_areset_n),
        .timer(axi_peripherals[2]),
        .timer_irq(ext_timer_irq)
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

    xlnx_clk_gen_solo i_clk_gen_core (
    .core_clk ( clk             ), // 100 MHz
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
    rstgen i_rstgen_main (
        .clk_i        ( clk                      ),
        .rst_ni       ( pll_locked & (!master_areset_reg) & sys_rst_n_c),
        .test_mode_i  ( '0                       ),
        .rst_no       ( core_areset_n            ),
        .init_no      (                          ) // keep open
    );

// -----------------
// END
// -----------------

endmodule
