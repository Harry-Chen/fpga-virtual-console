// user-defined data structured
`ifndef DATATYPE_SV
`define DATATYPE_SV

// constants
`define TEXT_RAM_ADDRESS_WIDTH 6
`define TEXT_RAM_DATA_WIDTH 1280

`define FONT_ROM_ADDRESS_WIDTH 8
`define FONT_ROM_DATA_WIDTH 96

`define SRAM_ADDRESS_WIDTH 20
`define SRAM_DATA_WIDTH 32


// vga signal
typedef struct packed {
    logic        hSync;
    logic        vSync;
    logic [2:0]  red;
    logic [2:0]  green;
    logic [2:0]  blue;
} VgaSignal_t;


// text ram read/write
typedef logic [`TEXT_RAM_DATA_WIDTH - 1:0] TextRamData_t;
typedef logic [`TEXT_RAM_ADDRESS_WIDTH - 1:0] TextRamAddress_t;

typedef struct packed {
	TextRamAddress_t address;
	TextRamData_t    data;
	logic	wren;
} TextRamRequest_t;

typedef TextRamData_t TextRamResult_t;


// font rom read
typedef logic [`FONT_ROM_DATA_WIDTH - 1:0] FontRomData_t;
typedef logic [`FONT_ROM_ADDRESS_WIDTH - 1:0] FontRomAddress_t;


// sram read/write
typedef logic [`SRAM_ADDRESS_WIDTH - 1:0] SramAddress_t;
typedef logic [`SRAM_DATA_WIDTH - 1:0] SramData_t;

typedef struct packed {
    SramAddress_t address;
    logic cs;
    logic oe_n;
    logic we_n;
} SramInterface_t;

typedef struct packed {
    SramData_t dout;
    logic den;
    SramAddress_t address;
    logic oe_n;
    logic we_n;
} SramRequest_t;

typedef struct packed {
    SramData_t din;
    logic done;
} SramResult_t;


typedef enum logic[7:0] {
	START, ESC, BRACKET, PN1, PN2, DEL1
} CommandsState;

typedef enum logic[7:0] {
	INPUT,
	CUP, CUU, CUD, CUF, CUB, IND, NEL, RI
} CommandsType;

`endif
