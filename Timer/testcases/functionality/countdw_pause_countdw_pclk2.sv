/* "Enter a random number less than 255.
-The timer is enabled and counts down with an internal clock of pclk × 2, starting from the number read above.
-It runs for a while, then pauses for a duration of COUNT_PAUSE time units.
- After the pause, it checks if an underflow occurred. 
If an underflow is detected, it displays a ""faulty"" message; otherwise, it displays a ""pass"" (normal operation).
- Keep the operation condition for the timer as before: counting-down, pclk2 and set the EN bit to 1. 
-The timer continues counting down and, upon reaching below 0, converts to 255.
-Check if the underflow status is triggered. If so, display a ""pass"" message (normal operation); otherwise, display a ""faulty"" message."

"-Write a random value to the TDR (address = 0).
-Load the value from TDR into the TCNT register.
-Set the conditions for operation, including disabling the LOAD bit, setting the count-down bit, configuring the internal clock to be equivalent to pclk × 2, 
and finally enabling the EN bit to put the timer into operation.
-The timer runs and counts down for a while, then disable the EN bit to stop the timer during the PAUSE time units.
-After the pause, check the underflow status and display the appropriate message: indicate a fault if underflow is triggered, 
or normal operation if underflow has not yet been triggered.
-Enable the timer (set the EN bit to 1). The timer continues counting down from where it stopped. 
Once the timer goes below 0, transfers to 255, check if the underflow status is triggered. 
If so, display a ""pass"" message (normal operation); otherwise, display a ""faulty"" message." 
*/
task countdw_pause_countdw_pclk2;
    logic [7:0] start_val;
    logic err;
    int unsigned ticks_needed;
    int unsigned tick_period;
    int unsigned ticks_before_pause, ticks_after_pause;
    int unsigned pre_pause_wait, remaining_wait;

    $display("===========================");
    $display("countdw_pause_countdw_pclk2");
    $display("===========================");   

    start_val = 8'($urandom_range(0, 254));
    //start_val = 1; failing for this test, write another later

    cpu.apb_write(ADDR_TDR, start_val, err);
    cpu.apb_write(ADDR_TCR, 8'b1000_0000, err);

    cpu.apb_write(ADDR_TCR, 8'b0011_0000, err); //down, enable, pclk*2

    tick_period = 2;
    ticks_needed =  start_val + 1;
    ticks_before_pause = ticks_needed / 2;
    ticks_after_pause = ticks_needed - ticks_before_pause;

    pre_pause_wait = ticks_before_pause * tick_period;
    remaining_wait = ticks_after_pause * tick_period + 2;

    repeat(pre_pause_wait) @(posedge PCLK);
    cpu.apb_write(ADDR_TCR, 8'b0010_0000, err); //pause
    cpu.apb_read_compare(ADDR_TSR, 8'h00, 8'h02, "after pause: underflow shouldn't have happened yet");

    repeat(6) @(posedge PCLK);
    cpu.apb_write(ADDR_TCR, 8'b0011_0000, err); //reenable

    repeat(remaining_wait) @(posedge PCLK);
    cpu.apb_read_compare(ADDR_TSR, 8'h02, 8'h02, "after resume: underflow should have happened");


endtask