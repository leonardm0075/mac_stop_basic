module test_mac_stop_top;

    // Parameters
    parameter M = 8;
    parameter K = 6;
    parameter N = 4;
    parameter DATA_WIDTH_INIT_MATRIX = 32;
    parameter DATA_WIDTH_RESULT_MATRIX = (DATA_WIDTH_INIT_MATRIX * 2 + $clog2(K));

    // Inputs
    logic clk;
    logic resetn;
    logic host2block_val;
    logic block2host_rdy;
    logic [DATA_WIDTH_INIT_MATRIX-1:0] ext_data_in_a;
    logic [DATA_WIDTH_INIT_MATRIX-1:0] ext_data_in_b;
    logic [$clog2(M)-1:0] ext_row_addr_a;
    logic [$clog2(K)-1:0] ext_col_addr_a;
    logic [$clog2(K)-1:0] ext_row_addr_b;
    logic [$clog2(N)-1:0] ext_col_addr_b;
    logic [$clog2(M)-1:0] ext_row_addr_c;
    logic [$clog2(N)-1:0] ext_col_addr_c;
    logic ext_matrix_a_we;
    logic ext_matrix_b_we;
    logic ext_matrix_c_re;
    logic done_sending_data;
    logic done_reading_result_matrix;

    // Outputs
    logic host2block_rdy;
    logic block2host_val;
    logic [DATA_WIDTH_RESULT_MATRIX-1:0] ext_data_out_c;
    logic start_reading_result_matrix;
    logic mac_done;

    // Instantiate the Unit Under Test (UUT)
    mac_stop_top #(
        .M(M),
        .K(K),
        .N(N),
        .DATA_WIDTH_INIT_MATRIX(DATA_WIDTH_INIT_MATRIX),
        .DATA_WIDTH_RESULT_MATRIX(DATA_WIDTH_RESULT_MATRIX)
    ) uut (
        .clk(clk),
        .resetn(resetn),
        .host2block_val(host2block_val),
        .host2block_rdy(host2block_rdy),
        .block2host_rdy(block2host_rdy),
        .block2host_val(block2host_val),
        .ext_data_in_a(ext_data_in_a),
        .ext_data_in_b(ext_data_in_b),
        .ext_data_out_c(ext_data_out_c),
        .ext_row_addr_a(ext_row_addr_a),
        .ext_col_addr_a(ext_col_addr_a),
        .ext_row_addr_b(ext_row_addr_b),
        .ext_col_addr_b(ext_col_addr_b),
        .ext_row_addr_c(ext_row_addr_c),
        .ext_col_addr_c(ext_col_addr_c),
        .ext_matrix_a_we(ext_matrix_a_we),
        .ext_matrix_b_we(ext_matrix_b_we),
        .ext_matrix_c_re(ext_matrix_c_re),
        .done_sending_data(done_sending_data),
        .done_reading_result_matrix(done_reading_result_matrix),
        .start_reading_result_matrix(start_reading_result_matrix),
        .mac_done(mac_done)
    );



    initial begin
        // Initialize Inputs
        clk = 0;
        resetn = 0;
        host2block_val = 0;
        block2host_rdy = 0;
        ext_data_in_a = 0;
        ext_data_in_b = 0;
        ext_row_addr_a = 0;
        ext_col_addr_a = 0;
        ext_row_addr_b = 0;
        ext_col_addr_b = 0;
        ext_row_addr_c = 0;
        ext_col_addr_c = 0;
        ext_matrix_a_we = 0;
        ext_matrix_b_we = 0;
        ext_matrix_c_re = 0;
        done_sending_data = 0;
        done_reading_result_matrix = 0;

        // Wait for global reset
        #10;
        resetn = 1;

        // Test Case 1: Write data to matrix A and B
        host2block_val = 1;
        #10; // wait a clock to transition from IDLE to SAVE state
        ext_matrix_a_we = 1;
        ext_matrix_b_we = 1;

        for (int i = 0; i < M; i = i + 1) begin
            for (int j = 0; j < K; j = j + 1) begin
                ext_row_addr_a = i;
                ext_col_addr_a = j;
                if (i == 0) ext_data_in_a = 4;
                if (i == 1) ext_data_in_a = 6;
                if (i == 2) ext_data_in_a = 8;
                if (i == 3) ext_data_in_a = 10;
                if (i == 4) ext_data_in_a = 12;
                if (i == 5) ext_data_in_a = 14;
                if (i == 6) ext_data_in_a = 16;
                if (i == 7) ext_data_in_a = 18;
                $display("Matrix A[%0d][%0d] = %0d", i, j, ext_data_in_a);
                #10;
            end
        end


        for (int i = 0; i < K; i = i + 1) begin
            for (int j = 0; j < N; j = j + 1) begin
                ext_row_addr_b = i;
                ext_col_addr_b = j;
                if (i==0) ext_data_in_b = 2;
                if (i==1) ext_data_in_b = 4;
                if (i==2) ext_data_in_b = 6;
                if (i==3) ext_data_in_b = 8;
                if (i==4) ext_data_in_b = 10;
                if (i==5) ext_data_in_b = 12;
                $display("Matrix B[%0d][%0d] = %0d", i, j, ext_data_in_b);
                #10;
            end
        end

        done_sending_data = 1;
        host2block_val = 0;
        ext_matrix_a_we = 0;
        ext_matrix_b_we = 0;
        #10; // wait a clock to transition from SAVE to COMPUTE state
        done_sending_data = 0;
        
        wait (mac_done);
        $display("MAC operation done");
        #10; // wait a clock to transition from COMPUTE to DONE state
        block2host_rdy = 1;
        #10;
        if (block2host_val & start_reading_result_matrix) begin
            for (int i = 0; i < M; i = i + 1) begin
                for (int j = 0; j < N; j = j + 1) begin
                    ext_row_addr_c = i;
                    ext_col_addr_c = j;
                    ext_matrix_c_re = 1;
                    #5;
                    $display("Matrix C[%0d][%0d] = %0d", i, j, ext_data_out_c);
                    #5;
                end
            end
        end

        done_reading_result_matrix = 1;
        #10; // wait a clock to transition from DONE to IDLE state

        done_reading_result_matrix = 0;


        // Finish simulation
        #100;
        $finish;
    end

    // Clock generation
    always #5 clk = ~clk;

endmodule