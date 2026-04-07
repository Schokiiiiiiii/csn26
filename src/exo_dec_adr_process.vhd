-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- File         : exo_dec_adr_process.vhd
-- Description  : Address decoder
--                Describing exercise combinatorial system with process
--
-- Author       : F. Léger
-- Date         : 07.04.2026
-- Version      : 2.0
--
-- Dependencies : 
--
--| Modifications |------------------------------------------------------------
-- Version   Author Date               Description
-- 1.0       EMI    31.03.19           Initial version
-- 1.1       YNG    03.02.25           Update header
-- 2.0       FLR    07.04.26           Described through sequential process
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exo_dec_adr_process is
  port(
    adr_i            : in   std_logic_vector(15 downto 0);
    cs_rom_o         : out  std_logic;
    cs_ram_o         : out  std_logic;
    cs_flash_o       : out  std_logic;
    cs_io_o          : out  std_logic;
    cs_leds_o        : out  std_logic;
    cs_switch_o      : out  std_logic;
    cs_matrice_led_o : out  std_logic;
    cs_capt_analog_o : out  std_logic;
    cs_cmd_moteur_o  : out  std_logic
  );
end exo_dec_adr_process ;

architecture flot_don of exo_dec_adr_process is
  
begin
  
  process(adr_i)
    
  begin
 
    -- values by default
    cs_rom_o         <= '0';
    cs_ram_o         <= '0';
    cs_flash_o       <= '0';
    cs_io_o          <= '0';
    cs_leds_o        <= '0';
    cs_switch_o      <= '0';
    cs_matrice_led_o <= '0';
    cs_capt_analog_o <= '0';
    cs_cmd_moteur_o  <= '0';
     
    -- address decoder
    case adr_i(15 downto 12) is
      when "0000"                             => cs_rom_o   <= '1'; -- ROM
      when "0001"|"0010"|"0011"|"0100"        => null;              -- free
      when "0101"|"0110"|"0111"               => cs_ram_o   <= '1'; -- RAM
      when "1000"|"1001"                      => cs_flash_o <= '1'; -- fash
      when "1010"|"1011"|"1100"|"1101"|"1110" => null;              -- free
      when "1111"                             => cs_io_o    <= '1'; -- io
        -- in case it's io check which io it is
        case adr_i(7 downto 4) is
	  when "0000"                                    => cs_leds_o        <= '1'; -- leds
	  when "0001"                                    => cs_switch_o      <= '1'; -- switch
	  when "0010"|"0011"                             => cs_matrice_led_o <= '1'; -- led matrix
	  when "0100"|"0101"|"0110"|"0111"|"1000"|"1001" => null;                    -- free
	  when "1010"|"1011"                             => cs_capt_analog_o <= '1'; -- analog captor
	  when "1100"|"1101"                             => cs_cmd_moteur_o  <= '1'; -- command motor
	  when "1110"|"1111"                             => null;                    -- free
	  when others                                    => null;
	end case;
      -- case for simulation                
      when others =>  cs_rom_o    <= 'X';
                      cs_ram_o   <= 'X';
                      cs_flash_o   <= 'X';
                      cs_io_o     <= 'X';
                      cs_leds_o        <= 'X';
                      cs_switch_o      <= 'X'; 
                      cs_matrice_led_o <= 'X';
                      cs_capt_analog_o <= 'X';
                      cs_cmd_moteur_o  <= 'X';
      end case;
  
  end process;
  
end flot_don;
