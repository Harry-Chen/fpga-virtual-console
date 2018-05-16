module FontShapeRenderer (
    input   clk,
    input   rst,
    input   [7:0] char,
    input   [COLOR_NUMBERS_BITS - 1:0] foregroudColor;
    input   [COLOR_NUMBERS_BITS - 1:0] backgroundColor;
    output  [HEIGHT_PER_CHARACTER * WIDTH_PER_CHARACTER - 1:0] fontColorR;
    output  [HEIGHT_PER_CHARACTER * WIDTH_PER_CHARACTER - 1:0] fontColorG;
    output  [HEIGHT_PER_CHARACTER * WIDTH_PER_CHARACTER - 1:0] fontColorB;
);

parameter COLOR_NUMBERS_BITS = 4
parameter HEIGHT_PER_CHARACTER = 20;
parameter WIDTH_PER_CHARACTER = 8;

endmodule // FontShapeRender;