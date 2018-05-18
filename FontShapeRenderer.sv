`include "DataType.sv"

module FontShapeRenderer(
    input                 clk,
    input                 rst,
    input   CharGrid_t    grid,
    input   SramAddress_t baseAddress,
    input   SramResult_t  ramResult,
    output  SramRequest_t ramRequest,
    output  logic         done,
    output  logic[6:0]    debug
);

    typedef enum logic[1:0] {
        STATE_INIT, STATE_WAIT_WRITE, STATE_DONE
    } FontShapeRendererState_t;

    FontShapeRendererState_t currentState, nextState;

    LedDecoder decoder_x2(
        .hex(currentState),
        .segments(debug)
    );

    assign done = currentState == STATE_DONE;

    logic [2:0] nextX, x;
    logic [3:0] nextY, y;
    CharGrid_t gridData, nowRenderingData;

    assign nowRenderingData = currentState == STATE_INIT ? grid : gridData;

    assign ramRequest.address = baseAddress + nextY * `CONSOLE_COLUMNS + nextX;
    assign ramRequest.dout = nowRenderingData.shape[nextY * `WIDTH_PER_CHARACTER + nextX] == 1 ? nowRenderingData.foreground : nowRenderingData.background;
    assign ramRequest.oe_n = 1;
    assign ramRequest.we_n = 0;

    always_ff @(posedge clk or negedge rst) begin
        if (~rst) begin
            x <= 0;
            y <= 0;
            currentState <= STATE_INIT;
        end else begin
            x <= nextX;
            y <= nextY;
            currentState <= nextState;
            if (currentState == STATE_INIT) begin
                gridData <= grid;
            end
        end
    end


    always_comb begin
        nextX = 0;
        nextY = 0;
        nextState = STATE_INIT;
        ramRequest.den = 1;
        unique case(currentState)
            STATE_INIT: begin
                nextState = STATE_WAIT_WRITE;
            end
            STATE_WAIT_WRITE: begin
                nextState = STATE_WAIT_WRITE;
                if (ramResult.done) begin
                    if (x == `WIDTH_PER_CHARACTER - 1) begin
                        nextX = 0;
                        if (y == `HEIGHT_PER_CHARACTER - 1) begin
                            nextState = STATE_DONE;
                            nextY = 0;
                        end else begin
                            nextY = y + 1;
                        end
                    end else begin
                        nextX = x + 1;
                        nextY = y;
                    end
                end else begin
                    nextX = x;
                    nextY = y;
                end
            end
            STATE_DONE: begin
                ramRequest.den = 0;
                nextState = STATE_INIT;
            end
        endcase
    end

endmodule // FontShapeRender;