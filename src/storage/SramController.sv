`include "DataType.svh"

module SramController (
    input                   clk, // need 25 MHz clock
    input                   rst,
    // directly connect to sram
    output  SramInterface_t sramInterface,
    inout   SramData_t      sramData,
    // dispatch requests and results
    input   SramRequest_t   vgaRequest,
    input   SramRequest_t   rendererRequest,
    output  SramResult_t    vgaResult,
    output  SramResult_t    rendererResult
    );

    SramData_t ramOut;
    logic den;

    assign vgaResult.din = sramData;
    assign sramData = den ? ramOut : {`SRAM_DATA_WIDTH{1'bZ}};

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            rendererResult.done <= 0;
            vgaResult.done <= 0;
            sramInterface <= 0;
            den <= 0;
        end else begin
            rendererResult.done <= 0;
            vgaResult.done <= 0;
            if (~vgaRequest.oe_n) begin
                sramInterface.address <= vgaRequest.address;
                sramInterface.oe_n <= vgaRequest.oe_n;
                sramInterface.we_n <= vgaRequest.we_n;
                den <= vgaRequest.den;
                vgaResult.done <= 1;
            end
            else if (~rendererRequest.we_n) begin
                sramInterface.address <= rendererRequest.address;
                sramInterface.oe_n <= rendererRequest.oe_n;
                sramInterface.we_n <= rendererRequest.we_n;
                den <= rendererRequest.den;
                ramOut <= rendererRequest.dout;
                rendererResult.done <= 1;
            end
        end
    end

endmodule // SramController