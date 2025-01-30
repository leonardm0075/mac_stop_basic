`timescale 1ns / 1ps

module test_mac_stop_mult;
    //Test Case 1: Matrix A is 2x2 and matrix B is 2x2 --> M = 2, K = 2, N = 2 --> all prduct and accumulation values fall in the decimal range of 0-50
    //Test Case 2: Matrix A is 10x8 and matrix B is 8x5 --> M = 10, K = 8, N = 5 --> all prduct and accumulation values fall in the decimal range of 50-100
    //Test Case 3: Matrix A is 3x5 and matrix B is 5x5 --> M = 3, K = 5, N = 5 --> all prduct and accumulation values fall in the decimal range of 100-150
    
    // Parameters
    parameter M = 3;
    parameter K = 5;
    parameter N = 5;
    parameter DATA_WIDTH_INIT_MATRIX = 32;
    parameter DATA_WIDTH_RESULT_MATRIX = (DATA_WIDTH_INIT_MATRIX * 2 + $clog2(K));

    // Inputs
    logic clk;
    logic resetn;
    logic [DATA_WIDTH_INIT_MATRIX-1:0] data_in_a;
    logic [DATA_WIDTH_INIT_MATRIX-1:0] data_in_b;
    logic do_mac;

    // Outputs
    logic [$clog2(M)-1:0] row_addr_a;
    logic [$clog2(K)-1:0] col_addr_a;
    logic [$clog2(K)-1:0] row_addr_b;
    logic [$clog2(N)-1:0] col_addr_b;
    logic matrix_a_re;
    logic matrix_b_re;
    logic mac_done;
    logic [(DATA_WIDTH_INIT_MATRIX*2)-1:0] product_reg;
    logic [$clog2(K)-1:0] matrix_a_col_addr_counter_reg, matrix_b_row_addr_counter_reg;
    logic [$clog2(M)-1:0] matrix_a_row_addr_counter_reg;
    logic [$clog2(N)-1:0] matrix_b_col_addr_counter_reg;
    logic mult_done_reg;

    // Instantiate the Unit Under Test (UUT)
    mac_stop #(
        .M(M),
        .K(K),
        .N(N),
        .DATA_WIDTH_INIT_MATRIX(DATA_WIDTH_INIT_MATRIX),
        .DATA_WIDTH_RESULT_MATRIX(DATA_WIDTH_RESULT_MATRIX)
    ) uut (
        .clk(clk),
        .resetn(resetn),
        .data_in_a(data_in_a),
        .data_in_b(data_in_b),
        .row_addr_a(row_addr_a),
        .col_addr_a(col_addr_a),
        .row_addr_b(row_addr_b),
        .col_addr_b(col_addr_b),
        .matrix_a_re(matrix_a_re),
        .matrix_b_re(matrix_b_re),
        .do_mac(do_mac),
        .mac_done(mac_done),
        .product_reg(product_reg),
        .matrix_a_col_addr_counter_reg(matrix_a_col_addr_counter_reg),
        .matrix_b_row_addr_counter_reg(matrix_b_row_addr_counter_reg),
        .matrix_a_row_addr_counter_reg(matrix_a_row_addr_counter_reg),
        .matrix_b_col_addr_counter_reg(matrix_b_col_addr_counter_reg),
        .mult_done_reg(mult_done_reg)
    );


    // local SRAMs
    logic [M-1:0][K-1:0][DATA_WIDTH_INIT_MATRIX-1:0] matrix_a;
    logic [K-1:0][N-1:0][DATA_WIDTH_INIT_MATRIX-1:0] matrix_b;

    logic [(M*N*K)-1:0][(DATA_WIDTH_INIT_MATRIX*2)-1:0] product_reg_array;
    logic [(M*N*K)-1:0][$clog2(K)-1:0] matrix_a_col_addr_counter_reg_array, matrix_b_row_addr_counter_reg_array;
    logic [(M*N*K)-1:0][$clog2(M)-1:0] matrix_a_row_addr_counter_reg_array;
    logic [(M*N*K)-1:0][$clog2(N)-1:0] matrix_b_col_addr_counter_reg_array;

    string product_reg_array_str;
    string matrix_a_col_addr_counter_reg_array_str;
    string matrix_b_row_addr_counter_reg_array_str;
    string matrix_a_row_addr_counter_reg_array_str;
    string matrix_b_col_addr_counter_reg_array_str;


    integer output_file;
    logic [$clog2(M*N*K)-1:0]array_counter;

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        output_file = $fopen("output_mac_stop_mult.txt", "w");
        // Initialize Inputs
        clk = 0;
        resetn = 0;
        data_in_a = 0;
        data_in_b = 0;
        do_mac = 0;
        array_counter = 0;
        matrix_a_col_addr_counter_reg_array = '0;
        matrix_b_row_addr_counter_reg_array = '0;
        matrix_a_row_addr_counter_reg_array = '0;
        matrix_b_col_addr_counter_reg_array = '0;
        product_reg_array = '0;

        // Test Case 1 - 2x2 matrices
        //matrix_a = '{'{4,3}, '{2,1}};
        ////matrix_b = '{'{8,7}, '{6,5}};

        // Test Case 2 - 10x8 and 8x5 matrices
        ////matrix_a = '{
        ////    '{3, 1, 1, 4, 3, 3, 2, 1},
        ////    '{3, 1, 2, 3, 3, 2, 4, 1},
        ////    '{4, 1, 3, 2, 1, 4, 3, 4},
        ////    '{4, 3, 4, 3, 3, 3, 1, 1},
        ////    '{1, 2, 3, 4, 2, 4, 3, 2},
        ////    '{2, 4, 4, 4, 3, 2, 3, 4},
        ////    '{1, 2, 4, 2, 1, 4, 3, 4},
        ////    '{2, 3, 4, 3, 2, 4, 3, 3},
        ////    '{4, 3, 3, 4, 4, 2, 3, 1},
        ////    '{4, 4, 1, 4, 2, 3, 1, 4}
        ////};
////
        ////matrix_b = '{
        ////    '{4, 4, 2, 2, 1},
        ////    '{4, 3, 3, 1, 1},
        ////    '{1, 4, 4, 2, 2},
        ////    '{4, 4, 4, 4, 3},
        ////    '{4, 2, 4, 4, 4},
        ////    '{3, 2, 2, 4, 4},
        ////    '{2, 3, 1, 2, 3},
        ////    '{2, 2, 2, 1, 4}
        ////};

        // Test Case 3 - 3x5 and 5x5 matrices
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

        // Wait for global reset
        #10;
        resetn = 1;

        while(!mac_done) begin
            do_mac = 1;
            #5;
            if (matrix_a_re || matrix_b_re) begin
                data_in_a = matrix_a[row_addr_a][col_addr_a];
                data_in_b = matrix_b[row_addr_b][col_addr_b];
            end
            #5;
            if (product_reg != data_in_a * data_in_b) begin
                $display("Error: product_reg = %0d || local_product_reg = %0d", product_reg, data_in_a * data_in_b);
                $finish;
            end else begin
                product_reg_array[array_counter] = product_reg;
                matrix_a_col_addr_counter_reg_array[array_counter] = matrix_a_col_addr_counter_reg;
                matrix_b_row_addr_counter_reg_array[array_counter] = matrix_b_row_addr_counter_reg;
                matrix_a_row_addr_counter_reg_array[array_counter] = matrix_a_row_addr_counter_reg;
                matrix_b_col_addr_counter_reg_array[array_counter] = matrix_b_col_addr_counter_reg;
                array_counter = array_counter + 1;


                $display("product_reg = %0d || local_product_reg = %0d", product_reg, data_in_a * data_in_b);
                $display("matrix_a_col_addr_counter_reg = %0d", matrix_a_col_addr_counter_reg);
                $display("matrix_b_row_addr_counter_reg = %0d", matrix_b_row_addr_counter_reg);
                $display("matrix_a_row_addr_counter_reg = %0d", matrix_a_row_addr_counter_reg);
                $display("matrix_b_col_addr_counter_reg = %0d", matrix_b_col_addr_counter_reg);
            end
        end

        #20;
        for (int i=(M*N*K); i>0; i=i-1) begin
            product_reg_array_str = {product_reg_array_str, $sformatf("%0d", product_reg_array[i-1]), ", " };
            matrix_a_col_addr_counter_reg_array_str = {matrix_a_col_addr_counter_reg_array_str, $sformatf("%0d", matrix_a_col_addr_counter_reg_array[i-1]), ", " };
            matrix_b_row_addr_counter_reg_array_str = {matrix_b_row_addr_counter_reg_array_str, $sformatf("%0d", matrix_b_row_addr_counter_reg_array[i-1]), ", " };
            matrix_a_row_addr_counter_reg_array_str = {matrix_a_row_addr_counter_reg_array_str, $sformatf("%0d", matrix_a_row_addr_counter_reg_array[i-1]), ", " };
            matrix_b_col_addr_counter_reg_array_str = {matrix_b_col_addr_counter_reg_array_str, $sformatf("%0d", matrix_b_col_addr_counter_reg_array[i-1]), ", " };
        end
        $fwrite(output_file, "product_reg_array = {%s}\n", product_reg_array_str);
        $fwrite(output_file, "matrix_a_col_addr_counter_reg_array = {%s}\n", matrix_a_col_addr_counter_reg_array_str);
        $fwrite(output_file, "matrix_b_row_addr_counter_reg_array = {%s}\n", matrix_b_row_addr_counter_reg_array_str);
        $fwrite(output_file, "matrix_a_row_addr_counter_reg_array = {%s}\n", matrix_a_row_addr_counter_reg_array_str);
        $fwrite(output_file, "matrix_b_col_addr_counter_reg_array = {%s}\n", matrix_b_col_addr_counter_reg_array_str);

            



        // Finish simulation
        $finish;
    end

endmodule