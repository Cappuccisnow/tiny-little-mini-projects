module cpu(
    input logic PCLK,
    output logic PRESETn,
    output logic PSEL, PENABLE, PWRITE,
    output logic [7:0] PADDR, PWDATA, 
    input logic [7:0] PRDATA,
    input logic PREADY,
    input logic PSLVERR
);
    integer timeout_cnt;

    task system_reset();
        PSEL = 1'b0;
        PENABLE = 1'b0;
        PWRITE = 1'b0;
        PWDATA = 8'h0;
        PADDR = 8'h0;

        PRESETn = 1'b0;
        repeat(2) @(posedge PCLK);
        PRESETn = 1'b1;
        repeat(2) @(posedge PCLK);
    endtask

    task apb_write (input [7:0] addr, input [7:0] wr_data, output logic slverr);
        begin
            //setup t1 - t2
            @(posedge PCLK);
            PSEL <= 1'b1;
            PWRITE <= 1'b1;
            PADDR <= addr;
            PWDATA <= wr_data;
            PENABLE <= 1'b0;

            //access t2 - t3
            @(posedge PCLK);
            PENABLE <= 1'b1;


            timeout_cnt = 0;
            while(PREADY !== 1'b1) begin
                @(posedge PCLK);
                timeout_cnt++; 
                if (timeout_cnt > 20) begin
                    $display("Error at addr %0d", addr);
                    $finish;
                end
            end
            
            slverr = PSLVERR;

            //t3 - t4
            PSEL <= 1'b0;
            PWRITE <= 1'b0;
            PENABLE <= 1'b0;
            @(posedge PCLK);
        end
    endtask

    task apb_read (input [7:0] addr, output [7:0] rd_data, output logic slverr);
        begin
            //setup 
            @(posedge PCLK);
            PSEL <= 1'b1;
            PWRITE <= 1'b0;
            PADDR <= addr;
            PENABLE <= 1'b0;

            //access 
            @(posedge PCLK);
            PENABLE <= 1'b1;

            timeout_cnt = 0;
            while(PREADY !== 1'b1) begin
                @(posedge PCLK);
                timeout_cnt++; 
                if (timeout_cnt > 20) begin
                    $display("Error at addr %0d", addr);
                    $finish;
                end
            end

            slverr = PSLVERR;

            rd_data = PRDATA;
            PSEL <= 1'b0;
            PENABLE <= 1'b0;
            @(posedge PCLK);
        end
    endtask

    task apb_read_compare(input [7:0] addr, input [7:0] expected, input [7:0] mask = 8'hFF, input string label = "");
        logic [7:0] rd_data;
        logic slverr;
        apb_read(addr, rd_data, slverr);
        if ((rd_data & mask) !== (expected & mask)) begin
            $display("FAIL %s, addr %0d expected %0h (masked %0h), read %0h (masked %0h)", label, addr, expected, mask, rd_data, mask);
        end
        else begin
            $display("PASS %s, read/write match (masked %0h)", label, rd_data & mask);
        end
    endtask


endmodule
