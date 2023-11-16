`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////

module top #(
    parameter BITS_DATA = 8,
    parameter SB_TICK = 16,
    parameter COUNTER_MOD = 326,
    parameter COUNTER_BITS = 9,
    parameter PTR_BITS = 2,
    parameter OP_LEN = 6     
) ( 
    input wire i_clk,
    input wire i_reset,
    input wire i_uart_rx,
    output wire o_uart_tx
);

wire tx_is_full;
wire rx_is_empty;
wire [BITS_DATA-1:0] data_to_rd;

wire rx_read;
wire tx_write;
wire [BITS_DATA-1:0] data_to_write;
wire [OP_LEN-1:0] alu_operation;
wire [BITS_DATA-1:0] alu_data_a;
wire [BITS_DATA-1:0] alu_data_b;

wire [BITS_DATA-1:0] aluResult;

uart #(
    .BITS_DATA(BITS_DATA),
    .SB_TICK(SB_TICK),
    .COUNTER_MOD(COUNTER_MOD),
    .COUNTER_BITS(COUNTER_BITS),
    .PTR_BITS(PTR_BITS)        
) u_uart (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_read_uart(rx_read),
    .i_write_uart(tx_write),
    .i_uart_rx(i_uart_rx),
    .i_data_to_write(data_to_write),
    .o_tx_full(tx_is_full),
    .o_rx_empty(rx_is_empty),
    .o_uart_tx(o_uart_tx),
    .o_data_to_read(data_to_rd)
);

interface #(
    .BITS_DATA(BITS_DATA),
    .OP_LEN(OP_LEN)     
) u_interface (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_alu_result(aluResult),
    .i_uart_rx(data_to_rd),
    .i_fifo_rx_is_empty(rx_is_empty),
    .i_fifo_tx_is_full(tx_is_full),
    .o_fifo_rx_read(rx_read),
    .o_fifo_tx_write(tx_write),
    .o_uart_tx(data_to_write),
    .o_alu_op(alu_operation),
    .o_alu_data_a(alu_data_a),
    .o_alu_data_b(alu_data_b)
);

alu #(
    .BITS_DATA(BITS_DATA),
    .BITS_OP(OP_LEN)
) u_alu ( 
    .i_a(alu_data_a),
    .i_b(alu_data_b),
    .i_op(alu_operation),
    .o_result(aluResult)
); 

endmodule
