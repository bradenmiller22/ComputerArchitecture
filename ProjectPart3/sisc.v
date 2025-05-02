// ECE:3350 SISC processor project
// main SISC module, part 2
//Braden Miller & Scott Pearson

`timescale 1ns/100ps  

module sisc (clk, rst_f);
  
  //Input signal declaration, signals provided by testbench
  input clk, rst_f;
  

  // Internal wires
  wire [3:0] alu_op; // ALU op control signal	
  wire rf_we; // Register file control signal
  wire wb_sel; // Mux control signal
  wire [3:0] stat_en; // Status register control signal
  wire [31:0] rsa, rsb; // Register file outputs
  wire [31:0] alu_result; // ALU output
  wire [31:0] write_data; // Writeback data between mux and rf
  wire [3:0] stat_in, stat_out; //Statreg input/output connection

 //pt2 wires:
 wire [15:0] pc_out; //Output of pc, input to br
 wire [15:0] br_addr; //output of br, input to pcv
 wire [31:0] read_data;
 wire [31:0] instr; //ir is now a wire and not an input from tb. read data is between IM and IR. 'instr' is actual instruction set
 wire pc_sel, pc_write, pc_rst; //pc control signals
 wire br_sel; //br control signal
 wire ir_load; //ir control signal

 //pt3 wires
 wire mm_sel, dm_we, rb_sel;
 wire [31:0] dmem_out;
 wire [15:0] mem_addr;
 wire [3:0] write_reg;


  // Instantiate modules
rf my_rf (
  .clk(clk),
  .read_rega(instr[19:16]),
  .read_regb(instr[15:12]),
  .write_reg(write_reg),    // <- UPDATED
  .write_data(write_data),
  .rf_we(rf_we),
  .rsa(rsa),
  .rsb(rsb)
);


  alu my_alu ( //uses CISC instruction set format 2
  .clk(clk),
  .rsa(rsa),	//RSA input
  .rsb(rsb),	//RSB input
  .imm(instr[15:0]),	//Immediate value from instruction
  .c_in(stat_out[3]), // connection between statreg and ctrl
  .alu_op(alu_op),    //ALU operation control signal
  .funct(instr[27:24]),  //MFF function
  .alu_result(alu_result), //ALU calculation output
  .stat(stat_in),  	//Connection between alu and statreg
  .stat_en(stat_en)	//Statreg control signal
);

statreg my_statreg (
  .clk(clk),
  .in(stat_in), //Connectrion between alu and statreg
  .enable(stat_en), //Control signal from alu
  .out(stat_out) // Output stored status to stat_out
);

//part 3
mux4 my_mux4 (
  .in_a(instr[23:20]),  // Default Rd
  .in_b(instr[15:12]),  // Rt
  .sel(rb_sel),      // Only use LSB of rb_sel
  .out(write_reg)
);


//part3
mux16 my_mux16 (
  .in_a(pc_out),          // instruction memory
  .in_b(alu_result[15:0]), // data memory
  .sel(mm_sel),
  .out(mem_addr)
);


mux32 my_mux32 (
  .in_a(alu_result),
  .in_b(dmem_out),
  .sel(wb_sel),
  .out(write_data)
);

//part3
dm my_dm (
  .read_addr(mem_addr),
  .write_addr(mem_addr),
  .write_data(rsb),
  .dm_we(dm_we),
  .read_data(dmem_out)
);



  ctrl my_ctrl (
  .clk(clk),
  .rst_f(rst_f), //external reset signal
  .opcode(instr[31:28]), //opcode from instruction
  .mm(instr[27:24]),  //memory function from instruction
  .stat(stat_out), //connection between statreg and ctrl
  .rf_we(rf_we), //Control signal for rf
  .alu_op(alu_op), //control signal for alu operation
  .wb_sel(wb_sel), //control signal for mux/rf data writeback
  .pc_sel(pc_sel),
  .pc_write(pc_write),
  .pc_rst(pc_rst),
  .br_sel(br_sel), 
  .ir_load(ir_load),
  .mm_sel(mm_sel),     //part3 wires
  .dm_we(dm_we),            
  .rb_sel(rb_sel)
);

  pc my_pc(
  .clk(clk),
  .br_addr(br_addr),
  .pc_sel(pc_sel),
  .pc_write(pc_write),
  .pc_rst(pc_rst),
  .pc_out(pc_out)
  );


  br my_br(
    .pc_out(pc_out),
    .imm(instr[15:0]),
    .br_sel(br_sel),
    .br_addr(br_addr)
  );

  im my_im(
    .read_addr(pc_out), 
    .read_data(read_data)
  );

 ir my_ir(
    .clk(clk), 
    .ir_load(ir_load),
    .read_data(read_data),
    .instr(instr)
  );


  // Monitor signals
  initial
  begin
	$monitor("IR=%h PC=%h R1=%h R2=%h R3=%h R4=%h R5=%h ALU_OP=%b BR_SEL=%b PC_WRITE=%b PC_SEL=%b M8=%h M9=%h", 
          instr, pc_out, my_rf.ram_array[1], my_rf.ram_array[2], my_rf.ram_array[3],
          my_rf.ram_array[4], my_rf.ram_array[5], alu_op, br_sel, pc_write, pc_sel,
          my_dm.ram_array[8], my_dm.ram_array[9]);

  end
always @(posedge clk)
begin
  $display("DEBUG: dm_we=%b mem_addr=%h write_data=%h alu_result=%h rsa=%h rsb=%h", 
           dm_we, mem_addr, rsb, alu_result, rsa, rsb);
end

endmodule


