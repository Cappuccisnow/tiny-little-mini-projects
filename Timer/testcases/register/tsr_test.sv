/*
"1. read tsr -> check default value
2. write random value to tsr (address = 3)
3. read tsr and compare 0
4. repeat 20 times"
*/
task tsr_test;
    logic [7:0] wr_data;
    logic err;
    integer i;

    $display("================");
    $display("tsr_test");
    $display("================");

    cpu.apb_read_compare(ADDR_TSR, 8'h00, 8'hFF, "default");

    for (i = 0; i < 20; i++) begin
        wr_data = 8'($urandom);
        cpu.apb_write(ADDR_TSR, wr_data, err);
        cpu.apb_read_compare(ADDR_TSR, 8'h00, 8'hFF, $sformatf("[%0d]", i));        
    end

endtask
