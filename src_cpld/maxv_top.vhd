------------------------------------------------------------------------------------------
-- HEIG-VD ///////////////////////////////////////////////////////////////////////////////
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
------------------------------------------------------------------------------------------
-- REDS Institute ////////////////////////////////////////////////////////////////////////
-- Reconfigurable Embedded Digital Systems
------------------------------------------------------------------------------------------
--
-- File                 : maxv_top.vhd
-- Author               : Gilles Curchod
-- Date                 : 28.05.2013
-- Target Devices       : Altera MAXV 5M570ZF256C5
--
-- Context              : Max_V_Board Project : Hardware bring-up
--
------------------------------------------------------------------------------------------
-- Description :
--   Top of the CPLD
------------------------------------------------------------------------------------------
-- Information :
--
------------------------------------------------------------------------------------------
-- Modifications :
-- Ver   Date        Engineer     Chnages
-- 0.0   See header  GCD          Initial version
-- 1.0   25.09.2014  EMI          Adaptation to use for CSN lab 
--
------------------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.det_clic_dblclic_pkg.all;

entity maxv_top is
    port(
        --| Clocks, Reset |-------------------------------------------------------------------
        Clk_Gen_i                : in    std_logic;                      -- CLK_GEN
        Clk_Main_i               : in    std_logic;                      -- CLK_MAIN
        --| Inout devices |-------------------------------------------------------------------
        Con_25p_io               : inout std_logic_vector(25 downto 1);  -- CON_25P_*
        Con_80p_io               : inout std_logic_vector(79 downto 2);  -- CON_80P_*
        Mezzanine_io             : inout std_logic_vector(20 downto 5);  -- MEZZANINE_*
        --| Input devices |-------------------------------------------------------------------
        Encoder_A_i              : in    std_logic;                      -- ENCODER_A
        Encoder_B_i              : in    std_logic;                      -- ENCODER_B
        nButton_i                : in    std_logic_vector( 8 downto 1);  -- NBUTTON_*
        nReset_i                 : in    std_logic;                      -- NRESET
        Switch_i                 : in    std_logic_vector( 7 downto 0);  -- SWITCH_*
        --| Output devices |------------------------------------------------------------------
        nLed_o                   : out   std_logic_vector( 7 downto 0);  -- NLED_*
        Led_RGB_o                : out   std_logic_vector( 2 downto 0);  -- LED_RGB_*
        nSeven_Seg_o             : out   std_logic_vector( 7 downto 0)   -- NDSP_SEG (dp, g downto a)
    );
end maxv_top;

