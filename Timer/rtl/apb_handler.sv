`timescale 1ns/1ns
module apb_handler#(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 8
)(
    input logic PCLK,
    input logic PRESETn,
    input logic PSEL,
    input logic [ADDR_WIDTH - 1:0] PADDR,
    input logic PENABLE,
    input logic PWRITE,
    input logic [DATA_WIDTH - 1:0] PWDATA,
    
    output logic [DATA_WIDTH - 1:0] PRDATA,
    output logic PREADY,
    output logic PSLVERR,

    output logic wr_en,
    output logic rd_en,
    output logic [DATA_WIDTH - 1:0] wr_data,
    output logic [2:0] addr,
    input logic [DATA_WIDTH - 1:0] rd_data 
);

    logic valid_addr;
    assign valid_addr = (PADDR == 8'd0) || (PADDR == 8'd1) || (PADDR == 8'd3);
  

    always_comb begin
        PREADY = 1'b0;
        PSLVERR = 1'b0;
        wr_en = 1'b0;
        rd_en = 1'b0;

        if (PRESETn && PSEL) begin
            if (PENABLE) begin
                PREADY = 1'b1;
                PSLVERR = !valid_addr;
                wr_en = PWRITE && valid_addr;
            end 
            else begin
                rd_en = !PWRITE && valid_addr;
            end
        end
    end

    assign addr = PADDR[2:0];
    assign wr_data = PWDATA;

    assign PRDATA = (PSEL && !PWRITE && valid_addr) ? rd_data : 8'hzz;
endmodule


