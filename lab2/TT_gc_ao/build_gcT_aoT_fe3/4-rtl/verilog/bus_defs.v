`define DATAWORD_WIDTH 32
`define DATAWORD_MSB 31
//==============================================================================
// Internal Bus BVCI Widths & Constants
// ====================================
`define IBUS_ADDR_WIDTH 32
`define IBUS_ADDR_MSB (`IBUS_ADDR_WIDTH - 1)
`define IBUS_BE_WIDTH 8
`define IBUS_BE_MSB (`IBUS_BE_WIDTH - 1)
`define IBUS_DATA_WIDTH 64
`define IBUS_DATA_MSB (`IBUS_DATA_WIDTH - 1)
`define IBUS_PLEN_WIDTH 9
`define IBUS_PLEN_MSB (`IBUS_PLEN_WIDTH - 1)

//==============================================================================
// GENERAL BVCI Constants
// ======================
`define BVCI_CMD_WIDTH 2
`define BVCI_CMD_MSB   (`BVCI_CMD_WIDTH - 1)
//removed- see STAR 9000528193
//`define BVCI_CMD_NOP   2'b00
//`define BVCI_CMD_READ  2'b01
//`define BVCI_CMD_WRITE 2'b10
`define BVCI_CMD_LCKRD 2'b11

//==============================================================================
// SYSTEM BVCI bus Constants
// ======================
`define SYSBUS_ADDR_WIDTH 32
`define SYSBUS_ADDR_MSB (`SYSBUS_ADDR_WIDTH - 1)
`define SYSBUS_BE_WIDTH 4
`define SYSBUS_BE_MSB (`SYSBUS_BE_WIDTH - 1)
`define SYSBUS_DATA_WIDTH 32
`define SYSBUS_DATA_MSB (`SYSBUS_DATA_WIDTH - 1)
// Not required for single-core AHB sub-systems but used
// in multicore-systems where the bvci initiators come out of the cpu isles
// and are N:1 arbitrated before being converted to ahb.
`define SYSBUS_PLEN_WIDTH 9
`define SYSBUS_PLEN_MSB (`SYSBUS_PLEN_WIDTH - 1)

