`include "DataType.svh"
module ScancodeDecoder(
    input   Scancode_t      scancode,
    input                   special,
    input                   shift,
    input                   ctrl,
    output  UartFifoData_t  fifoInData,
    output                  valid               
    );

    logic [7:0] length;
    logic [55:0] content;

    assign fifoInData[55:0] = content;
    assign fifoInData.length = length;

    always_comb begin
        valid = 1;
        content = 0;
        if (ctrl) begin
            if (!special) begin
                // see https://vt100.net/docs/vt100-ug/table3-5.html
                unique case (scancode)
                    8'h29: content = 8'h00;   // space
                    8'h1c: content = 8'h01;   // A
                    8'h32: content = 8'h02;   // B
                    8'h21: content = 8'h03;   // C
                    8'h23: content = 8'h04;   // D
                    8'h24: content = 8'h05;   // E
                    8'h2b: content = 8'h06;   // F
                    8'h34: content = 8'h07;   // G
                    8'h33: content = 8'h08;   // H
                    8'h43: content = 8'h09;   // I
                    8'h3b: content = 8'h0A;   // J
                    8'h42: content = 8'h0B;   // K
                    8'h4b: content = 8'h0C;   // L
                    8'h3a: content = 8'h0D;   // M
                    8'h31: content = 8'h0E;   // N
                    8'h44: content = 8'h0F;   // O
                    8'h4d: content = 8'h10;   // P
                    8'h15: content = 8'h11;   // Q
                    8'h2d: content = 8'h12;   // R
                    8'h1b: content = 8'h13;   // S
                    8'h2c: content = 8'h14;   // T
                    8'h3c: content = 8'h15;   // U
                    8'h2a: content = 8'h16;   // V
                    8'h1d: content = 8'h17;   // W
                    8'h22: content = 8'h18;   // X
                    8'h35: content = 8'h19;   // Y
                    8'h1a: content = 8'h1A;   // Z
                    8'h54: content = 8'h1B;   // [
                    8'h5d: content = 8'h1C;   // \
                    8'h5b: content = 8'h1D;   // ]
                    8'h0e: content = 8'h1E;   // ~
                    8'h4a: content = 8'h1F;   // ?
                    default: valid = 0;
                endcase
            end

            else begin
                unique case (scancode)
                    8'h75: content = 48'h1B_5B_31_3B_35_41; // Up arrow    -> `[1;5A
                    8'h72: content = 48'h1B_5B_31_3B_35_42; // Down arrow  -> `[1;5B
                    8'h74: content = 48'h1B_5B_31_3B_35_43; // Right arrow -> `[1;5C
                    8'h6B: content = 48'h1B_5B_31_3B_35_44; // Left arrow  -> `[1;5D
                    default: valid = 0;
                endcase
            end
        end

        else if (shift) begin
            if (!special) begin
                unique case (scancode)
                    8'h45: content = 8'h29;   // )
                    8'h16: content = 8'h21;   // !
                    8'h1e: content = 8'h40;   // @
                    8'h26: content = 8'h23;   // #
                    8'h25: content = 8'h24;   // $
                    8'h2e: content = 8'h25;   // %
                    8'h36: content = 8'h5E;   // ^
                    8'h3d: content = 8'h26;   // &
                    8'h3e: content = 8'h2A;   // *
                    8'h46: content = 8'h28;   // (
                    8'h1c: content = 8'h41;   // A
                    8'h32: content = 8'h42;   // B
                    8'h21: content = 8'h43;   // C
                    8'h23: content = 8'h44;   // D
                    8'h24: content = 8'h45;   // E
                    8'h2b: content = 8'h46;   // F
                    8'h34: content = 8'h47;   // G
                    8'h33: content = 8'h48;   // H
                    8'h43: content = 8'h49;   // I
                    8'h3b: content = 8'h4A;   // J
                    8'h42: content = 8'h4B;   // K
                    8'h4b: content = 8'h4C;   // L
                    8'h3a: content = 8'h4D;   // M
                    8'h31: content = 8'h4E;   // N
                    8'h44: content = 8'h4F;   // O
                    8'h4d: content = 8'h50;   // P
                    8'h15: content = 8'h51;   // Q
                    8'h2d: content = 8'h52;   // R
                    8'h1b: content = 8'h53;   // S
                    8'h2c: content = 8'h54;   // T
                    8'h3c: content = 8'h55;   // U
                    8'h2a: content = 8'h56;   // V
                    8'h1d: content = 8'h57;   // W
                    8'h22: content = 8'h58;   // X
                    8'h35: content = 8'h59;   // Y
                    8'h1a: content = 8'h5A;   // Z
                    8'h0e: content = 8'h7E;   // ~
                    8'h4e: content = 8'h5F;   // _
                    8'h55: content = 8'h2B;   // +
                    8'h54: content = 8'h7B;   // {
                    8'h5b: content = 8'h7D;   // }
                    8'h5d: content = 8'h7C;   // |
                    8'h4c: content = 8'h3A;   // :
                    8'h52: content = 8'h22;   // "
                    8'h41: content = 8'h3C;   // <
                    8'h49: content = 8'h3E;   // >
                    8'h4a: content = 8'h3F;   // ?
                    8'h29: content = 8'h20;   // space
                    8'h5a: content = 8'h0D;   // enter
                    8'h66: content = 8'h08;   // backspace
                    8'h0D: content = 8'h09;   // horizontal tab
                    default: valid = 0;
                endcase
            end

            else begin
                // TODO: handle Shift + Special Key
                valid = 0;
            end
        end

        else begin
            if (!special) begin
                unique case(scancode)
                    8'h45: content = 8'h30;   // 0
                    8'h16: content = 8'h31;   // 1
                    8'h1e: content = 8'h32;   // 2
                    8'h26: content = 8'h33;   // 3
                    8'h25: content = 8'h34;   // 4
                    8'h2e: content = 8'h35;   // 5
                    8'h36: content = 8'h36;   // 6
                    8'h3d: content = 8'h37;   // 7
                    8'h3e: content = 8'h38;   // 8
                    8'h46: content = 8'h39;   // 9
                    8'h1c: content = 8'h61;   // a
                    8'h32: content = 8'h62;   // b
                    8'h21: content = 8'h63;   // c
                    8'h23: content = 8'h64;   // d
                    8'h24: content = 8'h65;   // e
                    8'h2b: content = 8'h66;   // f
                    8'h34: content = 8'h67;   // g
                    8'h33: content = 8'h68;   // h
                    8'h43: content = 8'h69;   // i
                    8'h3b: content = 8'h6A;   // j
                    8'h42: content = 8'h6B;   // k
                    8'h4b: content = 8'h6C;   // l
                    8'h3a: content = 8'h6D;   // m
                    8'h31: content = 8'h6E;   // n
                    8'h44: content = 8'h6F;   // o
                    8'h4d: content = 8'h70;   // p
                    8'h15: content = 8'h71;   // q
                    8'h2d: content = 8'h72;   // r
                    8'h1b: content = 8'h73;   // s
                    8'h2c: content = 8'h74;   // t
                    8'h3c: content = 8'h75;   // u
                    8'h2a: content = 8'h76;   // v
                    8'h1d: content = 8'h77;   // w
                    8'h22: content = 8'h78;   // x
                    8'h35: content = 8'h79;   // y
                    8'h1a: content = 8'h7A;   // z
                    8'h0e: content = 8'h60;   // `
                    8'h4e: content = 8'h2D;   // -
                    8'h55: content = 8'h3D;   // =
                    8'h54: content = 8'h5B;   // [
                    8'h5b: content = 8'h5D;   // ]
                    8'h5d: content = 8'h5C;   // \
                    8'h4c: content = 8'h3B;   // ;
                    8'h52: content = 8'h27;   // '
                    8'h41: content = 8'h2C;   // ,
                    8'h49: content = 8'h2E;   // .
                    8'h4a: content = 8'h2F;   // /
                    8'h29: content = 8'h20;   // space
                    8'h5a: content = 8'h0D;   // enter
                    8'h66: content = 8'h08;   // backspace
                    8'h0D: content = 8'h09;   // horizontal tab	
                    8'h76: content = 8'h1B;   // esc
                    8'h05: content = 24'h1B_4F_50; // F1 -> `OP
                    8'h06: content = 24'h1B_4F_51; // F2 -> `OQ
                    8'h04: content = 24'h1B_4F_52; // F3 -> `OR
                    8'h0C: content = 24'h1B_4F_53; // F4 -> `OS
                    8'h03: content = 40'h1B_5B_31_35_7E; // F5 -> `[15~
                    8'h0B: content = 40'h1B_5B_31_37_7E; // F6 -> `[17~
                    8'h83: content = 40'h1B_5B_31_38_7E; // F7 -> `[18~
                    8'h0A: content = 40'h1B_5B_31_39_7E; // F8 -> `[19~
                    8'h01: content = 40'h1B_5B_32_30_7E; // F9 -> `[20~
                    8'h09: content = 40'h1B_5B_32_31_7E; // F10 -> `[21~
                    8'h78: content = 40'h1B_5B_32_32_7E; // F11 -> `[22~
                    8'h07: content = 40'h1B_5B_32_33_7E; // F12 -> `[23~
                    default: valid = 0;
                endcase
            end

            else begin
                unique case(scancode)
                    8'h70: content = 32'h1B_5B_32_7E; // Insert -> `[2~
                    8'h71: content = 32'h1B_5B_33_7E; // Delete -> `[3~
                    8'h7D: content = 32'h1B_5B_35_7E; // Page Up -> `[5~
                    8'h7A: content = 32'h1B_5B_36_7E; // Page Down -> `[6~
                    8'h75: content = 24'h1B_5B_41; // Up Arrow -> `[A
                    8'h72: content = 24'h1B_5B_42; // Down Arrow -> `[B
                    8'h74: content = 24'h1B_5B_43; // Right Arrow -> `[C
                    8'h6B: content = 24'h1B_5B_44; // Left Arrow -> `[D
                    8'h6C: content = 24'h1B_5B_48; // Home -> `[H
                    8'h69: content = 24'h1B_5B_46; // End -> `[F
                    default: valid = 0;
                endcase
            end
        end

    end


    always_comb begin
        length = 0;
        if (ctrl) begin
            if (!special) begin
                // see https://vt100.net/docs/vt100-ug/table3-5.html
                unique case (scancode)
                    8'h29,  // space
                    8'h1c,  // A
                    8'h32,  // B
                    8'h21,  // C
                    8'h23,  // D
                    8'h24,  // E
                    8'h2b,  // F
                    8'h34,  // G
                    8'h33,  // H
                    8'h43,  // I
                    8'h3b,  // J
                    8'h42,  // K
                    8'h4b,  // L
                    8'h3a,  // M
                    8'h31,  // N
                    8'h44,  // O
                    8'h4d,  // P
                    8'h15,  // Q
                    8'h2d,  // R
                    8'h1b,  // S
                    8'h2c,  // T
                    8'h3c,  // U
                    8'h2a,  // V
                    8'h1d,  // W
                    8'h22,  // X
                    8'h35,  // Y
                    8'h1a,  // Z
                    8'h54,  // [
                    8'h5d,  // \
                    8'h5b,  // ]
                    8'h0e,  // ~
                    8'h4a:  // ?
                    length = 1;
                endcase
            end

            else begin
                unique case (scancode)
                    8'h75,  // Up arrow    -> `[1;5A
                    8'h72,  // Down arrow  -> `[1;5B
                    8'h74,  // Right arrow -> `[1;5C
                    8'h6B:  // Left arrow  -> `[1;5D
                    length = 6;
                endcase
            end
        end

        else if (shift) begin
            if (!special) begin
                unique case (scancode)
                    8'h45,   // )
                    8'h16,   // !
                    8'h1e,   // @
                    8'h26,   // #
                    8'h25,   // $
                    8'h2e,   // %
                    8'h36,   // ^
                    8'h3d,   // &
                    8'h3e,   // *
                    8'h46,   // (
                    8'h1c,   // A
                    8'h32,   // B
                    8'h21,   // C
                    8'h23,   // D
                    8'h24,   // E
                    8'h2b,   // F
                    8'h34,   // G
                    8'h33,   // H
                    8'h43,   // I
                    8'h3b,   // J
                    8'h42,   // K
                    8'h4b,   // L
                    8'h3a,   // M
                    8'h31,   // N
                    8'h44,   // O
                    8'h4d,   // P
                    8'h15,   // Q
                    8'h2d,   // R
                    8'h1b,   // S
                    8'h2c,   // T
                    8'h3c,   // U
                    8'h2a,   // V
                    8'h1d,   // W
                    8'h22,   // X
                    8'h35,   // Y
                    8'h1a,   // Z
                    8'h0e,   // ~
                    8'h4e,   // _
                    8'h55,   // +
                    8'h54,   // {
                    8'h5b,   // }
                    8'h5d,   // |
                    8'h4c,   // :
                    8'h52,   // "
                    8'h41,   // <
                    8'h49,   // >
                    8'h4a,   // ?
                    8'h29,   // space
                    8'h5a,   // enter
                    8'h66,   // backspace
                    8'h0D:   // horizontal tab
                    length = 1;
                endcase
            end

            else begin
                // TODO: handle Shift + Special Key
            end
        end

        else begin
            if (!special) begin
                unique case(scancode)
                    8'h45,   // 0
                    8'h16,   // 1
                    8'h1e,   // 2
                    8'h26,   // 3
                    8'h25,   // 4
                    8'h2e,   // 5
                    8'h36,   // 6
                    8'h3d,   // 7
                    8'h3e,   // 8
                    8'h46,   // 9
                    8'h1c,   // a
                    8'h32,   // b
                    8'h21,   // c
                    8'h23,   // d
                    8'h24,   // e
                    8'h2b,   // f
                    8'h34,   // g
                    8'h33,   // h
                    8'h43,   // i
                    8'h3b,   // j
                    8'h42,   // k
                    8'h4b,   // l
                    8'h3a,   // m
                    8'h31,   // n
                    8'h44,   // o
                    8'h4d,   // p
                    8'h15,   // q
                    8'h2d,   // r
                    8'h1b,   // s
                    8'h2c,   // t
                    8'h3c,   // u
                    8'h2a,   // v
                    8'h1d,   // w
                    8'h22,   // x
                    8'h35,   // y
                    8'h1a,   // z
                    8'h0e,   // `
                    8'h4e,   // -
                    8'h55,   // =
                    8'h54,   // [
                    8'h5b,   // ]
                    8'h5d,   // \
                    8'h4c,   // ;
                    8'h52,   // '
                    8'h41,   // ,
                    8'h49,   // .
                    8'h4a,   // /
                    8'h29,   // space
                    8'h5a,   // enter
                    8'h66,   // backspace
                    8'h0D,   // horizontal tab	
                    8'h76:   // esc
                    length = 1;

                    8'h05, // F1 -> `OP
                    8'h06, // F2 -> `OQ
                    8'h04, // F3 -> `OR
                    8'h0C: // F4 -> `OS
                    length = 3;

                    8'h03, // F5 -> `[15~
                    8'h0B, // F6 -> `[17~
                    8'h83, // F7 -> `[18~
                    8'h0A, // F8 -> `[19~
                    8'h01, // F9 -> `[20~
                    8'h09, // F10 -> `[21~
                    8'h78, // F11 -> `[22~
                    8'h07: // F12 -> `[23~
                    length = 5;

                endcase
            end

            else begin
                unique case(scancode)
                    8'h70, // Insert -> `[2~
                    8'h71, // Delete -> `[3~
                    8'h7D, // Page Up -> `[5~
                    8'h7A: // Page Down -> `[6~
                    length = 4;

                    8'h75, // Up Arrow -> `[A
                    8'h72, // Down Arrow -> `[B
                    8'h74, // Right Arrow -> `[C
                    8'h6B, // Left Arrow -> `[D
                    8'h6C, // Home -> `[H
                    8'h69: // End -> `[F
                    length = 3;

                endcase
            end
        end

    end

endmodule