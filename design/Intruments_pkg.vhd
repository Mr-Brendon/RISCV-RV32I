
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package Instruments_pkg is
--Constants:
constant Nbit: integer := 32;
constant pip_f_d: integer:= 64;
constant binary4in32: std_logic_vector(31 downto 0) := "00000000000000000000000000000100"; --0x04
constant op_BRANCH: std_logic_vector(6 downto 0) := "1100011"; --OPCODE for conditional jump instructions
constant op_JALR: std_logic_vector(6 downto 0) := "1100111"; --OPCODE for JALR instruction
constant op_JAL: std_logic_vector(6 downto 0) := "1101111"; --OPCODE for JAL instruction
constant fu_JALR: std_logic_vector(2 downto 0):= "000"; --instruction for JALR in funct3
end Instruments_pkg;
