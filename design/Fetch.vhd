----------------------------------------------------------------------------------
--Fetch module includes the whole part of program counter and the interface with
--instruction memory. It finishes with the fetch/decoder pipeline register.
--Reset in all cpu in active low.
----------------------------------------------------------------------------------
--SEMBRA GIUSTO FORSE E' DA RIGUARDARE ATTENTAMENTE MA SEMBRA GIUSTO

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.Instruments_pkg.ALL;
use IEEE.NUMERIC_STD.ALL;
--use UNISIM.VComponents.all;

entity Fetch is
    port(CLK, RESET: in std_logic;
         OPCODE: in std_logic_vector(6 downto 0); --it comes from decode or ex_pipeline and contains OPCODE, index, data ecc...
         funct3: in std_logic_vector(2 downto 0); --it comes from decode or ex_pipeline and contains OPCODE, index, data ecc...
         JALR_values, JAL_values, condjmp_values: in std_logic_vector(Nbit-1 downto 0); --flux of index for PC
         --remember conditional jumps have 12-1 index multiplied by 2, so 13 bits. All in execute pippeline
         index_word_in: in std_logic_vector(Nbit-1 downto 0); --it comes from memory, the instruction 
         
         index_pc_out: out std_logic_vector (Nbit-1 downto 0); --index for the external instruction memory
         pipeline_fetch_decode: out std_logic_vector (pip_f_d-1 downto 0) --for next step: decode
         );
end Fetch;


architecture Fetch_bh of Fetch is
signal pc_in, pc_out, next_pc: std_logic_vector (Nbit-1 downto 0);
signal pipeline_fetch_register_in: std_logic_vector(pip_f_d-1 downto 0);

begin

--index for instruction memory
index_pc_out <= pc_out;


--PC index and current data of instruction memory for first pipeline stage
pipeline_fetch_register_in <= pc_out & index_word_in;



--PC_adder_block:
next_pc <= std_logic_vector(unsigned(pc_out) + unsigned(binary4in32));



--MUX jump:
pc_in <= JALR_values when OPCODE = op_JALR and funct3 = fu_JALR else
         JAL_values when OPCODE = op_JAL else
         condjmp_values when OPCODE = op_BRANCH else
         next_pc; -- aggiungere se ci sarà altro


--PC block(register):
PC_block: process(CLK, RESET)
begin
if(RESET = '0') then
    pc_out <= (others => '0');
    elsif(rising_edge(CLK)) then
        pc_out <= pc_in;
end if;
end process;


--pipeline fetch/decode(register):
pipeline_fetch_decode_reg: process(CLK, RESET)
begin
if(RESET = '0') then
    pipeline_fetch_decode <= (others => '0');
    elsif(rising_edge(CLK)) then
        pipeline_fetch_decode <= pipeline_fetch_register_in;
end if;
end process;




end Fetch_bh;
