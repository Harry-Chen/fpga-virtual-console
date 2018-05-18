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

`define COLOR_NUMBERS_BITS 3
`define CONSOLE_LINES 40
`define CONSOLE_COLUMNS 80
`define HEIGHT_PER_CHARACTER 12
`define WIDTH_PER_CHARACTER 8
`define PIXEL_PER_CHARACTER `HEIGHT_PER_CHARACTER * `WIDTH_PER_CHARACTER

`define VIDEO_BUFFER_SIZE 307200

// vga signal
typedef struct packed {
    logic [2:0]  red;
    logic [2:0]  green;
    logic [2:0]  blue;
} VgaColor_t;

typedef struct packed {
    logic        hSync;
    logic        vSync;
    VgaColor_t   color;
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


// char on screen
typedef struct packed {
    VgaColor_t color;
    logic [$bits(SramData_t) - $bits(VgaColor_t) - 1:0] placeholder;
} Pixel_t;

typedef struct packed {
    logic   [`PIXEL_PER_CHARACTER - 1:0]shape;
    Pixel_t foreground;
    Pixel_t background;
} CharGrid_t;


typedef enum logic[7:0] {
	START, ESC, BRACKET, PN1, PN2, DEL1
} CommandsState;

typedef enum logic[7:0] {
	INPUT,
	CUP, CUU, CUD, CUF, CUB, IND, NEL, RI
} CommandsType;

`endif
