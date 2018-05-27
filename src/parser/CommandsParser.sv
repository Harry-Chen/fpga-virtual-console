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
					8'h28: // '('
						status = LBRACKET;
					8'h29: // '('
						status = RBRACKET;
					8'h23, 8'h2a, 8'h2b: // '#', '*', '+'
						status = TRAP;
					default: status = START;
				endcase
			CSI:
				case(data)
					`CASE_DIGIT:
						status = PN1;
					8'h3f:  // '?'
						status = QUES;
					default:
						status = START;
				endcase
			DEL1:
				if(`IS_DIGIT(data)) // digit
					status = PN2;
				else  // non-digit
					status = START;
			DEL2:
				if(`IS_DIGIT(data)) // digit
					status = PNS;
				else // non-digit
					status = START;
			QDEL1:
				if(`IS_DIGIT(data)) // digit
					status = QPNS;
				else // non-digit
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
					`CASE_DIGIT:  // digit
						status = PN2;
					8'h3b:        // ';'
						status = DEL2;
					8'h48, 8'h66: // 'H', 'f'
						status = START;
					default:
						status = START;
				endcase
			PNS:
				case(data)
					`CASE_DIGIT: // digit
						status = PNS;
					8'h3b:       // ';'
						status = DEL2;
					default:
						status = START;
				endcase
			QUES:
				if(`IS_DIGIT(data)) // digit
					status = QPN1;
				else // non-digit
					status = START;
			QPN1:
				case(data)
					`CASE_DIGIT: // digit
						status = QPN1;
					8'h3b:       // ';'
						status = QDEL1;
					default:
						status = START;
				endcase
			QPNS:
				case(data)
					`CASE_DIGIT: // digit
						status = QPNS;
					8'h3b:       // ';'
						status = QDEL1;
					default:
						status = START;
				endcase
			TRAP:
				status = START;  // trapped and ignored
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
					8'h37: // '7'
						`SET_COMMAND_BLOCK(DECSC)
					8'h38: // '8'
						`SET_COMMAND_BLOCK(DECRC)
					8'h4e: // 'N'
						`SET_COMMAND_BLOCK(SS2)
					8'h30: // '0'
						`SET_COMMAND_BLOCK(SS3)
					8'h48: // 'H'
						`SET_COMMAND_BLOCK(HTS)
				endcase
			CSI:
				case(data)
					`CASE_DIGIT: // digit
					begin
						`SET_COMMAND(INIT_PN)
						param.Pn1 <= data - 8'h30;
					end
					8'h48, 8'h66: // 'H', 'f'
					begin
						param.Pn1 <= 8'd1;
						param.Pn2 <= 8'd1;
						`SET_COMMAND(CUP)
					end
					8'h41: // 'A'
					begin
						param.Pn1 <= 8'd1;
						`SET_COMMAND_BLOCK(CUU)
					end
					8'h42: // 'B'
					begin
						param.Pn1 <= 8'd1;
						`SET_COMMAND_BLOCK(CUD)
					end
					8'h43: // 'C'
					begin
						param.Pn1 <= 8'd1;
						`SET_COMMAND_BLOCK(CUF)
					end
					8'h44: // 'D'
					begin
						param.Pn1 <= 8'd1;
						`SET_COMMAND_BLOCK(CUB)
					end
					8'h72:  // 'r'
					begin
						param.Pn1 <= 8'd1;
						param.Pn2 <= `CONSOLE_LINES;
						`SET_COMMAND(DECSTBM)
					end
					8'h4a: // 'J'
					begin
						param.Pn1 <= 8'd0;
						`SET_COMMAND(ED)
					end
					8'h4b: // 'K'
					begin
						param.Pn1 <= 8'd0;
						`SET_COMMAND(EL)
					end
					8'h50: // 'P'
					begin
						param.Pn1 <= 8'd1;
						`SET_COMMAND_BLOCK(DCH)
					end
					8'h40: // '@'
					begin
						param.Pn1 <= 8'd1;
						`SET_COMMAND_BLOCK(ICH)
					end
					8'h58: // 'X'
					begin
						param.Pn1 <= 8'd1;
						`SET_COMMAND_BLOCK(ECH)
					end
					8'h4c: // 'L'
					begin
						param.Pn1 <= 8'd1;
						`SET_COMMAND_BLOCK(IL)
					end
					8'h4d: // 'M'
					begin
						param.Pn1 <= 8'd1;
						`SET_COMMAND_BLOCK(DL)
					end
					8'h6d: // 'm'
						`SET_COMMAND_BLOCK(SGR0)
				endcase
			DEL1:
				if(`IS_DIGIT(data)) // digit
					param.Pn2 <= data - 8'h30;
			DEL2:
				if(`IS_DIGIT(data)) // digit
					param.Pns <= data - 8'h30;
			QDEL1:
				if(`IS_DIGIT(data)) // digit
					param.Pns <= data - 8'h30;
			QUES:
				if(`IS_DIGIT(data)) // digit
				begin
					param.Pn1 <= data - 8'h30;
					`SET_COMMAND(INIT_PN)
				end
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
					8'h4a: // 'J'
						`SET_COMMAND_BLOCK(ED)
					8'h4b: // 'K'
						`SET_COMMAND_BLOCK(EL)
					8'h40: // '@'
						`SET_COMMAND_BLOCK(ICH)
					8'h50: // 'P'
						`SET_COMMAND_BLOCK(DCH)
					8'h58: // 'X'
						`SET_COMMAND_BLOCK(ECH)
					8'h4c: // 'L'
						`SET_COMMAND_BLOCK(IL)
					8'h4d: // 'M'
						`SET_COMMAND_BLOCK(DL)
					8'h67: // 'g'
						`SET_COMMAND_BLOCK(TBC)
					8'h6d: // 'm'
					begin
						param.Pns <= param.Pn1;
						`SET_COMMAND_BLOCK(SGR)
					end
					8'h3b: // ';'
					begin
						param.Pns <= param.Pn1;
						`SET_COMMAND_BLOCK(EMIT_PN)
					end
				endcase
			PN2:
				case(data)
					`CASE_DIGIT: // digit
						param.Pn2 <= param.Pn2 * 8'd10 + (data - 8'h30);
					8'h48, 8'h66: // 'H', 'f'
						`SET_COMMAND_BLOCK(CUP)
					8'h72: // 'r'
						`SET_COMMAND_BLOCK(DECSTBM)
					8'h6d: // 'm'
					begin
						param.Pns <= param.Pn2;
						`SET_COMMAND_BLOCK(SGR)
					end
					8'h3b: // ';'
					begin
						param.Pns <= param.Pn2;
						`SET_COMMAND(EMIT_PN)
					end
				endcase
			PNS:
				case(data)
					`CASE_DIGIT: // digit
						param.Pns <= param.Pns * 8'd10 + (data - 8'h30);
					8'h3b: // ';'
						`SET_COMMAND_BLOCK(EMIT_PN)
					8'h6d: // 'm'
						`SET_COMMAND_BLOCK(SGR)
				endcase
			QPN1:
				case(data)
					`CASE_DIGIT: // digit
						param.Pn1 <= param.Pn1 * 8'd10 + (data - 8'h30);
					8'h3b: // ';'
					begin
						param.Pns <= param.Pn1;
						`SET_COMMAND(EMIT_PN)
					end
					8'h68: // 'h'
						`SET_COMMAND_BLOCK(SETMODE)
					8'h6c: // 'l'
						`SET_COMMAND_BLOCK(RESETMODE)
				endcase
			QPNS:
				case(data)
					`CASE_DIGIT: // digit
						param.Pns <= param.Pns * 8'd10 + (data - 8'h30);
					8'h3b: // ';'
						`SET_COMMAND_BLOCK(EMIT_PN)
					8'h68: // 'h'
						`SET_COMMAND_BLOCK(SETMODE)
					8'h6c: // 'l'
						`SET_COMMAND_BLOCK(RESETMODE)
				endcase
			LBRACKET:
				case(data)
					8'h41, 8'h42, 8'h30, 8'h31, 8'h32:
					begin
						param.Pn1 <= data;
						`SET_COMMAND(SCS0)
					end
				endcase
			RBRACKET:
				case(data)
					8'h41, 8'h42, 8'h30, 8'h31, 8'h32:
					begin
						param.Pn1 <= data;
						`SET_COMMAND(SCS1)
					end
				endcase
		endcase
	end  // end if
end  // end always

endmodule
