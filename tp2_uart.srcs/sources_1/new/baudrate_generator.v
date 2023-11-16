`timescale 1ns / 1ps

module baudrate_generator #(
    parameter LIMITE = 163,
    parameter COUNTER_BITS = 8
)(
    input wire i_clock,
    input wire i_reset,
    output wire o_ticks
);

reg [COUNTER_BITS-1 : 0] counter;

assign o_ticks = (counter == LIMITE);

always @(posedge i_clock)
begin
    if(i_reset)
        counter <= {COUNTER_BITS {1'b0}};
    else if(counter == LIMITE)
        counter <= {{COUNTER_BITS-1 {1'b0}}, 1'b1}; // counter = 1
    else
        counter <= counter + {{COUNTER_BITS-1 {1'b0}}, 1'b1}; // counter++
end

endmodule