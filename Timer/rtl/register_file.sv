module register_file#(
    parameter DATA_WIDTH = 8
)(
    input logic clk,
    input logic rst_n,

    input logic wr_en,
    input logic rd_en,
    input logic [DATA_WIDTH - 1:0] data,
    input logic [2:0] addr,

    input logic hw_ovf_pulse,
    input logic hw_udf_pulse,

    output logic [DATA_WIDTH - 1:0] rd_data,
    output logic [DATA_WIDTH - 1:0] tcr_data_out,
    output logic [DATA_WIDTH - 1:0] tdr_data_out,
    output logic tcr_load_pulse
);
    localparam ADDR_TDR = 3'd0;
    localparam ADDR_TCR = 3'd1;
    localparam ADDR_TSR = 3'd3;

    logic tcr_wr_en, tdr_wr_en, tsr_wr_en;
    assign tcr_wr_en = wr_en && (addr == ADDR_TCR);
    assign tdr_wr_en = wr_en && (addr == ADDR_TDR);
    assign tsr_wr_en = wr_en && (addr == ADDR_TSR);

    logic [DATA_WIDTH - 1:0] tsr_data_out;

    timer_control_reg #(
        .DATA_WIDTH(DATA_WIDTH /* default 8 */)
    ) u_tcr (
        .clk         (clk),
        .rst_n       (rst_n),
        .tcr_wr_en   (tcr_wr_en),
        .tcr_data_in (data),
        .tcr_data_out(tcr_data_out),
        .tcr_load_pulse(tcr_load_pulse)
    );

    timer_data_reg #(
        .DATA_WIDTH(DATA_WIDTH /* default 8 */)
    ) u_tdr (
        .clk         (clk),
        .rst_n       (rst_n),
        .tdr_wr_en   (tdr_wr_en),
        .tdr_data_in (data),
        .tdr_data_out(tdr_data_out)
    );

    timer_status_reg #(
        .DATA_WIDTH(DATA_WIDTH /* default 8 */)
    ) u_tsr (
        .clk         (clk),
        .rst_n       (rst_n),
        .tsr_wr_en   (tsr_wr_en),
        .tsr_data_in (data),
        .hw_ovf_pulse(hw_ovf_pulse),
        .hw_udf_pulse(hw_udf_pulse),
        .tsr_data_out(tsr_data_out)
    );

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_data <= 8'hzz;
        end
        else if (rd_en) begin
            case (addr)
                ADDR_TDR: rd_data <= tdr_data_out;
                ADDR_TCR: rd_data <= tcr_data_out;
                ADDR_TSR: rd_data <= tsr_data_out;
                default: rd_data <= 8'hzz;
            endcase
        end
    end
endmodule
