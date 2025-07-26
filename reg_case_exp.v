module reg_fsm_case(
input clk, 
input rstn,
input [31:0]IN_FP32,
input start_compute,
output reg [31:0]composition,
output reg[31:0]ex_temp,
output reg seq_done
);

reg [31:0] exp_val1  =  32'h4b07975f; // 16
reg [31:0] exp_val2  =  32'h453a4f54; // 8
reg [31:0] exp_val3  =  32'h425a6481; // 4
reg [31:0] exp_val4  =  32'b01000000111011000111001100100110; // 2
reg [31:0] exp_val5  =  32'b01000000001011011111100001010100; // 1
reg [31:0] exp_val6  =  32'b00111111110100110000100101001100; // 0.5
reg [31:0] exp_val7  =  32'h3fa45af2; //0.25
reg [31:0] exp_val8  =  32'h3f910b02; //0.125
reg [31:0] exp_val9  =  32'h3f88415b; // 0.0625
reg [31:0] exp_val10 =  32'h3f84102b; // 0.03125
reg [31:0] exp_val11 =  32'h3f820405; // 0.015625
reg [31:0] exp_val12 =  32'h3f810101; // 0.0078125
reg [31:0] exp_val13 =  32'h3f808040; // 0.00390625
reg [31:0] exp_val14 =  32'h3f804010; // 0.001953125
reg [31:0] exp_val15 =  32'h3f802004; // 0.0009765625
reg [31:0] exp_val16 =  32'h3f801001; // 0.00048828125
reg [31:0] exp_val17 =  32'h3f800800; // 0.00024414063
reg [31:0] exp_val18 =  32'h3f800400; // 0.00012207031 
reg [31:0] exp_val19 =  32'h3f800200; // 0.000061035156
reg [31:0] exp_val20_neg =  32'h3f475f7d; //-0.25
reg [31:0] exp_val21_neg =  32'h3f61eb51; //-0.125
reg [31:0] exp_val22_neg =  32'h3f707d60; //-0.0625
reg [31:0] exp_val23_neg =  32'h3f781fab; //-0.03125
reg [31:0] exp_val24_neg =  32'h3f7c07f5; //-0.015625
reg [31:0] exp_val25_neg =  32'h3f7e01ff; //-0.0078125
reg [31:0] exp_val26_neg =  32'h3f7f0080; //-0.00390625
reg [31:0] exp_val27_neg =  32'h3f7f8020; //-0.001953125
reg [31:0] exp_val28_neg =  32'h3f7fc008; //-2^-10
reg [31:0] exp_val29_neg =  32'h3f7fe002; //-0.00048828125 
reg [31:0] exp_val30_neg =  32'h3f7ff000; //-0.00024414063
reg [31:0] exp_val31_neg =  32'h3f7ff800; //-0.00012207031
reg [31:0] exp_val32_neg =  32'h3f7ffc00; //-0.000061035156


parameter 
ST_RESET      = 6'd0,  
ST_READY      = 6'd1,  
ST_CMP_1      = 6'd2,  
ST_CMP_2      = 6'd3,  
ST_CMP_3      = 6'd4,  
ST_CMP_4      = 6'd5,  
ST_CMP_5      = 6'd6,  
ST_CMP_6      = 6'd7,  
ST_CMP_7      = 6'd8,  
ST_CMP_8      = 6'd9,  
ST_CMP_9      = 6'd10,  
ST_CMP_10     = 6'd11,  
ST_CMP_11     = 6'd12,  
ST_CMP_12     = 6'd13,  
ST_CMP_13     = 6'd14,  
ST_CMP_14     = 6'd15,  
ST_CMP_15     = 6'd16,  
ST_CMP_16     = 6'd17,  
ST_CMP_17     = 6'd18,  
ST_CMP_18     = 6'd19,  
ST_CMP_19     = 6'd20,  
ST_CMP_20_NEG = 6'd21,  
ST_CMP_21_NEG = 6'd22,  
ST_CMP_22_NEG = 6'd23,  
ST_CMP_23_NEG = 6'd24,  
ST_CMP_24_NEG = 6'd25,  
ST_CMP_25_NEG = 6'd26,  
ST_CMP_26_NEG = 6'd27,  
ST_CMP_27_NEG = 6'd28,  
ST_CMP_28_NEG = 6'd29,  
ST_CMP_29_NEG = 6'd30,  
ST_CMP_30_NEG = 6'd31,  
ST_CMP_31_NEG = 6'd32,  
ST_CMP_32_NEG = 6'd33,
ST_CMP_END    = 6'd34;

  


