module mac_stop #(
    parameter M                         = 4,
    parameter K                         = 4,
    parameter N                         = 4,
    parameter DATA_WIDTH_INIT_MATRIX    = 32,
    parameter DATA_WIDTH_RESULT_MATRIX  = (DATA_WIDTH_INIT_MATRIX * 2 + $clog2(K)) //$clog2 already rounds up 

)(
    input logic clk,
    input logic resetn,

    output logic [DATA_WIDTH_RESULT_MATRIX-1:0] data_out_c, // data that will be written to SRAM C
    output logic matrix_c_we,

    input logic [(DATA_WIDTH_INIT_MATRIX*2)-1:0] product_reg,
    input logic [$clog2(K)-1:0] matrix_a_col_addr_counter_reg, matrix_b_row_addr_counter_reg,
    input logic [$clog2(M)-1:0] matrix_a_row_addr_counter_reg,
    input logic [$clog2(N)-1:0] matrix_b_col_addr_counter_reg,
    input logic mult_done_reg,

    output logic [$clog2(M)-1:0] row_addr_c,
    output logic [$clog2(N)-1:0] col_addr_c,
    output logic mac_done

);

    logic [DATA_WIDTH_RESULT_MATRIX-1:0] accum_reg;


    always @(posedge clk, negedge resetn) begin
        if (~resetn) begin
            accum_reg <= '0;
        end else begin
            if (mult_done_reg) begin
                accum_reg <= accum_reg + product_reg;
            end
            if (matrix_b_row_addr_counter_reg == K-1) begin
                accum_reg <= '0;
            end
        end
    end


    always_comb begin
        if ((matrix_a_row_addr_counter_reg == M-1) & (matrix_b_col_addr_counter_reg == N-1) & (matrix_b_row_addr_counter_reg == K-1) )
            mac_done = 1'b1;
        else
            mac_done = 1'b0;

        if (matrix_b_row_addr_counter_reg == K-1) begin
            matrix_c_we = 1'b1;
            row_addr_c = matrix_a_row_addr_counter_reg;
            col_addr_c = matrix_b_col_addr_counter_reg;
            data_out_c = accum_reg + product_reg;
        end else begin
            matrix_c_we = 1'b0;
            row_addr_c = '0;
            col_addr_c = '0;
            data_out_c = '0;
        end
        

    end














endmodule