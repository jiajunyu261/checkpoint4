/**
 * READ THIS DESCRIPTION!
 *
 * The processor takes in several inputs from a skeleton file.
 *
 * Inputs
 * clock: this is the clock for your processor at 50 MHz
 * reset: we should be able to assert a reset to start your pc from 0 (sync or
 * async is fine)
 *
 * Imem: input data from imem
 * Dmem: input data from dmem
 * Regfile: input data from regfile
 *
 * Outputs
 * Imem: output control signals to interface with imem
 * Dmem: output control signals and data to interface with dmem
 * Regfile: output control signals and data to interface with regfile
 *
 * Notes
 *
 * Ultimately, your processor will be tested by subsituting a master skeleton, imem, dmem, so the
 * testbench can see which controls signal you active when. Therefore, there needs to be a way to
 * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
 * file acts as a small wrapper around your processor for this purpose.
 *
 * You will need to figure out how to instantiate two memory elements, called
 * "syncram," in Quartus: one for imem and one for dmem. Each should take in a
 * 12-bit address and allow for storing a 32-bit value at each address. Each
 * should have a single clock.
 *
 * Each memory element should have a corresponding .mif file that initializes
 * the memory element to certain value on start up. These should be named
 * imem.mif and dmem.mif respectively.
 *
 * Importantly, these .mif files should be placed at the top level, i.e. there
 * should be an imem.mif and a dmem.mif at the same level as process.v. You
 * should figure out how to point your generated imem.v and dmem.v files at
 * these MIF files.
 *
 * imem
 * Inputs:  12-bit address, 1-bit clock enable, and a clock
 * Outputs: 32-bit instruction
 *
 * dmem
 * Inputs:  12-bit address, 1-bit clock, 32-bit data, 1-bit write enable
 * Outputs: 32-bit data at the given address
 *
 */
module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem
    q_imem,                         // I: The data from imem

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem 
    wren,                           // O: Write enable for dmem
    q_dmem,                         // I: The data from dmem 

    // Regfile
    ctrl_writeEnable,               // O: Write enable for regfile
    ctrl_writeReg,                  // O: Register to write to in regfile
    ctrl_readRegA,                  // O: Register to read from port A of regfile
    ctrl_readRegB,                  // O: Register to read from port B of regfile
    data_writeReg,                  // O: Data to write to for regfile
    data_readRegA,                  // I: Data from port A of regfile
    data_readRegB                   // I: Data from port B of regfile
);
    // Control signals
    input clock, reset;

    // Imem
    output [11:0] address_imem;
    input [31:0] q_imem;

    // Dmem
    output [31:0] address_dmem;//^
    output [31:0] data;
    output wren;
    input [31:0] q_dmem;

    // Regfile
    output ctrl_writeEnable;
    output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
    output [31:0] data_writeReg;
    input [31:0] data_readRegA, data_readRegB;

    /* YOUR CODE STARTS HERE */
	 
	 
	 reg [0:9]Q[0:31];//column:row
	 
	 initial 
	 begin
		
		Q[5'b00000]=10'b1000000000;//alu 0
		Q[5'b00101]=10'b1010000000;
		Q[5'b00111]=10'b0110000010;//last 0
		Q[5'b01000]=10'b1010000001;
	 
	 end
	 
	 wire [0:9]control;
	 
	 wire [31:0]w0;//se output
	 wire [31:0]w1;//alu input2
	 wire w2, w3, w4;//alu output ==/</overflow
	 wire w13,w14; //actually overflow
	 
	 
	 wire [31:0]w5;//pc+1
	 wire w6, w7, w8;
	 
	 wire [4:0]w12;
	 assign w12 = 5'b11110;
	 
	 wire [31:0]w9;//data_writereg
	 wire [31:0]w10,w11;//mux 123
	 
	 of overflow(q_imem[31:27], q_imem[6:2], w13);
	 and (w14, w13, w4);
	 
	 assign control = Q[q_imem[31:27]];
	 
	 assign ctrl_readRegA = q_imem[21:17];//rs
	 
	 assign data = data_readRegB;
	 
	 assign wren = control[8];
	 
	 assign ctrl_writeEnable = control[0];
	 
	 
	 //assign ctrl_writeReg = q_imem[26:22];
	 
	 //reg
	 MUX mux5_1(ctrl_readRegB, q_imem[16:12], q_imem[26:22], control[1]);//rt
	 defparam mux5_1.width = 5;

	  MUX mux5_2(ctrl_writeReg, q_imem[26:22], w12, w14);//ctrl_writeReg
	 defparam mux5_2.width = 5;
	 
	 //alu
	 sign_extend se32(w0, q_imem[16:0]);
	 
	 MUX mux32_1(w1, data_readRegB, w0, control[2]);
	 defparam mux32_1.width = 32;
	 
	 alu alu123(data_readRegA, w1, q_imem[6:2], q_imem[11:7], address_dmem, w2, w3, w4);
	 
	
	 
	 //dmem
	 MUX mux32_2(w9, address_dmem, q_dmem, control[9]);
	 defparam mux32_2.width = 32;
	 
	 MUX mux32_3(w10, 32'd1, 32'd3, q_imem[2]);
	 defparam mux32_3.width = 32;
	 
	 MUX mux32_4(w11, w10, 32'd2, q_imem[27]);
	 defparam mux32_4.width = 32;
	 
	 MUX mux32_5(data_writeReg, w9, w11, w14);
	 defparam mux32_5.width = 32;
	 
	 
	 //pc
	 alu alu456({20'b0,address_imem}, 32'b1, 5'b00000, 5'b00000, w5, w6, w7, w8);
	 
	 genvar i;
	 generate for (i = 0; i < 12; i = i + 1) begin: loop0
		dffe_reg d1(address_imem[i], w5[i],clock, 1'b1, reset);
	 end
	 endgenerate

endmodule