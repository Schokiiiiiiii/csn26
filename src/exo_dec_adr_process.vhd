-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- File         : exo_dec_adr_process.vhd
-- Description  : Decodeur d'adresse :
--                Exercice description système combinatoire avec process
--
-- Author       : E. Messerli
-- Date         : 31.03.2019, nouvelle version exercice
-- Version      : 0.0
--
-- Dependencies : 
--
--| Modifications |------------------------------------------------------------
-- Version   Author Date               Description
-- 1.0       EMI    31.03.19           Initial version
-- 0.0       YNG    03.02.25           Update headers
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
 
     --valeur par defaut
     --   desactive tous les chips select
     cs_rom_o    <= '0';
     cs_ram_o    <= '0';

     
     a completer .....
     
     
     
    case ............... is
      when ......                    => cs_rom_o    <= '1';  -- ROM
      when ......                    => null;                -- libre

      

      when others => --cas pour simulation
                      cs_rom_o    <= 'X';
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
