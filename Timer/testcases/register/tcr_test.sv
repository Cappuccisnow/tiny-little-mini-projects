/*
"1. read tcr -> check default value
2. write random value to tcr (address = 1)
3. read tcr and compare written value with mask = 1011_0011
4. repeat 20 times"
*/

task tcr_test;
    logic [7:0] wr_data;
    logic err;
    integer i;
    logic [7:0] mask;
    mask = 8'b1011_0011;

    $display("================");
    $display("tcr_test");
    $display("================");

    cpu.apb_read_compare(ADDR_TCR, 8'h00, 8'hFF, "default");

    for (i = 0; i < 20; i++) begin
        wr_data = 8'($urandom);
        cpu.apb_write(ADDR_TCR, wr_data, err);
        cpu.apb_read_compare(ADDR_TCR, wr_data, mask, $sformatf("[%0d]", i));        
    end

endtask