architecture struct of maxv_top is

    --| Intermediate signals |--------------------------------------------------------------
    signal Reset_s          : std_logic;
    
    signal Con_25p_DI_s   : std_logic_vector(Con_25p_io'range);
    signal Con_25p_DO_s   : std_logic_vector(Con_25p_io'range);
    signal Con_25p_OE_s   : std_logic;
    signal Con_80p_DI_s   : std_logic_vector(Con_80p_io'range);
    signal Con_80p_DO_s   : std_logic_vector(Con_80p_io'range);
    signal Con_80p_OE_s   : std_logic;
    signal Mezzanine_DI_s : std_logic_vector(Mezzanine_io'range);
    signal Mezzanine_DO_s : std_logic_vector(Mezzanine_io'range);
    signal Mezzanine_OE_s : std_logic;
    signal Button_s       : std_logic_vector(nButton_i'range);
    signal Led_s          : std_logic_vector(nLed_o'range);
    signal Seven_Seg_s    : std_logic_vector(nSeven_Seg_o'range); -- order: dp, g f e d c b a

    --| Internal signals |------------------------------------------------------------------
    signal cpt_blink : unsigned(19 downto 0);
    signal cpt_ms_s  : unsigned(9 downto 0);
    signal top_ms_s   : std_logic;
    signal debounce_cpt    : unsigned (7 downto 0);
    signal button_sync1_s  : std_logic;
    signal button_sync2_s  : std_logic;
    signal diff_button_s   : std_logic;
    signal button_fltr_s   : std_logic;

    --| Components declaration |------------------------------------------------------------
    component det_clic_dblclic_top is
    generic (T1_g      : natural := 1;
             T2_g      : natural := 1 );
    port(clock_i       : in     std_logic;  --horloge systeme 1MHz
         nReset_i      : in     std_logic;  --reset asynchrone
         button_i      : in     std_logic;
         top_ms_i      : in     std_logic;
         clic_o        : out    std_logic;
         dbl_clic_o    : out    std_logic;
         clic_lg_o     : out    std_logic;
         dbl_clic_lg_o : out    std_logic
    );
    end component;
    for all : det_clic_dblclic_top use entity work.det_clic_dblclic_top(struct);

begin

    ----------------------------------------------------------------------------------------
    --| INPUTS PROCESSING |-----------------------------------------------------------------
    Reset_s <= not nReset_i;
    Button_s <= not nButton_i;
    
    ----------------------------------------------------------------------------------------
    --| OUTPUT PROCESSING |-----------------------------------------------------------------
    nLed_o <= not Led_s;
    nSeven_Seg_o <= not Seven_Seg_s;
    

    ----------------------------------------------------------------------------------------
    --| Unused output allocation |-----------------------------------------------------------------
    Led_RGB_o <= (others => '0');
    Seven_Seg_s(Seven_Seg_s'high-1 downto 0) <= (others => '0');
    Seven_Seg_s(Seven_Seg_s'high) <= cpt_blink(cpt_blink'high); -- decimal point blink at 1Hz
    
    ----------------------------------------------------------------------------------
    --| Filtrage du bouton SW1 |------------------------------------------------------
    process (Clk_Main_i, Reset_s)
    begin
        if Reset_s = '1' then
            button_sync1_s <= '0';
            button_sync2_s <= '0';
            button_fltr_s  <= '0';
        elsif rising_edge(Clk_Main_i) then
            button_sync1_s <= Button_s(1);
            button_sync2_s <= button_sync1_s;
            if debounce_cpt = 0 then  -- si Button(1) stable => mise a jour
                button_fltr_s  <= button_sync2_s;
            end if;
        end if;
    end process;
  
    diff_button_s <= button_sync1_s xor button_sync2_s;
    
    process (Clk_Main_i, Reset_s)
    begin
        if Reset_s = '1' then
            debounce_cpt <= (others => '0');
        elsif rising_edge(Clk_Main_i) then
            if diff_button_s = '1' then -- load lorsque diff_button_s
                debounce_cpt <= (others => '1'); --charge valeur max
            elsif debounce_cpt /= 0 then 
                debounce_cpt <= debounce_cpt -1;
            end if;
        end if;
    end process;

    -----------------------------------------------------------------------------------------
    --| Generateur signal top_ms |-----------------------------------------------------------
    process (Clk_Main_i, Reset_s)
    begin
        if Reset_s = '1' then
            cpt_ms_s <= (others => '0');
            top_ms_s   <= '0';
        elsif rising_edge(Clk_Main_i) then
            if cpt_ms_s = 999 then  --divise par 1000 clock 1MHz => 1KHz
                cpt_ms_s <= (others => '0');
                top_ms_s <= '1';
            else
                cpt_ms_s <= cpt_ms_s + 1;
                top_ms_s <= '0';
            end if;
        end if;
    end process;
    
    ----------------------------------------------------------------------------------------
    --| Components intanciation |-----------------------------------------------------------
    U1: det_clic_dblclic_top 
        generic map (T1_g       => T1_c,
                     T2_g       => T2_c )
        port map (clock_i       => Clk_Main_i,
                  nReset_i      => nReset_i,
                  button_i      => button_fltr_s,
                  top_ms_i      => top_ms_s,
                  clic_o        => Led_s(0),
                  dbl_clic_o    => Led_s(1),
                  clic_lg_o     => Led_s(2),
                  dbl_clic_lg_o => Led_s(3)
        );

    Led_s(7 downto 4) <= (others => '0'); --unused leds turned off 

    ----------------------------------------------------------------------------------------
    --| Signal blink at 1Hz |------------------------------------------------------------------
    process (Clk_Main_i, Reset_s)
    begin
        if Reset_s = '1' then
            cpt_blink <= (others => '0');
        elsif rising_edge(Clk_Main_i) then
            cpt_blink <= cpt_blink +1;
        end if;
    end process;
    
end struct;

