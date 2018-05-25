`include "DataType.svh"
module BlinkGenerator(
    input  clk,
    output status
    );

    parameter ClkFrequency = 100_000_000;
    localparam BlinkClk = ClkFrequency / `CURSOR_BLINKING_FREQ;

    logic blinking_status;
    logic [31:0] blinking_cnt;

    always @(posedge clk)
    begin
        if(blinking_cnt == BlinkClk)
        begin
            blinking_cnt <= 32'd0;
            blinking_status <= ~blinking_status;
        end else begin
            blinking_cnt <= blinking_cnt + 32'd1;
        end
    end

    assign status = blinking_status;

endmodule // BlinkGenerator