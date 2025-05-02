// ECE:3350 SISC processor project
// main SISC module, part 1
// Project Part 1
// Braden Miller & Scott Pearson

`timescale 1ns/100ps  

module sisc (clk, rst_f, ir);

  input clk, rst_f;
  input [31:0] ir;

  // Internal wires
  wire [31:0] rsa, rsb, alu_result, write_data;
  wire [3:0] stat, stat_en, alu_op;
  wire rf_we, wb_sel;

  // Instantiate the ALU
  alu alu_instance (
    .clk(clk),
    .rsa(rsa),
    .rsb(rsb),
    .imm(ir[15:0]),
    .c_in(stat[3]),
    .alu_op(alu_op),
    .funct(ir[27:24]),
    .alu_result(alu_result),
    .stat(stat),
    .stat_en(stat_en)
  );

  // Instantiate the Register File
  rf rf_instance (
    .clk(clk),
    .read_rega(ir[19:16]),
    .read_regb(ir[15:12]),
    .write_reg(ir[23:20]), // Write to the same register as read_rega
    .write_data(write_data),
    .rf_we(rf_we),
    .rsa(rsa),
    .rsb(rsb)
  );

  // Instantiate the Status Register
  statreg statreg_instance (
    .clk(clk),
    .in(stat),
    .enable(stat_en),
    .out(stat)
  );

  // Instantiate the 32-bit Mux
  mux32 mux32_instance (
    .in_a(alu_result),
    .in_b(32'b0), // Assuming no memory access in Part 1
    .sel(wb_sel),
    .out(write_data)
  );

  // Instantiate the Control Unit
  ctrl ctrl_instance (
    .clk(clk),
    .rst_f(rst_f),
    .opcode(ir[31:28]),
    .mm(ir[27:24]),
    .stat(stat),
    .rf_we(rf_we),
    .alu_op(alu_op),
    .wb_sel(wb_sel)
  );

  // Monitor the signals
  initial begin
    $monitor("IR=%h | R1=%h | R2=%h | R3=%h | R4=%h | R5=%h | ALU_OP=%b | WB_SEL=%b | RF_WE=%b | Write_Data=%h",
             ir, rf_instance.ram_array[1], rf_instance.ram_array[2], 
             rf_instance.ram_array[3], rf_instance.ram_array[4], 
             rf_instance.ram_array[5], alu_op, wb_sel, rf_we, write_data);
  end

endmodule
