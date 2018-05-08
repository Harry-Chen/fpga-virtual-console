module KeyboardToUart
	(	
		input wire clk, reset,
		input wire ps2d, ps2c,
		output wire tx
	);
		
	// signal declaration
	wire [7:0] scan_code, ascii_code;
	wire scan_code_ready;
	wire letter_case;
	reg  [7:0] r_reg;                       // baud rate generator register
	wire [7:0] r_next;                      // baud rate generator next state logic
	wire tick;                              // baud tick for uart_rx & uart_tx
	
	// instantiate keyboard scan code circuit
	keyboard kb_unit (.clk(clk), .reset(reset), .ps2d(ps2d), .ps2c(ps2c),
			 .scan_code(scan_code), .scan_code_ready(scan_code_ready), .letter_case_out(letter_case));
	
	// instantiate uart tx
	uart_tx tx_unit (.clk(clk), .reset(reset), .tx_start(scan_code_ready),
			.baud_tick(tick), .tx_data(ascii_code), .tx_done_tick(), .tx(tx));
					
	// instantiate key-to-ascii code conversion circuit
	key2ascii k2a_unit (.letter_case(letter_case), .scan_code(scan_code), .ascii_code(ascii_code));
	
	// register for oversampling baud rate generator
	always @(posedge clk, posedge reset)
		if(reset)
			r_reg <= 0;
		else
			r_reg <= r_next;
	
	// next state logic, mod 163 counter
	assign r_next = r_reg == 163 ? 0 : r_reg + 1;
	
	// tick high once every 163 clock cycles, for 19200 baud
	assign tick = r_reg == 163 ? 1 : 0;

endmodule
