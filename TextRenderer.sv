`include "DataType.sv"

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
    input   FontRomData_t    fontRomData
    //input [15:0] cursorPosition,
    //input [3:0]  cursorStates
);

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
    assign currentCharGrid.foreground = {32{1'b1}};
    assign currentCharGrid.background = {32{1'b1}};
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
        .done(subRendererDone),
    );

    always_ff @(posedge clk or negedge rst) begin
        if (~rst) begin
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
                fontRomAddress = currentLine[`FONT_ROM_ADDRESS_WIDTH - 1:0];
                nextState = STATE_READ_FONT;
            end
            STATE_READ_FONT: begin
                nextLine = line;
                nextColumn = column;
                fontReady = 1;
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
                        fontRomAddress = currentLine[16 * nextColumn + 8 - 1 -: 8];
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