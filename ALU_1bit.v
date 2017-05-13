module ALU_1bit( result, carryOut, a, b, invertA, invertB, operation, carryIn, less ); 
  
  output wire result;
  output wire carryOut;
  
  input wire a;
  input wire b;
  input wire invertA;
  input wire invertB;
  input wire[1:0] operation;
  input wire carryIn;
  input wire less;
  
  /*your code here*/ 
  
  wire rsand,rsor;	//result of and/or gate
  wire sum;			//result of adder(add)
  wire dif;				//result of adder(sub)
  wire _a,_b;			//~a/~b
  wire A,B;
  

 
  not (_a,a);
  not (_b,b);
  
  assign A = invertA ? _a : a;		// mux to select a or ~a
  assign B = invertB ? _b : b;		// mux to select b or ~b
  
  and		a1(rsand, A, B);	//op=00
  or		o1(rsor, A, B);	//op=01
  Full_adder FA1 (sum, carryOut, carryIn, A, B);	//op=10
  //less = 0;//op=11
  
  assign result = (operation==2'b00) ? rsand : (operation==2'b01) ? rsor : (operation==2'b10) ? sum : less;
 
 
  
  
endmodule