reg [5:0] ps,ns;
reg [31:0]A,B,FP32_temp,C,D;
wire [31:0]OUT,PRD;
reg update_FP32_temp;
//reg start;


always@(posedge clk, negedge rstn)begin
	if(!rstn)	ps <= ST_RESET;
	else			ps <= ns;		
end

always @(*) begin
	 case (ps)
        ST_RESET: begin
            if (seq_done) begin
                ns = ST_RESET; // Hold in reset until start_compute is asserted
					 //seq_done = 1'b0;
            end 
	    else if (start_compute) begin 	
                case (FP32_temp[30:23])
                    8'd131: ns = ST_CMP_1;
                    8'd130: ns = ST_CMP_2;
                    8'd129: ns = ST_CMP_3;
                    8'd128: ns = ST_CMP_4;
                    8'd127: ns = ST_CMP_5;
                    8'd126: ns = ST_CMP_6;
                    8'd125: ns = (FP32_temp[31]) ? ST_CMP_20_NEG : ST_CMP_7;
                    8'd124: ns = (FP32_temp[31]) ? ST_CMP_21_NEG : ST_CMP_8;
                    8'd123: ns = (FP32_temp[31]) ? ST_CMP_22_NEG : ST_CMP_9;
                    8'd122: ns = (FP32_temp[31]) ? ST_CMP_23_NEG : ST_CMP_10;
                    8'd121: ns = (FP32_temp[31]) ? ST_CMP_24_NEG : ST_CMP_11;
                    8'd120: ns = (FP32_temp[31]) ? ST_CMP_25_NEG : ST_CMP_12;
                    8'd119: ns = (FP32_temp[31]) ? ST_CMP_26_NEG : ST_CMP_13;
                    8'd118: ns = (FP32_temp[31]) ? ST_CMP_27_NEG : ST_CMP_14;
                    8'd117: ns = (FP32_temp[31]) ? ST_CMP_28_NEG : ST_CMP_15;
                    8'd116: ns = (FP32_temp[31]) ? ST_CMP_29_NEG : ST_CMP_16;
                    8'd115: ns = (FP32_temp[31]) ? ST_CMP_30_NEG : ST_CMP_17;
                    8'd114: ns = (FP32_temp[31]) ? ST_CMP_31_NEG : ST_CMP_18;
                    8'd113: ns = (FP32_temp[31]) ? ST_CMP_32_NEG : ST_CMP_19;
                    8'd112, 8'd111, 8'd110,
8'd109, 8'd108, 8'd107, 8'd106, 8'd105, 8'd104, 8'd103,
8'd102, 8'd101, 8'd100, 8'd99,  8'd98,  8'd97,  8'd96,
8'd95,  8'd94,  8'd93,  8'd92,  8'd91,  8'd90,  8'd89,
8'd88,  8'd87,  8'd86,  8'd85,  8'd84,  8'd83,  8'd82,
8'd81,  8'd80,  8'd79,  8'd78,  8'd77,  8'd76,  8'd75,
8'd74,  8'd73,  8'd72,  8'd71,  8'd70,  8'd69,  8'd68,
8'd67,  8'd66,  8'd65,  8'd64,  8'd63,  8'd62,  8'd61,
8'd60,  8'd59,  8'd58,  8'd57,  8'd56,  8'd55,  8'd54,
8'd53,  8'd52,  8'd51,  8'd50: begin
                        ns = ST_CMP_END;
                       // seq_done = 1'b1;
                    end
        default: begin
			     ns = ps; 
			   //  seq_done = 1'b0; 
				  end
        endcase
            end else begin
                ns = ST_RESET;
		//seq_done = 1'b0;
            end
        end
		ST_CMP_END: ns = ST_RESET;
        default: begin
            if (seq_done) begin
                ns = ST_RESET; // Ensure it resets after computation
					 //seq_done = 1'b0; 
