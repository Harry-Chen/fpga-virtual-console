// From https://timetoexplore.net/blog/arty-fpga-vga-verilog-01

module VgaSignalGenerator_640_480(
    input wire i_clk,       // base clock
    input wire i_pix_stb,   // pixel clock strobe
    output wire o_hs,       // horizontal sync
    output wire o_vs,       // vertical sync
    output wire o_blanking, // high during blanking interval
    output wire o_animate,  // high for one tick at end of active drawing
    output wire [9:0] o_x,  // current pixel x position: 10-bit value: 0-1023
    output wire [8:0] o_y   // current pixel y position:  9-bit value: 0-511
    );

    localparam HS_STA = 16;              // horizontal sync start
    localparam HS_END = 16 + 96;         // horizontal sync end
    localparam HA_STA = 16 + 96 + 48;    // horizontal active pixel start
    localparam VS_STA = 480 + 11;        // vertical sync start
    localparam VS_END = 480 + 11 + 2;    // vertical sync end
    localparam VA_END = 480;             // vertical active pixel end
    localparam LINE   = 800;             // complete line (pixels)
    localparam SCREEN = 524;             // complete screen (lines)

    reg [9:0] h_count = 0;  // line position:   10-bit value: 0-1023
    reg [9:0] v_count = 0;  // screen position: 10-bit value: 0-1023

    // generate horizontal and vertical sync signals (both active low for 640x480)
    assign o_hs = ~((h_count >= HS_STA) & (h_count < HS_END));
    assign o_vs = ~((v_count >= VS_STA) & (v_count < VS_END));

    // keep x and y bound within the active pixels
    assign o_x = (h_count < HA_STA) ? 0 : (h_count - HA_STA);
    assign o_y = (v_count >= VA_END) ? (VA_END - 1) : (v_count);

    // blanking: high within the blanking period
    assign o_blanking = ((h_count < HA_STA) | (v_count > VA_END - 1));

    // animate: high for one tick at the end of the final active pixel line
    assign o_animate = ((v_count == VA_END - 1) & (h_count == LINE));

    always @ (posedge i_clk)
    begin
        if (i_pix_stb)  // once per pixel
        begin
            if (h_count == LINE)  // end of line
            begin
                h_count <= 0;
                v_count <= v_count + 1;
            end
            else 
                h_count <= h_count + 1;

            if (v_count == SCREEN)  // end of screen
                v_count <= 0;
        end
    end
endmodule