module reg1_fsm_case(
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
reg [31:0] exp_val9_neg =  32'h3f475f7d; //-0.25
reg [31:0] exp_val10_neg =  32'h3f61eb51; //-0.125


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
ST_CMP_9_NEG = 6'd10,  
ST_CMP_10_NEG = 6'd11, 
ST_CMP_END    = 6'd12;

  
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
                    8'd125: ns = (FP32_temp[31]) ? ST_CMP_9_NEG : ST_CMP_7;
                    8'd124: ns = (FP32_temp[31]) ? ST_CMP_10_NEG : ST_CMP_8;
                    8'd123, 8'd122, 8'd121, 8'd120, 8'd119, 8'd118, 8'd117,
8'd116, 8'd115, 8'd114, 8'd113, 8'd112, 8'd111, 8'd110,
8'd109, 8'd108, 8'd107, 8'd106, 8'd105, 8'd104, 8'd103,
8'd102, 8'd101, 8'd100, 8'd99,  8'd98,  8'd97,  8'd96,
8'd95,  8'd94,  8'd93,  8'd92,  8'd91,  8'd90,  8'd89,
8'd88,  8'd87,  8'd86,  8'd85,  8'd84,  8'd83,  8'd82,
8'd81,  8'd80,  8'd79,  8'd78,  8'd77,  8'd76,  8'd75,
8'd74,  8'd73,  8'd72,  8'd71,  8'd70,  8'd69,  8'd68,
8'd67,  8'd66,  8'd65,  8'd64,  8'd63,  8'd62,  8'd61,
8'd60,  8'd59,  8'd58,  8'd57,  8'd56,  8'd55,  8'd54,
8'd53,  8'd52,  8'd51,  8'd50:
begin
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
                    8'd125: ns = (FP32_temp[31]) ? ST_CMP_9_NEG : ST_CMP_7;
                    8'd124: ns = (FP32_temp[31]) ? ST_CMP_10_NEG : ST_CMP_8;
                    8'd123, 8'd122, 8'd121, 8'd120, 8'd119, 8'd118, 8'd117,
8'd116, 8'd115, 8'd114, 8'd113, 8'd112, 8'd111, 8'd110,
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
				composition 	                   = 32'd0;	
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
		seq_done           = 1'd0;
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
        

       ST_CMP_9_NEG:
            begin
                A                  = FP32_temp;
                B                  = 32'hbe800000;
                C                  = ex_temp;
                D                  = exp_val9_neg;
                composition        = 32'hbe800000;
                update_FP32_temp   = 1'b1; 
		seq_done           = 1'd0;
            end
	ST_CMP_10_NEG:
            begin
                A                  = FP32_temp;
                B                  = 32'hbe000000;
                C                  = ex_temp;
                D                  = exp_val10_neg;
                composition        = 32'hbe000000;
                update_FP32_temp   = 1'b1; 
		seq_done           = 1'd0;
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


