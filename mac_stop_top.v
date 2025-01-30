

module mac_stop_top #(
    parameter M                         = 4,
    parameter K                         = 4,
    parameter N                         = 4,
    parameter DATA_WIDTH_INIT_MATRIX    = 32,
    parameter DATA_WIDTH_RESULT_MATRIX  = (DATA_WIDTH_INIT_MATRIX * 2 + $clog2(K)) //$clog2 already rounds up 
)(

    input logic clk,
    input logic resetn,

    input logic host2block_val,
    output logic host2block_rdy,

    input logic block2host_rdy,
    output logic block2host_val,

    input logic [DATA_WIDTH_INIT_MATRIX-1:0] ext_data_in_a, ext_data_in_b,
    output logic [DATA_WIDTH_RESULT_MATRIX-1:0] ext_data_out_c,

    input logic [$clog2(M)-1:0] ext_row_addr_a, ext_row_addr_c,
    input logic [$clog2(K)-1:0] ext_col_addr_a, ext_row_addr_b,
    input logic [$clog2(N)-1:0] ext_col_addr_b, ext_col_addr_c, 
    input logic ext_matrix_a_we, ext_matrix_b_we,
    input logic ext_matrix_c_re, 

    input logic done_sending_data,
    input logic done_reading_result_matrix,
    output logic start_reading_result_matrix,
    output logic mac_done


);

    logic do_mac;
    
    // internal signals for mac_stop_mem
    logic [DATA_WIDTH_INIT_MATRIX-1:0] data_in_a, data_in_b;
    logic [DATA_WIDTH_INIT_MATRIX-1:0] data_out_a, data_out_b;
    logic [DATA_WIDTH_RESULT_MATRIX-1:0] data_in_c;
    logic [DATA_WIDTH_RESULT_MATRIX-1:0] data_out_c;

    logic [$clog2(M)-1:0] row_addr_a, row_addr_c;
    logic [$clog2(K)-1:0] col_addr_a, row_addr_b;
    logic [$clog2(N)-1:0] col_addr_b, col_addr_c; 
    logic matrix_a_we, matrix_b_we, matrix_c_we;
    logic matrix_a_re, matrix_b_re, matrix_c_re; 

    logic [$clog2(M)-1:0] row_addr_a_temp, row_addr_c_temp;
    logic [$clog2(K)-1:0] col_addr_a_temp, row_addr_b_temp;
    logic [$clog2(N)-1:0] col_addr_b_temp, col_addr_c_temp; 


    typedef enum logic [1:0] {
        IDLE,
        SAVE,
        COMPUTE,
        DONE
    } state_t;


    state_t state, next_state;

    always @(posedge clk, negedge resetn) begin
        if (~resetn) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always_comb begin
        case(state)
            IDLE: begin
                next_state = host2block_val ? SAVE : IDLE;
            end
            SAVE: begin
                next_state = done_sending_data ? COMPUTE : SAVE;
            end
            COMPUTE: begin
                next_state = mac_done ? DONE : COMPUTE;
            end
            DONE: begin
                next_state = done_reading_result_matrix ? IDLE : DONE;
            end
            default: next_state = IDLE;
        endcase
    end


    always_comb begin
        case(state)
            IDLE: begin
                host2block_rdy = 1'b1;
                block2host_val = 1'b0;
                do_mac = 1'b0;
                start_reading_result_matrix = 1'b0;
            end
            SAVE: begin
                // write data to SRAM A & B
                host2block_rdy = 1'b1;
                block2host_val = 1'b0;
                do_mac = 1'b0;
                row_addr_a_temp = ext_row_addr_a;
                row_addr_b_temp = ext_row_addr_b;
                col_addr_a_temp = ext_col_addr_a;
                col_addr_b_temp = ext_col_addr_b;                

            end
            COMPUTE: begin
                host2block_rdy = 1'b0;
                block2host_val = 1'b0;
                do_mac = 1'b1;
                row_addr_a_temp = row_addr_a;
                row_addr_b_temp = row_addr_b;
                row_addr_c_temp = row_addr_c;
                col_addr_a_temp = col_addr_a;
                col_addr_b_temp = col_addr_b;
                col_addr_c_temp = col_addr_c;
            end
            DONE: begin
                host2block_rdy = 1'b0;
                block2host_val = 1'b1;
                do_mac = 1'b0;
                row_addr_c_temp = ext_row_addr_c;
                col_addr_c_temp = ext_col_addr_c;
                if (block2host_rdy) begin
                    start_reading_result_matrix = 1'b1;
                end else begin
                    start_reading_result_matrix = 1'b0;
                end

            end
            default: begin
                host2block_rdy = 1'b0;
                block2host_val = 1'b1;
                do_mac = 1'b0;
            end
        endcase

    end




    mac_stop_mem #(
        .M(M),
        .K(K),
        .N(N),
        .DATA_WIDTH_INIT_MATRIX(DATA_WIDTH_INIT_MATRIX),
        .DATA_WIDTH_RESULT_MATRIX(DATA_WIDTH_RESULT_MATRIX)
    ) mac_stop_mem_inst (
        .clk(clk),
        .resetn(resetn),
        .data_in_a(ext_data_in_a),
        .data_in_b(ext_data_in_b),
        .data_out_a(data_out_a),
        .data_out_b(data_out_b),
        .data_in_c(data_out_c),
        .data_out_c(ext_data_out_c),
        .row_addr_a(row_addr_a_temp),
        .row_addr_c(row_addr_c_temp),
        .col_addr_a(col_addr_a_temp),
        .row_addr_b(row_addr_b_temp),
        .col_addr_b(col_addr_b_temp),
        .col_addr_c(col_addr_c_temp),
        .matrix_a_we(ext_matrix_a_we),
        .matrix_b_we(ext_matrix_b_we),
        .matrix_c_we(matrix_c_we),
        .matrix_a_re(matrix_a_re),
        .matrix_b_re(matrix_b_re),
        .matrix_c_re(ext_matrix_c_re)
    );

    mac_stop #(
        .M(M),
        .K(K),
        .N(N),
        .DATA_WIDTH_INIT_MATRIX(DATA_WIDTH_INIT_MATRIX),
        .DATA_WIDTH_RESULT_MATRIX(DATA_WIDTH_RESULT_MATRIX)
    ) mac_stop_inst (
        .clk(clk),
        .resetn(resetn),
        .data_in_a(data_out_a),
        .data_in_b(data_out_b),
        .data_out_c(data_out_c),
        .row_addr_a(row_addr_a),
        .row_addr_c(row_addr_c),
        .col_addr_a(col_addr_a),
        .row_addr_b(row_addr_b),
        .col_addr_b(col_addr_b),
        .col_addr_c(col_addr_c),
        .matrix_c_we(matrix_c_we),
        .matrix_a_re(matrix_a_re),
        .matrix_b_re(matrix_b_re),
        .do_mac(do_mac),
        .mac_done(mac_done)
    );







endmodule   