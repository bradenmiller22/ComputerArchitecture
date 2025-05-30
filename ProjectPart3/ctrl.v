// ECE:3350 SISC computer project
// Braden Miller & Scott Pearson

`timescale 1ns/100ps

module ctrl (clk, rst_f, opcode, mm, stat, 
             rf_we, alu_op, wb_sel, pc_sel, pc_write, pc_rst, 
             br_sel, ir_load, mm_sel, dm_we, rb_sel);

  // I/O
  input clk, rst_f;
  input [3:0] opcode, mm, stat;
  
  output reg rf_we, wb_sel;
  output reg [3:0] alu_op;
  output reg pc_sel, pc_write, pc_rst;
  output reg br_sel;
  output reg ir_load;
  output reg mm_sel, dm_we;
  output reg rb_sel; // 1-bit (NOT 2-bit)

  // States
  parameter start0 = 0, start1 = 1, fetch = 2, decode = 3, execute = 4, mem = 5, writeback = 6;

  // Opcodes
  parameter NOOP = 0, REG_OP = 1, REG_IM = 2, SWAP = 3, BRA = 4, BRR = 5, BNE = 6, BNR = 7;
  parameter JPA = 8, JPR = 9, LOD = 10, STA = 11, STX = 12, LDA = 13, LDX = 14, HLT = 15;


  reg [2:0] present_state, next_state;

  // Initialize
  initial present_state = start0;

  // State register
  always @(posedge clk, negedge rst_f)
  begin
    if (rst_f == 1'b0)
      present_state <= start1;
    else
      present_state <= next_state;
  end

  // Next state logic
  always @(present_state, rst_f)
  begin
    case (present_state)
      start0: next_state = start1;
      start1: next_state = (rst_f == 1'b0) ? start1 : fetch;
      fetch: next_state = decode;
      decode: next_state = execute;
      execute: next_state = mem;
      mem: next_state = writeback;
      writeback: next_state = fetch;
      default: next_state = start1;
    endcase
  end

  // Main control logic
  always @(present_state, opcode, mm)
  begin
    // Default values
    rf_we = 1'b0;
    alu_op = 4'b0000;
    wb_sel = 1'b0;
    pc_sel = 1'b0;
    pc_write = 1'b0;
    pc_rst = 1'b0;
    br_sel = 1'b0;
    ir_load = 1'b0;
    mm_sel = 1'b0;
    dm_we = 1'b0;
    rb_sel = 1'b0;

    case (present_state)

      start1:
      begin
        pc_rst = 1'b1;
      end

      fetch:
      begin
        ir_load = 1'b1;
        pc_write = 1'b1;
      end

      decode:
      begin
        case (opcode)
          BRA, JPA:
          begin
            pc_sel = 1'b1;
            br_sel = 1'b1;
            if (opcode == BRA)
              pc_write = ((mm & stat) != 4'b0000);
            else
              pc_write = 1'b1;
          end

          BRR, JPR:
          begin
            pc_sel = 1'b1;
            br_sel = 1'b0;
            if (opcode == BRR)
              pc_write = ((mm & stat) != 4'b0000);
            else
              pc_write = 1'b1;
          end

          BNE:
          begin
            pc_sel = 1'b1;
            br_sel = 1'b1;
            pc_write = ((mm & stat) == 4'b0000);
          end

          BNR:
          begin
            pc_sel = 1'b1;
            br_sel = 1'b0;
            pc_write = ((mm & stat) == 4'b0000);
          end
        endcase
      end

      execute:
      begin
        if (opcode == REG_OP)
          alu_op = 4'b0001;
        else if (opcode == REG_IM)
          alu_op = 4'b0011;
        else if (opcode == STA || opcode == STX || opcode == LDA || opcode == LDX)
          alu_op = 4'b0010; // address calculation
      end

      mem:
      begin
        if (opcode == REG_OP)
          alu_op = 4'b0000;
        else if (opcode == REG_IM)
          alu_op = 4'b0010;
        else if (opcode == STA || opcode == STX)
        begin
          mm_sel = 1'b1;
          dm_we = 1'b1; // Write memory during mem state only
	  if (opcode == STX)
	     rb_sel = 1'b1;
        end
        else if (opcode == LDA || opcode == LDX)
        begin
          mm_sel = 1'b1;
          wb_sel = 1'b1; // select DMEM out
	  if (opcode == LDX)
	     rb_sel = 1'b1;
        end
      end

      writeback:
      begin
        if (opcode == REG_OP || opcode == REG_IM)
        begin
          rf_we = 1'b1;
          wb_sel = 1'b0; // write ALU result
        end
        else if (opcode == LDA || opcode == LDX)
        begin
          rf_we = 1'b1;
          wb_sel = 1'b1; // write DMEM result
	  if(opcode == LDX)
	    rb_sel = 1'b1;
        end

        dm_we = 1'b0; // Important! Disable dm_we during writeback to create falling edge
      end

      default:
        ; // do nothing
    endcase
  end

  // HLT instruction
  always @(opcode)
  begin
    if (opcode == HLT)
    begin
      #5 $display("Halt.");
      $stop;
    end
  end

endmodule