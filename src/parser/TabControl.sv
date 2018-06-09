`include "DataType.svh"

`define SET_TAB_FIND(dir, step) \
begin \
	status <= Tab_Loop; \
	tab_step <= step; \
	tab_now <= term.cursor.y; \
	tab_dir <= dir; \
end

`define SET_TAB_FORWARD(step) `SET_TAB_FIND(1'b1, step)
`define SET_TAB_BACKWARD(step) `SET_TAB_FIND(1'b0, step)

module TabControl(
	input               clk, rst,
	input               commandReady,
	input  CommandsType commandType,
	input  Param_t      param,
	input  Terminal_t   term,
	output reg [7:0]    tabPos,
	output reg          tabReady
);

logic [`CONSOLE_COLUMNS - 1:0] tab_stop;

enum {
	Tab_Idle, Tab_Loop
} status;

logic tab_dir;  // 0 - backward, 1 - forward
logic [7:0] tab_step, tab_now, tab_next, tab_step_next;

// Set TabStop
always_ff @(posedge clk, posedge rst)
begin
	if(rst)
	begin
		tab_stop <= {(`CONSOLE_COLUMNS / 8){8'b0000_0001}};
	end else if(commandReady) begin
		case(commandType)
			HTS:
				tab_stop[term.cursor.y] <= 1'b1;
			TBC:
				if(param.Pn1 == 8'd0)
					tab_stop[term.cursor.y] <= 1'b0;
				else tab_stop <= {`CONSOLE_COLUMNS{1'b0}};
		endcase
	end
end

// Find TabStop
always_ff @(posedge clk, posedge rst)
begin
	if(rst)
	begin
		status <= Tab_Idle;
	end else begin
		if(status == Tab_Idle)
		begin
			if(commandReady && commandType == INPUT && param.Pchar == 8'o11)
				`SET_TAB_FORWARD(8'd1)
		end else begin
			if(tab_step == 8'd0)
			begin
				status <= Tab_Idle;
			end else status <= Tab_Loop;
			tab_now <= tab_next;
			tab_step <= tab_step_next;
		end
	end
end

always_ff @(posedge clk)
begin
	if(tabReady == 1'b1)
		tabReady <= 1'b0;

	if(status == Tab_Loop && tab_step == 8'd0)
	begin
		tabPos <= tab_now;
		tabReady <= 1'b1;
	end
end

always_comb
begin
	if(tab_dir == 1'b1)
		tab_next = tab_now + 8'd1;
	else tab_next = tab_now - 8'd1;

	if(tab_next == 8'd0 || tab_next == 8'(`CONSOLE_COLUMNS))
		tab_step_next = 8'd0;
	else tab_step_next = tab_step - tab_stop[tab_next];
end

endmodule 
