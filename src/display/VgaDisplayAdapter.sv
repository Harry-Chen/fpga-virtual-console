`include "DataType.svh"

module VgaDisplayAdapter(
    input  clk,       
    input  rst,
    input  SramAddress_t baseAddress,
    input  SramResult_t  ramResult,
    output SramRequest_t ramRequest,
    output VgaSignal_t   vga,
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

    assign ramRequest.den = 0;
    assign ramRequest.we_n = 1;
	 
    assign vga.outClock = clk;

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

    Pixel_t pixel;
    assign vga.color = pixel.color;

    always_ff @(posedge clk or posedge rst) begin
      if (rst) begin
        hCounter <= 0;
        vCounter <= 0;
        pixel <= 0;
        outputEnable <= 0;
        nextEnable <= 0;
      end else begin
        hCounter <= nextX;
        vCounter <= nextY;

        outputEnable <= (hCounter < H_ACTIVE) & (vCounter < V_ACTIVE);
        nextEnable <= (nextX < H_ACTIVE) & (nextY < V_ACTIVE);

        ramRequest.oe_n <= ~nextEnable;
        ramRequest.address <= baseAddress + nextY * H_ACTIVE + nextX - 1;

        vga.hSync <= ~((hCounter >= H_ACTIVE + H_FRONT_PORCH) & (hCounter < H_ACTIVE + H_FRONT_PORCH + H_SYNC_PULSE));
        vga.vSync <= ~((vCounter >= V_ACTIVE + V_FRONT_PORCH) & (vCounter < V_ACTIVE + V_FRONT_PORCH + V_SYNC_PULSE));
        vga.de <= outputEnable;
        paintDone <= nextY >= V_ACTIVE;

        if (nextEnable) begin
          if (ramResult.done) begin
            pixel <= Pixel_t'(ramResult.din);
          end else begin
            pixel <= pixel;
          end
        end else begin
          pixel <= 0;
        end
      end
    end

endmodule