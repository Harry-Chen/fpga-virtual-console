`include "DataType.svh"

module TextControl(
	input                   clk, rst,
	input                   commandReady,
	input  CommandsType     commandType,
	input  Terminal_t       term,
	input  Param_t          param,
	input  Scrolling_t      i_scrolling,
	input  TextRamResult_t  ramRes,
	output TextRamRequest_t ramReq
);

enum {
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

// attribute for input text
wire [`TEXT_RAM_CHAR_WIDTH - 9:0] text_attribute;
assign text_attribute = { 4'b0, 9'b0, 9'h1ff, 2'b0 };

// single line edit parameters
logic [`TEXT_RAM_CHAR_WIDTH - 1:0] data;
logic [7:0] row, col;

/* scrolling parameters */
// scrolling scroll_step line between [scroll_top, scroll_bottom]
Scrolling_t scrolling;
logic [7:0] scrolling_row;
logic scrolling_enabled;
assign scrolling_enabled = scrolling.step != 8'd0;

/* reset parameters */
logic [7:0] reset_top, reset_bottom, reset_row;

logic char_printable;
assign char_printable = param.Pchar >= 8'h20 || param.Pchar == 8'h00;

always @(posedge clk or posedge rst)
begin
	if(rst)
	begin
	end else begin
		unique case(status)
			Idle:
			begin
				if(commandReady)
				begin
					if(commandType == INPUT && char_printable)
					begin
						status = input_ReadRam0;
						data = { text_attribute, param.Pchar };
						row = term.cursor.x;
						col = term.cursor.y;
					end else if(scrolling_enabled) begin
						status = scroll_Start;
						scrolling = i_scrolling;
					end else begin
						status = Idle;
					end
				end
			end
			input_ReadRam0:
				status = input_ReadRam1;
			input_ReadRam1:
				status = input_WriteRam;
			input_WriteRam:
				status = Idle;
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
				status = (reset_row == reset_bottom) ? Idle : reset_WriteRam;
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
	unique case(status)
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
			scrolling_row <= i_scrolling.dir ? i_scrolling.bottom : i_scrolling.top;
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
