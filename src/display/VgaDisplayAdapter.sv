`include "DataType.svh"

module VgaDisplayAdapter(
    input                 clk,       
    input                 rst,
    input  SramAddress_t  baseAddress,
    input  SramResult_t   ramResult,
    output SramRequest_t  ramRequest,
    output VgaSignal_t    vga,
    output                paintDone
    );

    localparam H_ACTIVE = 800;
    localparam H_FRONT_PORCH = 56;
    localparam H_SYNC_PULSE = 120;
    localparam H_BACK_PORCH = 64;
    localparam V_ACTIVE = 600;
    localparam V_FRONT_PORCH = 37;
    localparam V_SYNC_PULSE = 6;
    localparam V_BACK_PORCH = 23;

    localparam H_ALL = H_ACTIVE + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH;
    localparam V_ALL = V_ACTIVE + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH;

    logic [10:0] nextX, hCounter;
    logic [9:0] nextY, vCounter;

    logic loadMemory;

    assign ramRequest.den = 0;
    assign ramRequest.we_n = 1;
	 
    assign vga.outClock = clk;

    assign ramRequest.oe_n = ~loadMemory;
    assign ramRequest.address = baseAddress + (nextY * H_ACTIVE + nextX) >> 1;

    Pixel_t pixel, pixelData;

    assign pixel = (~ramRequest.oe_n) ? ramResult : pixelData;

    VgaColor_t color;

    assign color = (hCounter[0] == 0) ? pixel.pixelOdd : pixel.pixelEven;

    typedef enum logic[2:0] {
      STATE_INIT, STATE_OUTPUT_ODD, STATE_OUTPUT_EVEN, STATE_WAIT
    } VgaState_t;

    VgaState_t currentState, nextState;

    always_comb begin
      if (currentState != STATE_INIT) begin
        if (hCounter == H_ALL - 1) begin
          nextX = 0;
          if (vCounter == V_ALL - 1) nextY = 0;
          else nextY = vCounter + 1;
        end else begin
          nextX = hCounter + 1;
          nextY = vCounter;
        end
      end else begin
        nextX = 0;
        nextY = 0;
      end
    end

    always_comb begin
      nextState = currentState;
      loadMemory = 0;

      unique case (currentState)
        STATE_INIT: begin
          nextState = STATE_OUTPUT_ODD;
          loadMemory = 1;
        end

        STATE_OUTPUT_ODD: begin
          nextState = STATE_OUTPUT_EVEN;
        end

        STATE_OUTPUT_EVEN: begin
          if (hCounter < H_ACTIVE - 1) begin
            loadMemory = 1;
            nextState = STATE_OUTPUT_ODD;
          end else begin
            nextState = STATE_WAIT;
          end
        end

        STATE_WAIT: begin
          if (hCounter == H_ALL - 1) begin
            nextState = STATE_OUTPUT_ODD;
            loadMemory = 1;
          end
        end
      endcase
    end

    always_ff @(posedge clk or posedge rst) begin
      if (rst) begin
        hCounter <= 0;
        vCounter <= 0;
        currentState <= STATE_INIT;
      end else begin
        currentState <= nextState;
        hCounter <= nextX;
        vCounter <= nextY;

        if (~ramRequest.oe_n) begin
          pixelData <= ramResult;
        end

        vga.hSync <= ~((hCounter >= H_ACTIVE + H_FRONT_PORCH) & (hCounter < H_ACTIVE + H_FRONT_PORCH + H_SYNC_PULSE));
        vga.vSync <= ~((vCounter >= V_ACTIVE + V_FRONT_PORCH) & (vCounter < V_ACTIVE + V_FRONT_PORCH + V_SYNC_PULSE));
        paintDone <= nextY >= V_ACTIVE;

        if ((hCounter < H_ACTIVE) && (vCounter < V_ACTIVE)) begin
          vga.color <= color;
          vga.de <= 1;
        end else begin
          vga.color <= 0;
          vga.de <= 0;
        end
      end
    end

endmodule