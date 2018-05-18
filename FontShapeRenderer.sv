`include "DataType.sv"

module FontShapeRenderer (
    input   clk,
    input   rst,
    input   CharGrid_t char,
    input   SramAddress_t baseAddress,

);

parameter HEIGHT_PER_CHARACTER = 20;
parameter WIDTH_PER_CHARACTER = 8;

endmodule // FontShapeRender;