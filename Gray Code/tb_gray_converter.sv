`timescale 1ns/1ns

module tb_gray_converter;
    localparam W = 4;
    
    logic [W - 1:0] binary_in;
    logic [W - 1:0] gray_out;

    gray_converter #(.DATA_WIDTH(W)) dut(
        .binary_in(binary_in),
        .gray_out(gray_out)
    );

    initial begin
        binary_in = 4'b0010;
        #10
        $display("Binary: %b -> Gray : %b", binary_in, gray_out);

        binary_in = 4'b0001;
        #10
        $display("Binary: %b -> Gray : %b", binary_in, gray_out);

        binary_in = 4'b1011;
        #10
        $display("Binary: %b -> Gray : %b", binary_in, gray_out);
    end
endmodule 