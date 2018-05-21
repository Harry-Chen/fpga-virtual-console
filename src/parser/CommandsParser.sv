`include "DataType.svh"

`define SET_COMMAND(cmd_type) \
	commandReady <= 1; \
	commandType <= cmd_type; 

`define SET_COMMAND_BLOCK(cmd_type) \
	begin \
		`SET_COMMAND(cmd_type) \
	end

`define CASE_DIGIT \
	8'h30, 8'h31, 8'h32, 8'h33, 8'h34, 8'h35, 8'h36, 8'h37, 8'h38, 8'h39

`define IS_DIGIT(x) \
	((x) <= 8'h39 && (x) >= 8'h30)

module CommandsParser(
	input               clk, rst,
	input      [7:0]    data,
	input               dataReady,
	output              commandReady,  // only be '1' in one clock
	output CommandsType commandType,
	output Param_t      param,
	output     [7:0]    debug
);

CommandsState status;

assign debug = status;

// DFA
always @(posedge clk or posedge rst)
begin
	if(rst) begin
		status = START;
	end else if(dataReady) begin
		unique case(status)
			START:
				case(data)
					8'h1b: // ESC
						status = ESC;
					default:
						status = START;
				endcase
			ESC:
				case(data)
					8'h44, // 'D'
					8'h45, // 'E'
					8'h4d: // 'M'
						status = START;
					8'h5b: // '['
						status = CSI;
					default: status = START;
				endcase
			CSI:
				if(`IS_DIGIT(data)) // digit
					status = PN1;
				else // non-digit
					status = START;
			DEL1:
				if(`IS_DIGIT(data)) // digit
					status = PN2;
				else  // non-digit
					status = START;
			PN1:
				case(data)
					`CASE_DIGIT: // digit
						status = PN1;
					8'h3b: // ';'
						status = DEL1;
					8'h41, // 'A'
					8'h42, // 'B'
					8'h43, // 'C'
					8'h44: // 'D'
						status = START;
					default:
						status = START;
				endcase
			PN2:
				case(data)
					`CASE_DIGIT: // digit
						status = PN2;
					8'h48, 8'h66: // 'H', 'f'
						status = START;
					default:
						status = START;
				endcase
			default:
				status = START;
		endcase
	end  // end if
end  // end always

// set command type 
always @(posedge clk)
begin
	if(commandReady) 
	begin
		commandReady <= 0;
	end else if(dataReady) begin
		unique case(status)
			START:
				if(data != 8'h1b) // NOT ESC
				begin
					`SET_COMMAND(INPUT)
					param.Pchar <= data;
				end
			ESC:
				case(data)
					8'h44: // 'D'
						`SET_COMMAND_BLOCK(IND)
					8'h45: // 'E'
						`SET_COMMAND_BLOCK(NEL)
					8'h4d: // 'M'
						`SET_COMMAND_BLOCK(RI)
				endcase
			CSI:
				if(`IS_DIGIT(data)) // digit
					param.Pn1 <= data - 8'h30;
				else begin  // non-digit
					case(data)
						8'h48, 8'h66: // 'H', 'f'
						begin
							param.Pn1 <= 1;
							param.Pn2 <= 1;
							`SET_COMMAND(CUP)
						end
					endcase
				end
			DEL1:
				if(`IS_DIGIT(data)) // digit
					param.Pn2 <= data - 8'h30;
			PN1:
				case(data)
					`CASE_DIGIT: // digit
						param.Pn1 <= param.Pn1 * 8'd10 + (data - 8'h30);
					8'h41: // 'A'
						`SET_COMMAND_BLOCK(CUU)
					8'h42: // 'B'
						`SET_COMMAND_BLOCK(CUD)
					8'h43: // 'C'
						`SET_COMMAND_BLOCK(CUF)
					8'h44: // 'D'
						`SET_COMMAND_BLOCK(CUB)
				endcase
			PN2:
				case(data)
					`CASE_DIGIT: // digit
						param.Pn2 <= param.Pn2 * 8'd10 + (data - 8'h30);
					8'h48, 8'h66: // 'H', 'f'
						`SET_COMMAND_BLOCK(CUP)
				endcase
		endcase
	end  // end if
end  // end always

endmodule
