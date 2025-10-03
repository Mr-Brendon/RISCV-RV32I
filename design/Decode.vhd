
    
----------------------------------------------------------------------------------
-- Quale miglior modo di fare il decode se non iniziarlo.
--voglio in primis fare la CU, quindi iniziamo con tutti gli opcode ecc...
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.Instruments_pkg.ALL;
use IEEE.NUMERIC_STD.ALL;--
--library UNISIM;
--use UNISIM.VComponents.all;

entity Decode is
    port(pipeline_fetch_decode: in std_logic_vector (pip_f_d-1 downto 0) --la word è la parte bassa, quella alta è index del pc
         );
end Decode;

architecture Decode_bh of Decode is

----------------------------------
signal CLK, RESET, reg_write: std_logic; --da mettere poi nelle port
type reg_array is array(0 to 31) of std_logic_vector(31 downto 0);
signal file_reg_array: reg_array := (others => (others => '0'));
signal dec_out, reg_value_rd, rs1_value, rs2_value: std_logic_vector(31 downto 0);
----------------------------------
signal OPCODE: std_logic_vector(pip_f_d-1 downto 0);
signal rs1_index, rs2_index, rd_index: std_logic_vector(5 downto 0);--sicuro sia 5 e non 4??? COSA IMPORTANTE
signal funct3: std_logic_vector(2 downto 0);
signal funct7: std_logic_vector(6 downto 0);
signal imm_value: std_logic_vector(19 downto 0);

begin

--PARSER:
OPCODE <=  pipeline_fetch_decode(6 downto 0);
rs1_index <= pipeline_fetch_decode(19 downto 15);
rs2_index <= pipeline_fetch_decode(24 downto 20);
rd_index <= pipeline_fetch_decode(11 downto 7);
funct3 <= pipeline_fetch_decode(14 downto 12);
funct7 <= pipeline_fetch_decode(31 downto 25);

--imm_value: è particolare perchè dipende da istruzione
--facciamo la gestione dell'imm in base all'opcode:
imm_value_options: process(OPCODE, pipeline_fetch_decode)
begin

    case OPCODE is --NOTA: i branch poi vanno schiftati(nell'execute) a sinistra perchè hanno un primo zero
                   --(13 bit efettivi), jal setta il primo dei 12 a 0, quindi è diverso
        when "0110111" => --LUI
            imm_value <= pipeline_fetch_decode(31 downto 12); --quelli più bassi di pipe... sono l'instruction word, i più alti il pc
        when "0010111" => --AUIPC
            imm_value <= pipeline_fetch_decode(31 downto 12);
        when "1101111" => -- JAL
            --ATTENZIONE: essendo che l'imm totale è 13 bit,
                        --ossia i 12 bit di imm più l'implicito come bit meno significativo
                        --essendo che i bit nel set di istruzioni vanno da 20 ad 1 per l'imm, io li ho scalati di -1
                        --quindi 12 è 11 nell'imm (parte sinistra, a destra è la normale word con gli indici normali).
                        --e settato l'ultimo bit a 0.
            imm_value(19) <= pipeline_fetch_decode(31);
            imm_value(9 downto 1) <= pipeline_fetch_decode(30 downto 22);
            imm_value(0) <= '0'; --sarebbe stato il pipeline_fetch_decode(21), ma è settato a 0.
            imm_value(10) <= pipeline_fetch_decode(20);
            imm_value(18 downto 11) <= pipeline_fetch_decode(19 downto 12);
        when "1100111" => --JALR
            imm_value(19 downto 12) <= (others => '0');
            imm_value(11 downto 0) <= pipeline_fetch_decode(31 downto 20);
        when "1100011" => --salti condizionati
                        --ATTENZIONE: essendo che l'imm totale è 13 bit,
                        --ossia i 12 bit di imm più l'implicito come bit meno significativo
                        --essendo che i bit nel set di istruzioni vanno da 20 ad 1 per l'imm, io li ho scalati di -1
                        --quindi 12 è 11 nell'imm (parte sinistra, a destra è la normale word con gli indici normali).
            imm_value(19 downto 12) <= (others => '0');
            imm_value(11) <= pipeline_fetch_decode(31);
            imm_value(10) <= pipeline_fetch_decode(7);
            imm_value(9 downto 4) <= pipeline_fetch_decode(30 downto 25);
            imm_value(3 downto 0) <= pipeline_fetch_decode(11 downto 8);
        when "0000011" => --load instructions
            imm_value(19 downto 12) <= (others => '0');
            imm_value(11 downto 0) <= pipeline_fetch_decode(31 downto 20);
        when "0100011" => --store instructions
            imm_value(19 downto 12) <= (others => '0');
            imm_value(11 downto 5) <= pipeline_fetch_decode(31 downto 25);
            imm_value(4 downto 0) <= pipeline_fetch_decode(11 downto 7);
        when "0010011" => --ALU immediata
            imm_value(19 downto 12) <= (others => '0');
            imm_value(11 downto 0) <= pipeline_fetch_decode(31 downto 20);
        when others =>  --caso che comunque non dovrebbe mai succedere.
            imm_value(19 downto 0) <= (others => '0');
        
    end case;
end process;
--END PARSER.


--FILE_REGISTER: 
--Input: RESET, CLK, reg_write, rd_index, RS1_index, RS2_index, reg_value_rd
--output: rs1_value, rs2_value



--1) FILE_REG_DECODER:

--NOTA: ho creato il segnale:
-- type reg_array is array(0 to 31) of std_logic_vector(31 downto 0);
-- signal file_reg_array: reg_array := (others => (others => '0'));
--ed altri tra le lineette


--registri + decoder (una and per azionare i registri)
process(RESET, CLK)

variable index: integer;
begin
    if(RESET = '0') then
        file_reg_array <= (others => (others => '0'));
    elsif(rising_edge(CLK)) then
        if(reg_write = '1') then
            index := to_integer(unsigned(rd_index));
            if(index >= 0 and index < 32) then
                file_reg_array(index) <= reg_value_rd;
            end if;
        end if;
    end if;
end process;


process(rs1_index, file_reg_array)
begin
    rs1_value <= file_reg_array(to_integer(unsigned(rs1_index)));
end process;

process(rs2_index, file_reg_array)
begin
    rs2_value <= file_reg_array(to_integer(unsigned(rs2_index)));
end process;


--END FILE_REGISTER.




--CU
--prendiamo tutte le istruzioni(o meglio gli opcode) che usano i reg rs1, rs2 e rd.
CU_block: process()
begin



end process;








end Decode_bh;
