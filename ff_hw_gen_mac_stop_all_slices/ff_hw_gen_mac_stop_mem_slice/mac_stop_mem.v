

module mac_stop_mem #(
    //Test Case 1: Matrix A is 2x2 and matrix B is 2x2 --> M = 2, K = 2, N = 2 --> all prduct and accumulation values fall in the decimal range of 0-50
    //Test Case 2: Matrix A is 10x8 and matrix B is 8x5 --> M = 10, K = 8, N = 5 --> all prduct and accumulation values fall in the decimal range of 50-100
    //Test Case 3: Matrix A is 3x5 and matrix B is 5x5 --> M = 3, K = 5, N = 5 --> all prduct and accumulation values fall in the decimal range of 100-150

    parameter M                         = 4,
    parameter K                         = 4,
    parameter N                         = 4,
    parameter DATA_WIDTH_INIT_MATRIX    = 32,
    parameter DATA_WIDTH_RESULT_MATRIX  = (DATA_WIDTH_INIT_MATRIX * 2 + $clog2(K)) //$clog2 already rounds up 

)(

    input logic clk,
    input logic resetn,

    input logic [DATA_WIDTH_INIT_MATRIX-1:0] data_in_a, data_in_b, // write data to SRAM A & B
    output logic [DATA_WIDTH_INIT_MATRIX-1:0] data_out_a, data_out_b, // read data from SRAM A & B
    input logic [DATA_WIDTH_RESULT_MATRIX-1:0] data_in_c,  // write data to SRAM C
    output logic [DATA_WIDTH_RESULT_MATRIX-1:0] data_out_c, // read data from SRAM C

    input logic [$clog2(M)-1:0] row_addr_a, row_addr_c,
    input logic [$clog2(K)-1:0] col_addr_a, row_addr_b,
    input logic [$clog2(N)-1:0] col_addr_b, col_addr_c, 
    input logic matrix_a_we, matrix_b_we, matrix_c_we, 
    input logic matrix_a_re, matrix_b_re, matrix_c_re

);
    // create SRAMs for matrix A, B, and C
    logic [M-1:0][K-1:0][DATA_WIDTH_INIT_MATRIX-1:0] matrix_a;
    logic [K-1:0][N-1:0][DATA_WIDTH_INIT_MATRIX-1:0] matrix_b; 
    logic [M-1:0][N-1:0][DATA_WIDTH_RESULT_MATRIX-1:0] matrix_c;

    // writes are synchronous and reads are asynchronous
    always @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            matrix_a <= '0;
            matrix_b <= '0;
            matrix_c <= '0;

        end else begin 
            if (matrix_a_we) begin
                matrix_a[row_addr_a][col_addr_a] <= data_in_a;
            end
            if (matrix_b_we) begin
                matrix_b[row_addr_b][col_addr_b] <= data_in_b;
            end
            if (matrix_c_we) begin
                matrix_c[row_addr_c][col_addr_c] <= data_in_c;
            end
        end
    end



    always_comb begin
        data_out_a = '0;
        data_out_b = '0;
        data_out_c = '0;

        if (matrix_a_re) begin
            data_out_a = matrix_a[row_addr_a][col_addr_a];
        end
        if (matrix_b_re) begin
            data_out_b = matrix_b[row_addr_b][col_addr_b];
        end
        if (matrix_c_re) begin
            data_out_c = matrix_c[row_addr_c][col_addr_c];
        end

    end






endmodule 