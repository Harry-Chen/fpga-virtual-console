`include "DataType.sv"

module VgaDisplayAdapter(
    input  clk,       
    input  rst,
    input  SramAddress_t baseAddress,
    input  SramResult_t  ramResult,
    output SramRequest_t ramRequest,
    output VgaSignal_t vga,
    output paintDone
    );

    localparam H_ACTIVE = 640;
    localparam H_FRONT_PORCH = 16;
    localparam H_SYNC_PULSE = 96;
    localparam H_BACK_PORCH = 48;
    localparam V_ACTIVE = 480;
    localparam V_FRONT_PORCH = 10;
    localparam V_SYNC_PULSE = 2;
    localparam V_BACK_PORCH = 33;

    localparam H_ALL = H_ACTIVE + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH;
    localparam V_ALL = V_ACTIVE + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH;

    logic [9:0] nextX, hCounter;
    logic [8:0] nextY, vCounter;

    logic outputEnable, nextEnable;

    assign outputEnable = (hCounter < H_ACTIVE) & (vCounter < V_ACTIVE) & rst;
    assign nextEnable = (nextX < H_ACTIVE) & (nextY < V_ACTIVE) & rst;

    assign ramRequest.den = 0;
    assign ramRequest.address = baseAddress + nextY * H_ACTIVE + nextX;
    assign ramRequest.we_n = 1;
    assign ramRequest.oe_n = ~nextEnable;
	 
    assign vga.outClock = clk;
    assign vga.de = outputEnable;

    always_comb begin
      if (hCounter == H_ALL - 1) begin
        nextX = 0;
        if (vCounter == V_ALL - 1) nextY = 0;
        else nextY = vCounter + 1;
      end else begin
        nextX = hCounter + 1;
        nextY = vCounter;
      end
    end

    assign paintDone = nextY >= V_ACTIVE;
    assign vga.hSync = ~((hCounter >= H_ACTIVE + H_FRONT_PORCH) & (hCounter < H_ACTIVE + H_FRONT_PORCH + H_SYNC_PULSE));
    assign vga.vSync = ~((vCounter >= V_ACTIVE + V_FRONT_PORCH) & (vCounter < V_ACTIVE + V_FRONT_PORCH + V_SYNC_PULSE));

    Pixel_t pixel;
    assign vga.color = pixel.color;

    always_ff @(posedge clk or negedge rst) begin
      if (~rst) begin
        hCounter <= 0;
        vCounter <= 0;
        pixel <= 0;
        // vga.color <= 0;
      end else begin
        hCounter <= nextX;
        vCounter <= nextY;
        if (nextEnable) begin
          if (ramResult.done) begin
            pixel <= Pixel_t'(ramResult.din);
            //vga.color <= ramResult.din[31 -: 9];
          end else begin
            //vga.color <= vga.color;
            pixel <= pixel;
          end
        end else begin
          pixel <= 0;
        end
      end
    end

endmodule