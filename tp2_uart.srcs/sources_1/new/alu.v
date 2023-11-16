`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////

module alu #(
        parameter BITS_DATA = 8, // data size
        parameter BITS_OP = 6 // operation code size
    )(
        input wire signed [BITS_DATA-1 : 0] i_a,
        input wire signed [BITS_DATA-1 : 0] i_b,
        input wire [BITS_OP-1 : 0] i_op,
        output wire signed [BITS_DATA-1 : 0] o_result
    );

    // Operation codes
    localparam ADD = 6'b100000;
    localparam SUB = 6'b100010;
    localparam AND = 6'b100100;
    localparam OR  = 6'b100101;
    localparam XOR = 6'b100110;
    localparam SRA = 6'b000011;
    localparam SRL = 6'b000010;
    localparam NOR = 6'b100111;
    
    reg [BITS_DATA-1 : 0] result;
    assign o_result = result;
    
    always @(*) begin
        case (i_op)
            ADD: result = i_a + i_b;
            SUB: result = i_a - i_b;
            AND: result = i_a & i_b;
            OR : result = i_a | i_b;
            XOR: result = i_a ^ i_b;
            SRA: result = i_a >>> i_b; // desplazamiento aritmético a la derecha
            SRL: result = i_a >> i_b; // desplazamiento lógico a la derecha
            NOR: result = ~(i_a | i_b);
            default: result = {BITS_DATA{1'b0}}; // resultado 0 si la operacion no es válida
        endcase
    end

endmodule