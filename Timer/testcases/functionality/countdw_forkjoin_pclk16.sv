task countdw_forkjoin_pclk16;
    logic [7:0] start_val;
    logic err;
    int unsigned ticks_needed;
    int unsigned tick_period;
    int unsigned total_wait;
    int unsigned thread2_wait;
    logic t1_check, t2_check;

    $display("======================");
    $display("countdw_forkjoin_pclk16");
    $display("======================");    

    start_val = 8'($urandom_range(0, 254));
    //start_val = 254;

    cpu.apb_write(ADDR_TDR, start_val, err); //load start_val into tdr 
    cpu.apb_write(ADDR_TCR, 8'b1000_0000, err); //assert load bit

    cpu.apb_write(ADDR_TCR, 8'b0011_0011, err); //load = 0, 1'b0, up/dw = 1 (down), enable = 1, 2'b00, cks = 11 (pclk*16)

    tick_period = 16;
    ticks_needed = start_val + 1;
    total_wait = ticks_needed * tick_period;

    thread2_wait = (total_wait * 2) / 3;

    fork 
        begin: thread1
            repeat(total_wait) @(posedge PCLK);
            wait(!bus_busy);
            bus_busy = 1'b1;
            t1_check = 1'b1;
            cpu.apb_read_compare(ADDR_TSR, 8'h02, 8'h02, "Thread 1: underflow should assert now"); //tsr's [1:0] = 10 for udf flag
            t1_check = 1'b0;
            bus_busy = 1'b0;
        end
        begin: thread2
            repeat(thread2_wait) @(posedge PCLK);
            wait(!bus_busy);
            bus_busy = 1'b1;
            t2_check = 1'b1;
            cpu.apb_read_compare(ADDR_TSR, 8'h00, 8'h02, "Thread 2: underflow shouldn't have happened yet");
            t2_check = 1'b0;
            bus_busy = 1'b0;
        end
    join

endtask
