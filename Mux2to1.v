module Mux2to1( data0_i, data1_i, select_i, data_o );

parameter size = 0;			   
			
//I/O ports               
input wire	[size-1:0] data0_i;          
input wire	[size-1:0] data1_i;
input wire	select_i;
output wire	[size-1:0] data_o; 

//Main function
/*your code here*/

assign data_o = select_i ? data1_i : data0_i;
/*
wire A1,A0;
assign A1 = select_i & data1_i;
assign A0 = (~select_i) & data0_i;
assign data_o = A1 | A0;*/

endmodule      
    