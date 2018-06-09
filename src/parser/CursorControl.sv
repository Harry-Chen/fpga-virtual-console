`include "DataType.svh"
`define MIN(a, b) (((a) < (b)) ? (a) : (b))
`define MAX(a, b) (((a) < (b)) ? (b) : (a))
`define SET_SCROLLING(sc_dir, sc_step) \
	begin \
		scrolling.dir <= sc_dir;  \
		scrolling.step <= sc_step; \
		scrolling.top <= term.attrib.scroll_top; \
		scrolling.bottom <= term.attrib.scroll_bottom; \
		scrollReady <= 1'b1; \
	end
`define SET_SCROLLING_UP(sc_step) `SET_SCROLLING(1'b0, sc_step)
`define SET_SCROLLING_DOWN(sc_step) `SET_SCROLLING(1'b1, sc_step)

module CursorControl(
	input               clk, rst,
	input               commandReady,
	input  CommandsType commandType,
	input  Param_t      param,
	input  Terminal_t   term,
	input               blinkStatus,
	output              blinkReset,
	output Cursor_t     cursor,
	output Scrolling_t  o_scrolling,
	output              scrollReady,
	output              debug
);

assign debug = cursor.visible;

// the origin of cursor is (origin_x, 0)
wire [7:0] origin_x, cursor_x_max;
assign origin_x     = term.mode.origin_mode ? term.attrib.scroll_top : 8'd0;
assign cursor_x_max = term.attrib.scroll_bottom - origin_x;

// i_cursor and o_cursor is relative to (origin_x, 0)
Cursor_t i_cursor, o_cursor;
assign cursor.y = o_cursor.y;
assign cursor.x = origin_x + o_cursor.x;
assign i_cursor.y = term.cursor.y;
assign i_cursor.x = term.cursor.x - origin_x;

// some wires
wire [7:0] next_line;
wire is_final_line;
assign next_line = i_cursor.x == cursor_x_max ? cursor_x_max : `MIN(i_cursor.x + 8'd1, 8'(`CONSOLE_LINES - 1));
assign is_final_line = (i_cursor.x == cursor_x_max);

