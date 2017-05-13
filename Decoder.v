module Decoder( instr_op_i, RegWrite_o,	ALUOp_o, ALUSrc_o, RegDst_o, Branch_o, BranchType_o, Jump_o, MemRead_o, MemWrite_o, MemtoReg_o );
     
//I/O ports
input	[6-1:0] instr_op_i;

output			RegWrite_o;
output	[3-1:0] ALUOp_o;
output			ALUSrc_o;
output			RegDst_o;

output 			Branch_o;
output  [2:0]   BranchType_o;
output			Jump_o;

output			MemRead_o;
output			MemWrite_o;
output			MemtoReg_o;


//Internal Signals
wire	[3-1:0] ALUOp_o;
wire			ALUSrc_o;
wire			RegWrite_o;
wire			RegDst_o;

//Main function
/*your code here*/

wire j_type; 	//j_type trigger

assign ALUOp_o      = (instr_op_i==6'd0 ) ? 3'b010 : 		//R-type = 010
					  (instr_op_i==6'd8 ) ? 3'b100 : 		//8(addi) = 100
					  (instr_op_i==6'd15) ? 3'b101 :		//15(lui) = 101
					  (instr_op_i==6'd35) ? 3'b000 : 		//35(lw)  = 000
					  (instr_op_i==6'd43) ? 3'b000 : 		//43(sw)  = 000
					  (instr_op_i==6'd4 ) ? 3'b001 :			//4(beq)  = 001
					  (instr_op_i==6'd5 ) ? 3'b110 : 		//5(bne)  = 110
					  (instr_op_i==6'd6 ) ? 3'b011 : 		//6(blt)  = 011
					  (instr_op_i==6'd1 ) ? 3'b011 : 		//1(bge)  = 011
					  3'b010;
					
assign ALUSrc_o     = (instr_op_i==6'd0 | instr_op_i==6'd4 | instr_op_i==6'd5) ? 
															6'd0 : 6'd1;	//R-type = 0, I-type = 1

assign RegWrite_o   = (instr_op_i!=6'd2) &									//not jump 
					  ((instr_op_i[5]^instr_op_i[3])					//lw or addi/lui or jal
					    | (~(instr_op_i[2] | instr_op_i[3])));			//R-type or 

						
assign RegDst_o     = (instr_op_i==6'd0) ? 1 : 0;							//R-type to rd(=1), I-type to rt(=0)
																		//ALUOp_o[2]==1 means I-type
												

assign Branch_o     = (instr_op_i!=6'd0) & ~(instr_op_i[5] | instr_op_i[3]);
assign BranchType_o = instr_op_i[2:0];									//0 if beq, 1 if bne
			
assign Jump_o       = (instr_op_i==6'd2) | (instr_op_i==6'd3);				//j or jal

assign MemRead_o    = instr_op_i[5] & (~instr_op_i[3]);
assign MemWrite_o   = (instr_op_i!=6'd2) & instr_op_i[5] & instr_op_i[3];	//only sw
assign MemtoReg_o   = instr_op_i[5] & (~instr_op_i[3]); 						
														
														
endmodule
   