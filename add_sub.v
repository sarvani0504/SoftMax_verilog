module add_sub(
    input [31:0] A, B,
    output reg [31:0] s
);
    parameter e = 8'b01111111;
    reg [23:0] x, y, z;
    reg [7:0] expa, expb, expc;
    reg [7:0] shift;
    reg [4:0] count;
    wire [1:0] signs;
    integer shift_amount;
    assign signs = {A[31], B[31]};

    always @(*) begin
        x[23] = 1'b1;
        x[22:0] = A[22:0];
        y[23] = 2'b01;
        y[22:0] = B[22:0];

        expa = A[30:23];
        expb = B[30:23];
        count = 5'd0;
        shift_amount = 5'd0;

        if (expa > expb) begin
            shift = expa - expb;
            y = y >> shift;
            expc = expa;
        end 
        else begin
            shift = expb - expa;
            x = x >> shift;
            expc = expb;
        end

        if (signs == 2'b00 || signs == 2'b11) begin
            z = x + y;
            s[31] = A[31];
        end 
        else begin
            if (expa > expb) begin
                z = x - y;
                s[31] = A[31];
            end
            else if (expa < expb) begin
                z = y - x;
                s[31] = B[31];
            end
            else begin
                if (x >= y) begin
                    z = x - y;
                    s[31] = A[31];
                end 
                else begin
                    z = y - x;
                    s[31] = B[31];
                end
            end
        end
        
        if (z[23]) shift_amount = 0;
        else if (z[22]) shift_amount = 1;
        else if (z[21]) shift_amount = 2;
        else if (z[20]) shift_amount = 3;
        else if (z[19]) shift_amount = 4;
        else if (z[18]) shift_amount = 5;
        else if (z[17]) shift_amount = 6;
        else if (z[16]) shift_amount = 7;
        else if (z[15]) shift_amount = 8;
        else if (z[14]) shift_amount = 9;
        else if (z[13]) shift_amount = 10;
        else if (z[12]) shift_amount = 11;
        else if (z[11]) shift_amount = 12;
        else if (z[10]) shift_amount = 13;
        else if (z[9]) shift_amount = 14;
        else if (z[8]) shift_amount = 15;
        else if (z[7]) shift_amount = 16;
        else if (z[6]) shift_amount = 17;
        else if (z[5]) shift_amount = 18;
        else if (z[4]) shift_amount = 19;
        else if (z[3]) shift_amount = 20;
        else if (z[2]) shift_amount = 21;
        else if (z[1]) shift_amount = 22;
        else if (z[0]) shift_amount = 23;
        else shift_amount = 24;

        z = z << shift_amount;
        expc = expc - shift_amount;

        s[22:0] = z[22:0];
        s[30:23] = expc;
    end
endmodule
