module Mux3to1( data0_i, data1_i, data2_i, select_i, data_o );

parameter size = 0;			   
			
//I/O ports               
input wire	[size-1:0] data0_i;          
input wire	[size-1:0] data1_i;
input wire	[size-1:0] data2_i;
input wire	[2-1:0] select_i;
output wire	[size-1:0] data_o; 

//Main function
/*your code here*/

assign data_o = select_i[1] ? data2_i : select_i[0] ? data1_i : data0_i;
/*
wire A0,A1,A2;
assign A1 = (select_i==2) & data2_i;
assign A1 = (select_i==1) & data1_i;
assign A0 = (~select_i) & data0_i;
assign data_o = A0 | A1 | A2 ;*/


endmodule      
