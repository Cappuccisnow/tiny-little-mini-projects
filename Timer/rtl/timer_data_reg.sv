module timer_data_reg#(
    parameter DATA_WIDTH = 8
)(
    input logic clk,
    input logic rst_n,
    input logic tdr_wr_en,
    input logic [DATA_WIDTH - 1:0] tdr_data_in,
    output logic [DATA_WIDTH -1:0] tdr_data_out
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tdr_data_out <= 8'h00;
        end
        else if (tdr_wr_en) begin
            tdr_data_out <= tdr_data_in;
        end
    end
endmodule