end
         else begin
                case (OUT[30:23])
                    8'd131: ns = ST_CMP_1;
                    8'd130: ns = ST_CMP_2;
                    8'd129: ns = ST_CMP_3;
                    8'd128: ns = ST_CMP_4;
                    8'd127: ns = ST_CMP_5;
                    8'd126: ns = ST_CMP_6;
                    8'd125: ns = (FP32_temp[31]) ? ST_CMP_20_NEG : ST_CMP_7;
                    8'd124: ns = (FP32_temp[31]) ? ST_CMP_21_NEG : ST_CMP_8;
                    8'd123: ns = (FP32_temp[31]) ? ST_CMP_22_NEG : ST_CMP_9;
                    8'd122: ns = (FP32_temp[31]) ? ST_CMP_23_NEG : ST_CMP_10;
                    8'd121: ns = (FP32_temp[31]) ? ST_CMP_24_NEG : ST_CMP_11;
                    8'd120: ns = (FP32_temp[31]) ? ST_CMP_25_NEG : ST_CMP_12;
                    8'd119: ns = (FP32_temp[31]) ? ST_CMP_26_NEG : ST_CMP_13;
                    8'd118: ns = (FP32_temp[31]) ? ST_CMP_27_NEG : ST_CMP_14;
                    8'd117: ns = (FP32_temp[31]) ? ST_CMP_28_NEG : ST_CMP_15;
                    8'd116: ns = (FP32_temp[31]) ? ST_CMP_29_NEG : ST_CMP_16;
                    8'd115: ns = (FP32_temp[31]) ? ST_CMP_30_NEG : ST_CMP_17;
                    8'd114: ns = (FP32_temp[31]) ? ST_CMP_31_NEG : ST_CMP_18;
                    8'd113: ns = (FP32_temp[31]) ? ST_CMP_32_NEG : ST_CMP_19;
                    8'd112, 8'd111, 8'd110,
8'd109, 8'd108, 8'd107, 8'd106, 8'd105, 8'd104, 8'd103,
8'd102, 8'd101, 8'd100, 8'd99,  8'd98,  8'd97,  8'd96,
8'd95,  8'd94,  8'd93,  8'd92,  8'd91,  8'd90,  8'd89,
8'd88,  8'd87,  8'd86,  8'd85,  8'd84,  8'd83,  8'd82,
8'd81,  8'd80,  8'd79,  8'd78,  8'd77,  8'd76,  8'd75,
8'd74,  8'd73,  8'd72,  8'd71,  8'd70,  8'd69,  8'd68,
8'd67,  8'd66,  8'd65,  8'd64,  8'd63,  8'd62,  8'd61,
8'd60,  8'd59,  8'd58,  8'd57,  8'd56,  8'd55,  8'd54,
8'd53,  8'd52,  8'd51,  8'd50: begin
                        ns = ST_CMP_END;
                        
                    end
                    default: begin 
									ns = ps;
									//seq_done = 1'b0;
									end
                endcase
            end
        end
    endcase

    end


