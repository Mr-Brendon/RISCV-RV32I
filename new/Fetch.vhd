----------------------------------------------------------------------------------
--Fetch module includes the whole part of program counter and the interface with
--instruction memory. It also finishes with the fetch/decoder pipeline register.
--Reset in all cpu in active high, it is active low just in the main block.
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.Instruments_pkg.ALL;
use IEEE.NUMERIC_STD.ALL;
--use UNISIM.VComponents.all;

entity Fetch is
    port(CLK: in std_logic
         );
end Fetch;


architecture Fetch_bh of Fetch is
signal pc_in, pc_out, next_pc: std_logic_vector (Nbit-1 downto 0);
signal pc_reset: std_logic;

begin


--PC block(register):
PC_block: process(CLK)
begin
if(pc_reset = '1') then
    pc_out <= (others => '0');
    elsif(rising_edge(CLK)) then
        pc_out <= pc_in;
end if;
end process;

--PC_adder_block:
next_pc <= std_logic_vector(unsigned(pc_out) + unsigned(binary4in32));

--ci sono i mux di salto






end Fetch_bh;