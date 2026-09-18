/* 
"-Read a random number less than 255.
-The timer is enabled and counts up with an internal clock of pclk × 2, starting from the number read above.
-It runs for a while, then trigger reset signal in order that TDR,TCR, TSR are set to their default value (0).
- After the reset, it checks if registers TDR,TCR,TSR equals default values (0). 
If they equal 0, it displays a ""pass"" message (normal operation), otherwise, it displays a ""failed"" 
- Set the timer to count down, write a value similar to the one before the reset, and set the EN bit to 1.
-The timer begins counting down and, upon reaching below 0, changes to 255.
-Check if the underflow status is triggered. If so, display a ""pass"" message (normal operation); otherwise, display a ""faulty"" message."

"-Write a random value to the TDR (address = 0).
-Load the value from TDR into the TCNT register.
-Set the conditions for operation, including disabling the LOAD bit, setting the count-up bit, configuring the internal clock to be equivalent to pclk × 2, 
and finally enabling the EN bit to put the timer into operation.
-The timer runs and counts up for a while,then trigger reset signal in order that TDR,TCR, TSR are set to their default value (0).
-After the reset, it checks if registers TDR,TCR,TSR equals default values (0). 
If they equal 0, it displays a ""pass"" message (normal operation), otherwise, it displays a ""failed"" .
-Set the operation condition for the timer to count down (set TCR[5]), put value similar to the one before the reset, into TCNT and enable the timer (set the EN bit to 1). 
-The timer begins counting down. Once the timer goes 0, transfers to 255, check if the underflow status is triggered. 
If so, display a ""pass"" message (normal operation); otherwise, display a ""faulty"" message." 
*/

task countup_reset_countdw_pclk2;
    logic [7:0] start_val;
    logic err;
    int unsigned ticks_needed;
    int unsigned tick_period;
    int unsigned total_wait;
    int unsigned run_before_reset;

    start_val = 8'($urandom_range(0, 254));

    cpu.apb_write(ADDR_TDR, start_val, err);
    cpu.apb_write(ADDR_TCR, 8'b1000_0000, err);

    cpu.apb_write(ADDR_TCR, 8'b0001_0000, err); //up, enable, pclk*2

    tick_period = 2;
    ticks_needed = 256 - start_val; 
    total_wait = tick_period * ticks_needed;
    run_before_reset = total_wait / 2;

    repeat(run_before_reset) @(posedge PCLK);

    cpu.system_reset();

    cpu.apb_read_compare(ADDR_TDR, 8'h00, 8'hFF, "after reset: TDR should be default");
    cpu.apb_read_compare(ADDR_TCR, 8'h00, 8'hFF, "after reset: TCR should be default");
    cpu.apb_read_compare(ADDR_TSR, 8'h00, 8'hFF, "after reset: TSR should be default"); 

    cpu.apb_write(ADDR_TDR, start_val, err); 
    cpu.apb_write(ADDR_TCR, 8'b1000_0000, err);
    cpu.apb_write(ADDR_TCR, 8'b0011_0000, err);   

    ticks_needed = start_val + 1;
    total_wait = ticks_needed * tick_period;

    repeat(total_wait + tick_period) @(posedge PCLK);
    cpu.apb_read_compare(ADDR_TSR, 8'h02, 8'h02, "after countdown: underflow should have happened");

endtask