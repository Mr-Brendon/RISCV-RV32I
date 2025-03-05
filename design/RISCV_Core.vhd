----------------------------------------------------------------------------------
-- Engineer: 
-- 
-- Create Date: 13.11.2024
-- Module Name: RISCV_Core
-- Project Name: RISCV CPU RV32I instruction set
--
-- Description:
--
--Comments: allora inizamo con capire come fare questa cpu buttando giu un po di idee.
--Prima di tutto cosa voglio nel core: macchina a stati, i blocco da connettere?
--Forse entrambi cioè voglio i blocchi da collegare però anche la CU nel core magari 
--separata con dei trattini ------ però che sia dentro
--cerco di fare dei blocchi abbastanza semplici o comunque non con troppi sottoblocchi
--facendo abbastanza behavioural o comunque non troppi blocchi di sottoblocchi
--anche con il structural
--prima di tutto scrivo tutto ciò che faccio:
--ho gia fatto l'ALU poi la includerò, non ora perchè non c'ho voglia e devo mettere anche lo shifter.
--
--iniziamo a fare il program counter ricordando che deve poi saper fare i salti quindi deve avere mux e cose...
--si potrebbe fare i macroblocchi per gli stadi di pipeline che non sarebbe male,
--si potrebbe iniziare con il core con dentro la cu che va negli structural che sono gli stadi delle pipeline,
--NO FACCIO COSI': nel core metto solo lo structural che collega gli stadi delle pipeline e la cu sempre
--come compont.
--per il PC è interessante che deve esserci un +4 che dipende dall'istruazione di salto da vedere
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity RISCV_Core is
end RISCV_Core;

architecture Core of RISCV_Core is

begin


end Core;
