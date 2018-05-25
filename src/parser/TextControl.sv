`include "DataType.svh"

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
	term.graphics.blink,
	term.graphics.negative,
	term.graphics.bright,
	term.graphics.underline,
	term.graphics.bg,
	term.graphics.fg,
	term.mode.charset
};

// single line edit parameters
logic [`TEXT_RAM_CHAR_WIDTH - 1:0] data;
logic [7:0] row, col;

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
							data = { text_attribute, char };
							row = term.cursor.x;
							col = term.cursor.y;
						end
					end
					ED:
					begin
						status = reset_Start;
						reset_top = (param.Pn1 == 8'h0) ? 8'h0 : term.cursor.x;
						reset_bottom = (param.Pn1 == 8'h1) ? `CONSOLE_LINES - 1 : term.cursor.x;
					end
					IL, DL:
					begin
						// deletes/inserts Pn1 lines from the buffer
						// starting with the row the cursor is on.
						status = scroll_Start;
						scrolling.top = term.cursor.x;
						scrolling.bottom = `CONSOLE_LINES;
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
logic [`TEXT_RAM_LINE_WIDTH - 1:0] next_line, cur_line;
assign cur_line = ramRes;
genvar i;
generate
	for(i = 0; i < `CONSOLE_COLUMNS; i = i + 1)
	begin: gen_for
		logic [`TEXT_RAM_CHAR_WIDTH - 1:0] next_char, cur_char;
		assign cur_char = cur_line[`TEXT_RAM_CHAR_WIDTH * i +: `TEXT_RAM_CHAR_WIDTH];
		assign next_line[`TEXT_RAM_CHAR_WIDTH * i +: `TEXT_RAM_CHAR_WIDTH] = next_char;
		
		assign next_char = (i == col) ? data : cur_char;
	end
endgenerate

always @(posedge clk)
begin
	case(status)
		Idle:  // clear write request
		begin
			ramReq.wren <= 1'b0;
		end
		input_ReadRam0:  // setup read request
		begin
			ramReq.address <= row;
			ramReq.wren <= 1'b0;
		end
		input_WriteRam:  // setup write request
		begin
			ramReq.address <= row;
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
