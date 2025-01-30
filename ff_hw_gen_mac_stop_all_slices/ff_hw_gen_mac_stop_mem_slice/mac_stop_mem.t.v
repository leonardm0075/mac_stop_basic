module tb_mac_stop_mem;
    //Test Case 1: Matrix A is 2x2 and matrix B is 2x2 --> M = 2, K = 2, N = 2 --> all prduct and accumulation values fall in the decimal range of 0-50
    //Test Case 2: Matrix A is 10x8 and matrix B is 8x5 --> M = 10, K = 8, N = 5 --> all prduct and accumulation values fall in the decimal range of 50-100
    //Test Case 3: Matrix A is 3x5 and matrix B is 5x5 --> M = 3, K = 5, N = 5 --> all prduct and accumulation values fall in the decimal range of 100-150

    parameter int M = 3;
    parameter int K = 5;
    parameter int N = 5;
    parameter int DATA_WIDTH_INIT_MATRIX = 32;
    parameter int DATA_WIDTH_RESULT_MATRIX = (DATA_WIDTH_INIT_MATRIX * 2 + $clog2(K));

    logic clk;
    logic resetn;
    logic [DATA_WIDTH_INIT_MATRIX-1:0] data_in_a, data_in_b;
    logic [DATA_WIDTH_RESULT_MATRIX-1:0] data_in_c;
    logic [$clog2(M)-1:0] row_addr_a, row_addr_c;
    logic [$clog2(K)-1:0] col_addr_a, row_addr_b;
    logic [$clog2(N)-1:0] col_addr_b, col_addr_c;
    logic matrix_a_we, matrix_b_we, matrix_c_we;
    logic matrix_a_re, matrix_b_re, matrix_c_re;
    logic [DATA_WIDTH_INIT_MATRIX-1:0] data_out_a, data_out_b;
    logic [DATA_WIDTH_RESULT_MATRIX-1:0] data_out_c;


    mac_stop_mem #(.M(M), .K(K), .N(N), .DATA_WIDTH_INIT_MATRIX(DATA_WIDTH_INIT_MATRIX)) dut (
        .clk(clk),
        .resetn(resetn),
        .data_in_a(data_in_a),
        .data_in_b(data_in_b),
        .data_in_c(data_in_c),
        .row_addr_a(row_addr_a),
        .row_addr_c(row_addr_c),
        .col_addr_a(col_addr_a),
        .row_addr_b(row_addr_b),
        .col_addr_b(col_addr_b),
        .col_addr_c(col_addr_c),
        .matrix_a_we(matrix_a_we),
        .matrix_b_we(matrix_b_we),
        .matrix_c_we(matrix_c_we),
        .matrix_a_re(matrix_a_re),
        .matrix_b_re(matrix_b_re),
        .matrix_c_re(matrix_c_re),
        .data_out_a(data_out_a),
        .data_out_b(data_out_b),
        .data_out_c(data_out_c)
    );


    // Matrices that will be used to send corresponding write data to the SRAMs
    logic [M-1:0][K-1:0][DATA_WIDTH_INIT_MATRIX-1:0] matrix_a;
    logic [K-1:0][N-1:0][DATA_WIDTH_INIT_MATRIX-1:0] matrix_b;
    logic [M-1:0][N-1:0][DATA_WIDTH_RESULT_MATRIX-1:0] matrix_c;


    // Clock generation
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        resetn = 0;
        data_in_a = 0;
        data_in_b = 0;
        data_in_c = 0;
        matrix_a_we = 0;
        matrix_b_we = 0;
        matrix_c_we = 0;
        matrix_a_re = 0;
        matrix_b_re = 0;
        matrix_c_re = 0;
        row_addr_a = 0;
        row_addr_b = 0;
        row_addr_c = 0;
        col_addr_a = 0;
        col_addr_b = 0;
        col_addr_c = 0;


        //Test Case 1
        //matrix_a = '{
        //            '{4,3}, 
        //            '{2,1}};
        //matrix_b = '{
        //            '{8,7},
        //            '{6,5}};
        //matrix_c = '{
        //            '{50, 43},
        //            '{22, 19}};

        //Test Case 2
        //matrix_a = '{
        //    '{3, 1, 1, 4, 3, 3, 2, 1},
        //    '{3, 1, 2, 3, 3, 2, 4, 1},
        //    '{4, 1, 3, 2, 1, 4, 3, 4},
        //    '{4, 3, 4, 3, 3, 3, 1, 1},
        //    '{1, 2, 3, 4, 2, 4, 3, 2},
        //    '{2, 4, 4, 4, 3, 2, 3, 4},
        //    '{1, 2, 4, 2, 1, 4, 3, 4},
        //    '{2, 3, 4, 3, 2, 4, 3, 3},
        //    '{4, 3, 3, 4, 4, 2, 3, 1},
        //    '{4, 4, 1, 4, 2, 3, 1, 4}
        //};
