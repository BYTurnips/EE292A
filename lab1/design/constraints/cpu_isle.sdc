# CONFIDENTIAL AND PROPRIETARY INFORMATION
# Copyright 2003-2005 ARC International (Unpublished)
# All Rights Reserved.
#
# This document, material and/or software contains confidential
# and proprietary information of ARC International and is
# protected by copyright, trade secret and other state, federal,
# and international laws, and may be embodied in patents issued
# or pending.  Its receipt or possession does not convey any
# rights to use, reproduce, disclose its contents, or to
# manufacture, or sell anything it may describe.  Reverse
# engineering is prohibited, and reproduction, disclosure or use
# without specific written authorization of ARC International is
# strictly forbidden.  ARC and the ARC logotype are trademarks of
# ARC International.
#
# ARC Product:  @@PRODUCT_NAME@@ v@@VERSION_NUMBER@@
# File version: $Revision$
# ARC Chip ID:  0
#
# Description:
#
# This is the constraints to be used for synthesis.
# 
#--------------------------------------------------------------------
#------------------------------------------------------------------------------
# Clock Definitons
#------------------------------------------------------------------------------

# Sweeping values for local and system clock periods (ratio is 1:1)

# Clock period for main clock
# set arc_local_clock_period 100
# set arc_local_clock_period 20
# set arc_local_clock_period 10
# set arc_local_clock_period 8
# set arc_local_clock_period 5
set arc_local_clock_period 2


# Clock period for external system clock                                 
# set  arc_system_clock_period 100
# set  arc_system_clock_period 20
# set  arc_system_clock_period 10
# set  arc_system_clock_period 8
# set  arc_system_clock_period 5
set  arc_system_clock_period 2


# Clock uncertainty	
set arc_clock_skew  0.2

# Clock uncertainty for system clock, since system and cpu clocks are 
# synchronous, the skew figure is the same
set arc_sys_clock_skew  $arc_clock_skew


# Default maximum edge rate should not exceed 1/4 clk frq also see vendor req.
set arc_max_transition                  [expr $arc_local_clock_period / 4.0]     


# Margin used for hold time fixing
set arc_sys_clock_hold_margin  0.05

# Clock edge rate at each sequential element
# This is slope on input clock pin during initial synthesis. Should be non-zero value
# for more realistic driving of clock pins on flops and memories so as to give better alignment with backend results. 

set arc_clock_transition  0.2	        
# JTAG Clock period 
set arc_jtag_clock_period 100 

create_clock -period $arc_local_clock_period -name clk_in [get_ports -hier {clk_in}]
set_drive 0 [get_clocks {clk_in}]
set_clock_uncertainty -setup $arc_sys_clock_skew [get_clocks {clk_in}]
set_clock_uncertainty -hold  $arc_sys_clock_hold_margin [get_clocks {clk_in}]
set_clock_uncertainty -setup [expr $arc_sys_clock_skew + 0.05 * $arc_local_clock_period] -rise_from [get_clocks {clk_in}] -fall_to [get_clocks {clk_in}]
set_clock_uncertainty -setup [expr $arc_sys_clock_skew + 0.05 * $arc_local_clock_period] -fall_from [get_clocks {clk_in}] -rise_to [get_clocks {clk_in}]
set_clock_transition $arc_clock_transition [get_clocks {clk_in}]
set_ideal_network [get_clocks {clk_in}]

create_clock -period $arc_system_clock_period -name clk_system_in [get_ports -hier {clk_system_in}]
set_drive 0 [get_clocks {clk_system_in}]
set_clock_uncertainty -setup $arc_sys_clock_skew [get_clocks {clk_system_in}]
set_clock_uncertainty -hold  $arc_sys_clock_hold_margin [get_clocks {clk_system_in}]
set_clock_uncertainty -setup [expr $arc_sys_clock_skew + 0.05 * $arc_system_clock_period] -rise_from [get_clocks {clk_system_in}] -fall_to [get_clocks {clk_system_in}]
set_clock_uncertainty -setup [expr $arc_sys_clock_skew + 0.05 * $arc_system_clock_period] -fall_from [get_clocks {clk_system_in}] -rise_to [get_clocks {clk_system_in}]
set_clock_transition $arc_clock_transition [get_clocks {clk_system_in}]
set_ideal_network [get_clocks {clk_system_in}]

create_clock -period $arc_system_clock_period -name hclk [get_ports -hier {hclk}]
set_drive 0 [get_clocks {hclk}]
set_clock_uncertainty -setup $arc_sys_clock_skew [get_clocks {hclk}]
set_clock_uncertainty -hold  $arc_sys_clock_hold_margin [get_clocks {hclk}]
set_clock_uncertainty -setup [expr $arc_sys_clock_skew + 0.05 * $arc_system_clock_period] -rise_from [get_clocks {hclk}] -fall_to [get_clocks {hclk}]
set_clock_uncertainty -setup [expr $arc_sys_clock_skew + 0.05 * $arc_system_clock_period] -fall_from [get_clocks {hclk}] -rise_to [get_clocks {hclk}]
set_clock_transition $arc_clock_transition [get_clocks {hclk}]
set_ideal_network [get_clocks {hclk}]