always@(*)begin
	case(ps)
		ST_RESET:	
				begin	
				A				   = 32'd0;
				B 				   = 32'd0;
				C 				   = 32'd1;
				D 				   = 32'd1;
				composition 	= 32'd0;	
				update_FP32_temp                   = 1'b0;
				seq_done                           = 1'd0;
				end
				
	ST_CMP_1:
            begin
                A                  = FP32_temp;
                B                  = 32'h41800000; 
                C                  = ex_temp;
                D                  = exp_val1;
                composition        = 32'h41800000;
                update_FP32_temp   = 1'b1;
		seq_done        			     = 1'd0;
            end
        ST_CMP_2:
            begin
                A                  = FP32_temp;
                B                  = 32'h41000000;
                C                  = ex_temp;
                D                  = exp_val2;
                composition        = 32'h41000000;
                update_FP32_temp   = 1'b1;
		seq_done           = 1'd0;
            end
        ST_CMP_3:
            begin
                A                  = FP32_temp;
                B                  = 32'h40800000; 
                C                  = ex_temp;
                D                  = exp_val3;
                composition        = 32'h40800000;
                update_FP32_temp   = 1'b1;
		seq_done           = 1'd0;
            end
        ST_CMP_4:
            begin
                A                  = FP32_temp;
                B                  = 32'h40000000;
                C                  = ex_temp;
                D                  = exp_val4;
                composition        = 32'h40000000;
                update_FP32_temp   = 1'b1;
		seq_done           = 1'd0;
            end
        
        ST_CMP_5:
            begin
                A                  = FP32_temp;
                B                  = 32'h3f800000;
                C                  = ex_temp;
                D                  = exp_val5;
                composition        = 32'h3f800000;
                update_FP32_temp   = 1'b1;
		seq_done           = 1'd0;
            end
        
        ST_CMP_6:
            begin
                A                  = FP32_temp;
                B                  = 32'h3f000000;
                C                  = ex_temp;
                D                  = exp_val6;
                composition        = 32'h3f000000;
                update_FP32_temp   = 1'b1;
		seq_done           = 1'd0;
            end
        
        ST_CMP_7:
            begin
                A                  = FP32_temp;
                B                  = 32'h3e800000;
                C                  = ex_temp;
                D                  = exp_val7;
                composition        = 32'h3e800000;
                update_FP32_temp   = 1'b1;
		seq_done           = 1'd0;
            end
        
        ST_CMP_8:
            begin
                A                  = FP32_temp;
                B                  = 32'h3e000000;
                C                  = ex_temp;
                D                  = exp_val8;
                composition        = 32'h3e000000;
                update_FP32_temp   = 1'b1;
		seq_done           = 1'd0;
            end
        
        ST_CMP_9:
            begin
                A                  = FP32_temp;
                B                  = 32'h3d800000;
                C                  = ex_temp;
                D                  = exp_val9;
                composition        = 32'h3d800000;
                update_FP32_temp   = 1'b1;
		seq_done           = 1'd0;
            end
        
        ST_CMP_10:
            begin
                A                  = FP32_temp;
                B                  = 32'h3d000000;
                C                  = ex_temp;
                D                  = exp_val10;
                composition        = 32'h3d000000;
                update_FP32_temp   = 1'b1;
		seq_done           = 1'd0;
            end
        
        ST_CMP_11:
            begin
                A                  = FP32_temp;
                B                  = 32'h3c800000;
                C                  = ex_temp;
                D                  = exp_val11;
                composition        = 32'h3c800000;
                update_FP32_temp   = 1'b1;
		seq_done           = 1'd0;
            end
	ST_CMP_12:
            begin
                A                  = FP32_temp;
                B                  = 32'h3c000000;
                C                  = ex_temp;
                D                  = exp_val12;
                composition        = 32'h3c000000;
                update_FP32_temp   = 1'b1;
		seq_done           = 1'd0;             
            end
	ST_CMP_13:
            begin
                A                  = FP32_temp;
                B                  = 32'h3b800000;
                C                  = ex_temp;
                D                  = exp_val13;
                composition        = 32'h3b800000;
                update_FP32_temp   = 1'b1;
                seq_done           = 1'd0;
            end
	ST_CMP_14:
            begin
                A                  = FP32_temp;
                B                  = 32'h3b000000;
                C                  = ex_temp;
                D                  = exp_val14;
                composition        = 32'h3b000000;
                update_FP32_temp   = 1'b1;
                seq_done           = 1'd0;
            end
	ST_CMP_15:
            begin
                A                  = FP32_temp;
                B                  = 32'h3a800000;
                C                  = ex_temp;
                D                  = exp_val15;
                composition        = 32'h3a800000;
                update_FP32_temp   = 1'b1;
                seq_done           = 1'd0;
            end
	ST_CMP_16:
            begin
                A                  = FP32_temp;
                B                  = 32'h3a000000;
                C                  = ex_temp;
                D                  = exp_val16;
                composition        = 32'h3a000000;
                update_FP32_temp   = 1'b1;
                seq_done           = 1'd0;
            end
	ST_CMP_17:
            begin
                A                  = FP32_temp;
                B                  = 32'h39800000;
                C                  = ex_temp;
                D                  = exp_val17;
                composition        = 32'h39800000;
                update_FP32_temp   = 1'b1;
                seq_done           = 1'd0;
            end
	ST_CMP_18:
            begin
                A                  = FP32_temp;
                B                  = 32'h39000000;
                C                  = ex_temp;
                D                  = exp_val18;
                composition        = 32'h39000000;
                update_FP32_temp   = 1'b1;
                seq_done           = 1'd0;
            end
        ST_CMP_19:
            begin
                A                  = FP32_temp;
                B                  = 32'h38800000;
                C                  = ex_temp;
                D                  = exp_val19;
                composition        = 32'h38800000;
                update_FP32_temp   = 1'b1;
		seq_done           = 1'b0;
	end
       ST_CMP_20_NEG:
            begin
                A                  = FP32_temp;
                B                  = 32'hbe800000;
                C                  = ex_temp;
                D                  = exp_val20_neg;
                composition        = 32'hbe800000;
                update_FP32_temp   = 1'b1; 
		seq_done           = 1'd0;
            end
	ST_CMP_21_NEG:
            begin
                A                  = FP32_temp;
                B                  = 32'hbe000000;
                C                  = ex_temp;
                D                  = exp_val21_neg;
                composition        = 32'hbe000000;
                update_FP32_temp   = 1'b1; 
		seq_done           = 1'd0;
            end
	ST_CMP_22_NEG:
            begin
                A                  = FP32_temp;
                B                  = 32'hbd800000;
                C                  = ex_temp;
                D                  = exp_val22_neg;
                composition        = 32'hbd800000;
                update_FP32_temp   = 1'b1; 
		seq_done           = 1'd0;
            end
	ST_CMP_23_NEG:
            begin
                A                  = FP32_temp;
                B                  = 32'hbd000000;
                C                  = ex_temp;
                D                  = exp_val23_neg;
                composition        = 32'hbd000000;
                update_FP32_temp   = 1'b1; 
		seq_done           = 1'd0;
            end
	ST_CMP_24_NEG:
            begin
                A                  = FP32_temp;
                B                  = 32'hbc800000;
                C                  = ex_temp;
                D                  = exp_val24_neg;
                composition        = 32'hbc800000;
                update_FP32_temp   = 1'b1; 
		seq_done           = 1'd0;
            end
	ST_CMP_25_NEG:
            begin
                A                  = FP32_temp;
                B                  = 32'hbc000000;
                C                  = ex_temp;
                D                  = exp_val25_neg;
                composition        = 32'hbc000000;
                update_FP32_temp   = 1'b1; 
		seq_done           = 1'd0;
            end
	ST_CMP_26_NEG:
            begin
                A                  = FP32_temp;
                B                  = 32'hbb800000;
                C                  = ex_temp;
                D                  = exp_val26_neg;
                composition        = 32'hbb800000;
                update_FP32_temp   = 1'b1; 
		seq_done           = 1'd0;
            end
	ST_CMP_27_NEG:
            begin
                A                  = FP32_temp;
                B                  = 32'hbb000000;
                C                  = ex_temp;
                D                  = exp_val27_neg;
                composition        = 32'hbb000000;
                update_FP32_temp   = 1'b1; 
		seq_done           = 1'd0;
            end
	ST_CMP_28_NEG:
            begin
                A                  = FP32_temp;
                B                  = 32'hba800000;
                C                  = ex_temp;
                D                  = exp_val28_neg;
                composition        = 32'hba800000;
                update_FP32_temp   = 1'b1; 
		seq_done           = 1'd0;
		
            end
	ST_CMP_29_NEG:
            begin
                A                  = FP32_temp;
                B                  = 32'hba000000;
                C                  = ex_temp;
                D                  = exp_val29_neg;
                composition        = 32'hba000000;
                update_FP32_temp   = 1'b1; 
		seq_done           = 1'd0;
            end
	ST_CMP_30_NEG:
            begin
                A                  = FP32_temp;
                B                  = 32'hb9800000;
                C                 = ex_temp;
                D                  = exp_val30_neg;
                composition        = 32'hb9800000;
                update_FP32_temp   = 1'b1; 
		seq_done           = 1'd0;
            end
	ST_CMP_31_NEG:
            begin
                A                  = FP32_temp;
                B                  = 32'hb9000000;
                C                  = ex_temp;
                D                  = exp_val31_neg;
                composition        = 32'hb9000000;
                update_FP32_temp   = 1'b1; 
		seq_done           = 1'd0;
            end
	ST_CMP_32_NEG:
            begin
                A                  = FP32_temp;
                B                  = 32'hb8800000;
                C                  = ex_temp;
                D                  = exp_val32_neg;
                composition        = 32'hb8800000;
                update_FP32_temp   = 1'b1; 
                seq_done       	  = 1'b0;
            end
	ST_CMP_END:
				begin
					A                  = 32'd0;
                B                  = 32'd0;
                C                  = 32'd0;
                D                  = 32'd0;
                composition        = 32'd0;
                update_FP32_temp   = 1'b0;
                seq_done       	  = 1'b1;
					 end
				    
		default: begin
					 A                  = 32'd0;
                B                  = 32'd0;
                C                  = 32'd0;
                D                  = 32'd0;
                composition        = 32'd0;
                update_FP32_temp   = 1'b0;
                seq_done       	  = 1'b1;
					end
	endcase
	end



