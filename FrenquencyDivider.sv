module FrequencyDivider (
    input   clk,
    input   rst,
    output  slowClock
);

    parameter clockFrequency = 100000000; 
    parameter requiredFrequency = 25000000; 
    localparam CLOCKS_NEEDED = (clockFrequency / requiredFrequency) / 2 - 1;

    logic [7:0] counter = 0;
    logic       outClock;
    assign slowClock = outClock;

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            outClock <= 0;
            counter <= 0;
        end else begin
            if (counter == CLOCKS_NEEDED) begin
                outClock <= ~outClock;
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end
        end
    end

endmodule // FrequencyDivider