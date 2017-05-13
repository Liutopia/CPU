module ALU( aluSrc1, aluSrc2, ALU_operation_i, result, zero, overflow );

//I/O ports 
input	[32-1:0] aluSrc1;
input	[32-1:0] aluSrc2;
input	 [4-1:0] ALU_operation_i;

output	[32-1:0] result;
output			 zero;
output			 overflow;

//Internal Signals
wire			 zero;
wire			 overflow;
wire	[32-1:0] result;

//Main function
/*your code here*/
ALU_LAB2 A0( result, zero, overflow, aluSrc1, aluSrc2, ALU_operation_i[3], ALU_operation_i[2], ALU_operation_i[1:0] );

endmodule
