

module mac_stop #(
    parameter M                         = 4,
    parameter K                         = 4,
    parameter N                         = 4,
    parameter DATA_WIDTH_INIT_MATRIX    = 32,
    parameter DATA_WIDTH_RESULT_MATRIX  = (DATA_WIDTH_INIT_MATRIX * 2 + $clog2(K)) //$clog2 already rounds up 

)(
    input logic clk,
    input logic resetn,

    input logic [DATA_WIDTH_INIT_MATRIX-1:0] data_in_a, data_in_b, // data read from SRAM A & B

    output logic [$clog2(M)-1:0] row_addr_a,
    output logic [$clog2(K)-1:0] col_addr_a, row_addr_b,
    output logic [$clog2(N)-1:0] col_addr_b,
    output logic matrix_a_re, matrix_b_re,
    output logic [(DATA_WIDTH_INIT_MATRIX*2)-1:0] product_reg,
    output logic [$clog2(K)-1:0] matrix_a_col_addr_counter_reg, matrix_b_row_addr_counter_reg,
    output logic [$clog2(M)-1:0] matrix_a_row_addr_counter_reg,
    output logic [$clog2(N)-1:0] matrix_b_col_addr_counter_reg,
    output logic mult_done_reg,


    input logic do_mac,
    output logic mac_done

);
    

    // create counters for matrix A and B
    logic [$clog2(M)-1:0] matrix_a_row_addr_counter;
    logic [$clog2(K)-1:0] matrix_a_col_addr_counter, matrix_b_row_addr_counter;
    logic [$clog2(N)-1:0] matrix_b_col_addr_counter;


    always @(posedge clk, negedge resetn) begin
        if (~resetn) begin
            product_reg <= '0;
            matrix_a_row_addr_counter <= '0;
            matrix_a_col_addr_counter <= '0;
            matrix_b_row_addr_counter <= '0;
            matrix_b_col_addr_counter <= '0;
            matrix_a_col_addr_counter_reg <= '0;
            matrix_b_row_addr_counter_reg <= '0;
            matrix_a_row_addr_counter_reg <= '0;
            matrix_b_col_addr_counter_reg <= '0;
            mult_done_reg <= 1'b0;
        end else begin
            // calculate the product of A and B, row and column at per clock
            if (do_mac) begin
                product_reg <= data_in_a * data_in_b; 
                mult_done_reg <= 1'b1;
                matrix_a_col_addr_counter <= matrix_a_col_addr_counter + 1;
                matrix_b_row_addr_counter <= matrix_b_row_addr_counter + 1;
                matrix_a_col_addr_counter_reg <= matrix_a_col_addr_counter;
                matrix_b_row_addr_counter_reg <= matrix_b_row_addr_counter;
                matrix_a_row_addr_counter_reg <= matrix_a_row_addr_counter;
                matrix_b_col_addr_counter_reg <= matrix_b_col_addr_counter;
                
                // counters below are used to keep track of the current row and column of matrix A and B
                if (matrix_a_col_addr_counter == K-1) begin
                    matrix_a_col_addr_counter <= '0;
                    matrix_b_row_addr_counter <= '0;
                    matrix_b_col_addr_counter <= matrix_b_col_addr_counter + 1;
                end

                if ((matrix_b_col_addr_counter == N-1) & (matrix_a_col_addr_counter == K-1)) begin
                    matrix_b_col_addr_counter <= '0;
                    matrix_a_row_addr_counter <= matrix_a_row_addr_counter + 1;
                end

                if ((matrix_a_row_addr_counter == M-1) & (matrix_b_col_addr_counter == N-1) & (matrix_b_row_addr_counter == K-1) ) begin
                    matrix_a_row_addr_counter <= '0;
                    matrix_a_col_addr_counter <= '0;
                    matrix_b_col_addr_counter <= '0;
                    matrix_b_row_addr_counter <= '0;
                end 

            end else begin
                product_reg <= '0;
                matrix_a_row_addr_counter <= '0;
                matrix_a_col_addr_counter <= '0;
                matrix_b_row_addr_counter <= '0;
                matrix_b_col_addr_counter <= '0;
                mult_done_reg <= 1'b0;
            end
        end
    end

    // begin the MAC operation
    always_comb begin        
        if (do_mac) begin
            matrix_a_re = 1'b1;
            matrix_b_re = 1'b1;
            row_addr_a = matrix_a_row_addr_counter;
            col_addr_a = matrix_a_col_addr_counter;
            row_addr_b = matrix_b_row_addr_counter;
            col_addr_b = matrix_b_col_addr_counter;
        end else begin
            matrix_a_re = 1'b0;
            matrix_b_re = 1'b0;
            row_addr_a = '0;
            col_addr_a = '0;
            row_addr_b = '0;
            col_addr_b = '0;
        end


        if ((matrix_a_row_addr_counter_reg == M-1) & (matrix_b_col_addr_counter_reg == N-1) & (matrix_b_row_addr_counter_reg == K-1) ) begin
            mac_done <= 1'b1;
        end else begin
            mac_done <= 1'b0;
        end


    end


    












endmodule