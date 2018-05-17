// user-defined data structured

`ifndef DATATYPE_SV
`define DATATYPE_SV

`define TEXT_RAM_ADDRESS_WIDTH 6
`define TEXT_RAM_DATA_WIDTH 1280

typedef struct packed{
	logic    [`TEXT_RAM_ADDRESS_WIDTH - 1:0] address;
	logic	[`TEXT_RAM_DATA_WIDTH - 1:0]    data;
	logic	wren;
} TextRamRequest_t;

typedef struct packed{
    logic    [`TEXT_RAM_DATA_WIDTH - 1:0]    q;
} TextRamResult_t;

typedef struct packed{
    logic        hSync;
    logic        vSync;
    logic [2:0]  red;
    logic [2:0]  green;
    logic [2:0]  blue;
} VgaSignal_t;

`endif