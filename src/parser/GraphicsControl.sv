`include "DataType.svh"

`define RESET_GRAPHICS(gs) \
begin \
	gs.fg        <= 9'b110_110_110; \
	gs.bg        <= 9'b000_000_000; \
	gs.underline <= 1'b0; \
	gs.blink     <= 1'b0; \
	gs.negative  <= 1'b0; \
	gs.bright    <= 1'b0; \
end

module GraphicsControl(
	input                clk, rst,
	input                commandReady,
	input  CommandsType  commandType,
	input  [7:0]         Pns,
	output Graphics_t    graphics
);

Graphics_t new_graphics;

enum {
	SGR_START,
	SGR_BG, SGR_BG_TB, SGR_BG_R, SGR_BG_G, SGR_BG_B,
	SGR_FG, SGR_FG_TB, SGR_FG_R, SGR_FG_G, SGR_FG_B
} status;

always @(posedge clk, posedge rst)
begin
	if(rst)
	begin
		status = SGR_START;
	end else if(commandReady) begin
		if(commandType == EMIT_PN || commandType == SGR)
		begin
			// received a new ter
			case(status)
			SGR_START:
				case(Pns)
					8'd38: status = SGR_FG;
					8'd48: status = SGR_BG;
					default: status = SGR_START;
				endcase
			SGR_FG:
				case(Pns)
					8'd5: status = SGR_FG_TB;
					8'd2: status = SGR_FG_R;
					default: status = SGR_START;
				endcase
			SGR_FG_R:
				status = SGR_FG_G;
			SGR_FG_G:
				status = SGR_FG_B;
			SGR_BG:
				case(Pns)
					8'd5: status = SGR_BG_TB;
					8'd2: status = SGR_BG_R;
					default: status = SGR_START;
				endcase
			SGR_BG_R:
				status = SGR_BG_G;
			SGR_BG_G:
				status = SGR_BG_B;
			SGR_FG_B, SGR_FG_TB, SGR_BG_B, SGR_BG_TB:
				status = SGR_START;
			default:
				status = SGR_START;
			endcase
		end
	end
end

// graphicsReady for store new_graphics into graphics
logic graphicsReady;
always @(posedge clk)
begin
	if(graphicsReady) begin
		graphicsReady <= 1'b0;
	end else if(commandReady) begin
		graphicsReady <= (commandType == SGR || commandType == SGR0) ? 1'b1 : 1'b0;
	end
end

logic [8:0] decoded_color;
Color256Decoder color256_decoder(
	.code(Pns),
	.color(decoded_color)
);

// set new_graphics
always @(posedge clk)
begin
	if(rst)
	begin
		`RESET_GRAPHICS(graphics)
	end else if(graphicsReady) begin
		graphics <= new_graphics;
	end else if(commandReady) begin
		case(commandType)
		SGR0:
			`RESET_GRAPHICS(new_graphics)
		INIT_PN:
			new_graphics <= graphics;
		EMIT_PN, SGR:
			case(status)
				SGR_START:
				begin
					case(Pns)
						8'd0: `RESET_GRAPHICS(new_graphics)
						8'd4:  new_graphics.underline <= 1'b1;
						8'd24: new_graphics.underline <= 1'b0;
						8'd7:  new_graphics.negative <= 1'b1;
						8'd27: new_graphics.negative <= 1'b0;
						8'd1:  new_graphics.bright <= 1'b1;
						8'd22: new_graphics.bright <= 1'b0;
						8'd5:  new_graphics.blink <= 1'b1;
						8'd25: new_graphics.blink <= 1'b0;
						8'd37: new_graphics.fg <= 9'b110_110_110;
						8'd47: new_graphics.bg <= 9'b110_110_110;
						// foreground ( white excluded )
						8'd30, 8'd31, 8'd32, 8'd33, 8'd34, 8'd35, 8'd36:
						begin
							new_graphics.fg[8:6] <= ((Pns - 8'd30) & 8'b001) ? 3'b101 : 3'b000;
							new_graphics.fg[5:3] <= ((Pns - 8'd30) & 8'b010) ? 3'b101 : 3'b000;
							new_graphics.fg[2:0] <= ((Pns - 8'd30) & 8'b100) ? 3'b101 : 3'b000;
						end
						// background ( white excluded )
						8'd40, 8'd41, 8'd42, 8'd43, 8'd44, 8'd45, 8'd46:
						begin
							new_graphics.bg[8:6] <= ((Pns - 8'd40) & 8'b001) ? 3'b101 : 3'b000;
							new_graphics.bg[5:3] <= ((Pns - 8'd40) & 8'b010) ? 3'b101 : 3'b000;
							new_graphics.bg[2:0] <= ((Pns - 8'd40) & 8'b100) ? 3'b101 : 3'b000;
						end
						// bright foreground
						8'd90, 8'd91, 8'd92, 8'd93, 8'd94, 8'd95, 8'd96, 8'd97:
						begin
							new_graphics.fg[8:6] <= ((Pns - 8'd90) & 8'b001) ? 3'b111 : 3'b000;
							new_graphics.fg[5:3] <= ((Pns - 8'd90) & 8'b010) ? 3'b111 : 3'b000;
							new_graphics.fg[2:0] <= ((Pns - 8'd90) & 8'b100) ? 3'b111 : 3'b000;
						end
						// bright background
						8'd100, 8'd101, 8'd102, 8'd103, 8'd104, 8'd105, 8'd106, 8'd107:
						begin
							new_graphics.bg[8:6] <= ((Pns - 8'd100) & 8'b001) ? 3'b111 : 3'b000;
							new_graphics.bg[5:3] <= ((Pns - 8'd100) & 8'b010) ? 3'b111 : 3'b000;
							new_graphics.bg[2:0] <= ((Pns - 8'd100) & 8'b100) ? 3'b111 : 3'b000;
						end
					endcase
				end
				SGR_BG_R: new_graphics.bg[8:6] <= (Pns >> 5);
				SGR_BG_G: new_graphics.bg[5:3] <= (Pns >> 5);
				SGR_BG_B: new_graphics.bg[2:0] <= (Pns >> 5);
				SGR_FG_R: new_graphics.fg[8:6] <= (Pns >> 5);
				SGR_FG_G: new_graphics.fg[5:3] <= (Pns >> 5);
				SGR_FG_B: new_graphics.fg[2:0] <= (Pns >> 5);
				SGR_BG_TB: new_graphics.bg <= decoded_color;
				SGR_FG_TB: new_graphics.fg <= decoded_color;
			endcase  // end case status
		endcase // end case(commandType)
	end // end if(commandReady)
end

endmodule 
