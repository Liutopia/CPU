module ALU_Ctrl( funct_i, ALUOp_i, ALU_operation_o, FURslt_o );

//I/O ports 
input      [6-1:0] funct_i;
input      [3-1:0] ALUOp_i;

output     [4-1:0] ALU_operation_o;  
output     [2-1:0] FURslt_o;
     
//Internal Signals
wire		[4-1:0] ALU_operation_o;
wire		[2-1:0] FURslt_o;

//Main function
/*your code here*/

wire [3:0] ALU_operation_Rtype;
wire FURslt_Rtype;

assign ALU_operation_o = (ALUOp_i[1:0]==2'b00) ? 4'b0010 : 		//lw,sw,addi
						 (ALUOp_i==3'b001) ? 4'b0110 :			//beq
						 (ALUOp_i==3'b110) ? 4'b0110 :			//bne,bnez
						 (ALUOp_i==3'b011) ? 4'b0111 :			//blt,bgez
						 (ALUOp_i==3'b010) ? ALU_operation_Rtype : 4'b0000; 
	


assign ALU_operation_Rtype[3] = funct_i[2] & funct_i[1];
assign ALU_operation_Rtype[2] = funct_i[1];
assign ALU_operation_Rtype[1] = ~(funct_i[2] | funct_i[0]);
assign ALU_operation_Rtype[0] = (funct_i[3] ^ funct_i[2]) & (funct_i[1] ^ funct_i[0]);


assign FURslt_o = (ALUOp_i==3'b101) ? 2 :
                  (ALUOp_i==3'b010 & funct_i[5]==0) ? 1 : 0;


/*
assign FURslt_o[1] = ALUOp_i[0];			//LUI's ALUOp=101
assign FURslt_o[0] = (ALUOp_i[1]==0) ? 0 : funct_i[5] ? 0 : 1;	//funct_i[5] determines the operation is shift op. or other op.
				*/							//other op's funct_i[5]==1, shift op's funct_i[5]==0

/*

assign FURslt_o = (ALUOp_i==3'b100) ? 1 : */

//assign FURslt_Rtype = funct_i[5] ? 0 : 1;	//funct_i[5] determines the operation is shift op. or other op.
											//other op's funct_i[5]==1, shift op's funct_i[5]==0*/
//(FURslt == 2'b00) ALU
//(FURslt == 2'b01) SLL,SRL
//(FURslt == 2'b10) LUI

endmodule     
