module uart #(
    parameter BITS_DATA = 8,
    parameter SB_TICK = 16, // ticks for stop bits
    parameter COUNTER_MOD = 326, // 2 * 163 (basys3 frecuencia 100MHz entonces hacer *2)
    parameter COUNTER_BITS = 9, // only 8 not enough for 326
    parameter PTR_BITS = 2 // addr bits of FIFO   
)(
    input wire i_clk,
    input wire i_reset,
    input wire i_read_uart, // read flag
    input wire i_write_uart, // write flag
    input wire i_uart_rx,
    input wire [BITS_DATA-1 : 0] i_data_to_write,
    output wire o_tx_full,
    output wire o_rx_empty,
    output wire o_uart_tx,
    output wire [BITS_DATA-1 : 0] o_data_to_read
);

//Signal declaration
wire tick;
wire tx_done, rx_done;
wire tx_empty, tx_not_empty;
wire [BITS_DATA-1 : 0] tx_fifo_out, rx_data_out;


baudrate_generator #(
    .COUNTER_BITS(COUNTER_BITS),
    .LIMITE(COUNTER_MOD)
) u_baudrate_generator (
    .i_clock(i_clk),
    .i_reset(i_reset),
    .o_ticks(tick)
);

uart_rx #(
    .BITS_DATA(BITS_DATA),
    .SB_TICK(SB_TICK)
) u_uart_rx (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_rx(i_uart_rx),
    .i_tick(tick),
    .o_rx_done(rx_done),
    .o_data_out(rx_data_out)
);

fifo_buffer #(
    .BITS_DATA(BITS_DATA),
    .BITS_PTR(PTR_BITS)
) u_fifo_buffer_rx (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_read(i_read_uart),
    .i_write(rx_done),
    .i_write_data(rx_data_out),
    .o_is_empty(o_rx_empty),
    .o_is_full(),
    .o_read_data(o_data_to_read)
);

fifo_buffer #(
    .BITS_DATA(BITS_DATA),
    .BITS_PTR(PTR_BITS)
) u_fifo_fuffer_tx (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_read(tx_done),
    .i_write(i_write_uart),
    .i_write_data(i_data_to_write),
    .o_is_empty(tx_empty),
    .o_is_full(o_tx_full),
    .o_read_data(tx_fifo_out)
);

uart_tx #(
    .BITS_DATA(BITS_DATA),
    .SB_TICK(SB_TICK)
) u_uart_tx (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_tx_start(tx_not_empty),
    .i_tick(tick),
    .i_data_in(tx_fifo_out),
    .o_tx_done(tx_done),
    .o_tx(o_uart_tx)
);

assign tx_not_empty = ~tx_empty;

endmodule
