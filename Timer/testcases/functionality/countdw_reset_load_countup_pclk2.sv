task countdw_reset_load_countup_pclk2;
    logic [7:0] start_val, start_val2;
    logic err;
    int unsigned ticks_needed;
    int unsigned tick_period;
    int unsigned total_wait;
    int unsigned run_before_reset;

    start_val = 8'($urandom_range(0, 254));

    cpu.apb_write(ADDR_TDR, start_val, err);
    cpu.apb_write(ADDR_TCR, 8'b1000_0000, err);

    cpu.apb_write(ADDR_TCR, 8'b0011_0000, err); //down, enable, pclk*2

    tick_period = 2;
    ticks_needed = start_val + 1; 
    total_wait = tick_period * ticks_needed;
    run_before_reset = total_wait / 2;

    repeat(run_before_reset) @(posedge PCLK);

    cpu.system_reset();

    cpu.apb_read_compare(ADDR_TDR, 8'h00, 8'hFF, "after reset: TDR should be default");
    cpu.apb_read_compare(ADDR_TCR, 8'h00, 8'hFF, "after reset: TCR should be default");
    cpu.apb_read_compare(ADDR_TSR, 8'h00, 8'hFF, "after reset: TSR should be default"); 

    start_val2 = 8'($urandom_range(0, 254));
    cpu.apb_write(ADDR_TDR, start_val2, err); 
    cpu.apb_write(ADDR_TCR, 8'b1000_0000, err);
    cpu.apb_write(ADDR_TCR, 8'b0001_0000, err);   

    ticks_needed = 256 - start_val2;
    total_wait = ticks_needed * tick_period;

    repeat(total_wait + tick_period) @(posedge PCLK);
    cpu.apb_read_compare(ADDR_TSR, 8'h01, 8'h01, "after countdown: underflow should have happened");
endtask