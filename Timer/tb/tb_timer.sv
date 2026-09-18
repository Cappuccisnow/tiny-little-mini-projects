`timescale 1ns/1ns

module tb_timer;
    logic PCLK;
    logic PRESETn;
    logic PSEL, PENABLE, PWRITE;
    logic [7:0] PWDATA, PADDR, PRDATA;
    logic PREADY, PSLVERR;

    localparam ADDR_TDR = 8'd0;
    localparam ADDR_TCR = 8'd1;
    localparam ADDR_TSR = 8'd3;

    timer_top #(
        .DATA_WIDTH(8),
        .ADDR_WIDTH(8)
    ) u_dut (
        .PCLK   (PCLK),
        .PRESETn(PRESETn),
        .PSEL   (PSEL),
        .PENABLE(PENABLE),
        .PWRITE (PWRITE),
        .PADDR  (PADDR),
        .PWDATA (PWDATA),
        .PRDATA (PRDATA),
        .PREADY (PREADY),
        .PSLVERR(PSLVERR)
    );

    cpu cpu (
        .PCLK   (PCLK),
        .PRESETn(PRESETn),
        .PSEL   (PSEL),
        .PENABLE(PENABLE),
        .PWRITE (PWRITE),
        .PADDR  (PADDR),
        .PWDATA (PWDATA),
        .PRDATA (PRDATA),
        .PREADY (PREADY),
        .PSLVERR (PSLVERR)
    );

    initial begin
        PCLK = 0;
        forever #5 PCLK = ~PCLK;
    end

    logic bus_busy;
    string current_test;
    `include "tdr_test.sv"
    `include "tcr_test.sv"
    `include "tsr_test.sv"
    `include "null_addr.sv"
    `include "countup_forkjoin_pclk2.sv"
    `include "countup_forkjoin_pclk4.sv"
    `include "countup_forkjoin_pclk8.sv"
    `include "countup_forkjoin_pclk16.sv"
    `include "countdw_forkjoin_pclk2.sv"
    `include "countdw_forkjoin_pclk4.sv"
    `include "countdw_forkjoin_pclk8.sv"
    `include "countdw_forkjoin_pclk16.sv"
    `include "countup_pause_countup_pclk2.sv"
    `include "countdw_pause_countdw_pclk2.sv"
    `include "countup_reset_countdw_pclk2.sv"
    `include "countdw_reset_countup_pclk2.sv"
    `include "countup_reset_load_countdw_pclk2.sv"
    `include "fake_underflow.sv"
    `include "fake_overflow.sv"
    initial begin
        bus_busy = 1'b0;
        cpu.system_reset();

        if ($value$plusargs("TESTNAME=%s", current_test)) begin
            $display("Running test: %s", current_test);
            case (current_test) 
                "tdr_test": tdr_test(); 
                "tcr_test": tcr_test();
                "tsr_test": tsr_test();
                "null_addr": null_addr();
                "countup_forkjoin_pclk2": countup_forkjoin_pclk2();
                "countup_forkjoin_pclk4": countup_forkjoin_pclk4();
                "countup_forkjoin_pclk8": countup_forkjoin_pclk8();
                "countup_forkjoin_pclk16": countup_forkjoin_pclk16();
                "countdw_forkjoin_pclk2": countdw_forkjoin_pclk2();
                "countdw_forkjoin_pclk4": countdw_forkjoin_pclk4();
                "countdw_forkjoin_pclk8": countdw_forkjoin_pclk8();
                "countdw_forkjoin_pclk16": countdw_forkjoin_pclk16();
                "countup_pause_countup_pclk2": countup_pause_countup_pclk2();
                "countdw_pause_countdw_pclk2": countdw_pause_countdw_pclk2();
                "countup_reset_countdw_pclk2": countup_reset_countdw_pclk2();
                "countdw_reset_countup_pclk2": countdw_reset_countup_pclk2();
                "countup_reset_load_countdw_pclk2": countup_reset_load_countdw_pclk2();
                "fake_underflow": fake_underflow();
                "fake_overflow": fake_overflow();
                default: $display("Test %s not found", current_test);
            endcase
        end
        else begin
            $display("No TESTNAME provided");
        end

        $finish;
    end

  
endmodule
