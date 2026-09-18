module tcnt#(
    parameter DATA_WIDTH = 8
)(
    input logic tcnt_clk,
    input logic rst_n,
    input logic tcr_load,
    input logic tcr_enable,
    input logic tcr_up_dw,
    input logic [DATA_WIDTH - 1:0] tdr_data,
    input logic tick,
    output logic [DATA_WIDTH - 1:0] tcnt_data,
    output logic tcnt_udf,
    output logic tcnt_ovf
);
    always_ff @(posedge tcnt_clk or negedge rst_n) begin
        if (!rst_n) begin
            tcnt_data <= 8'h00;
            tcnt_udf <= 1'b0;
            tcnt_ovf <= 1'b0;
        end
        else begin
            tcnt_udf <= 1'b0;
            tcnt_ovf <= 1'b0;

            if (tcr_load) begin
                tcnt_data <= tdr_data;
            end
            else if (tcr_enable && tick) begin
                if (!tcr_up_dw) begin
                    if (tcnt_data == 8'hFF) begin
                        tcnt_ovf <= 1'b1;
                        tcnt_data <= 8'h00;
                    end
                    else begin
                        tcnt_data <= tcnt_data + 1'b1;
                    end
                end
                else begin
                    if (tcnt_data == 8'h00) begin
                        tcnt_udf <= 1'b1;
                        tcnt_data <= 8'hFF;
                    end
                    else begin
                        tcnt_data <= tcnt_data - 1'b1;
                    end
                end
            end
        end
    end
endmodule
