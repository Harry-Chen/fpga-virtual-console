`include "DataType.svh"

module TextRenderer(
    input   clk,
    input   rst,
    input   paintDone,
    input   SramResult_t  ramResult,
    output  SramRequest_t ramRequest,
    output  SramAddress_t vgaBaseAddress,
    output  TextRamRequest_t textRamRequest,
    input   TextRamResult_t  textRamResult,
    output  FontRomAddress_t fontRomAddress,
    input   FontRomData_t    fontRomData,
    output  [15:0]           nowRendering,
    input   Cursor_t         cursor
);

    // debug
    assign nowRendering = currentLine[16 * nextColumn +: 16];


    typedef enum logic[2:0]{
        STATE_INIT, STATE_READ_TEXT, STATE_READ_FONT, STATE_WAIT_FOR_RENDER, STATE_DONE
    } TextRendererState_t;

    TextRendererState_t currentState, nextState;
    logic [6:0] nextColumn, column;
    logic [5:0] nextLine, line;

    // typedef enum logic[1:0]{
    //     CURSOR_BLINKING, CURSOR_INVISIBLE, CURSOR_PERSISTENT
    // } CursorState_t;

    logic subRendererDone;
    logic vgaRam;
    SramAddress_t subRendererBaseAddress;
    SramAddress_t renderBaseAddress;
    TextRamResult_t lineData, currentLine;
    CharGrid_t currentCharGrid;
    

    assign textRamRequest.wren = 0;

    assign vgaBaseAddress = vgaRam ? 0 : `VIDEO_BUFFER_SIZE;
    assign renderBaseAddress = vgaRam ? `VIDEO_BUFFER_SIZE : 0;
    assign subRendererBaseAddress = renderBaseAddress + line * `CONSOLE_COLUMNS * `PIXEL_PER_CHARACTER + column * `WIDTH_PER_CHARACTER;
    assign currentLine = currentState == STATE_READ_TEXT ? textRamResult : lineData;


    Pixel_t foregroundColor, backgroundColor;
    assign foregroundColor = currentLine[`TEXT_RAM_CHAR_WIDTH * column + `CHAR_FOREGROUND_OFFSET +: `CHAR_FOREGROUND_LENGTH];
    assign backgroundColor = currentLine[`TEXT_RAM_CHAR_WIDTH * column + `CHAR_BACKGROUND_OFFSET +: `CHAR_BACKGROUND_LENGTH];

    CharEffect_t effect;
    assign effect = currentLine[`TEXT_RAM_CHAR_WIDTH * column + `CHAR_EFFECT_OFFSET +: `CHAR_EFFECT_LENGTH];

    logic currentCursor;
    assign currentCursor = line == cursor.x & column == cursor.y & cursor.visible;

    assign currentCharGrid.foreground = foregroundColor;
    assign currentCharGrid.background = backgroundColor;
    assign currentCharGrid.shape = fontRomData;

    logic fontReady;

    FontShapeRenderer subRenderer(
        .clk,
        .rst,
        .fontReady,
        .grid(currentCharGrid),
        .baseAddress(subRendererBaseAddress),
        .ramRequest,
        .ramResult,
        .effect,
        .currentCursor,
        .done(subRendererDone)
    );

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            vgaRam <= 0;
            currentState <= STATE_INIT;
            column <= 0;
            line <= 0;
        end else begin
            column <= nextColumn;
            line <= nextLine;
            currentState <= nextState;
            if (currentState == STATE_READ_TEXT) begin
                lineData <= textRamResult;
            end
            if (currentState == STATE_INIT) begin
                vgaRam <= ~vgaRam;
            end
        end
    end

    always_comb begin
        textRamRequest.address = 0;
        fontRomAddress = 0;
        nextColumn = 0;
        nextLine = 0;
        fontReady = 0;
        
        unique case(currentState)
            STATE_INIT: begin
                textRamRequest.address = 0;
                nextState = STATE_READ_TEXT;
            end
            STATE_READ_TEXT: begin
                nextLine = line;
                nextColumn = column;
                fontRomAddress = currentLine[0 +: 8];
                nextState = STATE_READ_FONT;
                fontReady = 1;
            end
            STATE_READ_FONT: begin
                nextLine = line;
                nextColumn = column;
                nextState = STATE_WAIT_FOR_RENDER;
            end
            STATE_WAIT_FOR_RENDER: begin
                nextState = STATE_WAIT_FOR_RENDER;
                if (subRendererDone) begin
                    if(column == `CONSOLE_COLUMNS - 1) begin
                        nextColumn = 0;
                        if (line == `CONSOLE_LINES - 1) begin
                            nextLine = 0;
                            nextState = STATE_DONE;
                        end else begin
                            nextLine = line + 1;
                            textRamRequest.address = nextLine;
                            nextState = STATE_READ_TEXT;
                        end
                    end else begin
                        nextColumn = column + 1;
                        nextLine = line;
                        fontRomAddress = currentLine[`TEXT_RAM_CHAR_WIDTH * nextColumn +: 8];
                        fontReady = 1;
                        nextState = STATE_READ_FONT;
                    end
                end else begin
                    nextColumn = column;
                    nextLine = line;
                end
            end
            STATE_DONE: begin
                nextState = STATE_DONE;
                if (paintDone) nextState = STATE_INIT;
            end
            default: nextState = STATE_INIT;
        endcase
    end

endmodule // TextRenderer
