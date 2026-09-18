module clk_select(
    input logic PCLK,
    input logic rst_n,
    input logic tcr_enable,
    input logic [1:0] tcr_cks,
    output logic tick
);
    logic [3:0] div_cnt;
    logic [3:0] div_max;

    always_comb begin
        case (tcr_cks)
            2'b00: div_max = 4'd1;
            2'b01: div_max = 4'd3;
            2'b10: div_max = 4'd7;
            default: div_max = 4'd15;
        endcase
    end
    always_ff @(posedge PCLK or negedge rst_n) begin
        if (!rst_n) begin
            div_cnt <= 4'd0;
            tick <= 1'b0;
        end
        else if (!tcr_enable) begin
            div_cnt <= 4'd0;
            tick <= 1'b0;
        end
        else if (div_cnt == div_max) begin
            div_cnt <= 4'd0;
            tick <= 1'b1;
        end
        else begin
            div_cnt <= div_cnt + 1'b1;
            tick <= 1'b0;
        end
    end
endmodule
