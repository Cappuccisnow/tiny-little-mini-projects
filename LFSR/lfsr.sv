// implement a Linear Feedback Shift Register
// a type of SR that can generate a pseudo-random stream of binary words
// a feedback loop is created by XOR-ing the outputs of specific
// stages (also known as taps) of the SR and connecting them to 
// the input of its first stage

// ===================================
// if the LFSR becomes all 0s, it locks up => default to 1
// ===================================

`timescale 1ns/1ns
module lfsr #(
    parameter WIDTH = 8
)(
    input logic clk, 
    input logic resetn,
    input logic load_en,
    input logic [WIDTH - 1:0] din,
    input logic [WIDTH - 1:0] tap,
    output logic [WIDTH - 1:0] dout
);

    logic [WIDTH - 1:0] tap_reg;

    always_ff @(posedge clk) begin
        if (!resetn) begin
            tap_reg <= '0;
            
            //default to 1 to prevent lock-up
            dout <= {{WIDTH - 1{1'b0}}, 1'b1};
        end
        else if (load_en) begin
            dout <= din;
            tap_reg <= tap;
        end
        else begin
            dout <= {dout[WIDTH - 2:0], ^(tap_reg & dout)};
            tap_reg <= tap;
        end
    end 
endmodule
