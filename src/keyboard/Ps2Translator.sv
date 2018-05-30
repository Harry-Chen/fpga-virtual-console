`include "DataType.svh"
module Ps2Translator(
    input                   clk,
    input                   rst,
    input                   fifoFull, // unused, we assert that the fifo will never be full
    input                   scancodeDone,
    input   Scancode_t      scancode,
    output                  fifoWriteRequest,
    output  UartFifoData_t  fifoInData
    );


    localparam  BREAK = 8'hF0,
                SPECIAL = 8'hE0,
                LEFT_SHIFT = 8'h12,
                RIGHT_SHIFT = 8'h59,
                LEFT_CTRL = 8'h14;

    typedef enum logic[3:0] {
        STATE_NORMAL, STATE_BREAK_NORMAL, STATE_SPECIAL_NORMAL,
        STATE_SHIFT, STATE_BREAK_SHIFT, STATE_SPECIAL_SHIFT,
        STATE_CTRL, STATE_BREAK_CTRL, STATE_SPECIAL_CTRL
    } Ps2TranslatorState_t;

    Ps2TranslatorState_t currentState, nextState;

    logic special, shift, ctrl;
    logic decoderValid, outputEnable;

    assign fifoWriteRequest = decoderValid & outputEnable;

    ScancodeDecoder decoder(
        .scancode,
        .special,
        .shift,
        .ctrl,
        .fifoInData,
        .valid(decoderValid)
    );

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            currentState <= STATE_NORMAL;
        end else begin
            currentState <= nextState;
        end
    end

    always_comb begin
        nextState = currentState;
        outputEnable = 0;
        special = 0;
        shift = 0;
        ctrl = 0;
        unique case (currentState)
            STATE_NORMAL: begin
                if(scancodeDone) begin
                    if (scancode == LEFT_SHIFT || scancode == RIGHT_SHIFT) begin
                        nextState = STATE_SHIFT;
                    end

                    else if (scancode == LEFT_CTRL) begin
                        nextState = STATE_CTRL;
                    end

                    else if (scancode == SPECIAL) begin
                        nextState = STATE_SPECIAL_NORMAL;
                    end

                    else if (scancode == BREAK) begin
                        nextState = STATE_BREAK_NORMAL;
                    end

                    else begin
                        outputEnable = 1;
                        nextState = STATE_NORMAL;
                        // Normal Key 
                    end
                end
            end

            STATE_BREAK_NORMAL: begin
                if(scancodeDone) begin
                    nextState = STATE_NORMAL;
                end
            end

            STATE_SPECIAL_NORMAL: begin
                if(scancodeDone) begin
                    if (scancode == BREAK) begin
                        nextState = STATE_BREAK_NORMAL;
                    end else begin
                        nextState = STATE_NORMAL;
                        special = 1;
                        outputEnable = 1;
                        // Special Key
                    end
                end
            end

            STATE_SHIFT: begin
                if(scancodeDone) begin
                    if (scancode == LEFT_SHIFT || scancode == RIGHT_SHIFT) begin
                        nextState = STATE_SHIFT;
                    end

                    else if (scancode == SPECIAL) begin
                        nextState = STATE_SPECIAL_SHIFT;
                    end

                    else if (scancode == BREAK) begin
                        nextState = STATE_BREAK_SHIFT;
                    end

                    else begin
                        outputEnable = 1;
                        shift = 1;
                        // Shift + Normal Key 
                    end
                end
            end

            STATE_BREAK_SHIFT: begin
                if(scancodeDone) begin
                    if (scancode == LEFT_SHIFT || scancode == RIGHT_SHIFT) begin
                        nextState = STATE_NORMAL;
                    end else begin
                        nextState = STATE_SHIFT;
                    end
                end
            end
        
            
            STATE_SPECIAL_SHIFT: begin
                if (scancode == BREAK) begin
                    nextState = STATE_BREAK_SHIFT;
                end else begin
                    nextState = STATE_SHIFT;
                    shift = 1;
                    special = 1;
                    // TODO: we do not handle Shift + Special Keys
                    // outputEnable = 1;
                end
            end
           
            STATE_CTRL: begin
                if(scancodeDone) begin
                    if (scancode == LEFT_CTRL) begin
                        nextState = STATE_CTRL;
                    end

                    else if (scancode == SPECIAL) begin
                        nextState = STATE_SPECIAL_CTRL;
                    end

                    else if (scancode == BREAK) begin
                        nextState = STATE_BREAK_CTRL;
                    end

                    else begin
                        outputEnable = 1;
                        ctrl = 1;
                        // Ctrl + Normal Key
                    end
                end
            end 
            
            STATE_BREAK_CTRL: begin
                if(scancodeDone) begin
                    if (scancode == LEFT_CTRL) begin
                        nextState = STATE_NORMAL;
                    end else begin
                        nextState = STATE_CTRL;
                    end
                end
            end
            
            STATE_SPECIAL_CTRL: begin
                if (scancode == BREAK) begin
                    nextState = STATE_BREAK_CTRL;
                end else begin
                    nextState = STATE_CTRL;
                    outputEnable = 1;
                    ctrl = 1;
                    special = 1;
                    // Ctrl + Special Key
                    // TODO: not working at the moment
                end
            end

        endcase
    end



endmodule