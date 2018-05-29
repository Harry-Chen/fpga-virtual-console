`include "DataType.svh"
module DisplayController (
    input                               clk25M,
    input                               clk50M,
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
        .clk(clk50M),
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
        .clock(clk50M),
        .q(fontRomData)
    );


    // Renderer module
    TextRenderer renderer(
        .clk(clk50M),
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
        .clk(clk25M),
        .rst,
        .baseAddress(vgaBaseAddress),
        .ramRequest(vgaRequest),
        .ramResult(vgaResult),
        .vga,
        .paintDone
    );

endmodule // DisplayController