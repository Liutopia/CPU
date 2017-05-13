module Simple_Single_CPU( clk_i, rst_n );

//I/O port
input         clk_i;
input         rst_n;

//Internal Signles

//wire for PC
wire [31:0] pc_in_i, pc_out_o;
//wire for PC+4 Adder
wire [31:0] pc_plus4;
//wire for branch address Adder
wire [31:0] branch_address;
//wire for IM
wire [31:0] instr_o;
//wire for Mux2to1_1, selecting rt or rd to be written
wire [4:0] RDaddr_i;
//wire for RegFile
wire [31:0] RSdata_o, RTdata_o;
//wire for Decoder
wire RegWrite_ctrl, ALUSrc_ctrl, RegDst_ctrl, Branch_ctrl, Jump_ctrl, MemRead_ctrl, MemWrite_ctrl, MemtoReg_ctrl;
wire [2:0] ALUOp_ctrl, BranchType_ctrl;
//wire for ALU_Ctrl
wire [3:0] ALU_operation_4bits;
wire [1:0] FURslt_ctrl;
//wire for sign/zero-extension
wire [31:0] Sign_Extend_o, Zero_Filled_o;
wire [31:0] Sign_Extend_Shiftleft_2bits;
//wire for Mux2to1_2, selecting rt or sign_extension_o to be ALU_src2
wire [31:0] aluSrc2_i;
wire [31:0] WTF;
//wire for ALU
wire [31:0] alu_rst;
wire alu_zero,alu_overflow;
//wire for shifter
wire [31:0] shft_rst;
wire [4:0] shift_amount;
//wire for Mux3to1
wire [31:0] Mux3to1_o;
//wire for Data_Memory
wire [31:0] Data_From_Memory;
//wire for Mux2to1, selecting the data written to reg
wire [31:0] Data_to_Write;
//wire for Mux2to1, check zero for branch
wire Whether_to_Branch;
//wire for and gate
wire PCSrc;
//wire for Mux2to1, selecting pc = pc_plus4 or pc_branch 
wire [31:0] pc_branch;
//wire for Mux2to1, selecting pc = pc_branch or pc_jump
wire [31:0] pc_jump;

//modules

wire jr_signal;
wire [31:0] pc_in_with_jr;		
assign pc_in_with_jr = jr_signal ? RSdata_o : pc_in_i;

Program_Counter PC(
        .clk_i(clk_i),      
	    .rst_n(rst_n),     
	    .pc_in_i(pc_in_with_jr) ,   
	    .pc_out_o(pc_out_o) 
	    );
		
//Adder only used in pc_out+4
Adder Adder1(
        .src1_i(pc_out_o),     
	    .src2_i(32'd4),
	    .sum_o(pc_plus4)    
	    );
		
//Adder used to calculate address to branch 		
Adder Adder2(
        .src1_i(pc_plus4),     
	    .src2_i(Sign_Extend_Shiftleft_2bits),
	    .sum_o(branch_address)    
	    );
	
Instr_Memory IM(
        .pc_addr_i(pc_out_o),  
	    .instr_o(instr_o)    
	    );

Mux2to1 #(.size(5)) Mux_Write_Reg(
        .data0_i(instr_o[20:16]),
        .data1_i(instr_o[15:11]),
        .select_i(RegDst_ctrl),
        .data_o(RDaddr_i)
        );	


assign jr_signal = (instr_o[31:26]==6'b000000 & instr_o[5:0]==6'b001000);

wire [4:0] RDaddr_with_jal;
assign 	RDaddr_with_jal = (instr_o[31:26]==3) ? 5'b11111 : RDaddr_i;
		
//wire RegWrite_ctrl_with_jr;
//assign RegWrite_ctrl_with_jr = jr_signal ? 0 : RegWrite_ctrl;
		
wire [31:0] Data_to_Write_wih_jal;
assign Data_to_Write_wih_jal = (instr_o[31:26]==3) ? pc_plus4 : Data_to_Write;	
		
Reg_File RF(
        .clk_i(clk_i),      
	    .rst_n(rst_n) ,     
        .RSaddr_i(instr_o[25:21]) ,  
        .RTaddr_i(instr_o[20:16]) ,  
        .RDaddr_i(RDaddr_with_jal) ,  
        .RDdata_i(Data_to_Write_wih_jal)  , 
        .RegWrite_i(RegWrite_ctrl),
        .RSdata_o(RSdata_o) ,  
        .RTdata_o(RTdata_o)   
        );
	