create_clock -period $arc_jtag_clock_period -name jtag_tck [get_ports -hier {jtag_tck}]
set_drive 0 [get_clocks {jtag_tck}]
set_clock_uncertainty -setup $arc_sys_clock_skew [get_clocks {jtag_tck}]
set_clock_uncertainty -hold  $arc_sys_clock_hold_margin [get_clocks {jtag_tck}]
set_clock_uncertainty -setup [expr $arc_sys_clock_skew + 0.05 * $arc_jtag_clock_period] -rise_from [get_clocks {jtag_tck}] -fall_to [get_clocks {jtag_tck}]
set_clock_uncertainty -setup [expr $arc_sys_clock_skew + 0.05 * $arc_jtag_clock_period] -fall_from [get_clocks {jtag_tck}] -rise_to [get_clocks {jtag_tck}]
set_clock_transition $arc_clock_transition [get_clocks {jtag_tck}]
set_ideal_network [get_clocks {jtag_tck}]

set_false_path -from [get_clocks {clk_in}] -to [get_clocks {jtag_tck}]
set_false_path -from [get_clocks {jtag_tck}] -to [get_clocks {clk_in}]
set_false_path -from [get_clocks {clk_system_in}] -to [get_clocks {jtag_tck}]
set_false_path -from [get_clocks {jtag_tck}] -to [get_clocks {clk_system_in}]
set_false_path -from [get_clocks {hclk}] -to [get_clocks {jtag_tck}]
set_false_path -from [get_clocks {jtag_tck}] -to [get_clocks {hclk}]



# -----------------------------------------------------------------------------
# Define Input and Output constraints
# -----------------------------------------------------------------------------

# ----------------------------------------------------------------------
# ARC600 Constraints
# ----------------------------------------------------------------------
# ----------------------------------------------------------------------
# AHB Constraints
# ----------------------------------------------------------------------
set_input_delay [expr $arc_system_clock_period * 0.3 ] -clock [get_clocks {hclk}] [get_ports {hready} -filter {@port_direction == in}]

set_input_delay [expr $arc_system_clock_period * 0.3 ] -clock [get_clocks {hclk}] [get_ports {hresetn} -filter {@port_direction == in}]

set_input_delay [expr $arc_system_clock_period * 0.3 ] -clock [get_clocks {hclk}] [get_ports {hresp*} -filter {@port_direction == in}]

set_input_delay [expr $arc_system_clock_period * 0.3 ] -clock [get_clocks {hclk}] [get_ports {hrdata*} -filter {@port_direction == in}]

set_input_delay [expr $arc_system_clock_period * 0.3 ] -clock [get_clocks {hclk}] [get_ports {hgrant} -filter {@port_direction == in}]

set_output_delay [expr $arc_system_clock_period * 0.3 ] -clock [get_clocks {hclk}] [get_ports haddr* -filter {@port_direction == out}]

set_output_delay [expr $arc_system_clock_period * 0.3 ] -clock [get_clocks {hclk}] [get_ports hburst* -filter {@port_direction == out}]

set_output_delay [expr $arc_system_clock_period * 0.3 ] -clock [get_clocks {hclk}] [get_ports hbusreq -filter {@port_direction == out}]

set_output_delay [expr $arc_system_clock_period * 0.3 ] -clock [get_clocks {hclk}] [get_ports hsize* -filter {@port_direction == out}]

set_output_delay [expr $arc_system_clock_period * 0.3 ] -clock [get_clocks {hclk}] [get_ports htrans* -filter {@port_direction == out}]

set_output_delay [expr $arc_system_clock_period * 0.3 ] -clock [get_clocks {hclk}] [get_ports hwdata* -filter {@port_direction == out}]

set_output_delay [expr $arc_system_clock_period * 0.3 ] -clock [get_clocks {hclk}] [get_ports hwrite -filter {@port_direction == out}]

set_output_delay [expr $arc_system_clock_period * 0.3 ] -clock [get_clocks {hclk}] [get_ports hlock -filter {@port_direction == out}]

set_output_delay [expr $arc_system_clock_period * 0.3 ] -clock [get_clocks {hclk}] [get_ports hprot* -filter {@port_direction == out}]

set_input_delay [expr $arc_local_clock_period * 0.25 ] -clock [get_clocks {clk_in}] [get_ports {*irq*} -filter {@port_direction == in}]

