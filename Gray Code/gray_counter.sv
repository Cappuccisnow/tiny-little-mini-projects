// build a circuit that generates a Gray code sequence
// starting from 0 on the output dout
// ==============================
// binary -> gray: gray bit = binary bit XOR binary bit-1
// aka binary XOR binary >> 1
// ==============================

`timescale 1ns/1ns

module gray_counter #(
    parameter DATA_WIDTH = 4
)(
    input logic clk,
    input logic resetn,
    output logic [DATA_WIDTH - 1:0] dout
);
    logic [DATA_WIDTH - 1:0] binary_count;

    always_ff @(posedge clk) begin
        if (!resetn) begin
            binary_count <= 0;
        end
        else begin
            binary_count <= binary_count + 1;
        end
    end

    assign dout = binary_count ^ (binary_count >> 1);

endmodule