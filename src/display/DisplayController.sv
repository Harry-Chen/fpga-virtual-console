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


    // synchronize signals from other clock domain
    logic blinkStatusReg1, blinkStatusReg2;
    Cursor_t cursorReg1, cursorReg2;

    always_ff @(posedge clk) begin
        cursorReg1 <= cursor;
        cursorReg2 <= cursorReg1;
        blinkStatusReg1 <= blinkStatus;
        blinkStatusReg2 <= blinkStatusReg1;
    end

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
        .cursor(cursorReg2),
        .blinkStatus(blinkStatusReg2)
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