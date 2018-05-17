`include "DataType.sv"

module SramController (
    input clk, // need 25 MHz clock
    input rst,
    // directly connect to sram
    output  SramInterface_t ramInterface,
    inout   SramData_t      ramData,
    // dispatch requests and results
    input   SramRequest_t   vgaRequest,
    input   SramRequest_t   rendererRequest,
    output  SramResult_t    vgaResult,
    output  SramResult_t    rendererResult
);

    typedef enum logic [1:0] {
        STATE_INIT, STATE_VGA_READ, STATE_RENDERER_WRITE
    } SramControllerState_t;

    SramControllerState_t currentState;

    logic [`SRAM_DATA_WIDTH - 1:0] ramOut;
    logic [`SRAM_DATA_WIDTH - 1:0] vgaData;
    logic den;

    always_ff @(posedge clk or negedge rst) begin
        if(!rst) begin
            currentState <= STATE_INIT;
            vgaData <= {`SRAM_DATA_WIDTH{0}};
        end else begin
            unique case (currentState)
                STATE_INIT: currentState <= STATE_VGA_READ;
                STATE_VGA_READ: begin
                    vgaData <= ramData;
                    currentState <= STATE_RENDERER_WRITE;
                end
                STATE_RENDERER_WRITE: currentState <= STATE_VGA_READ;
                default: currentState <= STATE_INIT;
            endcase
        end
    end

    assign vgaResult.din = currentState == STATE_VGA_READ ? ramOut : vgaData;
    assign ramData = den ? ramOut : {`SRAM_DATA_WIDTH{1'bZ}};

    always_comb begin
        ramInterface.address = {`SRAM_ADDRESS_WIDTH{0}};
        ramOut =  {`SRAM_DATA_WIDTH{0}};
        den = 0;
        vgaResult.done = 0;
        rendererResult.done = 0;
        unique case (currentState)
            STATE_VGA_READ: begin
                ramInterface.address = vgaRequest.address;
                ramInterface.oe_n = vgaRequest.oe_n;
                ramInterface.we_n = vgaRequest.we_n;
                den = vgaRequest.den;
                vgaResult.done = 1;
            end
            STATE_RENDERER_WRITE: begin
                ramInterface.address = rendererRequest.address;
                ramInterface.oe_n = rendererRequest.oe_n;
                ramInterface.we_n = rendererRequest.we_n;
                den = rendererRequest.den;
                ramOut = rendererRequest.dout;
                rendererResult.done = 1;
            end
            default: ;
        endcase
    end

endmodule // SramController