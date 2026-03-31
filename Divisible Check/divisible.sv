// divisible by 5, input value is of unknown length and is left-shifted one bit at a time

`timescale 1ns/1ns
module divisible #(
  parameter MOD_VAL = 5
)(
  input logic clk,
  input logic resetn,
  input logic din,
  output logic dout
);
  
  localparam WIDTH = $clog2(MOD_VAL); 
  logic [WIDTH - 1:0] state, next_state;
  
  always_comb begin
    next_state = ({state, din}) % MOD_VAL;
  end
  
  always_ff @(posedge clk) begin
    if (!resetn) 	state <= '0; 
    else			state <= next_state; 
  end
  
  assign dout = (state == 0);
  
endmodule
