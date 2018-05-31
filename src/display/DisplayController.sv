`include "DataType.svh"
module DisplayController (
    input                               clk,
    input                               rst,
    input                               blinkStatus,
    input   Cursor_t                    cursor,
    input   TextRamResult_t             textRamResult,
    output  TextRamRequest_t            textRamRequest,
    output  SramInterface_t             sramInterface,
    inout   [`SRAM_DATA_WIDTH - 1:0]    sramData,
    output  VgaSignal_t                 vga
    );

    // Sram controller module
    SramRequest_t vgaRequest, rendererRequest;
    SramResult_t vgaResult, rendererResult;
    logic paintDone;
    SramAddress_t vgaBaseAddress;

    SramController sramController(
        .clk,
        .rst,
        .sramInterface,
        .sramData,
        .vgaRequest,
        .vgaResult,
        .rendererRequest,
        .rendererResult
    );


    // Font ROM module
    FontRomData_t fontRomData;
    FontRomAddress_t fontRomAddress;

    FontRom fontRom(
        .aclr(rst),
        .address(fontRomAddress),
        .clock(clk),
        .q(fontRomData)
    );


    // Renderer module
    TextRenderer renderer(
        .clk,
        .rst(rst),
        .paintDone,
        .ramRequest(rendererRequest),
        .ramResult(rendererResult),
        .vgaBaseAddress,
        .textRamRequest,
        .textRamResult,
        .fontRomAddress,
        .fontRomData,
        .cursor,
        .blinkStatus
    );


    // VGA module
    VgaDisplayAdapter display(
        .clk,
        .rst,
        .baseAddress(vgaBaseAddress),
        .ramRequest(vgaRequest),
        .ramResult(vgaResult),
        .vga,
        .paintDone
    );

endmodule // DisplayController