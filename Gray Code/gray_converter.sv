`timescale 1ns/1ns

module gray_converter #(
    parameter DATA_WIDTH = 4
)(
    input logic [DATA_WIDTH - 1:0] binary_in,
    output logic [DATA_WIDTH - 1:0] gray_out
);

    assign gray_out = binary_in ^ (binary_in >> 1); 
endmodule