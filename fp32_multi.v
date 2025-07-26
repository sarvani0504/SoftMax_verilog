module multi(
    input wire [31:0] a,
    input wire [31:0] b,
    output reg [31:0] result
);

    wire sign_a = a[31];
    wire sign_b = b[31];
    wire [7:0] exp_a = a[30:23];
    wire [7:0] exp_b = b[30:23];
    wire [23:0] mantissa_a = {1'b1, a[22:0]};
    wire [23:0] mantissa_b = {1'b1, b[22:0]};

    wire sign_result = sign_a ^ sign_b;
    wire [47:0] mantissa_product = mantissa_a * mantissa_b;
    reg [7:0] exp_result;
    reg [22:0] mantissa_result;

    always @(*) begin
        if (mantissa_product[47] == 1) begin
            mantissa_result = mantissa_product[46:24];
            exp_result = exp_a + exp_b - 127 + 1;
        end 
        else begin
            mantissa_result = mantissa_product[45:23];
            exp_result = exp_a + exp_b - 127;
        end

        if (exp_a == 8'b0 || exp_b == 8'b0) begin
            result = 32'b0;
        end 
        else if (exp_result >= 255) begin
            result = {sign_result, 8'hFF, 23'b0};
        end 
        else begin
            result = {sign_result, exp_result, mantissa_result};
        end
    end
endmodule