set_input_delay [expr $arc_local_clock_period * 0.25 ] -clock [get_clocks {clk_in}] [get_ports {ctrl_cpu_start} -filter {@port_direction == in}]

set_input_delay [expr $arc_local_clock_period * 0.25 ] -clock [get_clocks {clk_in}] [get_ports {test_mode} -filter {@port_direction == in}]

set_input_delay [expr $arc_local_clock_period * 0.25 ] -clock [get_clocks {clk_in}] [get_ports {arc_start_a} -filter {@port_direction == in}]

set_output_delay [expr $arc_local_clock_period * 0.25 ] -clock [get_clocks {clk_in}] [get_ports power_toggle -filter {@port_direction == out}]

set_output_delay [expr $arc_local_clock_period * 0.25 ] -clock [get_clocks {clk_in}] [get_ports en -filter {@port_direction == out}]

set_output_delay [expr $arc_local_clock_period * 0.25 ] -clock [get_clocks {clk_in}] [get_ports jtag_tdo_zen_n -filter {@port_direction == out}]

# ----------------------------------------------------------------------
# DCCM DMI Constraints
# ----------------------------------------------------------------------
set_input_delay [expr $arc_local_clock_period * 0.25 ] -clock [get_clocks {clk_in}] [get_ports {ldst_dmi_req} -filter {@port_direction == in}]

set_input_delay [expr $arc_local_clock_period * 0.25 ] -clock [get_clocks {clk_in}] [get_ports {ldst_dmi_addr*} -filter {@port_direction == in}]

set_input_delay [expr $arc_local_clock_period * 0.25 ] -clock [get_clocks {clk_in}] [get_ports {ldst_dmi_wdata*} -filter {@port_direction == in}]

set_input_delay [expr $arc_local_clock_period * 0.25 ] -clock [get_clocks {clk_in}] [get_ports {ldst_dmi_wr} -filter {@port_direction == in}]

set_input_delay [expr $arc_local_clock_period * 0.25 ] -clock [get_clocks {clk_in}] [get_ports {ldst_dmi_be*} -filter {@port_direction == in}]

set_output_delay [expr $arc_local_clock_period * 0.25 ] -clock [get_clocks {clk_in}] [get_ports ldst_dmi_rdata* -filter {@port_direction == out}]

# ----------------------------------------------------------------------
# ICCM DMI Constraints
# ----------------------------------------------------------------------
set_input_delay [expr $arc_local_clock_period * 0.25 ] -clock [get_clocks {clk_in}] [get_ports {code_dmi_req} -filter {@port_direction == in}]

set_input_delay [expr $arc_local_clock_period * 0.25 ] -clock [get_clocks {clk_in}] [get_ports {code_dmi_addr*} -filter {@port_direction == in}]

set_input_delay [expr $arc_local_clock_period * 0.25 ] -clock [get_clocks {clk_in}] [get_ports {code_dmi_wdata*} -filter {@port_direction == in}]

set_input_delay [expr $arc_local_clock_period * 0.25 ] -clock [get_clocks {clk_in}] [get_ports {code_dmi_wr} -filter {@port_direction == in}]

set_input_delay [expr $arc_local_clock_period * 0.25 ] -clock [get_clocks {clk_in}] [get_ports {code_dmi_be*} -filter {@port_direction == in}]

set_output_delay [expr $arc_local_clock_period * 0.25 ] -clock [get_clocks {clk_in}] [get_ports code_dmi_rdata* -filter {@port_direction == out}]

# ----------------------------------------------------------------------
# JTAG Constraints
# ----------------------------------------------------------------------
set_input_delay [expr $arc_jtag_clock_period * 0.1] -clock [get_clocks {jtag*_tck}] [get_ports {jtag*} -filter {@port_direction == in && @name !~ jtag*_tck}]

set_output_delay [expr $arc_jtag_clock_period * 0.1] -clock [get_clocks {jtag*_tck}] [get_ports jtag* -filter {@port_direction == out}]



#------------------------------------------------------------------------------
# False Paths
#------------------------------------------------------------------------------

set_false_path -from [get_ports {arc_start_a}] 


# -----------------------------------------------------------------------------
# Multicycle paths
# -----------------------------------------------------------------------------

set bus_inputs [get_ports {*merged_ahb_* haddr hburst hbusreq hgrant hlock hprot hrdata hready hresp hsize htrans hwdata hwrite} -filter "@port_direction == in"]
set_multicycle_path -setup 4 -from $bus_inputs -to [get_clocks {clk_in}]
set_multicycle_path -hold -end 3 -from $bus_inputs -to [get_clocks {clk_in}]


#------------------------------------------------------------------------------
# Case Analysis
#------------------------------------------------------------------------------

set_case_analysis 0 [get_ports {test_mode}] 

