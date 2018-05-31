`include "DataType.svh"

module FontShapeRenderer(
    input                 clk,
    input                 rst,
    input                 fontReady,
    input   CharGrid_t    grid,
    input   SramAddress_t baseAddress,
    input   SramResult_t  ramResult,
    output  SramRequest_t ramRequest,
    input   CharEffect_t  effect,
    input                 currentCursor,
    input                 blinkStatus,
    output                done
    );

    typedef enum logic[1:0] {
        STATE_INIT, STATE_RENDER_ODD_PIXEL, STATE_WAIT_WRITE, STATE_DONE
    } FontShapeRendererState_t;

    FontShapeRendererState_t currentState, nextState;

    assign done = currentState == STATE_DONE;

    logic [2:0] nextX, x;
    logic [3:0] nextY, y;
    CharGrid_t gridData, nowRenderingData;
    SramAddress_t baseAddressData, nowBaseAddress;

    assign nowRenderingData = currentState == STATE_INIT ? grid : gridData;
    assign nowBaseAddress = currentState == STATE_INIT ? baseAddress : baseAddressData;
    
    assign ramRequest.oe_n = 1;

    // the bit order of the font shape is inverted
    `define CURRENT_PIXEL (`PIXEL_PER_CHARACTER - 1 - (y * `WIDTH_PER_CHARACTER + x))

    logic pixelSolid;
    assign pixelSolid = nowRenderingData.shape[`CURRENT_PIXEL] == ~currentCursor;

    VgaColor_t foreground, background;
    VgaColor_t nowColor;

    always_comb begin
        if (effect.negative) begin
            if (effect.bright) begin
                background = nowRenderingData.foreground | 9'b100_100_100;
            end else begin
                background = nowRenderingData.foreground;
            end
            foreground = nowRenderingData.background;
        end else begin
            if (effect.bright) begin
                foreground = nowRenderingData.foreground | 9'b100_100_100;
            end else begin
                foreground = nowRenderingData.foreground;
           end
           background = nowRenderingData.background;
        end

        if (effect.underline & y == (`HEIGHT_PER_CHARACTER - 1)) begin
            nowColor = foreground;
        end else begin
            if (effect.blink & !blinkStatus) begin
                nowColor = background;
            end else begin
                nowColor = pixelSolid ? foreground : background;
            end
        end
    end

    Pixel_t pixel;

    always_ff @(posedge clk) begin
        if (currentState == STATE_RENDER_ODD_PIXEL) begin
            pixel.pixelOdd <= nowColor;
        end
    end

    assign pixel.pixelEven = nowColor;

    assign ramRequest.dout = pixel;
    assign ramRequest.address = nowBaseAddress + (y * `CONSOLE_COLUMNS * `WIDTH_PER_CHARACTER + x) >> 1;


    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            x <= 0;
            y <= 0;
            currentState <= STATE_INIT;
        end else begin
            x <= nextX;
            y <= nextY;
            currentState <= nextState;
            if (currentState == STATE_INIT) begin
                gridData <= grid;
                baseAddressData <= baseAddress;
            end
        end
    end


    always_comb begin
        nextX = x;
        nextY = y;
        nextState = STATE_INIT;
        ramRequest.den = 0;
        ramRequest.we_n = 1;
        unique case(currentState)
            STATE_INIT: begin
                nextX = 0;
                nextY = 0;
                nextState = STATE_RENDER_ODD_PIXEL;
            end

            STATE_RENDER_ODD_PIXEL: begin
                nextX = x + 1'b1;
                nextY = y;
                nextState = STATE_WAIT_WRITE;
            end

            STATE_WAIT_WRITE: begin
                ramRequest.den = 1;
                ramRequest.we_n = 0;
                nextState = STATE_WAIT_WRITE;
                if (ramResult.done) begin
                    nextState = STATE_RENDER_ODD_PIXEL;
                    if (x == `WIDTH_PER_CHARACTER - 1) begin
                        nextX = 0;
                        if (y == `HEIGHT_PER_CHARACTER - 1) begin
                            nextState = STATE_DONE;
                            nextY = 0;
                        end else begin
                            nextY = y + 1'b1;
                        end
                    end else begin
                        nextX = x + 1'b1;
                        nextY = y;
                    end
                end
            end


            STATE_DONE: begin
                if (fontReady) nextState = STATE_INIT;
                else nextState = STATE_DONE;
            end
        endcase
    end

endmodule // FontShapeRender;