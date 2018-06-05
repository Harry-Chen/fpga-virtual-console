`include "DataType.svh"
`define MIN(a, b) (((a) < (b)) ? (a) : (b))
`define MAX(a, b) (((a) < (b)) ? (b) : (a))
`define RESET_TERM_MODE(m) \
begin \
	m.origin_mode        <= 1'b0; \
	m.auto_wrap          <= 1'b1; \
	m.insert_mode        <= 1'b0; \
	m.line_feed          <= 1'b0; \
	m.cursor_blinking    <= 1'b1; \
	m.cursor_visibility  <= 1'b1; \
end

module ModeControl(
	input                clk, rst,
	input                commandReady,
	input  CommandsType  commandType,
	input  Param_t       param,
	output TermMode_t    termMode
);

TermMode_t new_mode, new_mode_dec;

// modeReady for store new_graphics into graphics
logic modeReady;
always @(posedge clk)
begin
	if(modeReady) begin
		modeReady <= 1'b0;
	end else if(commandReady) begin
		modeReady <= (commandType == SETMODE || commandType == RESETMODE
			|| commandType == SETDEC || commandType == RESETDEC) ? 1'b1 : 1'b0;
	end
end

// set termMode
always @(posedge clk, posedge rst)
begin
	if(rst)
	begin
		`RESET_TERM_MODE(termMode)
	end else if(modeReady) begin
		case(commandType)
			SETMODE:
				termMode <= termMode | new_mode;
			RESETMODE:
				termMode <= termMode & ~new_mode;
			SETDEC:
				termMode <= termMode | new_mode_dec;
			RESETDEC:
				termMode <= termMode & ~new_mode_dec;
		endcase
	end
end

// record parameters
always @(posedge clk, posedge rst)
begin
	if(rst)
	begin
		new_mode <= 0;
		new_mode_dec <= 0;
	end else if(commandReady) begin
		case(commandType)
			INIT_PN:
			begin
				new_mode <= 0;
				new_mode_dec <= 0;
			end
			EMIT_PN,
			SETMODE, RESETMODE,
			SETDEC, RESETDEC:
			begin
				case(param.Pns)
					8'd6:  new_mode_dec.origin_mode       <= 1'b1;
					8'd7:  new_mode_dec.auto_wrap         <= 1'b1;
					8'd12: new_mode_dec.cursor_blinking   <= 1'b1;
					8'd25: new_mode_dec.cursor_visibility <= 1'b1;

					8'd4:  new_mode.insert_mode <= 1'b1;
					8'd20: new_mode.line_feed   <= 1'b1;
				endcase
			end
		endcase
	end
end

endmodule 
