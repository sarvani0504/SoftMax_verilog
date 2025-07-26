module tb_softmax_top;

    reg clk, rst, start_exp, start_div;
    reg [31:0] x_values [0:12];         // 13 input x values
    reg [31:0] exp_results [0:12];      // Store 13 e^x values
    reg [31:0] numerator, denominator;
    reg [31:0] op1,op2;
    reg [31:0] sum_exp;
    integer i, j;

    wire done_exp, done_div;
    wire [31:0] y_exp, y_div, sum;

    // Clock generation
    always #5 clk = ~clk;

    // Instantiate exp_module
    reg2_fsm_case u_exp (
    .clk(clk),
    .rstn(~rst),                  // assuming active-low reset
    .IN_FP32(x_values[i]),        // input x value
    .start_compute(start_exp),    // start signal
    .composition(),               // not used in your TB yet
    .ex_temp(y_exp),              // e^x output
    .seq_done(done_exp)           // done signal
);

    // Instantiate division_module
    fp_div_restoring_fsm_32bit u_div (
    .clk(clk),
    .rst(rst),
    .start(start_div),
    .a(numerator),
    .b(denominator),
    .result(y_div),
    .done(done_div)
);
    add_sub sum_exponents(
    .A(op1), 
    .B(op2),
    .s(sum)
);

    initial begin
        // Initialize signals
        clk = 1;
        rst = 1;
        start_exp = 0;
        start_div = 0;
        sum_exp = 0;

        // Sample 13 x-values (can be float32 IEEE hex)
        x_values[0] = 32'hbe559b3d; // -0.2086
        x_values[1] = 32'hbe773190; // -0.2414
        x_values[2] = 32'hbe77b4a2; // -0.2419
        x_values[3] = 32'hbe843fe6; // -0.2583
        x_values[4] = 32'hbe866666; // -0.2625
        x_values[5] = 32'h3fdbf141; //  1.7183
        x_values[6] = 32'h3fe1b717; //  1.7634
        x_values[7] = 32'h408df3b6; //  4.436
        x_values[8] = 32'h40ef652c; //  7.4811
        x_values[9] = 32'h4125793e; //  10.3421
        x_values[10] = 32'h415d5a86; // 13.8346
        x_values[11] = 32'h41a04bfb; // 20.0371
        x_values[12] = 32'h417fff97; // 15.9999

        #20 rst = 0;

        // Step 1: Send values to exp_module
        for (i = 0; i < 13; i = i + 1) begin
            @(negedge clk);
            start_exp = 1;
            #20;
            start_exp = 0;

            wait(done_exp);
            exp_results[i] = y_exp;
	    op1 = y_exp;
            op2 = sum_exp;
	    #10;
	    sum_exp = sum;
            $display("x[%0d] = %h, e^x = %h", i, x_values[i], y_exp);
	    #10;
        end
	    $display("Sum of e^x : %h \n", sum_exp);
	    
        // Step 2: Normalize using division
        $display("\n--- Normalized Softmax Outputs ---");
        for (j = 0; j < 13; j = j + 1) begin
            numerator = exp_results[j];
            denominator = sum_exp;

            @(negedge clk);
            start_div = 1;
            @(negedge clk);
            start_div = 0;

            wait(done_div);
            $display("softmax(x[%0d]) = %h", j, y_div);
	    #10;
        end

        $stop;
    end

endmodule
