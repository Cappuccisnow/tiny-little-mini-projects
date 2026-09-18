/*
"1. read tdr -> check default value
2. write random value to tdr (address = 0)
3. read tdr and compare written value
4. repeat 20 times"
*/

task tdr_test;
    logic [7:0] wr_data;
    logic err;
    integer i;

    $display("================");
    $display("tdr_test");
    $display("================");

    cpu.apb_read_compare(ADDR_TDR, 8'h00, 8'hFF, "default");

    for (i = 0; i < 20; i++) begin
        wr_data = 8'($urandom);
        cpu.apb_write(ADDR_TDR, wr_data, err);
        cpu.apb_read_compare(ADDR_TDR, wr_data, 8'hFF, $sformatf("[%0d]", i));
    end

endtask