//
        //matrix_b = '{
        //    '{4, 4, 2, 2, 1},
        //    '{4, 3, 3, 1, 1},
        //    '{1, 4, 4, 2, 2},
        //    '{4, 4, 4, 4, 3},
        //    '{4, 2, 4, 4, 4},
        //    '{3, 2, 2, 4, 4},
        //    '{2, 3, 1, 2, 3},
        //    '{2, 2, 2, 1, 4}
        //};
//
        //matrix_c = '{
        //    '{60, 55, 51, 54, 52},
        //    '{58, 59, 51, 52, 53},
        //    '{61, 66, 54, 53, 62},
        //    '{69, 70, 66, 58, 55},
        //    '{61, 63, 59, 58, 62},
        //    '{76, 79, 75, 62, 71},
        //    '{54, 61, 55, 50, 62},
        //    '{68, 72, 66, 60, 67},
        //    '{77, 76, 70, 64, 62},
        //    '{76, 69, 63, 56, 61}};
//

        //Test Case 3
        matrix_a = '{
            '{4, 3, 5, 4, 4},
            '{3, 4, 4, 5, 4},
            '{5, 4, 3, 4, 4}
        };

        matrix_b = '{
            '{5, 6, 5, 5, 6},
            '{6, 5, 6, 6, 5},
            '{5, 5, 6, 5, 6},
            '{6, 6, 5, 6, 5},
            '{5, 5, 6, 5, 5}
        };

        matrix_c = '{
                '{107, 108, 112, 107, 109},
                '{109, 108, 112, 109, 107},
                '{108, 109, 111, 108, 108}};


        #10;
        resetn = 1;

        // Write matrix A to SRAM A
        for (int i = 0; i < M; i++) begin
            for (int j = 0; j < K; j++) begin
                matrix_a_we = 1;
                row_addr_a = i;
                col_addr_a = j;
                data_in_a = matrix_a[i][j];
                #10;
            end
        end

        // Write matrix B to SRAM B
        for (int i = 0; i < K; i++) begin
            for (int j = 0; j < N; j++) begin
                matrix_b_we = 1;
                row_addr_b = i;
                col_addr_b = j;
                data_in_b = matrix_b[i][j];
                #10;
            end
        end

        // Write matrix C to SRAM C
        for (int i = 0; i < M; i++) begin
            for (int j = 0; j < N; j++) begin
                matrix_c_we = 1;
                row_addr_c = i;
                col_addr_c = j;
                data_in_c = matrix_c[i][j];
                #10;
            end
        end

        #10;
        matrix_a_we = 0;
        matrix_b_we = 0;
        matrix_c_we = 0;

        // Read and verify matrix A, B, and C

        for (int i = 0; i < M; i++) begin
            for (int j = 0; j < K; j++) begin
                matrix_a_re = 1;
                row_addr_a = i;
                col_addr_a = j;
                #5;
                if (data_out_a == matrix_a[i][j]) begin
                    $display("local matrix_a[%0d][%0d] = %0d || dut matrix_a[%0d][%0d] = %0d", i, j, matrix_a[i][j], i, j, data_out_a);
                end
                #5;
            end
        end
        matrix_a_re = 0;
        $display("\n\n");

        for (int i = 0; i < K; i++) begin
            for (int j = 0; j < N; j++) begin
                matrix_b_re = 1;
                row_addr_b = i;
                col_addr_b = j;
                #5;
                if (data_out_b == matrix_b[i][j]) begin
                    $display("local matrix_b[%0d][%0d] = %0d || dut matrix_b[%0d][%0d] = %0d", i, j, matrix_b[i][j], i, j, data_out_b);
                end
                #5;
            end
        end
        matrix_b_re = 0;
        $display("\n\n");


        for (int i = 0; i < M; i++) begin
            for (int j = 0; j < N; j++) begin
                matrix_c_re = 1;
                row_addr_c = i;
                col_addr_c = j;
                #5;
                if (data_out_c == matrix_c[i][j]) begin
                    $display("local matrix_c[%0d][%0d] = %0d || dut matrix_c[%0d][%0d] = %0d", i, j, matrix_c[i][j], i, j, data_out_c);
                end
                #5;
            end
        end

        matrix_c_re = 0;
        $display("\n\n");



        #20; 
        $finish;

    end



endmodule
