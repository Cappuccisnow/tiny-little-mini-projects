`timescale 1ns/1ns

module parity (
  input logic clk,
  input logic reset,
  input logic in,
  output logic odd
);
  
  always_ff @(posedge clk) begin
    if (reset) begin
      odd <= 0;
    end
    else if (in) begin
      odd <= ~odd;
    end
  end
endmodule