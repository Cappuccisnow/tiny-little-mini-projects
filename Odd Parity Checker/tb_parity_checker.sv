`timescale 1ns/1ns

module tb_parity_checker;
  logic clk;
  logic reset;
  logic in;
  logic [7:0] out_byte;
  logic done;
  logic odd;
  
  parity_checker dut(
    .clk(clk),
    .reset(reset),
    .in(in),
    .out_byte(out_byte),
    .done(done)
  );
  
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  task send_byte(
    input logic [7:0] data_to_send,
    input logic parity_bit
  );
    begin
      @(negedge clk);
      
      //start bit
      in = 0;
      @(negedge clk);
      
      for (int i = 0; i < 8; i++) begin
        in = data_to_send[i];
        @(negedge clk);
      end
      
      in = parity_bit;
      @(negedge clk);
      
      //stop bit 
      in = 1;
      @(negedge clk);
    end
  endtask
    
  initial begin
    reset = 0;
    in = 1;
    
    repeat(2) @(negedge clk);
    
    reset = 1;
    
    @(negedge clk);
    
    $display("Test case 1: valid data");
    send_byte(8'b11010010, 1'b1);
    
    repeat(3) @(posedge clk);
    
    $display("Test case 2: parity error");
    send_byte(8'b00001111, 1'b0);
    
    repeat(3) @(posedge clk);
    
    $display("Finished");
    $finish;
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, tb_parity_checker);
    $monitor("Time = %0t | in = %b | state = %5s | out_byte = %8b | done = %b", $time, in, dut.state_name, out_byte, done);
  end
  
endmodule
    