//Inputs
always@(posedge clk, negedge rstn)begin
	if(!rstn)	begin
		FP32_temp <= 32'd0;
		end
	else if(update_FP32_temp) begin
		FP32_temp <= OUT; 
		end
	else if (start_compute)	begin
		FP32_temp <= IN_FP32;//TODO
		end
	else if(seq_done) begin
		FP32_temp <= 32'd0;
		end
end

//Outputs
always@(posedge clk, negedge rstn)begin
	if(!rstn)	begin
		ex_temp<=32'd0; 
		end
	else if(update_FP32_temp) begin
		ex_temp<=PRD;	
		end
	else if (start_compute)	begin
		ex_temp<=32'h3f800000;
		end
end

//always@(posedge clk or negedge rstn) begin
//if(!rstn) begin
//     	update_FP32_temp <= 1'd0;
	//	seq_done <= 1'd0; end
//else if(start_compute)
	//start <= 1'b1;
//else if(update_FP32_temp)
	//update_FP32_temp <= 1'd0;
//else if(seq_done) begin
//	seq_done <=1'b0;
	//start  <= 1'b0;
	//end
//end

//FP32_CMP xFP32_CMP0(.A(A),.B(B),.cmp_res(value_found));

add_sub xadd_sub_gpt0( .A(A), .B({!B[31],B[30:0]}), .s(OUT));

multi xexponent(.a(C),.b(D),.result(PRD));

endmodule


