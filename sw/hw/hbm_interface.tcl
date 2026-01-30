
################################################################
# This is a generated script based on design: hbm_interface
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2023.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   if { [string compare $scripts_vivado_version $current_vivado_version] > 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2042 -severity "ERROR" " This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Sourcing the script failed since it was created with a future version of Vivado."}

   } else {
     catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   }

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source hbm_interface_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# axi4_boot_check

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xcu55c-fsvh2892-2L-e
   set_property BOARD_PART xilinx.com:au55c:part0:1.0 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name hbm_interface

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:hbm:1.0\
xilinx.com:ip:smartconnect:1.0\
xilinx.com:ip:system_ila:1.1\
xilinx.com:ip:xdma:4.1\
xilinx.com:ip:clk_wiz:6.0\
xilinx.com:ip:proc_sys_reset:5.0\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
axi4_boot_check\
"

   set list_mods_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2020 -severity "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2021 -severity "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_gid_msg -ssname BD::TCL -id 2022 -severity "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set S00_AXI_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI_0 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {34} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {64} \
   CONFIG.FREQ_HZ {100000000} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {1} \
   CONFIG.HAS_REGION {1} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {12} \
   CONFIG.MAX_BURST_LENGTH {1} \
   CONFIG.NUM_READ_OUTSTANDING {16} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {16} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $S00_AXI_0

  set pcie_mgt_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pcie_mgt_0 ]


  # Create ports
  set HBM_REF_CLK_0_0 [ create_bd_port -dir I -type clk HBM_REF_CLK_0_0 ]
  set axi_clk_ariane_0 [ create_bd_port -dir I -type clk -freq_hz 100000000 axi_clk_ariane_0 ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S00_AXI_0} \
   CONFIG.ASSOCIATED_RESET {axi_aresetn_0} \
 ] $axi_clk_ariane_0
  set master_areset_o_0 [ create_bd_port -dir O master_areset_o_0 ]
  set sys_clk_0 [ create_bd_port -dir I -type clk sys_clk_0 ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_RESET {sys_rst_n_0} \
 ] $sys_clk_0
  set sys_clk_gt_0 [ create_bd_port -dir I -type clk sys_clk_gt_0 ]
  set usr_irq_req_0 [ create_bd_port -dir I -from 0 -to 0 usr_irq_req_0 ]
  set sys_rst_n_0 [ create_bd_port -dir I -type rst sys_rst_n_0 ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $sys_rst_n_0

  # Create instance: hbm_0, and set properties
  set hbm_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:hbm:1.0 hbm_0 ]
  set_property -dict [list \
    CONFIG.USER_APB_EN {false} \
    CONFIG.USER_AXI_CLK_FREQ {250} \
    CONFIG.USER_AXI_INPUT_CLK_FREQ {250} \
    CONFIG.USER_AXI_INPUT_CLK_NS {4.000} \
    CONFIG.USER_AXI_INPUT_CLK_PS {4000} \
    CONFIG.USER_AXI_INPUT_CLK_XDC {4.000} \
    CONFIG.USER_CLK_SEL_LIST0 {AXI_00_ACLK} \
    CONFIG.USER_CLK_SEL_LIST1 {AXI_16_ACLK} \
    CONFIG.USER_HBM_CP_1 {6} \
    CONFIG.USER_HBM_DENSITY {16GB} \
    CONFIG.USER_HBM_FBDIV_1 {36} \
    CONFIG.USER_HBM_HEX_CP_RES_1 {0x0000A600} \
    CONFIG.USER_HBM_HEX_FBDIV_CLKOUTDIV_1 {0x00000902} \
    CONFIG.USER_HBM_HEX_LOCK_FB_REF_DLY_1 {0x00001f1f} \
    CONFIG.USER_HBM_LOCK_FB_DLY_1 {31} \
    CONFIG.USER_HBM_LOCK_REF_DLY_1 {31} \
    CONFIG.USER_HBM_RES_1 {10} \
    CONFIG.USER_HBM_STACK {2} \
    CONFIG.USER_MC0_Q_AGE_LIMIT {0x7F} \
    CONFIG.USER_MC0_REORDER_QUEUE_EN {true} \
    CONFIG.USER_MC0_TEMP_CTRL_SELF_REF_INTVL {false} \
    CONFIG.USER_MC0_TRAFFIC_OPTION {Random} \
    CONFIG.USER_MC10_Q_AGE_LIMIT {0x7F} \
    CONFIG.USER_MC10_REORDER_QUEUE_EN {true} \
    CONFIG.USER_MC10_TEMP_CTRL_SELF_REF_INTVL {false} \
    CONFIG.USER_MC10_TRAFFIC_OPTION {Random} \
    CONFIG.USER_MC11_Q_AGE_LIMIT {0x7F} \
    CONFIG.USER_MC11_REORDER_QUEUE_EN {true} \
    CONFIG.USER_MC11_TEMP_CTRL_SELF_REF_INTVL {false} \
    CONFIG.USER_MC11_TRAFFIC_OPTION {Random} \
    CONFIG.USER_MC12_Q_AGE_LIMIT {0x7F} \
    CONFIG.USER_MC12_REORDER_QUEUE_EN {true} \
    CONFIG.USER_MC12_TEMP_CTRL_SELF_REF_INTVL {false} \
    CONFIG.USER_MC12_TRAFFIC_OPTION {Random} \
    CONFIG.USER_MC13_Q_AGE_LIMIT {0x7F} \
    CONFIG.USER_MC13_REORDER_QUEUE_EN {true} \
    CONFIG.USER_MC13_TEMP_CTRL_SELF_REF_INTVL {false} \
    CONFIG.USER_MC13_TRAFFIC_OPTION {Random} \
    CONFIG.USER_MC14_Q_AGE_LIMIT {0x7F} \
    CONFIG.USER_MC14_REORDER_QUEUE_EN {true} \
    CONFIG.USER_MC14_TEMP_CTRL_SELF_REF_INTVL {false} \
    CONFIG.USER_MC14_TRAFFIC_OPTION {Random} \
    CONFIG.USER_MC15_Q_AGE_LIMIT {0x7F} \
    CONFIG.USER_MC15_REORDER_QUEUE_EN {true} \
    CONFIG.USER_MC15_TEMP_CTRL_SELF_REF_INTVL {false} \
    CONFIG.USER_MC15_TRAFFIC_OPTION {Random} \
    CONFIG.USER_MC1_Q_AGE_LIMIT {0x7F} \
    CONFIG.USER_MC1_REORDER_QUEUE_EN {true} \
    CONFIG.USER_MC1_TEMP_CTRL_SELF_REF_INTVL {false} \
    CONFIG.USER_MC1_TRAFFIC_OPTION {Random} \
    CONFIG.USER_MC2_Q_AGE_LIMIT {0x7F} \
    CONFIG.USER_MC2_REORDER_QUEUE_EN {true} \
    CONFIG.USER_MC2_TEMP_CTRL_SELF_REF_INTVL {false} \
    CONFIG.USER_MC2_TRAFFIC_OPTION {Random} \
    CONFIG.USER_MC3_Q_AGE_LIMIT {0x7F} \
    CONFIG.USER_MC3_REORDER_QUEUE_EN {true} \
    CONFIG.USER_MC3_TEMP_CTRL_SELF_REF_INTVL {false} \
    CONFIG.USER_MC3_TRAFFIC_OPTION {Random} \
    CONFIG.USER_MC4_Q_AGE_LIMIT {0x7F} \
    CONFIG.USER_MC4_REORDER_QUEUE_EN {true} \
    CONFIG.USER_MC4_TEMP_CTRL_SELF_REF_INTVL {false} \
    CONFIG.USER_MC4_TRAFFIC_OPTION {Random} \
    CONFIG.USER_MC5_Q_AGE_LIMIT {0x7F} \
    CONFIG.USER_MC5_REORDER_QUEUE_EN {true} \
    CONFIG.USER_MC5_TEMP_CTRL_SELF_REF_INTVL {false} \
    CONFIG.USER_MC5_TRAFFIC_OPTION {Random} \
    CONFIG.USER_MC6_Q_AGE_LIMIT {0x7F} \
    CONFIG.USER_MC6_REORDER_QUEUE_EN {true} \
    CONFIG.USER_MC6_TEMP_CTRL_SELF_REF_INTVL {false} \
    CONFIG.USER_MC6_TRAFFIC_OPTION {Random} \
    CONFIG.USER_MC7_Q_AGE_LIMIT {0x7F} \
    CONFIG.USER_MC7_REORDER_QUEUE_EN {true} \
    CONFIG.USER_MC7_TEMP_CTRL_SELF_REF_INTVL {false} \
    CONFIG.USER_MC7_TRAFFIC_OPTION {Random} \
    CONFIG.USER_MC8_Q_AGE_LIMIT {0x7F} \
    CONFIG.USER_MC8_REORDER_QUEUE_EN {true} \
    CONFIG.USER_MC8_TEMP_CTRL_SELF_REF_INTVL {false} \
    CONFIG.USER_MC8_TRAFFIC_OPTION {Random} \
    CONFIG.USER_MC9_Q_AGE_LIMIT {0x7F} \
    CONFIG.USER_MC9_REORDER_QUEUE_EN {true} \
    CONFIG.USER_MC9_TEMP_CTRL_SELF_REF_INTVL {false} \
    CONFIG.USER_MC9_TRAFFIC_OPTION {Random} \
    CONFIG.USER_MC_ENABLE_01 {TRUE} \
    CONFIG.USER_MC_ENABLE_02 {TRUE} \
    CONFIG.USER_MC_ENABLE_03 {TRUE} \
    CONFIG.USER_MC_ENABLE_04 {TRUE} \
    CONFIG.USER_MC_ENABLE_05 {TRUE} \
    CONFIG.USER_MC_ENABLE_06 {TRUE} \
    CONFIG.USER_MC_ENABLE_07 {TRUE} \
    CONFIG.USER_MC_ENABLE_08 {TRUE} \
    CONFIG.USER_MC_ENABLE_09 {TRUE} \
    CONFIG.USER_MC_ENABLE_10 {TRUE} \
    CONFIG.USER_MC_ENABLE_11 {TRUE} \
    CONFIG.USER_MC_ENABLE_12 {TRUE} \
    CONFIG.USER_MC_ENABLE_13 {TRUE} \
    CONFIG.USER_MC_ENABLE_14 {TRUE} \
    CONFIG.USER_MC_ENABLE_15 {TRUE} \
    CONFIG.USER_MC_ENABLE_APB_01 {TRUE} \
    CONFIG.USER_PHY_ENABLE_08 {TRUE} \
    CONFIG.USER_PHY_ENABLE_09 {TRUE} \
    CONFIG.USER_PHY_ENABLE_10 {TRUE} \
    CONFIG.USER_PHY_ENABLE_11 {TRUE} \
    CONFIG.USER_PHY_ENABLE_12 {TRUE} \
    CONFIG.USER_PHY_ENABLE_13 {TRUE} \
    CONFIG.USER_PHY_ENABLE_14 {TRUE} \
    CONFIG.USER_PHY_ENABLE_15 {TRUE} \
    CONFIG.USER_SAXI_01 {false} \
    CONFIG.USER_SAXI_02 {false} \
    CONFIG.USER_SAXI_03 {false} \
    CONFIG.USER_SAXI_04 {false} \
    CONFIG.USER_SAXI_05 {false} \
    CONFIG.USER_SAXI_06 {false} \
    CONFIG.USER_SAXI_07 {false} \
    CONFIG.USER_SAXI_08 {false} \
    CONFIG.USER_SAXI_09 {false} \
    CONFIG.USER_SAXI_10 {false} \
    CONFIG.USER_SAXI_11 {false} \
    CONFIG.USER_SAXI_12 {false} \
    CONFIG.USER_SAXI_13 {false} \
    CONFIG.USER_SAXI_14 {false} \
    CONFIG.USER_SAXI_15 {false} \
    CONFIG.USER_SAXI_16 {true} \
    CONFIG.USER_SAXI_17 {false} \
    CONFIG.USER_SAXI_18 {false} \
    CONFIG.USER_SAXI_19 {false} \
    CONFIG.USER_SAXI_20 {false} \
    CONFIG.USER_SAXI_21 {false} \
    CONFIG.USER_SAXI_22 {false} \
    CONFIG.USER_SAXI_23 {false} \
    CONFIG.USER_SAXI_24 {false} \
    CONFIG.USER_SAXI_25 {false} \
    CONFIG.USER_SAXI_26 {false} \
    CONFIG.USER_SAXI_27 {false} \
    CONFIG.USER_SAXI_28 {false} \
    CONFIG.USER_SAXI_29 {false} \
    CONFIG.USER_SAXI_30 {false} \
    CONFIG.USER_SAXI_31 {false} \
    CONFIG.USER_SWITCH_ENABLE_00 {TRUE} \
    CONFIG.USER_SWITCH_ENABLE_01 {TRUE} \
    CONFIG.USER_XSDB_INTF_EN {TRUE} \
  ] $hbm_0


  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_0 ]
  set_property -dict [list \
    CONFIG.ADVANCED_PROPERTIES {   __view__ { clocking { SW0 { ASSOCIATED_CLK aclk1 } } }  } \
    CONFIG.NUM_CLKS {3} \
    CONFIG.NUM_MI {2} \
    CONFIG.NUM_SI {2} \
  ] $smartconnect_0


  # Create instance: system_ila_0, and set properties
  set system_ila_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:system_ila:1.1 system_ila_0 ]
  set_property -dict [list \
    CONFIG.C_MON_TYPE {INTERFACE} \
    CONFIG.C_NUM_MONITOR_SLOTS {1} \
  ] $system_ila_0


  # Create instance: xdma_0, and set properties
  set xdma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xdma:4.1 xdma_0 ]
  set_property -dict [list \
    CONFIG.PCIE_BOARD_INTERFACE {Custom} \
    CONFIG.PF0_DEVICE_ID_mqdma {903F} \
    CONFIG.PF0_SRIOV_VF_DEVICE_ID {A03F} \
    CONFIG.PF2_DEVICE_ID_mqdma {923F} \
    CONFIG.PF3_DEVICE_ID_mqdma {933F} \
    CONFIG.SYS_RST_N_BOARD_INTERFACE {pcie_perstn} \
    CONFIG.axi_data_width {512_bit} \
    CONFIG.axisten_freq {250} \
    CONFIG.cfg_mgmt_if {false} \
    CONFIG.drp_clk_sel {Internal} \
    CONFIG.mode_selection {Advanced} \
    CONFIG.pcie_blk_locn {PCIE4C_X1Y0} \
    CONFIG.pf0_Use_Class_Code_Lookup_Assistant {false} \
    CONFIG.pf0_base_class_menu {Processing_accelerators} \
    CONFIG.pf0_class_code_base {12} \
    CONFIG.pf0_class_code_interface {00} \
    CONFIG.pf0_class_code_sub {00} \
    CONFIG.pf0_device_id {903F} \
    CONFIG.pf0_sub_class_interface_menu {Unknown} \
    CONFIG.pl_link_cap_max_link_speed {8.0_GT/s} \
    CONFIG.pl_link_cap_max_link_width {X16} \
    CONFIG.plltype {QPLL1} \
    CONFIG.xdma_pcie_64bit_en {true} \
  ] $xdma_0


  # Create instance: axi4_boot_check_0, and set properties
  set block_name axi4_boot_check
  set block_cell_name axi4_boot_check_0
  if { [catch {set axi4_boot_check_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $axi4_boot_check_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property CONFIG.DATA_WIDTH {512} $axi4_boot_check_0


  # Create instance: system_ila_1, and set properties
  set system_ila_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:system_ila:1.1 system_ila_1 ]
  set_property -dict [list \
    CONFIG.C_MON_TYPE {NATIVE} \
    CONFIG.C_NUM_OF_PROBES {10} \
  ] $system_ila_1


  # Create instance: clk_wiz_0, and set properties
  set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0 ]
  set_property -dict [list \
    CONFIG.AUTO_PRIMITIVE {MMCM} \
    CONFIG.CLKOUT1_DRIVES {Buffer} \
    CONFIG.CLKOUT1_JITTER {102.484} \
    CONFIG.CLKOUT1_PHASE_ERROR {79.008} \
    CONFIG.CLKOUT2_DRIVES {Buffer} \
    CONFIG.CLKOUT2_JITTER {85.736} \
    CONFIG.CLKOUT2_PHASE_ERROR {79.008} \
    CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {250.000} \
    CONFIG.CLKOUT2_USED {true} \
    CONFIG.CLKOUT3_DRIVES {Buffer} \
    CONFIG.CLKOUT4_DRIVES {Buffer} \
    CONFIG.CLKOUT5_DRIVES {Buffer} \
    CONFIG.CLKOUT6_DRIVES {Buffer} \
    CONFIG.CLKOUT7_DRIVES {Buffer} \
    CONFIG.CLK_IN1_BOARD_INTERFACE {Custom} \
    CONFIG.CLK_IN2_BOARD_INTERFACE {Custom} \
    CONFIG.CLK_OUT1_PORT {apb_clk} \
    CONFIG.CLK_OUT2_PORT {axi_250_clk} \
    CONFIG.FEEDBACK_SOURCE {FDBK_AUTO} \
    CONFIG.MMCM_BANDWIDTH {OPTIMIZED} \
    CONFIG.MMCM_CLKFBOUT_MULT_F {5.000} \
    CONFIG.MMCM_CLKOUT0_DIVIDE_F {12.500} \
    CONFIG.MMCM_CLKOUT1_DIVIDE {5} \
    CONFIG.MMCM_COMPENSATION {AUTO} \
    CONFIG.MMCM_DIVCLK_DIVIDE {1} \
    CONFIG.NUM_OUT_CLKS {2} \
    CONFIG.OPTIMIZE_CLOCKING_STRUCTURE_EN {true} \
    CONFIG.PRIMITIVE {Auto} \
    CONFIG.PRIM_SOURCE {No_buffer} \
    CONFIG.RESET_BOARD_INTERFACE {Custom} \
    CONFIG.SECONDARY_SOURCE {Single_ended_clock_capable_pin} \
    CONFIG.USE_LOCKED {false} \
    CONFIG.USE_PHASE_ALIGNMENT {true} \
    CONFIG.USE_RESET {false} \
    CONFIG.USE_SAFE_CLOCK_STARTUP {false} \
  ] $clk_wiz_0


  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net S00_AXI_0_1 [get_bd_intf_ports S00_AXI_0] [get_bd_intf_pins smartconnect_0/S00_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins hbm_0/SAXI_00_8HI]
connect_bd_intf_net -intf_net [get_bd_intf_nets smartconnect_0_M00_AXI] [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins system_ila_0/SLOT_0_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M01_AXI [get_bd_intf_pins smartconnect_0/M01_AXI] [get_bd_intf_pins hbm_0/SAXI_16_8HI]
  connect_bd_intf_net -intf_net xdma_0_M_AXI [get_bd_intf_pins smartconnect_0/S01_AXI] [get_bd_intf_pins xdma_0/M_AXI]
  connect_bd_intf_net -intf_net xdma_0_pcie_mgt [get_bd_intf_ports pcie_mgt_0] [get_bd_intf_pins xdma_0/pcie_mgt]

  # Create port connections
  connect_bd_net -net HBM_REF_CLK_0_0_1 [get_bd_ports HBM_REF_CLK_0_0] [get_bd_pins hbm_0/HBM_REF_CLK_0] [get_bd_pins hbm_0/HBM_REF_CLK_1]
  connect_bd_net -net axi4_boot_check_0_start_o [get_bd_pins axi4_boot_check_0/start_o] [get_bd_ports master_areset_o_0]
  connect_bd_net -net axi_clk_ariane_0_1 [get_bd_ports axi_clk_ariane_0] [get_bd_pins smartconnect_0/aclk]
  connect_bd_net -net clk_wiz_0_apb_clk [get_bd_pins clk_wiz_0/apb_clk] [get_bd_pins hbm_0/APB_0_PCLK] [get_bd_pins system_ila_1/clk] [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins hbm_0/APB_1_PCLK]
  connect_bd_net -net clk_wiz_0_axi_450_clk [get_bd_pins clk_wiz_0/axi_250_clk] [get_bd_pins system_ila_0/clk] [get_bd_pins hbm_0/AXI_00_ACLK] [get_bd_pins smartconnect_0/aclk2] [get_bd_pins hbm_0/AXI_16_ACLK]
  connect_bd_net -net pcie_perstn_1 [get_bd_ports sys_rst_n_0] [get_bd_pins xdma_0/sys_rst_n] [get_bd_pins system_ila_1/probe0] [get_bd_pins proc_sys_reset_0/ext_reset_in]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins hbm_0/APB_0_PRESET_N] [get_bd_pins system_ila_1/probe1] [get_bd_pins hbm_0/APB_1_PRESET_N]
  connect_bd_net -net sys_clk_0_1 [get_bd_ports sys_clk_0] [get_bd_pins xdma_0/sys_clk]
  connect_bd_net -net sys_clk_gt_0_1 [get_bd_ports sys_clk_gt_0] [get_bd_pins xdma_0/sys_clk_gt]
  connect_bd_net -net usr_irq_req_0_1 [get_bd_ports usr_irq_req_0] [get_bd_pins xdma_0/usr_irq_req]
  connect_bd_net -net xdma_0_axi_aclk [get_bd_pins xdma_0/axi_aclk] [get_bd_pins smartconnect_0/aclk1] [get_bd_pins axi4_boot_check_0/aclk] [get_bd_pins clk_wiz_0/clk_in1]
  connect_bd_net -net xdma_0_axi_aresetn [get_bd_pins xdma_0/axi_aresetn] [get_bd_pins hbm_0/AXI_00_ARESET_N] [get_bd_pins smartconnect_0/aresetn] [get_bd_pins system_ila_0/resetn] [get_bd_pins axi4_boot_check_0/aresetn] [get_bd_pins hbm_0/AXI_16_ARESET_N]
  connect_bd_net -net xdma_0_m_axi_awaddr [get_bd_pins xdma_0/m_axi_awaddr] [get_bd_pins smartconnect_0/S01_AXI_awaddr] [get_bd_pins axi4_boot_check_0/s_axi_awaddr]
  connect_bd_net -net xdma_0_m_axi_wdata [get_bd_pins xdma_0/m_axi_wdata] [get_bd_pins smartconnect_0/S01_AXI_wdata] [get_bd_pins axi4_boot_check_0/s_axi_wdata]
  connect_bd_net -net xdma_0_m_axi_wvalid [get_bd_pins xdma_0/m_axi_wvalid] [get_bd_pins smartconnect_0/S01_AXI_wvalid] [get_bd_pins axi4_boot_check_0/s_axi_wvalid]

  # Create address segments
  assign_bd_address -offset 0x00000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM00] -force
  assign_bd_address -offset 0x20000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM01] -force
  assign_bd_address -offset 0x40000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM02] -force
  assign_bd_address -offset 0x60000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM03] -force
  assign_bd_address -offset 0x80000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM04] -force
  assign_bd_address -offset 0xA0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM05] -force
  assign_bd_address -offset 0xC0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM06] -force
  assign_bd_address -offset 0xE0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM07] -force
  assign_bd_address -offset 0x000100000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM08] -force
  assign_bd_address -offset 0x000120000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM09] -force
  assign_bd_address -offset 0x000140000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM10] -force
  assign_bd_address -offset 0x000160000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM11] -force
  assign_bd_address -offset 0x000180000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM12] -force
  assign_bd_address -offset 0x0001A0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM13] -force
  assign_bd_address -offset 0x0001C0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM14] -force
  assign_bd_address -offset 0x0001E0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM15] -force
  assign_bd_address -offset 0x000200000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM16] -force
  assign_bd_address -offset 0x000220000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM17] -force
  assign_bd_address -offset 0x000240000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM18] -force
  assign_bd_address -offset 0x000260000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM19] -force
  assign_bd_address -offset 0x000280000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM20] -force
  assign_bd_address -offset 0x0002A0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM21] -force
  assign_bd_address -offset 0x0002C0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM22] -force
  assign_bd_address -offset 0x0002E0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM23] -force
  assign_bd_address -offset 0x000300000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM24] -force
  assign_bd_address -offset 0x000320000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM25] -force
  assign_bd_address -offset 0x000340000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM26] -force
  assign_bd_address -offset 0x000360000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM27] -force
  assign_bd_address -offset 0x000380000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM28] -force
  assign_bd_address -offset 0x0003A0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM29] -force
  assign_bd_address -offset 0x0003C0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM30] -force
  assign_bd_address -offset 0x0003E0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM31] -force
  assign_bd_address -offset 0x00000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM00] -force
  assign_bd_address -offset 0x20000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM01] -force
  assign_bd_address -offset 0x40000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM02] -force
  assign_bd_address -offset 0x60000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM03] -force

  # Exclude Address Segments
  exclude_bd_addr_seg -offset 0x00000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM00]
  exclude_bd_addr_seg -offset 0x20000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM01]
  exclude_bd_addr_seg -offset 0x40000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM02]
  exclude_bd_addr_seg -offset 0x60000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM03]
  exclude_bd_addr_seg -offset 0x80000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM04]
  exclude_bd_addr_seg -offset 0x80000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM04]
  exclude_bd_addr_seg -offset 0xA0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM05]
  exclude_bd_addr_seg -offset 0xA0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM05]
  exclude_bd_addr_seg -offset 0xC0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM06]
  exclude_bd_addr_seg -offset 0xC0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM06]
  exclude_bd_addr_seg -offset 0xE0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM07]
  exclude_bd_addr_seg -offset 0xE0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM07]
  exclude_bd_addr_seg -offset 0x000100000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM08]
  exclude_bd_addr_seg -offset 0x000100000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM08]
  exclude_bd_addr_seg -offset 0x000120000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM09]
  exclude_bd_addr_seg -offset 0x000120000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM09]
  exclude_bd_addr_seg -offset 0x000140000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM10]
  exclude_bd_addr_seg -offset 0x000140000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM10]
  exclude_bd_addr_seg -offset 0x000160000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM11]
  exclude_bd_addr_seg -offset 0x000160000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM11]
  exclude_bd_addr_seg -offset 0x000180000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM12]
  exclude_bd_addr_seg -offset 0x000180000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM12]
  exclude_bd_addr_seg -offset 0x0001A0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM13]
  exclude_bd_addr_seg -offset 0x0001A0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM13]
  exclude_bd_addr_seg -offset 0x0001C0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM14]
  exclude_bd_addr_seg -offset 0x0001C0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM14]
  exclude_bd_addr_seg -offset 0x0001E0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM15]
  exclude_bd_addr_seg -offset 0x0001E0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM15]
  exclude_bd_addr_seg -offset 0x000200000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM16]
  exclude_bd_addr_seg -offset 0x000200000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM16]
  exclude_bd_addr_seg -offset 0x000220000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM17]
  exclude_bd_addr_seg -offset 0x000220000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM17]
  exclude_bd_addr_seg -offset 0x000240000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM18]
  exclude_bd_addr_seg -offset 0x000240000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM18]
  exclude_bd_addr_seg -offset 0x000260000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM19]
  exclude_bd_addr_seg -offset 0x000260000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM19]
  exclude_bd_addr_seg -offset 0x000280000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM20]
  exclude_bd_addr_seg -offset 0x000280000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM20]
  exclude_bd_addr_seg -offset 0x0002A0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM21]
  exclude_bd_addr_seg -offset 0x0002A0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM21]
  exclude_bd_addr_seg -offset 0x0002C0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM22]
  exclude_bd_addr_seg -offset 0x0002C0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM22]
  exclude_bd_addr_seg -offset 0x0002E0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM23]
  exclude_bd_addr_seg -offset 0x0002E0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM23]
  exclude_bd_addr_seg -offset 0x000300000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM24]
  exclude_bd_addr_seg -offset 0x000300000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM24]
  exclude_bd_addr_seg -offset 0x000320000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM25]
  exclude_bd_addr_seg -offset 0x000320000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM25]
  exclude_bd_addr_seg -offset 0x000340000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM26]
  exclude_bd_addr_seg -offset 0x000340000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM26]
  exclude_bd_addr_seg -offset 0x000360000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM27]
  exclude_bd_addr_seg -offset 0x000360000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM27]
  exclude_bd_addr_seg -offset 0x000380000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM28]
  exclude_bd_addr_seg -offset 0x000380000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM28]
  exclude_bd_addr_seg -offset 0x0003A0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM29]
  exclude_bd_addr_seg -offset 0x0003A0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM29]
  exclude_bd_addr_seg -offset 0x0003C0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM30]
  exclude_bd_addr_seg -offset 0x0003C0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM30]
  exclude_bd_addr_seg -offset 0x0003E0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM31]
  exclude_bd_addr_seg -offset 0x0003E0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM31]
  exclude_bd_addr_seg -offset 0x00000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM00]
  exclude_bd_addr_seg -offset 0x000420000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM01]
  exclude_bd_addr_seg -offset 0x000440000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM02]
  exclude_bd_addr_seg -offset 0x000460000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM03]
  exclude_bd_addr_seg -offset 0x000480000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM04]
  exclude_bd_addr_seg -offset 0x0004A0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM05]
  exclude_bd_addr_seg -offset 0x0004C0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM06]
  exclude_bd_addr_seg -offset 0x0004E0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM07]
  exclude_bd_addr_seg -offset 0x000500000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM08]
  exclude_bd_addr_seg -offset 0x000520000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM09]
  exclude_bd_addr_seg -offset 0x000540000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM10]
  exclude_bd_addr_seg -offset 0x000560000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM11]
  exclude_bd_addr_seg -offset 0x000580000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM12]
  exclude_bd_addr_seg -offset 0x0005A0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM13]
  exclude_bd_addr_seg -offset 0x0005C0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM14]
  exclude_bd_addr_seg -offset 0x0005E0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_16_8HI/HBM_MEM15]
  exclude_bd_addr_seg -offset 0x000600000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM16]
  exclude_bd_addr_seg -offset 0x000620000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM17]
  exclude_bd_addr_seg -offset 0x000640000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM18]
  exclude_bd_addr_seg -offset 0x000660000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM19]
  exclude_bd_addr_seg -offset 0x000680000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM20]
  exclude_bd_addr_seg -offset 0x0006A0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM21]
  exclude_bd_addr_seg -offset 0x0006C0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM22]
  exclude_bd_addr_seg -offset 0x0006E0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM23]
  exclude_bd_addr_seg -offset 0x000700000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM24]
  exclude_bd_addr_seg -offset 0x000720000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM25]
  exclude_bd_addr_seg -offset 0x000740000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM26]
  exclude_bd_addr_seg -offset 0x000760000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM27]
  exclude_bd_addr_seg -offset 0x000780000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM28]
  exclude_bd_addr_seg -offset 0x0007A0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM29]
  exclude_bd_addr_seg -offset 0x0007C0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM30]
  exclude_bd_addr_seg -offset 0x0007E0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00_8HI/HBM_MEM31]


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


