module VgaDisplayAdapter_640_480(
    input wire CLK,             // board clock: 100 MHz on Arty & Basys 3
    input wire RST_BTN,         // reset button
    output wire VGA_HS_O,       // horizontal sync output
    output wire VGA_VS_O,       // vertical sync output
    output wire [2:0] VGA_R,    // 4-bit VGA red output
    output wire [2:0] VGA_G,    // 4-bit VGA green output
    output wire [2:0] VGA_B     // 4-bit VGA blue output
    );

    parameter ClkFrequency = 25000000; // 25MHz
    localparam VGA_FREQUENCY = 25000000;
    localparam CLOCKS_NEEDED = ClkFrequency / VGA_FREQUENCY;

    wire rst = ~RST_BTN;  // reset is active low on Arty

    // generate a 25 MHz pixel strobe
    reg [15:0] cnt = 0;
    reg pix_stb = 0;
    always @(posedge CLK) begin
      if(cnt == CLOCKS_NEEDED) begin
        cnt <= 0;
        pix_stb <= ~pix_stb;
      end
      else cnt <= cnt + 1;
    end

    wire [9:0] x;  // current pixel x position: 10-bit value: 0-1023
    wire [8:0] y;  // current pixel y position:  9-bit value: 0-511

    VgaSignalGenerator_640_480 display (
        .i_clk(CLK),
        .i_pix_stb(pix_stb),
        .o_hs(VGA_HS_O), 
        .o_vs(VGA_VS_O), 
        .o_x(x), 
        .o_y(y)
    );

    // Demo: Four overlapping squares
    wire sq_a, sq_b, sq_c, sq_d;
    assign sq_a = ((x > 120) & (y >  40) & (x < 280) & (y < 200)) ? 1 : 0;
    assign sq_b = ((x > 200) & (y > 120) & (x < 360) & (y < 280)) ? 1 : 0;
    assign sq_c = ((x > 280) & (y > 200) & (x < 440) & (y < 360)) ? 1 : 0;
    assign sq_d = ((x > 360) & (y > 280) & (x < 520) & (y < 440)) ? 1 : 0;

    assign VGA_R[2] = sq_b;         // square b is red
    assign VGA_G[2] = sq_a | sq_d;  // squares a and d are green
    assign VGA_B[2] = sq_c;         // square c is blue

    // TODO: read from SRAM
endmodule