`include "DataType.svh"
`define MODE_SETCHAR    1'b0
`define MODE_REMOVELINE 1'b1

typedef struct packed {
	logic mode;  // 0 - SET_CHAR, 1 - REMOVE_LINE
	logic [7:0] row;  // which line to be edit

	logic [`TEXT_RAM_CHAR_WIDTH - 1:0] data;
	logic [7:0] col_start, col_end;  // including the two end points
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
	output [4:0]            debug
);

enum logic[4:0] {
	Idle, 
	input_ReadRam0,
	input_ReadRam1,
	input_SetData0,
	input_SetData1,
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
	term.mode.charset
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

/* reset parameters */
logic [7:0] reset_top, reset_bottom, reset_row;

/* data preprocess */
logic [7:0] char;
logic char_printable;
assign char = (param.Pchar == 8'h0) ? 8'h20 : param.Pchar;
assign char_printable = char >= 8'h20;

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
							line_edit.data      = { text_attribute, char };
							line_edit.row       = term.cursor.x;
							line_edit.col_start = term.cursor.y;
							line_edit.col_end   = term.cursor.y;
						end
					end
					EL:
					begin
						status = input_ReadRam0;
						line_edit.mode      = `MODE_SETCHAR;  
						line_edit.data      = `EMPTY_DATA;
						line_edit.row       = term.cursor.x;
						line_edit.col_start = (param.Pn1 == 8'h0) ? 8'h0 : term.cursor.y;
						line_edit.col_end   = (param.Pn1 == 8'h1) ? `CONSOLE_COLUMNS - 1 : term.cursor.y;
					end
					DCH:
					begin
						status = input_ReadRam0;
						line_edit.mode      = `MODE_REMOVELINE;  
						line_edit.row       = term.cursor.x;
						line_edit.col_start = term.cursor.y;
						line_edit.col_end   = term.cursor.y + param.Pn1 - 8'd1;
					end
					ED:
					begin
						status = reset_Start;
						reset_top    = (param.Pn1 == 8'h0) ? 8'h0 : term.cursor.x;
						reset_bottom = (param.Pn1 == 8'h1) ? `CONSOLE_LINES - 1 : term.cursor.x;
					end
					IL, DL:
					begin
						// deletes/inserts Pn1 lines from the buffer
						// starting with the row the cursor is on.
						status = scroll_Start;
						scrolling.top = term.cursor.x;
						scrolling.bottom = `CONSOLE_LINES - 1;
						scrolling.step = param.Pn1;
						scrolling.dir = (commandType == DL) ? 1'b0 : 1'b1;
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
				status = input_SetData0;
			input_SetData0:
				status = input_SetData1;
			input_SetData1:
				status = input_WriteRam;
			input_WriteRam:
				status = delay_scrolling ? scroll_Start : Idle;
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
				status = reset_WriteRam;
			reset_WriteRam:
				status = (reset_row >= reset_bottom) ? Idle : reset_WriteRam;
			default:
				status = Idle;
		endcase
	end
end

// setup write info
logic [`TEXT_RAM_LINE_WIDTH - 1:0] next_line, next_line_set, next_line_move;

TextControlSetData text_control_set_data(
	.line_edit,
	.cur_line(ramRes),
	.next_line_set,
	.next_line_move
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
		end
		input_SetData1:  // latch data
			next_line <= line_edit.mode ? next_line_move : next_line_set;
		input_WriteRam:  // setup write request
		begin
			ramReq.address <= line_edit.row;
			ramReq.wren <= 1'b1;
			ramReq.data <= next_line;
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
	output [`TEXT_RAM_LINE_WIDTH - 1:0] next_line_move
);

logic [5:0] step;
assign step = line_edit.col_end - line_edit.col_start + 1;

genvar i;

generate
	for(i = 0; i < `CONSOLE_COLUMNS; i = i + 1)
	begin: next_line_set_loop
		logic col_in, col_left;
		assign col_in = line_edit.col_start <= i && i <= line_edit.col_end;
		assign col_left0 = i < line_edit.col_start;
		assign col_left1 = i <= line_edit.col_end;

		assign next_line_set[`TEXT_RAM_CHAR_WIDTH * i +: `TEXT_RAM_CHAR_WIDTH]
			= col_in ? line_edit.data : cur_line[`TEXT_RAM_CHAR_WIDTH * i +: `TEXT_RAM_CHAR_WIDTH];
		assign next_line_move[`TEXT_RAM_CHAR_WIDTH * i +: `TEXT_RAM_CHAR_WIDTH]
			= col_left0 ? cur_line[`TEXT_RAM_CHAR_WIDTH * i +: `TEXT_RAM_CHAR_WIDTH]
			: col_left1 ? cur_line[`TEXT_RAM_CHAR_WIDTH * (i + step) +: `TEXT_RAM_CHAR_WIDTH] : `EMPTY_DATA;
	end
endgenerate

endmodule
