module TextRenderer(
    input clk,
    input rst,
    input [CONSOLE_LINES * CONSOLE_COLUMNS * 8 - 1:0] text,
    input [CONSOLE_LINES * CONSOLE_COLUMNS * COLOR_NUMBERS:0] color,
    input [15:0] cursorPosition,
    input [3:0]  cursorStates
);

typedef enum logic[1:0]{
    RENDER_INIT, RENDER_INPROCESS, RENDER_WAIT_FOR_FONT, RENDER_DONE
} RenderState;

typedef enum logic[2:0]{
    CURSOR_BLINKING, CURSOR_INVISIBLE, CURSOR_PERSISTENT
} CursorState;

// read from ROM
// write to sram

parameter CONSOLE_LINES = 24;
parameter CONSOLE_COLUMNS = 80;
parameter COLOR_NUMBERS = 4;

endmodule // TextRenderer