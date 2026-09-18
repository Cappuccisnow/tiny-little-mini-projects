/* "-Timer is disabled, set Timer with pclk2, couting-up.
-Load 255 into TCNT.
-Load 255 into TCNT.
-Check if Overflow (TSR[0]) is triggered or not. And display appropriate message  "	"-Write 8'hFF to TDR. Load data from TDR into TCNT
-make Timer disabled; off load function; setting internal_clock equivalent to pclk2; set count-up.
-Write 8h'00  to TDR. Load data from TDR into TCNT
-Timer still disabled; Off load function
-Check TSR[1] if overflow or not." */

task fake_overflow;
    logic err;

    $display("==============");
    $display("fake_overflow");
    $display("=============="); 

    cpu.apb_write(ADDR_TDR, 8'hFF, err);
    cpu.apb_write(ADDR_TCR, 8'b1000_0000, err); //off load function; setting internal_clock equivalent to pclk2; set count-up

    cpu.apb_write(ADDR_TDR, 8'h00, err); 
    cpu.apb_write(ADDR_TCR, 8'b1010_0000, err);

    cpu.apb_read_compare(ADDR_TSR, 8'h00, 8'h01, "load only, disabled, overflow shouldn't trigger");
endtask