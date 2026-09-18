module timer_control_reg#(
    parameter DATA_WIDTH = 8
)(
    input logic clk,
    input logic rst_n,
    input logic tcr_wr_en,
    input logic [DATA_WIDTH - 1:0] tcr_data_in,
    output logic tcr_load_pulse,
    output logic [DATA_WIDTH - 1:0] tcr_data_out
);
    logic tcr_load;
    logic tcr_up_dw;
    logic tcr_enable;
    logic [1:0] tcr_cks;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tcr_load <= 1'b0;
            tcr_up_dw <= 1'b0;
            tcr_enable <= 1'b0;
            tcr_cks <= 2'b00;
        end
        else if (tcr_wr_en) begin
            tcr_load <= tcr_data_in[7];           
            tcr_up_dw <= tcr_data_in[5];
            tcr_enable <= tcr_data_in[4];
            tcr_cks <= tcr_data_in[1:0];
            
        end
    end
    assign tcr_load_pulse = tcr_wr_en && tcr_data_in[7];
    assign tcr_data_out = {tcr_load, 1'b0, tcr_up_dw, tcr_enable, 2'b00, tcr_cks};
endmodule
