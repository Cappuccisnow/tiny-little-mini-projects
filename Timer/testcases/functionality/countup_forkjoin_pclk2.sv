/* "-Enter a random number less than 255.
-Thread 1: Counts up with an internal clock of pclk × 2, starting from the number above. 
If the Thread 1 count-up exceeds 255, it checks if the overflow status is triggered. 
If so, it displays a ""pass"" message (normal operation); otherwise, it displays a ""faulty"" message.

-Thread 2 runs counting-up in parallel with Thread 1, but Thread 2's job duration is shorter than Thread 1's (about 2/3 of Thread 1's duration).

Thread 2 eventually stops its counting job (while Thread 1 is still running) and checks if an overflow occurred. 
If overflow occurs, it displays a ""faulty"" message; otherwise, it displays a ""pass"" (normal operation).
" 
*/

/* "-Write a random value to TDR (address = 0).
-Load the value from TDR into the TCNT register.
-Set the conditions for operation, including disabling the LOAD bit, setting the count-up bit, 
configuring the internal clock to be equivalent to pclk × 2, and finally enabling the EN bit to put Timer into operation.
-Thread 1 and Thread 2 run count-up in parallel, but Thread 2's duration is 2/3 of Thread 1's.
-At the end of tasks, each thread checks the overflow status and displays the appropriate message indicating a fault or normal operation." 
*/

task countup_forkjoin_pclk2;
    logic [7:0] start_val;
    logic err;
    int unsigned ticks_needed;
    int unsigned tick_period;
    int unsigned total_wait;
    int unsigned thread2_wait;
    logic t1_check, t2_check;

    $display("======================");
    $display("countup_forkjoin_pclk2");
    $display("======================");    

    start_val = 8'($urandom_range(0, 254));
    //start_val = 254;

    cpu.apb_write(ADDR_TDR, start_val, err); //load start_val into tdr 
    cpu.apb_write(ADDR_TCR, 8'b1000_0000, err); //assert load bit

    cpu.apb_write(ADDR_TCR, 8'b0001_0000, err); //load = 0, 1'b0, up/dw = 0 (up), enable = 1, 2'b00, cks = 00 (pclk*2)

    tick_period = 2;
    ticks_needed = 256 - start_val;
    total_wait = ticks_needed * tick_period;

    thread2_wait = (total_wait * 2) / 3;

    fork 
        begin: thread1
            repeat(total_wait) @(posedge PCLK);
            wait(!bus_busy);
            bus_busy = 1'b1;
            t1_check = 1'b1;
            cpu.apb_read_compare(ADDR_TSR, 8'h01, 8'h01, "Thread 1: overflow should assert now"); //tsr's [1:0] = 01 for ovf flag
            t1_check = 1'b0;
            bus_busy = 1'b0;
        end
        begin: thread2
            repeat(thread2_wait) @(posedge PCLK);
            wait(!bus_busy);
            bus_busy = 1'b1;
            t2_check = 1'b1;
            cpu.apb_read_compare(ADDR_TSR, 8'h00, 8'h01, "Thread 2: overflow shouldn't have happened yet");
            t2_check = 1'b0;
            bus_busy = 1'b0;
        end
    join

endtask
