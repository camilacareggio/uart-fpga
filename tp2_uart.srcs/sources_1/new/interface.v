module interface #(
    parameter BITS_DATA = 8,
    parameter OP_LEN = 6     
)(
    input wire i_clk,
    input wire i_reset,
    input wire [BITS_DATA-1:0] i_alu_result,
    input wire [BITS_DATA-1:0] i_uart_rx, // data received
    input wire i_fifo_rx_is_empty,
    input wire i_fifo_tx_is_full,
    output wire o_fifo_rx_read,  
    output wire o_fifo_tx_write,
    output wire [BITS_DATA-1:0] o_uart_tx, // data to transmit
    output wire [OP_LEN-1:0] o_alu_op,
    output wire [BITS_DATA-1:0] o_alu_data_a,
    output wire [BITS_DATA-1:0] o_alu_data_b
);

// States for state machine
localparam [3:0] INITIAL = 3'b000;
localparam [3:0] OP_CODE = 3'b001;
localparam [3:0] DATA_A = 3'b010;
localparam [3:0] DATA_B = 3'b011;
localparam [3:0] RESULT = 3'b100;
localparam [3:0] SYNC_WAIT = 3'b101;

reg [3:0] state, state_next;
reg fifo_rx_read, fifo_rx_read_next;
reg fifo_tx_write, fifo_tx_write_next;
reg [3:0] pending_state, pending_next;

reg [OP_LEN-1:0] op_reg, op_next;
reg [BITS_DATA-1:0] data_a_reg, data_a_next;
reg [BITS_DATA-1:0] data_b_reg, data_b_next;
reg [BITS_DATA-1:0] result, result_next;

always @(posedge i_clk) begin
    if(i_reset) begin
        state <= INITIAL;
        fifo_rx_read <= 1'b0;
        fifo_tx_write <= 1'b0;
        op_reg <= {OP_LEN{1'b0}};
        data_a_reg <= {BITS_DATA{1'b0}};
        data_b_reg <= {BITS_DATA{1'b0}};
        result <= {BITS_DATA{1'b0}};
        pending_state <= INITIAL;
    end
    else begin
        state <= state_next;
        fifo_rx_read <= fifo_rx_read_next;
        fifo_tx_write <= fifo_tx_write_next;
        op_reg <= op_next;
        data_a_reg <= data_a_next;
        data_b_reg <= data_b_next;
        result <= result_next;
        pending_state <= pending_next;
    end
end

// next state logic
always @(*) begin
    state_next = state;
    fifo_rx_read_next = fifo_rx_read;
    fifo_tx_write_next = fifo_tx_write;
    op_next = op_reg;
    data_a_next = data_a_reg;
    data_b_next = data_b_reg;
    result_next = result;
    pending_next = pending_state;

    case (state)
        INITIAL: begin // waiting for incoming data
            fifo_tx_write_next = 1'b0; // writing not allowed   
            if(~i_fifo_rx_is_empty) begin
                state_next = OP_CODE;
                fifo_rx_read_next = 1'b1; // if not empty, read next
            end
        end
        
        SYNC_WAIT: begin
            if(~i_fifo_rx_is_empty) begin
                state_next = pending_state;
                fifo_rx_read_next = 1'b1;
            end
        end
        
        OP_CODE: begin
            if(i_fifo_rx_is_empty) begin
                fifo_rx_read_next = 1'b0;
                state_next = SYNC_WAIT;
                pending_next = OP_CODE;
            end
            else begin
                state_next = DATA_A;
                op_next = i_uart_rx[OP_LEN-1:0];
                fifo_rx_read_next = 1'b1;
            end
        end 

        DATA_A: begin
            if(i_fifo_rx_is_empty) begin
                fifo_rx_read_next = 1'b0;
                state_next = SYNC_WAIT;
                pending_next = DATA_A;
            end
            else begin
                state_next = DATA_B;
                data_a_next = i_uart_rx;
                fifo_rx_read_next = 1'b1;
            end
        end

        DATA_B: begin
            if(i_fifo_rx_is_empty) begin
                fifo_rx_read_next = 1'b0;
                state_next = SYNC_WAIT;
                pending_next = DATA_B;
            end
            else begin
                state_next = RESULT;
                data_b_next = i_uart_rx;
                fifo_rx_read_next = 1'b0;
            end
        end

        RESULT: begin
            if(~i_fifo_tx_is_full) begin
                state_next = INITIAL;
                result_next = i_alu_result;
                fifo_tx_write_next = 1'b1;
            end
        end

        default: begin
            state_next = INITIAL;
            fifo_rx_read_next = 1'b0;
            fifo_tx_write_next = 1'b0;
        end

    endcase
end

assign o_alu_data_a = data_a_reg;
assign o_alu_data_b = data_b_reg;
assign o_alu_op = op_reg;
assign o_uart_tx = result;
assign o_fifo_tx_write = fifo_tx_write;
assign o_fifo_rx_read = fifo_rx_read;

endmodule