//start bit 0
//stop bit 1
//data 8 bits
`timescale 1ns/1ns

module parity_checker (
  input logic clk, 
  input logic reset,
  input logic in,
  output logic [7:0] out_byte,
  output logic done
);
  
  logic [7:0] data_reg;
  logic [39:0] state_name;
  
  typedef enum logic [2:0] {
    IDLE,
    DATA,
    STOP,
    WAIT,
    ERROR
  } state_t;
  
  state_t state, next_state;
  
  logic odd_out;
  logic parity_reset;
  logic [3:0] counter;
  
  always_comb begin
    parity_reset = !reset || (state == IDLE || state == WAIT);
  end
  
  parity parity_inst(.clk(clk),
                     .reset(parity_reset),
                     .in(in),
                     .odd(odd_out));
  
  
  always_comb begin
    next_state = state;
    case (state) 
      IDLE: 
        begin
          state_name = "IDLE";
          if (in == 0) 	next_state = DATA;
          else 			next_state = IDLE;    
        end
      DATA: 
        begin
          state_name = "DATA";
          if (counter == 4'd8) next_state = STOP;
          else 				 next_state = DATA;
        end
      STOP: 
        begin
          state_name = "STOP";
          if (in == 1) begin
            if (odd_out) next_state = WAIT;
            else 		 next_state = IDLE;
          end
          else 		   next_state = ERROR;
        end
      ERROR:
        begin
          state_name = "ERROR";
          if (in == 1) next_state = IDLE;
          else 		   next_state = ERROR;
        end
      WAIT: 
        begin
          state_name = "WAIT";
          if (in == 0) next_state = DATA;
          else 		   next_state = IDLE;
        end
      default: next_state = IDLE;
    endcase
  end
  
  always_ff @(posedge clk) begin
    if (!reset) begin
      state <= IDLE;
      counter <= '0;
      data_reg <= 8'bXXXXXXXX;
    end
    else begin
      state <= next_state;
      
      if (state == DATA) begin
        counter <= counter + 1'b1;
      end
      else counter <= '0;
      
      if (state == DATA && counter < 8) begin
        data_reg[counter] <= in;
      end
    end
  end
  
  assign done = (state == WAIT);
  assign out_byte = data_reg;
  
endmodule
