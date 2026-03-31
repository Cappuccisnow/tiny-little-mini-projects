`timescale 1ns/1ns

module tb_divisible5;
  logic clk;
  logic resetn;
  logic din;
  logic dout;
  
  string full_seq = "";
  
  divisible #(
    .MOD_VAL(5)
  ) dut(
    .clk(clk),
    .resetn(resetn),
    .din(din),
    .dout(dout)
  );
  
  initial begin
    clk = 0;
    forever #10 clk = ~clk;
  end
  
  task send_bits(input logic [31:0] data, input int num_bits);
    begin
      full_seq = "";
      for (int i = 0; i < num_bits; i++) begin
        @(negedge clk);
        din = data[(num_bits - 1) - i];
        
        full_seq = {full_seq, din ? "1" : "0"};
        $display("Current seq: [%s]", full_seq);
      end
      @(posedge clk);
    end
  endtask
  
  task reset();
    @(negedge clk); 
    resetn = 0;
    @(negedge clk);
    resetn = 1;
  endtask
  
  initial begin
    resetn = 0;
    din = 0;
    
    repeat(2) @(negedge clk);
    resetn = 1;
    
    $display("---Test case 1: 1010 (decimal 10)---");
    send_bits(32'b1010, 4);
    $display("Result dout = %b", dout);
    
    reset();
    
    $display("---Test case 2: 10110 (decimal 22)---");
    send_bits(32'b10110, 5);
    $display("Result dout = %b", dout);

    reset();
    
    $display("---Test case 3: 0 (decimal 0)---");
    send_bits(32'b0, 1);
    $display("Result dout = %b", dout);
    
    repeat(4) @(posedge clk);
    $display("Finished");
    $finish;
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, tb_divisible5);
    $monitor("Time = %0t | resetn = %b | din = %b | dout = %b", $time, resetn, din, dout);
  end
endmodule