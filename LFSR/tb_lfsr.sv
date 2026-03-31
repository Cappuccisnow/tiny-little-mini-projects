`timescale 1ns/1ns
module tb_lfsr;
    localparam W = 8;

    logic clk;
    logic resetn;
    logic load_en;
    logic [W - 1:0] din;
    logic [W - 1:0] tap;
    logic [W - 1:0] dout;

    lfsr #(.WIDTH(W)) dut(
        .clk(clk),
        .resetn(resetn),
        .load_en(load_en),
        .din(din),
        .tap(tap),
        .dout(dout)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task inject_seed(input logic [W - 1:0] seed_val, input logic [W - 1:0] tap_val);
        begin
            @(negedge clk);

            load_en = 1'b1;
            din = seed_val;
            tap = tap_val;

            @(negedge clk);

            load_en = 1'b0;
        end
    endtask

    initial begin
        resetn = 0;
        load_en = 0;
        din = 0;
        tap = 0;

        repeat(2) @(negedge clk);
        resetn = 1;
        repeat(3) @(negedge clk);

        $display("Case 1: seed: 10101010, tap: 10001110");
        inject_seed(8'b10101010, 8'b10001110);

        repeat(20) @(posedge clk);

        $display("Case 2: Zero lockup");
        inject_seed(8'b00000000, 8'b10110010);

        repeat(20) @(posedge clk);

        $display("Case 3: seed: 11111111, tap: 00000000");
        inject_seed(8'b11111111, 8'b00000000);

        repeat(20) @(posedge clk);

        $display("Finished");
        $finish;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars("1, tb_lfsr");
        $monitor("Time = %0t | resetn = %b | load_en = %b | seed = %b | dout = %b", 
        $time, resetn, load_en, din, dout);
    end

endmodule