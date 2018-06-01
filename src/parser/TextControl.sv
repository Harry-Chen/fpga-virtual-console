`include "DataType.svh"
`define MODE_SETCHAR    1'b0
`define MODE_MOVELINE 1'b1
`define MIN(a, b) (((a) < (b)) ? (a) : (b))

typedef struct packed {
	logic mode;  // 0 - SET_CHAR, 1 - MOVE_LINE
	logic [7:0] row;  // which line to be edit

	logic [`TEXT_RAM_CHAR_WIDTH - 1:0] data;
	logic [7:0] col_start, col_end;  // including the two end points
	logic [7:0] col_now, col_read_addr;
	logic move_dir;  // 1 - right, 0 - left

	// for REP command
	logic rep_mode;
	logic [7:0] row_end, col_final;
} LineEdit_t;

module TextControl(
	input                   clk, rst,
	input                   commandReady,
	input  CommandsType     commandType,
	input  Terminal_t       term,
	input  Param_t          param,
	input  Scrolling_t      i_scrolling,
	input                   scrollReady,
	input  TextRamResult_t  ramRes,
	output TextRamRequest_t ramReq,
	output [31:0]           prevData,
	output [4:0]            debug
);

enum logic[4:0] {
	Idle, 
	input_ReadRam0,
	input_ReadRam1,
	input_CycRead,
	input_CycSet,
	input_WriteRam,
	scroll_Start,
	scroll_ReadRam0,
	scroll_ReadRam1,
	scroll_WriteRam,
	reset_Start,
	reset_WriteRam
} status;

assign debug = status;

// attribute for input text
wire [`TEXT_RAM_CHAR_WIDTH - 9:0] text_attribute;
assign text_attribute = {
	term.graphics.effect,
	term.graphics.bg,
	term.graphics.fg,
	term.attrib.charset
};

/* single line edit parameters */
LineEdit_t line_edit;

/* scrolling parameters */
// scrolling scroll_step line between [scroll_top, scroll_bottom]
Scrolling_t scrolling;
logic [7:0] scrolling_row;

// this is for the case that the cursor is at (CONSOLE_LINE - 1,
// CONSOLE_COLUMN - 1), and requiring scrolling and input
logic delay_scrolling;

// used for ID, DL, reset after input
logic delay_reset;

/* reset parameters */
logic [7:0] reset_top, reset_bottom, reset_row;

/* data preprocess */
logic [7:0] char;
logic char_printable;
assign char = (param.Pchar == 8'h0) ? 8'h20 : param.Pchar;
assign char_printable = char >= 8'h20;

// for repeat command
logic [7:0] divmod_Q, divmod_R;
DivideMod #(
	.Mod(`CONSOLE_COLUMNS)
) divmod(
	.X(term.cursor.y + param.Pn1 - 8'd1),
	.Q(divmod_Q),
	.R(divmod_R)
);

always @(posedge clk or posedge rst)
begin
	if(rst) 
	begin
		prevData <= 32'd0;
	end else if(commandReady) begin
		if(commandType == INPUT)
			prevData <= char_printable ? { text_attribute, char } : 32'd0;
	end
end

always @(posedge clk or posedge rst)
begin
	if(rst)
	begin
		status = Idle;
	end else begin
		unique case(status)
			Idle:
			begin
				if(scrollReady)
				begin
					status = scroll_Start;
					scrolling = i_scrolling;
				end else if(commandReady) begin
					case(commandType)
					INPUT:
					begin
						if(char_printable)
						begin
							status = input_ReadRam0;
							line_edit.mode      = `MODE_SETCHAR;  
							line_edit.rep_mode  = 1'b0;  
							line_edit.data      = { text_attribute, char };
							line_edit.row       = term.cursor.x;
							line_edit.col_start = term.cursor.y;
							line_edit.col_end   = term.cursor.y;
						end
					end
					REP:
					if(term.prev_data != 32'd0)
					begin
						status = input_ReadRam0;
						line_edit.mode      = `MODE_SETCHAR;  
						line_edit.rep_mode  = term.mode.auto_wrap;  
						line_edit.data      = term.prev_data;
						line_edit.row       = term.cursor.x;
						line_edit.col_start = term.cursor.y;
						line_edit.col_end   = `MIN(term.cursor.y + param.Pn1 - 8'd1, 8'(`CONSOLE_COLUMNS - 1));
						line_edit.row_end   = term.cursor.x + divmod_Q;
						line_edit.col_final = divmod_R;
					end
					EL:
					begin
						status = input_ReadRam0;
						line_edit.mode      = `MODE_SETCHAR;  
						line_edit.rep_mode  = 1'b0;
						line_edit.data      = `EMPTY_DATA;
						line_edit.row       = term.cursor.x;
						line_edit.col_start = (param.Pn1 != 8'h0) ? 8'h0 : term.cursor.y;
						line_edit.col_end   = (param.Pn1 != 8'h1) ? 8'(`CONSOLE_COLUMNS - 1) : term.cursor.y;
					end
					DCH, ICH:
					begin
						status = input_ReadRam0;
						line_edit.mode      = `MODE_MOVELINE;  
						line_edit.rep_mode  = 1'b0;
						line_edit.row       = term.cursor.x;
						line_edit.col_start = term.cursor.y;
						line_edit.col_end   = term.cursor.y + param.Pn1 - 8'd1;
						line_edit.move_dir  = commandType == DCH ? 1'b1 : 1'b0;
					end
					ECH:
					begin
						status = input_ReadRam0;
						line_edit.mode      = `MODE_SETCHAR;  
						line_edit.rep_mode  = 1'b0;
						line_edit.data      = `EMPTY_DATA;
						line_edit.row       = term.cursor.x;
						line_edit.col_start = term.cursor.y;
						line_edit.col_end   = term.cursor.y + param.Pn1 - 8'h1;
					end
					ED:
					begin
						status = input_ReadRam0;
						line_edit.mode      = `MODE_SETCHAR;  
						line_edit.rep_mode  = 1'b0;
						line_edit.data      = `EMPTY_DATA;
						line_edit.row       = term.cursor.x;
						line_edit.col_start = (param.Pn1 != 8'h0) ? 8'h0 : term.cursor.y;
						line_edit.col_end   = (param.Pn1 != 8'h1) ? 8'(`CONSOLE_COLUMNS - 1) : term.cursor.y;

						delay_reset  = 1'd1;
						reset_top    = (param.Pn1 != 8'h0) ? 8'h0 : term.cursor.x + 8'd1;
						reset_bottom = (param.Pn1 != 8'h1) ? 8'(`CONSOLE_LINES - 1) : term.cursor.x - 8'd1;
					end
					IL, DL:
					if(scrolling.top <= term.cursor.x && term.cursor.x <= scrolling.bottom)
					begin
						// deletes/inserts Pn1 lines from the buffer
						// starting with the row the cursor is on.
						status = scroll_Start;
						scrolling.top    = term.cursor.x;
						scrolling.bottom = term.attrib.scroll_bottom;
						scrolling.step   = param.Pn1;
						scrolling.dir    = (commandType == DL) ? 1'b0 : 1'b1;
					end
					SU, SD: // Scroll up/down Ps lines
					begin
						status = scroll_Start;
						scrolling.top    = term.attrib.scroll_top;
						scrolling.bottom = term.attrib.scroll_bottom;
						scrolling.step   = param.Pn1;
						scrolling.dir    = (commandType == SU) ? 1'b0 : 1'b1;
					end
					default:
						status = Idle;
					endcase
				end
			end
			input_ReadRam0:
			begin
				status = input_ReadRam1;
				// for the case that cursor is at the end of screen
				if(scrollReady)
				begin
					delay_scrolling = 1'b1;
					scrolling = i_scrolling;
				end else begin
					delay_scrolling = 1'b0;
				end
			end
			input_ReadRam1:
				status = line_edit.mode == `MODE_MOVELINE ? input_CycRead : input_WriteRam;
			input_CycRead:
				status = input_CycSet;
			input_CycSet:
			begin
				if(line_edit.move_dir == 1'b1)  // move right
					status = line_edit.col_now == 8'(`CONSOLE_COLUMNS - 1) ? input_WriteRam : input_CycRead;
				else status = line_edit.col_now == 8'd0 ? input_WriteRam : input_CycRead;
			end
			input_WriteRam:
				if(line_edit.rep_mode && line_edit.row < line_edit.row_end)
				begin
					status = input_ReadRam0;
					line_edit.row       = line_edit.row + 8'd1;
					line_edit.col_start = 8'd0;
					line_edit.col_end   = (line_edit.row == line_edit.row_end) ? line_edit.col_final : 8'(`CONSOLE_COLUMNS - 1);
				end else begin
					if(delay_scrolling)
						status = scroll_Start;
					else if(delay_reset)
						status = reset_Start;
					else status = Idle;
					delay_reset = 1'b0;
				end
			scroll_Start:
				status = scroll_ReadRam0;
			scroll_ReadRam0:
				status = scroll_ReadRam1;
			scroll_ReadRam1:
				status = scroll_WriteRam;
			scroll_WriteRam:
				if(scrolling.dir && scrolling_row <= scrolling.step + scrolling.top)
				begin
					status = reset_Start;
					reset_top = scrolling.top;
					reset_bottom = scrolling_row - 8'd1;
				end else if(~scrolling.dir && scrolling_row + scrolling.step >= scrolling.bottom) begin
					status = reset_Start;
					reset_top = scrolling_row + 8'd1;
					reset_bottom = scrolling.bottom;
				end else begin
					status = scroll_ReadRam0;
				end
			reset_Start:
				status = (reset_top <= reset_bottom) ? reset_WriteRam : Idle;
			reset_WriteRam:
				status = (reset_row >= reset_bottom) ? Idle : reset_WriteRam;
			default:
				status = Idle;
		endcase
	end
end

// setup write info
logic [`TEXT_RAM_LINE_WIDTH - 1:0] next_line_set, next_line_move;
logic [`TEXT_RAM_LINE_WIDTH + `TEXT_RAM_CHAR_WIDTH - 1:0] cur_line;
logic [`TEXT_RAM_CHAR_WIDTH - 1:0] char_reg;
logic [7:0] col_read_addr_next, col_set_addr_next;

TextControlSetData text_control_set_data(
	.line_edit,
	.cur_line(ramRes),
	.next_line_set,
	.col_read_addr_next,
	.col_set_addr_next
);

always @(posedge clk)
begin
	case(status)
		Idle:  // clear write request
		begin
			ramReq.wren <= 1'b0;
		end
		input_ReadRam0:  // setup read request
		begin
			ramReq.address <= line_edit.row;
			ramReq.wren <= 1'b0;
			line_edit.col_now <= line_edit.move_dir ? 8'hff : 8'(`CONSOLE_COLUMNS);
		end
		input_ReadRam1:
		begin
			cur_line <= { `EMPTY_DATA, ramRes };
			line_edit.col_now <= col_set_addr_next; 
			line_edit.col_read_addr <= col_read_addr_next;
		end
		input_CycRead:
			// for MODE_MOVELINE, latch char data
			char_reg <= cur_line[`TEXT_RAM_CHAR_WIDTH * line_edit.col_read_addr +: `TEXT_RAM_CHAR_WIDTH];
		input_CycSet:     // for MODE_MOVELINE, store char data
		begin
			line_edit.col_now <= col_set_addr_next; 
			line_edit.col_read_addr <= col_read_addr_next;
			next_line_move[`TEXT_RAM_CHAR_WIDTH * line_edit.col_now +: `TEXT_RAM_CHAR_WIDTH] <= char_reg;
		end
		input_WriteRam:  // setup write request
		begin
			ramReq.address <= line_edit.row;
			ramReq.wren <= 1'b1;
			ramReq.data <= line_edit.mode == `MODE_SETCHAR ? next_line_set : next_line_move;
		end
		scroll_Start:
			scrolling_row <= scrolling.dir ? scrolling.bottom : scrolling.top;
		scroll_ReadRam0:
		begin
			ramReq.address <= scrolling.dir ? scrolling_row - scrolling.step : scrolling_row + scrolling.step;
			ramReq.wren <= 1'b0;
		end
		scroll_WriteRam:
		begin
			ramReq.address <= scrolling_row;
			ramReq.wren <= 1'b1;
			ramReq.data <= ramRes;
			if(scrolling.dir)
				scrolling_row <= scrolling_row - 8'b1;
			else
				scrolling_row <= scrolling_row + 8'b1;
		end
		reset_Start:
			reset_row <= reset_top;
		reset_WriteRam:
		begin
			ramReq.address <= reset_row;
			ramReq.wren <= 1'b1;
			ramReq.data <= {`CONSOLE_COLUMNS{32'h0007fc20}};
			reset_row <= reset_row + 8'b1;
		end
	endcase
end

endmodule

module TextControlSetData(
	input  LineEdit_t line_edit,
	input  [`TEXT_RAM_LINE_WIDTH - 1:0] cur_line,
	output [`TEXT_RAM_LINE_WIDTH - 1:0] next_line_set,
	output [7:0] col_set_addr_next, col_read_addr_next
);

logic [7:0] step, col_next;
assign col_set_addr_next = col_next;

always_comb
begin
	step = line_edit.col_end - line_edit.col_start + 8'd1;
	if(line_edit.move_dir)
	begin
		col_next = line_edit.col_now + 8'd1;
		col_read_addr_next
			= (col_next <  line_edit.col_start) ? col_next
			: (col_next <= line_edit.col_end)   ? col_next + step
			: 8'(`CONSOLE_COLUMNS);  // this place is `EMPTY_DATA
	end else begin
		col_next = line_edit.col_now - 8'd1;
		col_read_addr_next
			= (col_next >  line_edit.col_end)   ? col_next - step
			: (col_next >= line_edit.col_start) ? 8'(`CONSOLE_COLUMNS)
			: col_next;
	end
end

genvar i;
generate
	for(i = 0; i < `CONSOLE_COLUMNS; i = i + 1)
	begin: next_line_set_loop
		logic col_in;
		assign col_in = line_edit.col_start <= i && i <= line_edit.col_end;

		assign next_line_set[`TEXT_RAM_CHAR_WIDTH * i +: `TEXT_RAM_CHAR_WIDTH]
			= col_in ? line_edit.data : cur_line[`TEXT_RAM_CHAR_WIDTH * i +: `TEXT_RAM_CHAR_WIDTH];
	end
endgenerate

endmodule
