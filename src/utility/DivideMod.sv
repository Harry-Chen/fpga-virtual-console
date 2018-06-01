module DivideMod(
	input  [7:0] X,
	output [7:0] Q, R
);

parameter Mod = 2;

always_comb
begin
	case(X)
		8'h00: begin
			Q = 8'h00 / 8'(Mod);
			R = 8'h00 % 8'(Mod);
		end
		8'h01: begin
			Q = 8'h01 / 8'(Mod);
			R = 8'h01 % 8'(Mod);
		end
		8'h02: begin
			Q = 8'h02 / 8'(Mod);
			R = 8'h02 % 8'(Mod);
		end
		8'h03: begin
			Q = 8'h03 / 8'(Mod);
			R = 8'h03 % 8'(Mod);
		end
		8'h04: begin
			Q = 8'h04 / 8'(Mod);
			R = 8'h04 % 8'(Mod);
		end
		8'h05: begin
			Q = 8'h05 / 8'(Mod);
			R = 8'h05 % 8'(Mod);
		end
		8'h06: begin
			Q = 8'h06 / 8'(Mod);
			R = 8'h06 % 8'(Mod);
		end
		8'h07: begin
			Q = 8'h07 / 8'(Mod);
			R = 8'h07 % 8'(Mod);
		end
		8'h08: begin
			Q = 8'h08 / 8'(Mod);
			R = 8'h08 % 8'(Mod);
		end
		8'h09: begin
			Q = 8'h09 / 8'(Mod);
			R = 8'h09 % 8'(Mod);
		end
		8'h0a: begin
			Q = 8'h0a / 8'(Mod);
			R = 8'h0a % 8'(Mod);
		end
		8'h0b: begin
			Q = 8'h0b / 8'(Mod);
			R = 8'h0b % 8'(Mod);
		end
		8'h0c: begin
			Q = 8'h0c / 8'(Mod);
			R = 8'h0c % 8'(Mod);
		end
		8'h0d: begin
			Q = 8'h0d / 8'(Mod);
			R = 8'h0d % 8'(Mod);
		end
		8'h0e: begin
			Q = 8'h0e / 8'(Mod);
			R = 8'h0e % 8'(Mod);
		end
		8'h0f: begin
			Q = 8'h0f / 8'(Mod);
			R = 8'h0f % 8'(Mod);
		end
		8'h10: begin
			Q = 8'h10 / 8'(Mod);
			R = 8'h10 % 8'(Mod);
		end
		8'h11: begin
			Q = 8'h11 / 8'(Mod);
			R = 8'h11 % 8'(Mod);
		end
		8'h12: begin
			Q = 8'h12 / 8'(Mod);
			R = 8'h12 % 8'(Mod);
		end
		8'h13: begin
			Q = 8'h13 / 8'(Mod);
			R = 8'h13 % 8'(Mod);
		end
		8'h14: begin
			Q = 8'h14 / 8'(Mod);
			R = 8'h14 % 8'(Mod);
		end
		8'h15: begin
			Q = 8'h15 / 8'(Mod);
			R = 8'h15 % 8'(Mod);
		end
		8'h16: begin
			Q = 8'h16 / 8'(Mod);
			R = 8'h16 % 8'(Mod);
		end
		8'h17: begin
			Q = 8'h17 / 8'(Mod);
			R = 8'h17 % 8'(Mod);
		end
		8'h18: begin
			Q = 8'h18 / 8'(Mod);
			R = 8'h18 % 8'(Mod);
		end
		8'h19: begin
			Q = 8'h19 / 8'(Mod);
			R = 8'h19 % 8'(Mod);
		end
		8'h1a: begin
			Q = 8'h1a / 8'(Mod);
			R = 8'h1a % 8'(Mod);
		end
		8'h1b: begin
			Q = 8'h1b / 8'(Mod);
			R = 8'h1b % 8'(Mod);
		end
		8'h1c: begin
			Q = 8'h1c / 8'(Mod);
			R = 8'h1c % 8'(Mod);
		end
		8'h1d: begin
			Q = 8'h1d / 8'(Mod);
			R = 8'h1d % 8'(Mod);
		end
		8'h1e: begin
			Q = 8'h1e / 8'(Mod);
			R = 8'h1e % 8'(Mod);
		end
		8'h1f: begin
			Q = 8'h1f / 8'(Mod);
			R = 8'h1f % 8'(Mod);
		end
		8'h20: begin
			Q = 8'h20 / 8'(Mod);
			R = 8'h20 % 8'(Mod);
		end
		8'h21: begin
			Q = 8'h21 / 8'(Mod);
			R = 8'h21 % 8'(Mod);
		end
		8'h22: begin
			Q = 8'h22 / 8'(Mod);
			R = 8'h22 % 8'(Mod);
		end
		8'h23: begin
			Q = 8'h23 / 8'(Mod);
			R = 8'h23 % 8'(Mod);
		end
		8'h24: begin
			Q = 8'h24 / 8'(Mod);
			R = 8'h24 % 8'(Mod);
		end
		8'h25: begin
			Q = 8'h25 / 8'(Mod);
			R = 8'h25 % 8'(Mod);
		end
		8'h26: begin
			Q = 8'h26 / 8'(Mod);
			R = 8'h26 % 8'(Mod);
		end
		8'h27: begin
			Q = 8'h27 / 8'(Mod);
			R = 8'h27 % 8'(Mod);
		end
		8'h28: begin
			Q = 8'h28 / 8'(Mod);
			R = 8'h28 % 8'(Mod);
		end
		8'h29: begin
			Q = 8'h29 / 8'(Mod);
			R = 8'h29 % 8'(Mod);
		end
		8'h2a: begin
			Q = 8'h2a / 8'(Mod);
			R = 8'h2a % 8'(Mod);
		end
		8'h2b: begin
			Q = 8'h2b / 8'(Mod);
			R = 8'h2b % 8'(Mod);
		end
		8'h2c: begin
			Q = 8'h2c / 8'(Mod);
			R = 8'h2c % 8'(Mod);
		end
		8'h2d: begin
			Q = 8'h2d / 8'(Mod);
			R = 8'h2d % 8'(Mod);
		end
		8'h2e: begin
			Q = 8'h2e / 8'(Mod);
			R = 8'h2e % 8'(Mod);
		end
		8'h2f: begin
			Q = 8'h2f / 8'(Mod);
			R = 8'h2f % 8'(Mod);
		end
		8'h30: begin
			Q = 8'h30 / 8'(Mod);
			R = 8'h30 % 8'(Mod);
		end
		8'h31: begin
			Q = 8'h31 / 8'(Mod);
			R = 8'h31 % 8'(Mod);
		end
		8'h32: begin
			Q = 8'h32 / 8'(Mod);
			R = 8'h32 % 8'(Mod);
		end
		8'h33: begin
			Q = 8'h33 / 8'(Mod);
			R = 8'h33 % 8'(Mod);
		end
		8'h34: begin
			Q = 8'h34 / 8'(Mod);
			R = 8'h34 % 8'(Mod);
		end
		8'h35: begin
			Q = 8'h35 / 8'(Mod);
			R = 8'h35 % 8'(Mod);
		end
		8'h36: begin
			Q = 8'h36 / 8'(Mod);
			R = 8'h36 % 8'(Mod);
		end
		8'h37: begin
			Q = 8'h37 / 8'(Mod);
			R = 8'h37 % 8'(Mod);
		end
		8'h38: begin
			Q = 8'h38 / 8'(Mod);
			R = 8'h38 % 8'(Mod);
		end
		8'h39: begin
			Q = 8'h39 / 8'(Mod);
			R = 8'h39 % 8'(Mod);
		end
		8'h3a: begin
			Q = 8'h3a / 8'(Mod);
			R = 8'h3a % 8'(Mod);
		end
		8'h3b: begin
			Q = 8'h3b / 8'(Mod);
			R = 8'h3b % 8'(Mod);
		end
		8'h3c: begin
			Q = 8'h3c / 8'(Mod);
			R = 8'h3c % 8'(Mod);
		end
		8'h3d: begin
			Q = 8'h3d / 8'(Mod);
			R = 8'h3d % 8'(Mod);
		end
		8'h3e: begin
			Q = 8'h3e / 8'(Mod);
			R = 8'h3e % 8'(Mod);
		end
		8'h3f: begin
			Q = 8'h3f / 8'(Mod);
			R = 8'h3f % 8'(Mod);
		end
		8'h40: begin
			Q = 8'h40 / 8'(Mod);
			R = 8'h40 % 8'(Mod);
		end
		8'h41: begin
			Q = 8'h41 / 8'(Mod);
			R = 8'h41 % 8'(Mod);
		end
		8'h42: begin
			Q = 8'h42 / 8'(Mod);
			R = 8'h42 % 8'(Mod);
		end
		8'h43: begin
			Q = 8'h43 / 8'(Mod);
			R = 8'h43 % 8'(Mod);
		end
		8'h44: begin
			Q = 8'h44 / 8'(Mod);
			R = 8'h44 % 8'(Mod);
		end
		8'h45: begin
			Q = 8'h45 / 8'(Mod);
			R = 8'h45 % 8'(Mod);
		end
		8'h46: begin
			Q = 8'h46 / 8'(Mod);
			R = 8'h46 % 8'(Mod);
		end
		8'h47: begin
			Q = 8'h47 / 8'(Mod);
			R = 8'h47 % 8'(Mod);
		end
		8'h48: begin
			Q = 8'h48 / 8'(Mod);
			R = 8'h48 % 8'(Mod);
		end
		8'h49: begin
			Q = 8'h49 / 8'(Mod);
			R = 8'h49 % 8'(Mod);
		end
		8'h4a: begin
			Q = 8'h4a / 8'(Mod);
			R = 8'h4a % 8'(Mod);
		end
		8'h4b: begin
			Q = 8'h4b / 8'(Mod);
			R = 8'h4b % 8'(Mod);
		end
		8'h4c: begin
			Q = 8'h4c / 8'(Mod);
			R = 8'h4c % 8'(Mod);
		end
		8'h4d: begin
			Q = 8'h4d / 8'(Mod);
			R = 8'h4d % 8'(Mod);
		end
		8'h4e: begin
			Q = 8'h4e / 8'(Mod);
			R = 8'h4e % 8'(Mod);
		end
		8'h4f: begin
			Q = 8'h4f / 8'(Mod);
			R = 8'h4f % 8'(Mod);
		end
		8'h50: begin
			Q = 8'h50 / 8'(Mod);
			R = 8'h50 % 8'(Mod);
		end
		8'h51: begin
			Q = 8'h51 / 8'(Mod);
			R = 8'h51 % 8'(Mod);
		end
		8'h52: begin
			Q = 8'h52 / 8'(Mod);
			R = 8'h52 % 8'(Mod);
		end
		8'h53: begin
			Q = 8'h53 / 8'(Mod);
			R = 8'h53 % 8'(Mod);
		end
		8'h54: begin
			Q = 8'h54 / 8'(Mod);
			R = 8'h54 % 8'(Mod);
		end
		8'h55: begin
			Q = 8'h55 / 8'(Mod);
			R = 8'h55 % 8'(Mod);
		end
		8'h56: begin
			Q = 8'h56 / 8'(Mod);
			R = 8'h56 % 8'(Mod);
		end
		8'h57: begin
			Q = 8'h57 / 8'(Mod);
			R = 8'h57 % 8'(Mod);
		end
		8'h58: begin
			Q = 8'h58 / 8'(Mod);
			R = 8'h58 % 8'(Mod);
		end
		8'h59: begin
			Q = 8'h59 / 8'(Mod);
			R = 8'h59 % 8'(Mod);
		end
		8'h5a: begin
			Q = 8'h5a / 8'(Mod);
			R = 8'h5a % 8'(Mod);
		end
		8'h5b: begin
			Q = 8'h5b / 8'(Mod);
			R = 8'h5b % 8'(Mod);
		end
		8'h5c: begin
			Q = 8'h5c / 8'(Mod);
			R = 8'h5c % 8'(Mod);
		end
		8'h5d: begin
			Q = 8'h5d / 8'(Mod);
			R = 8'h5d % 8'(Mod);
		end
		8'h5e: begin
			Q = 8'h5e / 8'(Mod);
			R = 8'h5e % 8'(Mod);
		end
		8'h5f: begin
			Q = 8'h5f / 8'(Mod);
			R = 8'h5f % 8'(Mod);
		end
		8'h60: begin
			Q = 8'h60 / 8'(Mod);
			R = 8'h60 % 8'(Mod);
		end
		8'h61: begin
			Q = 8'h61 / 8'(Mod);
			R = 8'h61 % 8'(Mod);
		end
		8'h62: begin
			Q = 8'h62 / 8'(Mod);
			R = 8'h62 % 8'(Mod);
		end
		8'h63: begin
			Q = 8'h63 / 8'(Mod);
			R = 8'h63 % 8'(Mod);
		end
		8'h64: begin
			Q = 8'h64 / 8'(Mod);
			R = 8'h64 % 8'(Mod);
		end
		8'h65: begin
			Q = 8'h65 / 8'(Mod);
			R = 8'h65 % 8'(Mod);
		end
		8'h66: begin
			Q = 8'h66 / 8'(Mod);
			R = 8'h66 % 8'(Mod);
		end
		8'h67: begin
			Q = 8'h67 / 8'(Mod);
			R = 8'h67 % 8'(Mod);
		end
		8'h68: begin
			Q = 8'h68 / 8'(Mod);
			R = 8'h68 % 8'(Mod);
		end
		8'h69: begin
			Q = 8'h69 / 8'(Mod);
			R = 8'h69 % 8'(Mod);
		end
		8'h6a: begin
			Q = 8'h6a / 8'(Mod);
			R = 8'h6a % 8'(Mod);
		end
		8'h6b: begin
			Q = 8'h6b / 8'(Mod);
			R = 8'h6b % 8'(Mod);
		end
		8'h6c: begin
			Q = 8'h6c / 8'(Mod);
			R = 8'h6c % 8'(Mod);
		end
		8'h6d: begin
			Q = 8'h6d / 8'(Mod);
			R = 8'h6d % 8'(Mod);
		end
		8'h6e: begin
			Q = 8'h6e / 8'(Mod);
			R = 8'h6e % 8'(Mod);
		end
		8'h6f: begin
			Q = 8'h6f / 8'(Mod);
			R = 8'h6f % 8'(Mod);
		end
		8'h70: begin
			Q = 8'h70 / 8'(Mod);
			R = 8'h70 % 8'(Mod);
		end
		8'h71: begin
			Q = 8'h71 / 8'(Mod);
			R = 8'h71 % 8'(Mod);
		end
		8'h72: begin
			Q = 8'h72 / 8'(Mod);
			R = 8'h72 % 8'(Mod);
		end
		8'h73: begin
			Q = 8'h73 / 8'(Mod);
			R = 8'h73 % 8'(Mod);
		end
		8'h74: begin
			Q = 8'h74 / 8'(Mod);
			R = 8'h74 % 8'(Mod);
		end
		8'h75: begin
			Q = 8'h75 / 8'(Mod);
			R = 8'h75 % 8'(Mod);
		end
		8'h76: begin
			Q = 8'h76 / 8'(Mod);
			R = 8'h76 % 8'(Mod);
		end
		8'h77: begin
			Q = 8'h77 / 8'(Mod);
			R = 8'h77 % 8'(Mod);
		end
		8'h78: begin
			Q = 8'h78 / 8'(Mod);
			R = 8'h78 % 8'(Mod);
		end
		8'h79: begin
			Q = 8'h79 / 8'(Mod);
			R = 8'h79 % 8'(Mod);
		end
		8'h7a: begin
			Q = 8'h7a / 8'(Mod);
			R = 8'h7a % 8'(Mod);
		end
		8'h7b: begin
			Q = 8'h7b / 8'(Mod);
			R = 8'h7b % 8'(Mod);
		end
		8'h7c: begin
			Q = 8'h7c / 8'(Mod);
			R = 8'h7c % 8'(Mod);
		end
		8'h7d: begin
			Q = 8'h7d / 8'(Mod);
			R = 8'h7d % 8'(Mod);
		end
		8'h7e: begin
			Q = 8'h7e / 8'(Mod);
			R = 8'h7e % 8'(Mod);
		end
		8'h7f: begin
			Q = 8'h7f / 8'(Mod);
			R = 8'h7f % 8'(Mod);
		end
		8'h80: begin
			Q = 8'h80 / 8'(Mod);
			R = 8'h80 % 8'(Mod);
		end
		8'h81: begin
			Q = 8'h81 / 8'(Mod);
			R = 8'h81 % 8'(Mod);
		end
		8'h82: begin
			Q = 8'h82 / 8'(Mod);
			R = 8'h82 % 8'(Mod);
		end
		8'h83: begin
			Q = 8'h83 / 8'(Mod);
			R = 8'h83 % 8'(Mod);
		end
		8'h84: begin
			Q = 8'h84 / 8'(Mod);
			R = 8'h84 % 8'(Mod);
		end
		8'h85: begin
			Q = 8'h85 / 8'(Mod);
			R = 8'h85 % 8'(Mod);
		end
		8'h86: begin
			Q = 8'h86 / 8'(Mod);
			R = 8'h86 % 8'(Mod);
		end
		8'h87: begin
			Q = 8'h87 / 8'(Mod);
			R = 8'h87 % 8'(Mod);
		end
		8'h88: begin
			Q = 8'h88 / 8'(Mod);
			R = 8'h88 % 8'(Mod);
		end
		8'h89: begin
			Q = 8'h89 / 8'(Mod);
			R = 8'h89 % 8'(Mod);
		end
		8'h8a: begin
			Q = 8'h8a / 8'(Mod);
			R = 8'h8a % 8'(Mod);
		end
		8'h8b: begin
			Q = 8'h8b / 8'(Mod);
			R = 8'h8b % 8'(Mod);
		end
		8'h8c: begin
			Q = 8'h8c / 8'(Mod);
			R = 8'h8c % 8'(Mod);
		end
		8'h8d: begin
			Q = 8'h8d / 8'(Mod);
			R = 8'h8d % 8'(Mod);
		end
		8'h8e: begin
			Q = 8'h8e / 8'(Mod);
			R = 8'h8e % 8'(Mod);
		end
		8'h8f: begin
			Q = 8'h8f / 8'(Mod);
			R = 8'h8f % 8'(Mod);
		end
		8'h90: begin
			Q = 8'h90 / 8'(Mod);
			R = 8'h90 % 8'(Mod);
		end
		8'h91: begin
			Q = 8'h91 / 8'(Mod);
			R = 8'h91 % 8'(Mod);
		end
		8'h92: begin
			Q = 8'h92 / 8'(Mod);
			R = 8'h92 % 8'(Mod);
		end
		8'h93: begin
			Q = 8'h93 / 8'(Mod);
			R = 8'h93 % 8'(Mod);
		end
		8'h94: begin
			Q = 8'h94 / 8'(Mod);
			R = 8'h94 % 8'(Mod);
		end
		8'h95: begin
			Q = 8'h95 / 8'(Mod);
			R = 8'h95 % 8'(Mod);
		end
		8'h96: begin
			Q = 8'h96 / 8'(Mod);
			R = 8'h96 % 8'(Mod);
		end
		8'h97: begin
			Q = 8'h97 / 8'(Mod);
			R = 8'h97 % 8'(Mod);
		end
		8'h98: begin
			Q = 8'h98 / 8'(Mod);
			R = 8'h98 % 8'(Mod);
		end
		8'h99: begin
			Q = 8'h99 / 8'(Mod);
			R = 8'h99 % 8'(Mod);
		end
		8'h9a: begin
			Q = 8'h9a / 8'(Mod);
			R = 8'h9a % 8'(Mod);
		end
		8'h9b: begin
			Q = 8'h9b / 8'(Mod);
			R = 8'h9b % 8'(Mod);
		end
		8'h9c: begin
			Q = 8'h9c / 8'(Mod);
			R = 8'h9c % 8'(Mod);
		end
		8'h9d: begin
			Q = 8'h9d / 8'(Mod);
			R = 8'h9d % 8'(Mod);
		end
		8'h9e: begin
			Q = 8'h9e / 8'(Mod);
			R = 8'h9e % 8'(Mod);
		end
		8'h9f: begin
			Q = 8'h9f / 8'(Mod);
			R = 8'h9f % 8'(Mod);
		end
		8'ha0: begin
			Q = 8'ha0 / 8'(Mod);
			R = 8'ha0 % 8'(Mod);
		end
		8'ha1: begin
			Q = 8'ha1 / 8'(Mod);
			R = 8'ha1 % 8'(Mod);
		end
		8'ha2: begin
			Q = 8'ha2 / 8'(Mod);
			R = 8'ha2 % 8'(Mod);
		end
		8'ha3: begin
			Q = 8'ha3 / 8'(Mod);
			R = 8'ha3 % 8'(Mod);
		end
		8'ha4: begin
			Q = 8'ha4 / 8'(Mod);
			R = 8'ha4 % 8'(Mod);
		end
		8'ha5: begin
			Q = 8'ha5 / 8'(Mod);
			R = 8'ha5 % 8'(Mod);
		end
		8'ha6: begin
			Q = 8'ha6 / 8'(Mod);
			R = 8'ha6 % 8'(Mod);
		end
		8'ha7: begin
			Q = 8'ha7 / 8'(Mod);
			R = 8'ha7 % 8'(Mod);
		end
		8'ha8: begin
			Q = 8'ha8 / 8'(Mod);
			R = 8'ha8 % 8'(Mod);
		end
		8'ha9: begin
			Q = 8'ha9 / 8'(Mod);
			R = 8'ha9 % 8'(Mod);
		end
		8'haa: begin
			Q = 8'haa / 8'(Mod);
			R = 8'haa % 8'(Mod);
		end
		8'hab: begin
			Q = 8'hab / 8'(Mod);
			R = 8'hab % 8'(Mod);
		end
		8'hac: begin
			Q = 8'hac / 8'(Mod);
			R = 8'hac % 8'(Mod);
		end
		8'had: begin
			Q = 8'had / 8'(Mod);
			R = 8'had % 8'(Mod);
		end
		8'hae: begin
			Q = 8'hae / 8'(Mod);
			R = 8'hae % 8'(Mod);
		end
		8'haf: begin
			Q = 8'haf / 8'(Mod);
			R = 8'haf % 8'(Mod);
		end
		8'hb0: begin
			Q = 8'hb0 / 8'(Mod);
			R = 8'hb0 % 8'(Mod);
		end
		8'hb1: begin
			Q = 8'hb1 / 8'(Mod);
			R = 8'hb1 % 8'(Mod);
		end
		8'hb2: begin
			Q = 8'hb2 / 8'(Mod);
			R = 8'hb2 % 8'(Mod);
		end
		8'hb3: begin
			Q = 8'hb3 / 8'(Mod);
			R = 8'hb3 % 8'(Mod);
		end
		8'hb4: begin
			Q = 8'hb4 / 8'(Mod);
			R = 8'hb4 % 8'(Mod);
		end
		8'hb5: begin
			Q = 8'hb5 / 8'(Mod);
			R = 8'hb5 % 8'(Mod);
		end
		8'hb6: begin
			Q = 8'hb6 / 8'(Mod);
			R = 8'hb6 % 8'(Mod);
		end
		8'hb7: begin
			Q = 8'hb7 / 8'(Mod);
			R = 8'hb7 % 8'(Mod);
		end
		8'hb8: begin
			Q = 8'hb8 / 8'(Mod);
			R = 8'hb8 % 8'(Mod);
		end
		8'hb9: begin
			Q = 8'hb9 / 8'(Mod);
			R = 8'hb9 % 8'(Mod);
		end
		8'hba: begin
			Q = 8'hba / 8'(Mod);
			R = 8'hba % 8'(Mod);
		end
		8'hbb: begin
			Q = 8'hbb / 8'(Mod);
			R = 8'hbb % 8'(Mod);
		end
		8'hbc: begin
			Q = 8'hbc / 8'(Mod);
			R = 8'hbc % 8'(Mod);
		end
		8'hbd: begin
			Q = 8'hbd / 8'(Mod);
			R = 8'hbd % 8'(Mod);
		end
		8'hbe: begin
			Q = 8'hbe / 8'(Mod);
			R = 8'hbe % 8'(Mod);
		end
		8'hbf: begin
			Q = 8'hbf / 8'(Mod);
			R = 8'hbf % 8'(Mod);
		end
		8'hc0: begin
			Q = 8'hc0 / 8'(Mod);
			R = 8'hc0 % 8'(Mod);
		end
		8'hc1: begin
			Q = 8'hc1 / 8'(Mod);
			R = 8'hc1 % 8'(Mod);
		end
		8'hc2: begin
			Q = 8'hc2 / 8'(Mod);
			R = 8'hc2 % 8'(Mod);
		end
		8'hc3: begin
			Q = 8'hc3 / 8'(Mod);
			R = 8'hc3 % 8'(Mod);
		end
		8'hc4: begin
			Q = 8'hc4 / 8'(Mod);
			R = 8'hc4 % 8'(Mod);
		end
		8'hc5: begin
			Q = 8'hc5 / 8'(Mod);
			R = 8'hc5 % 8'(Mod);
		end
		8'hc6: begin
			Q = 8'hc6 / 8'(Mod);
			R = 8'hc6 % 8'(Mod);
		end
		8'hc7: begin
			Q = 8'hc7 / 8'(Mod);
			R = 8'hc7 % 8'(Mod);
		end
		8'hc8: begin
			Q = 8'hc8 / 8'(Mod);
			R = 8'hc8 % 8'(Mod);
		end
		8'hc9: begin
			Q = 8'hc9 / 8'(Mod);
			R = 8'hc9 % 8'(Mod);
		end
		8'hca: begin
			Q = 8'hca / 8'(Mod);
			R = 8'hca % 8'(Mod);
		end
		8'hcb: begin
			Q = 8'hcb / 8'(Mod);
			R = 8'hcb % 8'(Mod);
		end
		8'hcc: begin
			Q = 8'hcc / 8'(Mod);
			R = 8'hcc % 8'(Mod);
		end
		8'hcd: begin
			Q = 8'hcd / 8'(Mod);
			R = 8'hcd % 8'(Mod);
		end
		8'hce: begin
			Q = 8'hce / 8'(Mod);
			R = 8'hce % 8'(Mod);
		end
		8'hcf: begin
			Q = 8'hcf / 8'(Mod);
			R = 8'hcf % 8'(Mod);
		end
		8'hd0: begin
			Q = 8'hd0 / 8'(Mod);
			R = 8'hd0 % 8'(Mod);
		end
		8'hd1: begin
			Q = 8'hd1 / 8'(Mod);
			R = 8'hd1 % 8'(Mod);
		end
		8'hd2: begin
			Q = 8'hd2 / 8'(Mod);
			R = 8'hd2 % 8'(Mod);
		end
		8'hd3: begin
			Q = 8'hd3 / 8'(Mod);
			R = 8'hd3 % 8'(Mod);
		end
		8'hd4: begin
			Q = 8'hd4 / 8'(Mod);
			R = 8'hd4 % 8'(Mod);
		end
		8'hd5: begin
			Q = 8'hd5 / 8'(Mod);
			R = 8'hd5 % 8'(Mod);
		end
		8'hd6: begin
			Q = 8'hd6 / 8'(Mod);
			R = 8'hd6 % 8'(Mod);
		end
		8'hd7: begin
			Q = 8'hd7 / 8'(Mod);
			R = 8'hd7 % 8'(Mod);
		end
		8'hd8: begin
			Q = 8'hd8 / 8'(Mod);
			R = 8'hd8 % 8'(Mod);
		end
		8'hd9: begin
			Q = 8'hd9 / 8'(Mod);
			R = 8'hd9 % 8'(Mod);
		end
		8'hda: begin
			Q = 8'hda / 8'(Mod);
			R = 8'hda % 8'(Mod);
		end
		8'hdb: begin
			Q = 8'hdb / 8'(Mod);
			R = 8'hdb % 8'(Mod);
		end
		8'hdc: begin
			Q = 8'hdc / 8'(Mod);
			R = 8'hdc % 8'(Mod);
		end
		8'hdd: begin
			Q = 8'hdd / 8'(Mod);
			R = 8'hdd % 8'(Mod);
		end
		8'hde: begin
			Q = 8'hde / 8'(Mod);
			R = 8'hde % 8'(Mod);
		end
		8'hdf: begin
			Q = 8'hdf / 8'(Mod);
			R = 8'hdf % 8'(Mod);
		end
		8'he0: begin
			Q = 8'he0 / 8'(Mod);
			R = 8'he0 % 8'(Mod);
		end
		8'he1: begin
			Q = 8'he1 / 8'(Mod);
			R = 8'he1 % 8'(Mod);
		end
		8'he2: begin
			Q = 8'he2 / 8'(Mod);
			R = 8'he2 % 8'(Mod);
		end
		8'he3: begin
			Q = 8'he3 / 8'(Mod);
			R = 8'he3 % 8'(Mod);
		end
		8'he4: begin
			Q = 8'he4 / 8'(Mod);
			R = 8'he4 % 8'(Mod);
		end
		8'he5: begin
			Q = 8'he5 / 8'(Mod);
			R = 8'he5 % 8'(Mod);
		end
		8'he6: begin
			Q = 8'he6 / 8'(Mod);
			R = 8'he6 % 8'(Mod);
		end
		8'he7: begin
			Q = 8'he7 / 8'(Mod);
			R = 8'he7 % 8'(Mod);
		end
		8'he8: begin
			Q = 8'he8 / 8'(Mod);
			R = 8'he8 % 8'(Mod);
		end
		8'he9: begin
			Q = 8'he9 / 8'(Mod);
			R = 8'he9 % 8'(Mod);
		end
		8'hea: begin
			Q = 8'hea / 8'(Mod);
			R = 8'hea % 8'(Mod);
		end
		8'heb: begin
			Q = 8'heb / 8'(Mod);
			R = 8'heb % 8'(Mod);
		end
		8'hec: begin
			Q = 8'hec / 8'(Mod);
			R = 8'hec % 8'(Mod);
		end
		8'hed: begin
			Q = 8'hed / 8'(Mod);
			R = 8'hed % 8'(Mod);
		end
		8'hee: begin
			Q = 8'hee / 8'(Mod);
			R = 8'hee % 8'(Mod);
		end
		8'hef: begin
			Q = 8'hef / 8'(Mod);
			R = 8'hef % 8'(Mod);
		end
		8'hf0: begin
			Q = 8'hf0 / 8'(Mod);
			R = 8'hf0 % 8'(Mod);
		end
		8'hf1: begin
			Q = 8'hf1 / 8'(Mod);
			R = 8'hf1 % 8'(Mod);
		end
		8'hf2: begin
			Q = 8'hf2 / 8'(Mod);
			R = 8'hf2 % 8'(Mod);
		end
		8'hf3: begin
			Q = 8'hf3 / 8'(Mod);
			R = 8'hf3 % 8'(Mod);
		end
		8'hf4: begin
			Q = 8'hf4 / 8'(Mod);
			R = 8'hf4 % 8'(Mod);
		end
		8'hf5: begin
			Q = 8'hf5 / 8'(Mod);
			R = 8'hf5 % 8'(Mod);
		end
		8'hf6: begin
			Q = 8'hf6 / 8'(Mod);
			R = 8'hf6 % 8'(Mod);
		end
		8'hf7: begin
			Q = 8'hf7 / 8'(Mod);
			R = 8'hf7 % 8'(Mod);
		end
		8'hf8: begin
			Q = 8'hf8 / 8'(Mod);
			R = 8'hf8 % 8'(Mod);
		end
		8'hf9: begin
			Q = 8'hf9 / 8'(Mod);
			R = 8'hf9 % 8'(Mod);
		end
		8'hfa: begin
			Q = 8'hfa / 8'(Mod);
			R = 8'hfa % 8'(Mod);
		end
		8'hfb: begin
			Q = 8'hfb / 8'(Mod);
			R = 8'hfb % 8'(Mod);
		end
		8'hfc: begin
			Q = 8'hfc / 8'(Mod);
			R = 8'hfc % 8'(Mod);
		end
		8'hfd: begin
			Q = 8'hfd / 8'(Mod);
			R = 8'hfd % 8'(Mod);
		end
		8'hfe: begin
			Q = 8'hfe / 8'(Mod);
			R = 8'hfe % 8'(Mod);
		end
		default: begin
			Q = 8'hff / 8'(Mod);
			R = 8'hff % 8'(Mod);
		end
	endcase
end

endmodule
