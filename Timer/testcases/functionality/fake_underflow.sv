/* "-Timer is disabled, set Timer with pclk2, couting-down.
-Load 0 into TCNT.
-Load 255 into TCNT.
-Check if Underflow (TSR[1]) is triggered or not. And display appropriate message  "	
"-Write 8'h00 to TDR. Load data from TDR into TCNT
-make Timer disabled; off load function; setting internal_clock equivalent to pclk2; set count-down.
-Write 8h'FF (255) to TDR. Load data from TDR into TCNT
-Timer still disabled; Off load function
-Check TSR[1] if underflow or not." */

task fake_underflow;
    logic err;

    $display("==============");
    $display("fake_underflow");
    $display("=============="); 

    cpu.apb_write(ADDR_TDR, 8'h00, err);
    cpu.apb_write(ADDR_TCR, 8'b1010_0000, err); //off load function; setting internal_clock equivalent to pclk2; set count-down

    cpu.apb_write(ADDR_TDR, 8'hFF, err); 
    cpu.apb_write(ADDR_TCR, 8'b1010_0000, err);

    cpu.apb_read_compare(ADDR_TSR, 8'h00, 8'h02, "load only, disabled, underflow shouldn't trigger");
endtask