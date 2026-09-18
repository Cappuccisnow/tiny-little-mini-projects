`timescale 1ns/1ns
module timer_top#(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 8
)(
    input logic PCLK,
    input logic PRESETn,
    input logic PSEL,
    input logic PENABLE,
    input logic PWRITE,
    input logic [ADDR_WIDTH - 1:0] PADDR,
    input logic [DATA_WIDTH - 1:0] PWDATA,
    output logic [DATA_WIDTH - 1:0] PRDATA,
    output logic PREADY,
    output logic PSLVERR
);
    logic u_wr_en, u_rd_en;
    logic [2:0] u_addr;
    logic [DATA_WIDTH - 1:0] u_data;
    logic [DATA_WIDTH - 1:0] u_rd_data;

    //out of tdr, tcr
    logic [DATA_WIDTH - 1:0] tdr_tcnt_data, tcr_tcnt_data;
    logic tcr_load;

    //out of tcnt
    logic tcnt_udf, tcnt_ovf;
    logic [DATA_WIDTH - 1:0] tcnt_data;

    //out of clk sel
    logic tick;

    apb_handler #(
        .ADDR_WIDTH(ADDR_WIDTH /* default 8 */),
        .DATA_WIDTH(DATA_WIDTH /* default 8 */)
    ) u_handler (
        .PCLK   (PCLK),
        .PRESETn(PRESETn),
        .PSEL   (PSEL),
        .PADDR  (PADDR),
        .PENABLE(PENABLE),
        .PWRITE (PWRITE),
        .PWDATA (PWDATA),
        .PRDATA (PRDATA),
        .PREADY (PREADY),
        .PSLVERR(PSLVERR),
        .wr_en  (u_wr_en),
        .rd_en  (u_rd_en),
        .wr_data(u_data),
        .addr   (u_addr),
        .rd_data(u_rd_data)
    );

    register_file #(
        .DATA_WIDTH(DATA_WIDTH /* default 8 */)
    ) u_regfile (
        .clk         (PCLK),
        .rst_n       (PRESETn),
        .wr_en       (u_wr_en),
        .rd_en       (u_rd_en),
        .data        (u_data),
        .addr        (u_addr),
        .hw_ovf_pulse(tcnt_ovf),
        .hw_udf_pulse(tcnt_udf),
        .rd_data     (u_rd_data),
        .tcr_data_out(tcr_tcnt_data),
        .tdr_data_out(tdr_tcnt_data),
        .tcr_load_pulse(tcr_load)
    );

    clk_select u_clk_select (
        .PCLK   (PCLK),
        .rst_n  (PRESETn),
        .tcr_enable(tcr_tcnt_data[4]),
        .tcr_cks(tcr_tcnt_data[1:0]),
        .tick   (tick)
    );

    tcnt #(
        .DATA_WIDTH(DATA_WIDTH /* default 8 */)
    ) u_tcnt (
        .tcnt_clk  (PCLK),
        .rst_n     (PRESETn),
        .tcr_load  (tcr_load),
        .tcr_enable(tcr_tcnt_data[4]),
        .tcr_up_dw (tcr_tcnt_data[5]),
        .tdr_data  (tdr_tcnt_data),
        .tick      (tick),
        .tcnt_data (tcnt_data),
        .tcnt_udf  (tcnt_udf),
        .tcnt_ovf  (tcnt_ovf)
    );
     
endmodule
