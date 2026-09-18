/* "-Enter a random number less than 255.
-The timer is enabled and counts up with an internal clock of pclk × 2, starting from the number read above.
-It runs for a while, then pauses for a duration of COUNT_PAUSE time units. 
-After the pause, it checks if an overflow occurred. 
If an overflow is detected, it displays a ""faulty"" message; otherwise, it displays a ""pass"" (normal operation).
-Keep the operation condition unchanged for the timer to count up and set the EN bit to 1. 
The timer continues counting up and, upon reaching 255, transfes to 0.
-Check if the overflow status is triggered. If so, display a ""pass"" message (normal operation); otherwise, display a ""faulty"" message." */
/* 
-Write a random value to the TDR (address = 0).
-Load the value from TDR into the TCNT register.
-Set the conditions for operation, including disabling the LOAD bit, setting the count-up bit, configuring the internal clock to be equivalent to pclk × 2, 
and finally enabling the EN bit to put the timer into operation.
-The timer runs and counts up for a while, then disable the EN bit to stop the timer during the PAUSE time units.
-After the pause, check the overflow status and display the appropriate message: 
indicate a fault if overflow is triggered, or normal operation if overflow has not yet been triggered.
-Enable the timer (set the EN bit to 1). The timer continues counting up from where it stopped. 
Once the timer exceeds 255, check if the overflow status is triggered. If so, display a ""pass"" message (normal operation); otherwise, display a ""faulty"" message." */

task countup_pause_countup_pclk2;
    logic [7:0] start_val;
    logic err;
    int unsigned ticks_needed;
    int unsigned tick_period;
    int unsigned ticks_before_pause, ticks_after_pause;
    int unsigned pre_pause_wait, remaining_wait;


    $display("===========================");
    $display("countup_pause_countup_pclk2");
    $display("===========================");   

    //start_val = 8'($urandom_range(0, 254));
    start_val = 253; //failing for this test, write another later

    cpu.apb_write(ADDR_TDR, start_val, err);
    cpu.apb_write(ADDR_TCR, 8'b1000_0000, err);

    cpu.apb_write(ADDR_TCR, 8'b0001_0000, err); //enable, up, pclk*2

    tick_period = 2;
    ticks_needed = 256 - start_val;
    ticks_before_pause = ticks_needed / 2;
    ticks_after_pause = ticks_needed - ticks_before_pause;

    pre_pause_wait = ticks_before_pause * tick_period;
    remaining_wait = ticks_after_pause * tick_period + 2;

    repeat(pre_pause_wait) @(posedge PCLK);
    cpu.apb_write(ADDR_TCR, 8'b0000_0000, err); //pause
    cpu.apb_read_compare(ADDR_TSR, 8'h00, 8'h01, "after pause: overflow shouldn't have happened yet");

    repeat(6) @(posedge PCLK);
    cpu.apb_write(ADDR_TCR, 8'b0001_0000, err); //reenable

    repeat(remaining_wait) @(posedge PCLK);
    cpu.apb_read_compare(ADDR_TSR, 8'h01, 8'h01, "after resume: overflow should have happened");


endtask