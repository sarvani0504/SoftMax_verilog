module fp_div_restoring_fsm_32bit (
    input  wire        clk,
    input  wire        rst,
    input  wire        start,
    input  wire [31:0] a,
    input  wire [31:0] b,
    output reg  [31:0] result,
    output reg         done
);

    // FSM states
    localparam IDLE      = 3'b000,
               UNPACK    = 3'b001,
               DIVIDE_1  = 3'b010,
               DIVIDE_2  = 3'b011,
               NORMALIZE = 3'b100,
               ROUND     = 3'b101,
               PACK      = 3'b110,
               DONE      = 3'b111;

    reg [2:0] current_state, next_state;

    // IEEE-754 fields
    reg sign_a, sign_b, sign_res;
    reg [7:0] exp_a, exp_b, exp_res;
    reg [24:0] mant_a, mant_b;        // 24 bits mantissa + 1 extra bit for rounding
    reg signed [47:0] remainder, divisor;
    reg [24:0] quotient;              // 25 bits quotient to hold guard bit
    reg [4:0]  count;

    // Normalization signals
    reg [4:0] shift_amount;
    reg [24:0] normalized_mantissa;  // 25 bits including guard bit
    reg [7:0] normalized_exp;

    // Sticky bit for rounding
    reg sticky_bit;

    // Temporary variables for rounding - declared at module scope
    reg [22:0] mantissa_bits;
    reg guard_bit, round_bit;
    reg round_up;
    reg [23:0] mantissa_rounded;
    reg signed [47:0] temp_remainder;

    // Mantissa result register
    reg [22:0] mant_res;

    // Sequential state update
    always @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Datapath sequential logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            result      <= 0;
            done        <= 0;
            quotient    <= 0;
            remainder   <= 0;
            divisor     <= 0;
            count       <= 0;
            sign_a      <= 0;
            sign_b      <= 0;
            sign_res    <= 0;
            exp_a       <= 0;
            exp_b       <= 0;
            exp_res     <= 0;
            mant_a      <= 0;
            mant_b      <= 0;
            normalized_mantissa <= 0;
            normalized_exp      <= 0;
            shift_amount <= 0;
            sticky_bit <= 0;
            mantissa_bits <= 0;
            guard_bit <= 0;
            round_bit <= 0;
            round_up <= 0;
            mantissa_rounded <= 0;
            mant_res <= 0;
        end else begin
            case (current_state)
                UNPACK: begin
                    sign_a   <= a[31];
                    sign_b   <= b[31];
                    exp_a    <= a[30:23];
                    exp_b    <= b[30:23];
                    mant_a   <= {1'b1, a[22:0], 1'b0}; // Append extra zero bit for rounding
                    mant_b   <= {1'b1, b[22:0], 1'b0};
                    quotient <= 0;
                    remainder <= {{1'b1, a[22:0]},24'd0}; // 48 bits
                    divisor  <= {{1'b1, b[22:0]}, 24'd0};  // 48 bits
                    count    <= 0;
                    done     <= 0;
                    sticky_bit <= 0;
                end

                DIVIDE_1: begin	 
                    temp_remainder <= remainder - divisor;
			
			end             

                DIVIDE_2: begin
                    if (temp_remainder[47]) begin
                        // Negative remainder, restore
                        remainder <= temp_remainder + divisor;
                        quotient  <= quotient << 1;
                    end else begin
                        // Positive remainder, set quotient bit to 1
			remainder <= temp_remainder;
                        quotient  <= (quotient << 1) | 1'b1;
                    end

                    divisor <= divisor >> 1;
                    count   <= count + 1;
			// Debug print          	           
		    //$display("TEMP REMAINDER: %b", temp_remainder);
                    //$display("******************************\n");
                end

                NORMALIZE: begin
                    // Priority encoder to find leading 1 position in 25-bit quotient
                    if      (quotient[24]) shift_amount <= 0;
                    else if (quotient[23]) shift_amount <= 1;
                    else if (quotient[22]) shift_amount <= 2;
                    else if (quotient[21]) shift_amount <= 3;
                    else if (quotient[20]) shift_amount <= 4;
                    else if (quotient[19]) shift_amount <= 5;
                    else if (quotient[18]) shift_amount <= 6;
                    else if (quotient[17]) shift_amount <= 7;
                    else if (quotient[16]) shift_amount <= 8;
                    else if (quotient[15]) shift_amount <= 9;
                    else if (quotient[14]) shift_amount <= 10;
                    else if (quotient[13]) shift_amount <= 11;
                    else if (quotient[12]) shift_amount <= 12;
                    else if (quotient[11]) shift_amount <= 13;
                    else if (quotient[10]) shift_amount <= 14;
                    else if (quotient[9])  shift_amount <= 15;
                    else if (quotient[8])  shift_amount <= 16;
                    else if (quotient[7])  shift_amount <= 17;
                    else if (quotient[6])  shift_amount <= 18;
                    else if (quotient[5])  shift_amount <= 19;
                    else if (quotient[4])  shift_amount <= 20;
                    else if (quotient[3])  shift_amount <= 21;
                    else if (quotient[2])  shift_amount <= 22;
                    else if (quotient[1])  shift_amount <= 23;
                    else if (quotient[0])  shift_amount <= 24;
                    else                   shift_amount <= 25;

                    // Calculate sticky bit: OR of all bits shifted out during normalization
                    sticky_bit <= |(quotient << (25 - shift_amount));
                end

                ROUND: begin
                    // Shift quotient left by shift_amount to normalize
                    normalized_mantissa <= quotient << shift_amount;

                    // Exponent adjustment
                    if (shift_amount == 0)
                        normalized_exp <= exp_a - exp_b + 8'd127;
                    else
                        normalized_exp <= exp_a - exp_b + 8'd127 - shift_amount + 1'b1;

                    sign_res <= sign_a ^ sign_b;
                end

                PACK: begin
                    // Extract mantissa bits (23 bits) from normalized mantissa [24:2]
                    mantissa_bits = {normalized_mantissa[23:2],1'b0};
                    guard_bit     = normalized_mantissa[1];
                    round_bit     = normalized_mantissa[0];

                    // Round to nearest even
                    round_up = (guard_bit && (round_bit || sticky_bit || mantissa_bits[0]));

                    mantissa_rounded = {1'b0, mantissa_bits} + round_up;

                    // Handle mantissa overflow from rounding
                    if (mantissa_rounded[23]) begin
                        // Mantissa overflowed, shift right by 1 and increment exponent
                        mant_res <= mantissa_rounded[23:1];
                        exp_res  <= normalized_exp + 1;
                    end else begin
                        mant_res <= mantissa_rounded[22:0];
                        exp_res  <= normalized_exp;
                   
end
end

DONE: begin
    done <= 1;
    result <= {sign_res, exp_res, mant_res};

    // Debug prints
    //$display("DONE STATE DEBUG:");
    //$display("Sign       : %b", sign_res);
    //$display("Exponent   : %08b (decimal %d)", exp_res, exp_res);
    //$display("Mantissa   : %023b", mant_res);
    //$display("Result     : %032b", result);
end

                IDLE: begin
                    done <= 0;
                end
            endcase
        end
    end

    // Next-state logic
    always @(*) begin
        next_state = current_state;
        case (current_state)
            IDLE:      if (start) next_state = UNPACK;
            UNPACK:    next_state = DIVIDE_1;
            DIVIDE_1:  next_state = DIVIDE_2;
            DIVIDE_2:  next_state = ((count == 5'd23 || remainder == 48'd0)) ? NORMALIZE : DIVIDE_1;
            NORMALIZE: next_state = ROUND;
            ROUND:     next_state = PACK;
            PACK:      next_state = DONE;
            DONE:      if (!start) next_state = IDLE;
        endcase
    end

endmodule
