module TextRenderer(
    input clk,
    input rst,
    input [CONSOLE_LINES * CONSOLE_COLUMNS * 8 - 1:0] text,
    input [CONSOLE_LINES * CONSOLE_COLUMNS * COLOR_NUMBERS_BITS:0] foregroundColor,
    input [CONSOLE_LINES * CONSOLE_COLUMNS * COLOR_NUMBERS_BITS:0] backgroundColor,
    input [15:0] cursorPosition,
    input [3:0]  cursorStates
);

parameter CONSOLE_LINES = 24;
parameter CONSOLE_COLUMNS = 80;
parameter COLOR_NUMBERS_BITS = 4;
parameter HEIGHT_PER_CHARACTER = 20;
parameter WIDTH_PER_CHARACTER = 8;

typedef enum logic[1:0]{
    RENDER_INIT, RENDER_INPROCESS, RENDER_WAIT_FOR_FONT, RENDER_DONE
} RenderState;

typedef enum logic[2:0]{
    CURSOR_BLINKING, CURSOR_INVISIBLE, CURSOR_PERSISTENT
} CursorState;

// read from ROM
// write to sram

logic [7:0] charToRender
logic [COLOR_NUMBERS_BITS - 1:0] currentForegroundColor, currentBackgroundColor;
logic [HEIGHT_PER_CHARACTER * WIDTH_PER_CHARACTER - 1:0] currentFontColorR, currentFontColorG, currentFontColorB;

FontShapeRenderer #(
    .COLOR_NUMBERS_BITS(COLOR_NUMBERS_BITS),
    .HEIGHT_PER_CHARACTER(20)
    .WIDTH_PER_CHARACTER(8)
) fontRenderer (
    .clk(clk),
    .rst(rst),
    .char(charToRender),
    .foregroundColor(currentForegroundColor),
    .backgroundColor(currentBackgroundColor);
    .fontColorR(currentFontColorR);
    .fontColorG(currentFontColorG);
    .fontColorB(currentFontColorB);
)

endmodule // TextRenderer