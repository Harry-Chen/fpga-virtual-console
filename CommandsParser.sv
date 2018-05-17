`include "DataType.sv"
`define SET_COMMAND(cmd_type) \
	begin \
		status = START; \
		commandReady <= 1; \
		commandType <= cmd_type; \
	end

module CommandsParser(
	input               clk, rst,
	input      [7:0]    data,
	input               dataReady,
	output              commandReady,  // only be '1' in one clock
	output CommandsType commandType,
	output reg [7:0]    Pn1, Pn2, Pchar,
	output     [7:0]   debug
);

CommandsState status;

// LedDecoder decoder_x1(.hex(status[7:4]), .segments(debug[15:8]));
// LedDecoder decoder_x2(.hex(status[3:0]), .segments(debug[7:0]));
assign debug = status;

// commands parser
always @(posedge clk or negedge rst)
begin
	if(~rst)
	begin
		status = START;
	end
	else if(commandReady)
	begin
		commandReady <= 0;
	end
	else if(dataReady)
	begin
		unique case(status)
			START:
				case(data)
					8'h1b: // ESC
						status = ESC;
					default:
					begin
						status = START;
						commandReady <= 1;
						commandType <= INPUT;
						Pchar <= data;
					end
				endcase
			ESC:
				case(data)
					8'h44: // 'D'
						`SET_COMMAND(IND)
					8'h45: // 'E'
						`SET_COMMAND(NEL)
					8'h4d: // 'M'
						`SET_COMMAND(RI)
					8'h5b: // '['
						status = BRACKET;
					default: status = START;
				endcase
			BRACKET:
				if(data <= 8'h39 && data >= 8'h30) // digit
				begin
					status = PN1;
					Pn1 <= data - 8'h30;
				end
				else  // non-digit
				begin
					status = START;
				end
			DEL1:
				if(data <= 8'h39 && data >= 8'h30) // digit
				begin
					status = PN2;
					Pn2 <= data - 8'h30;
				end
				else  // non-digit
				begin
					status = START;
				end
			PN1:
				case(data)
					8'h30, 8'h31, 8'h32, 8'h33, 8'h34, 8'h35, 8'h36, 8'h37, 8'h38, 8'h39: // digit
					begin
						status = PN1;
						Pn1 <= Pn1 * 8'd10 + (data - 8'h30);
					end
					8'h3b: // ';'
						status = DEL1;
					8'h41: // 'A'
						`SET_COMMAND(CUU)
					8'h42: // 'B'
						`SET_COMMAND(CUD)
					8'h43: // 'C'
						`SET_COMMAND(CUF)
					8'h44: // 'D'
						`SET_COMMAND(CUB)
					default:
						status = START;
				endcase
			PN2:
				case(data)
					8'h30, 8'h31, 8'h32, 8'h33, 8'h34, 8'h35, 8'h36, 8'h37, 8'h38, 8'h39: // digit
					begin
						status = PN1;
						Pn2 <= Pn2 * 8'd10 + (data - 8'h30);
					end
					8'h48, 8'h66: // 'H', 'f'
						`SET_COMMAND(CUP)
					default:
						status = START;
				endcase
			default:
				status = START;
		endcase
	end  // end if
end  // end always

endmodule
