// user-defined data structured

`ifndef DATATYPE_SV
`define DATATYPE_SV

`define TEXT_RAM_ADDRESS_WIDTH 6
`define TEXT_RAM_DATA_WIDTH 1280
`define SRAM_ADDRESS_WIDTH 20
`define SRAM_DATA_WIDTH 32

typedef struct packed{
	logic   [`TEXT_RAM_ADDRESS_WIDTH - 1:0] address;
	logic   [`TEXT_RAM_DATA_WIDTH - 1:0]    data;
	logic	wren;
} TextRamRequest_t;

typedef logic [`TEXT_RAM_DATA_WIDTH - 1:0] TextRamResult_t;

typedef struct packed{
    logic        hSync;
    logic        vSync;
    logic [2:0]  red;
    logic [2:0]  green;
    logic [2:0]  blue;
} VgaSignal_t;

typedef struct packed{
    logic [`SRAM_ADDRESS_WIDTH - 1:0] address;
    logic cs;
    logic oe;
    logic we;
} SramRequest_t;

typedef logic [`SRAM_DATA_WIDTH - 1:0] SramData_t;

`endif