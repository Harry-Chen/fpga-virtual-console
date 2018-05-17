module TextRenderer(
    input   clk,
    input   rst,
    input   paintDone,
    input   SramResult_t  ramResult,
    output  SramRequest_t ramRequest,
    output  SramAddress_t vgaBaseAddress,
    output  TextRamRequest_t textRamRequest,
    input   TextRamResult_t  textRamResult
    //input [15:0] cursorPosition,
    //input [3:0]  cursorStates
);

parameter CONSOLE_LINES = 24;
parameter CONSOLE_COLUMNS = 80;
parameter COLOR_NUMBERS_BITS = 4;
parameter HEIGHT_PER_CHARACTER = 12;
parameter WIDTH_PER_CHARACTER = 8;

typedef enum logic[1:0]{
    RENDER_INIT, RENDER_INPROCESS, RENDER_WAIT_FOR_FONT, RENDER_DONE
} RenderState;

typedef enum logic[1:0]{
    CURSOR_BLINKING, CURSOR_INVISIBLE, CURSOR_PERSISTENT
} CursorState;

assign ramRequest.oe_n = 1;
assign ramRequest.we_n = 0;
assign ramRequest.den = 1;
assign ramRequest.address = 0;
assign ramRequest.dout = {32{1'b1}};

// read from ROM
// write to sram

// logic [7:0] charToRender;
// logic [COLOR_NUMBERS_BITS - 1:0] currentForegroundColor, currentBackgroundColor;
// logic [HEIGHT_PER_CHARACTER * WIDTH_PER_CHARACTER - 1:0] currentFontColorR, currentFontColorG, currentFontColorB;

// FontShapeRenderer #(
//     .COLOR_NUMBERS_BITS(COLOR_NUMBERS_BITS),
//     .HEIGHT_PER_CHARACTER(20),
//     .WIDTH_PER_CHARACTER(8)
// ) fontRenderer (
//     .clk(clk),
//     .rst(rst),
//     .char(charToRender),
//     .foregroundColor(currentForegroundColor),
//     .backgroundColor(currentBackgroundColor),
//     .fontColorR(currentFontColorR),
//     .fontColorG(currentFontColorG),
//     .fontColorB(currentFontColorB)
// );

endmodule // TextRenderer