/*
"-Write a random value to a random address.
-Check if PSLVERR is triggered. If the address is not 
TDR (0), TCR (1), or TSR (3), 
display the message ""NULL-ADDRESS""; 
otherwise, compare the read value with the written value.
-Repeat 20 times."
*/

task null_addr;
    logic [7:0] wr_data;
    logic [7:0] rd_addr;
    logic err;
    integer i;
    logic [7:0] tcr_mask;
    tcr_mask = 8'b1011_0011;


    $display("================");
    $display("null_address_test");
    $display("================");
   
    for (i = 0; i < 20; i++) begin
        rd_addr = 8'($urandom_range(0, 10));
        wr_data = 8'($urandom);

        cpu.apb_write(rd_addr, wr_data, err);

        if (rd_addr == ADDR_TDR) begin
            cpu.apb_read_compare(rd_addr, wr_data, 8'hFF, $sformatf("[%0d]", i));
        end
        else if (rd_addr == ADDR_TCR) begin
            cpu.apb_read_compare(rd_addr, wr_data, tcr_mask, $sformatf("[%0d]", i));       
        end
        else if (rd_addr == ADDR_TSR) begin
            cpu.apb_read_compare(rd_addr, 8'h00, 8'hFF, $sformatf("[%0d]", i));           
        end
        else begin
            $display("NULL ADDRESS");
            if (!err) begin
                $display("FAIL %0d, addr %0d expected PSLVERR, got none", i, rd_addr);
            end
            else begin
                $display("PASS %0d, addr %0d correctly flagged PSLVERR", i, rd_addr);
            end
        end
    end
endtask