// Pn is used for single parameter commands
// Pl, Pc is used for CUP command
wire [7:0] Pn, Pl, Pc;
assign Pl = (param.Pn1 == 8'd0) ? 8'd0 : param.Pn1 - 8'd1;  // line number
assign Pc = (param.Pn2 == 8'd0) ? 8'd0 : param.Pn2 - 8'd1;  // column number
assign Pn = (param.Pn1 == 8'd0) ? 8'd1 : param.Pn1;         // number 

Scrolling_t scrolling;
assign o_scrolling.reset = (
	commandReady &&
	(commandType == CUP) &&
	~term.mode.origin_mode &&
	(Pl > term.attrib.scroll_bottom)
);
assign o_scrolling.dir    = scrolling.dir;
assign o_scrolling.step   = scrolling.step;
assign o_scrolling.top    = scrolling.top;
assign o_scrolling.bottom = scrolling.bottom;

// for repeat command
logic [7:0] divmod_Q, divmod_R;
DivideMod #(
	.Mod(`CONSOLE_COLUMNS)
) divmod(
	.X(term.cursor.y + param.Pn1),
	.Q(divmod_Q),
	.R(divmod_R)
);

// counter for cursor blinking status
assign cursor.visible = 
	term.mode.cursor_blinking ? 
	  blinkStatus & term.mode.cursor_visibility :
	  term.mode.cursor_visibility;

// tab control
logic tabReady;
logic [7:0] tab_pos;
TabControl tab_control(
	.clk,
	.rst,
	.commandReady,
	.commandType,
	.param,
	.term,
	.tabPos(tab_pos),
	.tabReady
);

// blink reset
always_comb
begin
	if(tabReady)
	begin
		blinkReset = 1'b1;
	end else if(commandReady) begin
		case(commandType)
			CUP, CUF, CUB, CUD, CUU, CNL, CPL,
			CHA, VPA, IND, IL, DL, RI, NEL, 
			DECSTBM, REP, INPUT:
				blinkReset = 1'b1;
			default blinkReset = 1'b0;
		endcase
	end else begin
		blinkReset = 1'b0;
	end
end

always @(posedge clk or posedge rst)
begin
	if(rst)
	begin
		o_cursor.x <= 8'd0;
		o_cursor.y <= 8'd0;
	end else if(scrollReady) begin
		scrollReady <= 1'b0;
	end else if(tabReady) begin
		o_cursor.y <= tab_pos;
	end else if(commandReady) begin
		unique case(commandType)
			CUP:  // Cursor Position
			begin
				o_cursor.x <= `MIN(Pl, term.mode.origin_mode ? cursor_x_max : 8'(`CONSOLE_LINES - 1));
				o_cursor.y <= `MIN(Pc, 8'(`CONSOLE_COLUMNS - 1));
			end
			CUF:  // Cursor Forward 
				o_cursor.y <= `MIN(i_cursor.y + Pn, 8'(`CONSOLE_COLUMNS - 1));
			CUB:  // Cursor Backward
				o_cursor.y <= (i_cursor.y < Pn) ? 8'd0 : i_cursor.y - Pn;
			CUD:  // Cursor Down
				o_cursor.x <= `MIN(i_cursor.x + Pn, cursor_x_max);
			CUU:  // Cursor Up
				if(term.cursor.x < term.attrib.scroll_top + Pn)
					o_cursor.x <= term.attrib.scroll_top - origin_x;
				else
					o_cursor.x <= i_cursor.x - Pn;
			CNL:
			begin
				o_cursor.y <= 8'd0;
				o_cursor.x <= `MIN(i_cursor.x + Pn, cursor_x_max);
			end
			CPL:
			begin
				o_cursor.y <= 8'd0;
				o_cursor.x <= (i_cursor.x < Pn) ? 8'd0 : i_cursor.x - Pn;
			end
			CHA:
				o_cursor.y <= `MIN(Pl, 8'(`CONSOLE_COLUMNS - 1));
			VPA:
				o_cursor.x <= `MIN(Pl, cursor_x_max);
			IND:  // Index
			begin
				o_cursor.x <= next_line;
				if(is_final_line)
					`SET_SCROLLING_UP(8'b1)
			end
			IL, DL:
				if(term.attrib.scroll_top <= term.cursor.x && term.cursor.x <= term.attrib.scroll_bottom)
					o_cursor.y <= 8'd0;
			RI:  // Reverse Index
				if(term.cursor.x == term.attrib.scroll_top)  // absolute position needed
				begin
					o_cursor.x <= term.attrib.scroll_top - origin_x;
					`SET_SCROLLING_DOWN(8'd1)
				end else begin
					o_cursor.x <= i_cursor.x - 8'd1;
				end
			NEL:  // Next Line
			begin
				o_cursor.x <= next_line;
				o_cursor.y <= 8'd0;
				if(is_final_line)
					`SET_SCROLLING_UP(8'b1)
			end
			DECSTBM: // set scroll margin
			begin
				o_cursor.x <= 8'd0;
				o_cursor.y <= 8'd0;
			end
			REP:
				if(term.prev_data)
				begin
					if(term.mode.auto_wrap)
					begin
						o_cursor.y <= divmod_R;
						o_cursor.x <= i_cursor.x + divmod_Q;
					end else begin
						o_cursor.y <= `MIN(i_cursor.y + param.Pn1, 8'(`CONSOLE_COLUMNS - 1));
					end
				end
			INPUT:
				unique case(param.Pchar)
				8'o12,8'o13,8'o14:  // LF, VT, FF
				begin
					o_cursor.x <= next_line;
					o_cursor.y <= term.mode.line_feed ? 8'd0 : o_cursor.y;
					if(is_final_line)
						`SET_SCROLLING_UP(8'b1)
				end
				8'o15: // CR
					o_cursor.y <= 8'd0;
				8'o10: // BS
					o_cursor.y <= (i_cursor.y == 8'd0) ? 8'd0 : i_cursor.y - 8'd1;
				default:
					if(param.Pchar == 8'h0 || param.Pchar >= 8'h20)
					begin
						if(i_cursor.y + 8'd1 < 8'(`CONSOLE_COLUMNS))
						begin
							o_cursor.y <= i_cursor.y + 8'd1;
						end else if(term.mode.auto_wrap) begin
							o_cursor.x <= next_line;
							o_cursor.y <= 8'd0;
							if(is_final_line)
								`SET_SCROLLING_UP(8'b1)
						end
					end
				endcase
			default:
			begin
				o_cursor.x <= i_cursor.x;
				o_cursor.y <= i_cursor.y;
			end
		endcase
	end
end

endmodule
