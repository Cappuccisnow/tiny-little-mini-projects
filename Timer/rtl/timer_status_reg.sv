module timer_status_reg#(
    parameter DATA_WIDTH = 8
)(
    input logic clk,
    input logic rst_n,
    input logic tsr_wr_en,
    input logic [DATA_WIDTH - 1:0] tsr_data_in,
    input logic hw_ovf_pulse, //from tcnt
    input logic hw_udf_pulse, //from tcnt
    output logic [DATA_WIDTH - 1:0] tsr_data_out
);
    logic S_TSR_OVF;
    logic S_TSR_UDF;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            S_TSR_OVF <= 1'b0;
            S_TSR_UDF <= 1'b0;
        end
        else begin
            if (hw_ovf_pulse) begin
                S_TSR_OVF <= 1'b1;
            end
            else if (tsr_wr_en && tsr_data_in[0]) begin
                S_TSR_OVF <= 1'b0;
            end

            if (hw_udf_pulse) begin
                S_TSR_UDF <= 1'b1;
            end
            else if (tsr_wr_en && tsr_data_in[1]) begin
                S_TSR_UDF <= 1'b0;
            end
        end
    end

    assign tsr_data_out = {6'b000000, S_TSR_UDF, S_TSR_OVF};
endmodule
