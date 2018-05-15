module LedDecoder(
	input   [3:0]	hex,
	output  [6:0]	segments
	);

	always_comb begin
		unique case(hex)
			4'h0: segments = 7'b0111111;
			4'h1: segments = 7'b0000011;
			4'h2: segments = 7'b1011101;
			4'h3: segments = 7'b1001111;
			4'h4: segments = 7'b1100011;
			4'h5: segments = 7'b1101110;
			4'h6: segments = 7'b1111110;
			4'h7: segments = 7'b0001011;
			4'h8: segments = 7'b1111111;
			4'h9: segments = 7'b1101111;
			4'ha: segments = 7'b1111011;
			4'hb: segments = 7'b1110110;
			4'hc: segments = 7'b0111100;
			4'hd: segments = 7'b1010111;
			4'he: segments = 7'b1111100;
			4'hf: segments = 7'b1111000;
		endcase
	end
endmodule // LedDecoder
