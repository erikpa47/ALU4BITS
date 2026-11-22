/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_ALU4b (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // =========================================
    // INPUTS
    // =========================================

    // A = ui_in[3:0]
    // B = ui_in[7:4]
    // Opcode = uio_in[3:0]

    wire [3:0] A;
    wire [3:0] B;
    wire [3:0] opcode;

    assign A      = ui_in[7:4];   // Input A  Mas  significativo
    assign B      = ui_in[3:0];   // Input B  Menos significativo
    assign opcode = uio_in[3:0];


    // =========================================
    // INTERNAL SIGNALS
    // =========================================

    reg [3:0] result;
    reg carry;
    reg overflow;

    reg [4:0] temp_add;
    reg [4:0] temp_sub;

    reg [7:0] temp_mul;


    // =========================================
    // ALU
    // =========================================

    always @(*) begin

        // Default values
        result   = 4'b0000;
        carry    = 1'b0;
        overflow = 1'b0;

        temp_add = 5'b00000;
        temp_sub = 5'b00000;
        temp_mul = 8'b00000000;

        case (opcode)

            // ADD
            4'b0000: begin

                temp_add = A + B;

                result = temp_add[3:0];
                carry  = temp_add[4];

                overflow =
                    (A[3] == B[3]) &&
                    (result[3] != A[3]);

            end


            // SUB
            4'b0001: begin

                temp_sub = A + (~B) + 1'b1;

                result = temp_sub[3:0];
                carry  = temp_sub[4];

                overflow =
                    (A[3] != B[3]) &&
                    (result[3] != A[3]);

            end


            // MUL
            4'b0010: begin

                temp_mul = A * B;

                result = temp_mul[3:0];

                carry = |temp_mul[7:4];

                overflow = |temp_mul[7:4];

            end


            // DIV
            4'b0011: begin

                if (B != 4'b0000) begin

                    result = A / B;

                end
                else begin

                    result   = 4'b0000;
                    overflow = 1'b1;

                end

            end


            // AND
            4'b0100: begin

                result = A & B;

            end


            // OR
            4'b0101: begin

                result = A | B;

            end


            // XOR
            4'b0110: begin

                result = A ^ B;

            end


            // NOT
            4'b0111: begin

                result = ~A;

            end


            // ENC
            4'b1000: begin

                result = A ^ B;

            end


            // Invalid opcode
            default: begin

                result   = 4'b0000;
                carry    = 1'b0;
                overflow = 1'b0;

            end

        endcase

    end


    // =========================================
    // OUTPUTS
    // =========================================

    // Result in uo_out[3:0]
    // Upper bits unused

    assign uo_out = {4'b0000, result};


    // uio_out[6] = Carry
    // uio_out[7] = Overflow

    assign uio_out = {
        overflow,
        carry,
        6'b000000
    };


    // uio[7:6] outputs
    // uio[5:0] inputs

    assign uio_oe = 8'b11000000;


    // =========================================
    // UNUSED INPUTS
    // =========================================

    wire _unused = &{ena, clk, rst_n, uio_in[7:4], 1'b0};

endmodule