Decoder Decoder(
        .instr_op_i(instr_o[31:26]), 
	    .RegWrite_o(RegWrite_ctrl), 
	    .ALUOp_o(ALUOp_ctrl),   
	    .ALUSrc_o(ALUSrc_ctrl),   
	    .RegDst_o(RegDst_ctrl),
		.Branch_o(Branch_ctrl), 
		.BranchType_o(BranchType_ctrl),
		.Jump_o(Jump_ctrl),
		.MemRead_o(MemRead_ctrl), 
		.MemWrite_o(MemWrite_ctrl), 
		.MemtoReg_o(MemtoReg_ctrl)
		);

ALU_Ctrl AC(
        .funct_i(instr_o[5:0]),   
        .ALUOp_i(ALUOp_ctrl),   
        .ALU_operation_o(ALU_operation_4bits),
		.FURslt_o(FURslt_ctrl)
        );

Sign_Extend SE(
        .data_i(instr_o[15:0]),
        .data_o(Sign_Extend_o)
        );
		
assign Sign_Extend_Shiftleft_2bits = Sign_Extend_o << 2;
		
//for LUI
Zero_Filled ZF(
        .data_i(instr_o[15:0]),
        .data_o(Zero_Filled_o)
        );
		
Mux2to1 #(.size(32)) ALU_src2Src(
        .data0_i(RTdata_o),
        .data1_i(Sign_Extend_o),
        .select_i(ALUSrc_ctrl),
        .data_o(aluSrc2_i)
        );	
		
wire [31:0] aluSrc2_i_with_bgez;
assign aluSrc2_i_with_bgez = (instr_o[31:26]==6'b1) ? 32'b0 : aluSrc2_i;


ALU ALU(
		.aluSrc1(RSdata_o),
	    .aluSrc2(aluSrc2_i_with_bgez),
	    .ALU_operation_i(ALU_operation_4bits),
		.result(alu_rst),
		.zero(alu_zero),
		.overflow(alu_overflow)
	    );
		
//leftRight = instr_o[1] (including sllv,srlv)	
//ALU_operation_4bits[2] = instr_o[1] 
//0 = shift left, 1=shift right
Shifter shifter( 
		.result(shft_rst), 
		.leftRight(ALU_operation_4bits[2]),
		.shamt(shift_amount),
		.sftSrc(aluSrc2_i) 
		);

//for sll/srl and sllv/srlv		
Mux2to1 #(.size(5)) Mux_Shift_Amount(
        .data0_i(instr_o[10:6]),
        .data1_i(RSdata_o[4:0]),
        .select_i(instr_o[2]),
        .data_o(shift_amount)
        );					
		
Mux3to1 #(.size(32)) RDdata_Source(
        .data0_i(alu_rst),
        .data1_i(shft_rst),
		.data2_i(Zero_Filled_o),
        .select_i(FURslt_ctrl),
        .data_o(Mux3to1_o)
        );
		
//Data Memory
Data_Memory DM(
		.clk_i(clk_i),
		.addr_i(Mux3to1_o),
		.data_i(RTdata_o), 
		.MemRead_i(MemRead_ctrl), 
		.MemWrite_i(MemWrite_ctrl), 
		.data_o(Data_From_Memory)
		);		
		
//for select data written to reg	
Mux2to1 #(.size(32)) Mux_Data_to_Reg(
        .data0_i(Mux3to1_o),
        .data1_i(Data_From_Memory),
        .select_i(MemtoReg_ctrl),
        .data_o(Data_to_Write)
        );		

wire Whether_to_Branch_with_slt;

	
//considering blt, bge
Mux2to1 #(.size(1)) Mux_Signal_for_Branch(
        .data0_i(Whether_to_Branch),
        .data1_i(~Whether_to_Branch),
        .select_i(ALU_operation_4bits[0]),			//ALU_operation_4bits[0] determine 0110(sub) or 0111(slt)
        .data_o(Whether_to_Branch_with_slt)
        );	
		
//check zero for branch
Mux2to1 #(.size(1)) Mux_Zero_for_Branch(
        .data0_i(alu_zero),
        .data1_i(~alu_zero),
        .select_i(BranchType_ctrl[0]),
        .data_o(Whether_to_Branch)
        );		
	
assign PCSrc = Branch_ctrl & Whether_to_Branch_with_slt;
			
		
//check PC branch or not
Mux2to1 #(.size(32)) Mux_PC_Branch(
        .data0_i(pc_plus4),
        .data1_i(branch_address),
        .select_i(PCSrc),
        .data_o(pc_branch)
        );		

assign pc_jump = {pc_plus4[31:28], instr_o[25:0], 2'b00};		
		
//check PC jump or not
Mux2to1 #(.size(32)) Mux_Zero_PC_Jump(
        .data0_i(pc_branch),
        .data1_i(pc_jump),
        .select_i(Jump_ctrl),
        .data_o(pc_in_i)
        );				

		
endmodule



