// ECE:3350 SISC computer project
// finite state machine 
// Braden Miller & Scott Pearson

`timescale 1ns/100ps
//mm is condition code
module ctrl (clk, rst_f, opcode, mm, stat, rf_we, alu_op, wb_sel,rb_sel, pc_sel, pc_write, pc_rst, ir_load, br_sel, mux_16_sel, dm_we, mux4_swap_sel,swap_ctrl);
  /* TODO: Declare the ports listed above as inputs or outputs */
  input clk,rst_f;
  input[3:0] opcode, mm, stat;
  output reg[1:0] alu_op, wb_sel;
  output reg rf_we, rb_sel, pc_sel, pc_write, pc_rst, ir_load, br_sel, mux_16_sel, dm_we, mux4_swap_sel, swap_ctrl;

  
  reg wb_wire, rf_wire;
  
  // states
  parameter start0 = 0, start1 = 1, fetch = 2, decode = 3, execute = 4, mem = 5, writeback = 6;
   
  // opcodes - Updated for new instruction format
  parameter NOOP = 0, ADD = 1, SUB = 2, NOT = 4, OR = 5, AND = 6, XOR = 7, RTR = 8, RTL = 9, SHR = 10, SHL = 11, 
            ADI = 2, BRA = 4, BRR = 5, BNE = 6, BNR = 7, LOD = 10, STR = 11, SWP = 3, HLT=15;
	
  // addressing modes
  parameter am_imm = 8;

  // state registers
  reg [2:0]  present_state, next_state;

  // New instruction format flags
  wire is_alu_op;
  wire is_branch;
  wire is_load;
  wire is_store;
  
  // Determine instruction type based on opcode
  assign is_alu_op = (opcode >= 1 && opcode <= 11);
  assign is_branch = (opcode >= 4 && opcode <= 7);
  assign is_load = (opcode == 10);
  assign is_store = (opcode == 11);

  initial
    present_state = start0;

	always @(posedge clk) begin
	   pc_rst = 1'b0;
	   present_state = next_state;
	end 

	always @(negedge clk)begin

	    if(rst_f == 0) begin
	        present_state = start1;
		pc_rst = 1'b1;
	    end
  	end
		

	always @(present_state) begin
		case(present_state)
			start0: begin
				next_state <= start1;
			end
			start1: begin
				next_state <= fetch;
			end 
			fetch: begin
				next_state <= decode;
			end
			decode: begin
				next_state <= execute;
			end
			execute: begin
				next_state <= mem;
			end
			mem: begin
				next_state <= writeback;
			end
			writeback: begin
				next_state <= fetch;
			end
		endcase
		
	end
 always @ (posedge clk or opcode) begin
	case(present_state) 
		start0: begin
			swap_ctrl <= 0;
			rf_we <= 1'b0;
			wb_sel <= 0;
			alu_op <= 2'b10;
			rb_sel <= 1'b0;
			pc_write <= 1'b0;	
			ir_load <= 1'b0;
			br_sel <= 1'b0;
			pc_rst <= 1'b1;
			pc_sel <= 1'b0;
			mux4_swap_sel <= 0;
		end

		start1: begin
			//wb_sel <= 0;
			alu_op <= 2'b00;
			ir_load <= 1'b0;
			pc_rst <= 1'b0;
			mux4_swap_sel <= 0;
			dm_we <= 0;
		end

		fetch: begin
			swap_ctrl <= 0;
			rf_we <= 1'b0;
			wb_sel <= 0;
			alu_op <= 2'b00;
			rb_sel <= 1'b0;
			pc_write <= 1'b1;	// Always increment the pc in fetch
			ir_load <= 1'b1;
			br_sel <= 1'b0;
			pc_rst <= 1'b0;
			pc_sel <= 1'b0;	
		end

		decode: begin
			ir_load <= 1'b0;
			pc_write <= 1'b0;
			
			// Branch handling for new instruction format
			if (opcode == BNE || opcode == BRA || opcode == BRR || opcode == BNR) begin
				case(opcode)
					BNE: begin
						br_sel <= 1'b1;
						pc_sel <= 1;
						if((stat & mm) == 4'b0000) begin
							pc_sel <= 1;
							pc_write <= 1;
							br_sel <= 1;
						end
					end
					BRA: begin
						pc_sel <= 1;
						if ((stat & mm) != 4'b0000) begin
							pc_sel <= 1;
							pc_write <= 1;
							br_sel <= 1;
						end
					end
					BRR: begin
						br_sel <= 1'b0;
						pc_sel <= 1;
						if ((stat & mm) != 4'b0000) begin
							pc_sel <= 1;
							pc_write <= 1;
							br_sel <= 0;
						end
					end
					BNR: begin
						pc_sel <= 1;
						if ((stat & mm) == 4'b0000) begin
							pc_sel <= 1;
							pc_write <= 1;
							br_sel <= 0;
						end
					end
				endcase
			end
			// Handle STR and SWP in new format
			else if (opcode == STR) begin
				rb_sel <= 1;
			end
			else if (opcode == SWP) begin
				rb_sel <= 1;
			end
		end

		execute: begin
			pc_write <= 1'b0;
			ir_load <= 1'b0;
			
			// Handle immediate vs register operations
			if(mm == am_imm) begin
				case(opcode)
					ADD, SUB, NOT, OR, AND, XOR, RTR, RTL, SHR, SHL: begin
						alu_op <= 2'b01;
						dm_we <= 0;
					end
					STR: begin
						alu_op <= 2'b11;
						dm_we <= 1;
					end
					LOD: begin
						alu_op <= 2'b11;
						wb_sel = 1;
						dm_we <= 0;
					end
					SWP: begin
						swap_ctrl <= 1;
						wb_sel <= 2;
					end
					default: begin
						alu_op <= 2'b11;
						dm_we <= 0;
					end
				endcase
			end
			else begin
				// Handle regular register operations
				case(opcode)
					ADD, SUB, NOT, OR, AND, XOR, RTR, RTL, SHR, SHL: begin
						alu_op <= 2'b00;
						dm_we <= 0;
					end
					STR: begin
						alu_op <= 2'b10;
						dm_we <= 1;
					end
					SWP: begin
						swap_ctrl <= 1;
						wb_sel <= 2;
					end
					LOD: begin
						alu_op <= 2'b10;
						wb_sel = 1;
						dm_we <= 0;
					end
					default: begin
						alu_op <= 2'b10;
						dm_we <= 0;
					end
				endcase
			end
		end

		mem: begin
			swap_ctrl <= 0;
			case (opcode)
				LOD: begin
					if(mm == am_imm) begin
						mux_16_sel <= 1;
					end
					else begin
						mux_16_sel <= 0;
					end
					rf_we <= 1;
				end
				STR: begin
					if(mm == am_imm) begin
						mux_16_sel <= 1;
					end
					else begin
						mux_16_sel <= 0;
					end
					dm_we <= 1;
				end
				SWP: begin
					rf_we = 1;
				end
			endcase
		end

		writeback: begin 
			rf_we = 0;
			dm_we <= 0;
			case(opcode)
				ADD, SUB, NOT, OR, AND, XOR, RTR, RTL, SHR, SHL: begin
					rf_we = 1;
				end
				LOD: begin
					rf_we = 1;
				end
				SWP: begin
					wb_sel = 3;
					mux4_swap_sel = 1;
					rf_we = 1;
				end
			endcase 
		end
	endcase
 end

// Halt on HLT instruction
  always @ (opcode)
  begin
    if (opcode == HLT)
    begin 
      #5 $display ("Halt."); //Delay 5 ns so $monitor will print the halt instruction
        $stop;
    end
  end
endmodule
