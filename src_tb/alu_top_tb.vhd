--------------------------------------------------------------------------------
-- HEIG-VD
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
--------------------------------------------------------------------------------
-- REDS Institute
-- Reconfigurable Embedded Digital Systems
--------------------------------------------------------------------------------
--
-- File         : alu_n_top_tb.vhd
-- Author       : E. Messerli
-- Date         : 14.03.2016
-- Version      : 0.0
--
-- Description  : Test bench de l'ALU N bits avec 8 operations
--                simulation du fichier alu_n_top.vhd
--
-- Used in      : Labo ALU, unite SysLog2
--
--| Modifications |-------------------------------------------------------------
-- Ver   Author   Date         Comments
-- 1.0   EMI      24.03.2016   Ajout flag pour verification full lors egalite
--                             Corrige comptage nombre d'erreur
-- 2.0   EMI      07.04.2016   Correction gestion flag verification full
--                             lors egalite
-- 2.1   EMI      07.04.2016   Correction calcul reference operations logiques
-- 2.2   SMS      21.03.2018   Adaptations à la donnée 2018
-- 2.3   LFR      29.02.2024   Adaptations à la donnée 2024
--------------------------------------------------------------------------------

--| Library |-------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;
    use ieee.math_real.all;
use work.common_pkg.all;
use work.project_logger_pkg.all;
--------------------------------------------------------------------------------

--| Entity |--------------------------------------------------------------------
entity alu_top_tb is
    generic(
        VAL_N : natural range 1 to 16 := 6
    );
end alu_top_tb;
--------------------------------------------------------------------------------

--| Architecture |--------------------------------------------------------------
architecture test_bench of alu_top_tb is

    --| Types |-----------------------------------------------------------------
    type stimulus_int_t is record
        opcode : natural;
        na     : integer;
        nb     : integer;
    end record;

    type observed_int_t is record
        result_sgn  : integer;
        result_nsgn : integer;
        z           : std_logic;
        dep_nsgn    : std_logic;
        dep_sgn     : std_logic;
    end record;

    type tab_stimulus_int_t is array (natural range <>) of stimulus_int_t;
    ----------------------------------------------------------------------------

    --| Constants |-------------------------------------------------------------

    -- Flag pour selectionner une verification "full" de l'operation Egalite
    constant CHECK_FULL_EGALITE : boolean := true;
    -- Choisir nombre de cas vérifier aleatoirement (random)
    constant NBR_VERIF_RANDOM : natural := 50000;
    -- ALU sur VAL_N bits avec nombre non-signe ou signe en C2
    constant RES_MAX_SGN  : integer :=  (2**(VAL_N-1))-1;
    constant RES_MIN_SGN  : integer := -(2**(VAL_N-1))  ;
    constant RES_MAX_NSGN : integer :=  (2**(VAL_N)  )-1;
    ----------------------------------------------------------------------------

    --| Signals |---------------------------------------------------------------
    -- simulation signal
    signal clk_sim_s : std_logic;
    signal sim_end_s : boolean   := false;
    signal error_s   : std_logic := '0';

    -- Stimulis
    signal stimulus_sti : stimulus_t(
                              opcode(2 downto 0),
                              na(VAL_N-1 downto 0),
                              nb(VAL_N-1 downto 0)
                           );
    -- Observed
    signal observed_obs : observed_t(
                              result(VAL_N-1 downto 0)
                          );
    -- Reference
    signal reference_ref : observed_t(
                               result(VAL_N-1 downto 0)
                           );
    ----------------------------------------------------------------------------

    --| Components |------------------------------------------------------------
    component ALU_nbits_top
        generic(
            N : positive range 1 to 16 := 4
        );
        port(
            opcode_i   : in  std_logic_vector(2 downto 0);
            na_i       : in  std_logic_vector(N-1 downto 0);
            nb_i       : in  std_logic_vector(N-1 downto 0);
            result_o   : out std_logic_vector(N-1 downto 0);
            z_o        : out std_Logic;
            dep_nsgn_o : out std_Logic;
            dep_sgn_o  : out std_Logic
        );
    end component;
    for all : ALU_nbits_top use entity work.ALU_nbits_top;
    ----------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- Tab for directed test with unsigned number
    constant TAB_STIMULI_NSGN : tab_stimulus_int_t := (
    --     opcode      na          nb
    --     0 à 7       nbr:  0 à (2**n)-1
    --                 Cas n=8  0 à 255
        (    0      ,   255  ,      0  ),  --add
        (    0      ,   255  ,      1  ),  --add, carry, zero
        (    0      ,   128  ,    128  ),  --add, carry, ovr, zero
        (    0      ,   126  ,    126  ),  --add, ovr
        (    0      ,   136  ,    120  ),  --add, carry
        (    1      ,    60  ,    200  ),  -- *2,
        (    1      ,   115  ,    200  ),  -- *2,
        (    1      ,   235  ,    200  ),  -- *2, carry
        (    1      ,   182  ,    200  ),  -- *2, carrry, ovr
        (    2      ,   127  ,    128  ),  -- and, zero
        (    2      ,   170  ,     85  ),  -- and, zero
        (    2      ,   255  ,    170  ),  -- and
        (    2      ,   255  ,     85  ),  -- and
        (    2      ,    15  ,    255  ),  -- and
        (    3      ,   127  ,      0  ),  -- incr, ovr
        (    3      ,   128  ,     15  ),  -- incr, 
        (    3      ,   255  ,     15  ),  -- incr, carry, zero
        (    3      ,   200  ,     15  ),  -- incr, 
        (    4      ,   127  ,    127  ),  -- sub a-b, zero
        (    4      ,   128  ,    128  ),  -- sub a-b, zero
        (    4      ,   255  ,    255  ),  -- sub a-b, zero
        (    4      ,   127  ,    128  ),  -- sub a-b, borrow
        (    4      ,   170  ,    110  ),  -- sub a-b, ovr
        (    4      ,    80  ,    110  ),  -- sub a-b, borrow
        (    5      ,   127  ,    127  ),  -- sub b - a, zero
        (    5      ,   128  ,    128  ),  -- sub b - a, zero
        (    5      ,   255  ,    255  ),  -- sub b - a, zero
        (    5      ,   127  ,    128  ),  -- sub b - a, ovr
        (    5      ,   170  ,    110  ),  -- sub b - a, borrow
        (    5      ,    80  ,    110  ),  -- sub b - a, 
        (    6      ,   25   ,     14  ),  -- or b-a, emprunt
        (    6      ,  127   ,    128  ), -- or, zero
        (    6      ,  170   ,     85  ), -- or, zero
        (    6      ,  255   ,    170  ), -- or, 
        (    6      ,  255   ,     85  ), -- or
        (    6      ,   15   ,    255  ), -- or,
        (    7      ,  127   ,      0  ), -- decr,
        (    7      ,  170   ,     15  ), -- decr,
        (    7      ,    0   ,     15  ), -- decr, borrow
        (    7      ,  128   ,     15  ), -- decr, ovr
        (    7      ,  240   ,     15  )  -- decr,
    );

    --table avec nombre signes
    constant TAB_STIMULI_SGN : tab_stimulus_int_t := (
    --    opcode        na         nb
    --     0 à 7        nbr:  -2**(n-1) à +(2**(n-1))-1
    --                  Cas n=6  -32 à 31
        (    0      ,    14  ,     12  ),
        (    0      ,   -10  ,     -3  ),  --ok, mais carry
        (    0      ,   -25  ,    -10  ),  --ovr
        (    0      ,    17  ,     23  )   --ovr
    );
    ----------------------------------------------------------------------------

begin

    --| Components instanciation |----------------------------------------------
    uut : ALU_nbits_top
    generic map(
        N => VAL_N
    )
    port map(
        opcode_i   => stimulus_sti.opcode,
        na_i       => stimulus_sti.na,
        nb_i       => stimulus_sti.nb,
        result_o   => observed_obs.result,
        z_o        => observed_obs.z,
        dep_nsgn_o => observed_obs.dep_nsgn,
        dep_sgn_o  => observed_obs.dep_sgn
    );
    ----------------------------------------------------------------------------

    --| clock process |---------------------------------------------------------
    -- This process generate a clock with a period CLK_PERIOD used for the
    -- simulation
    clk_gen_proc : process is
    begin
        while not(sim_end_s) loop
            clk_sim_s <= '0', '1' after CLK_PERIOD/2;
            wait for CLK_PERIOD;
        end loop;
        wait;
    end process clk_gen_proc;
    ----------------------------------------------------------------------------

    --| Stimulus generation process |-------------------------------------------
    stimulus_proc : process is
        variable stimulus_v : stimulus_int_t;
        variable seed_1_v   : positive := 5; -- seed arbitrary set
        variable seed_2_v   : positive := 63;
        variable rand_v     : real     := 0.0;
    begin
        -- wait for the metavalue warning to be removed
        wait for 1 ns;
        -- User notification
        logger.log_note("Start of simulation");

        -- Init signal
        sim_end_s           <= false;
        stimulus_sti.opcode <= (others => '0');
        stimulus_sti.na     <= (others => '0');
        stimulus_sti.nb     <= (others => '0');
        cycle_fall(clk_sim_s, 1);

        --| Directed tests |----------------------------------------------------
        -- Unsigned number (TAB_STIMULI_NSGN)
        tab_loop1: for i in 0 to TAB_STIMULI_NSGN'length-1 loop
            -- Get value in tab corresponding to the test number
            stimulus_v.opcode := TAB_STIMULI_NSGN(i).opcode;
            stimulus_v.na     := TAB_STIMULI_NSGN(i).na;
            stimulus_v.nb     := TAB_STIMULI_NSGN(i).nb;

            -- Stimulus affectation
            stimulus_sti.opcode <= std_logic_vector(to_unsigned(stimulus_v.opcode, stimulus_sti.opcode'length));
            stimulus_sti.na     <= std_logic_vector(to_unsigned(stimulus_v.na, VAL_N));
            stimulus_sti.nb     <= std_logic_vector(to_unsigned(stimulus_v.nb, VAL_N));

            cycle_fall(clk_sim_s, 1);
        end loop;

        -- Signed number (TAB_STIMULI_SGN)
        tab_loop2: for i in 0 to TAB_STIMULI_SGN'length-1 loop
            -- Get value in tab corresponding to the test number
            stimulus_v.opcode := TAB_STIMULI_SGN(i).opcode;
            stimulus_v.na     := TAB_STIMULI_SGN(i).na;
            stimulus_v.nb     := TAB_STIMULI_SGN(i).nb;

            -- Stimulus affectation
            stimulus_sti.opcode <= std_logic_vector(to_signed(stimulus_v.opcode, stimulus_sti.opcode'length));
            stimulus_sti.na     <= std_logic_vector(to_signed(stimulus_v.na, VAL_N));
            stimulus_sti.nb     <= std_logic_vector(to_signed(stimulus_v.nb, VAL_N));

            cycle_fall(clk_sim_s, 1);
        end loop;
        ------------------------------------------------------------------------

        --| Random tests |------------------------------------------------------
        rand_loop: for i in 0 to NBR_VERIF_RANDOM-1 loop

            -- Get random value between 0.0 and 1.0
            Uniform(seed_1_v, seed_2_v, rand_v);
            -- Transform the rand to an integer value between 0 and 65535
            stimulus_v.na := integer(rand_v*real((2**VAL_N)-1));

            -- Get another random value between 0.0 and 1.0
            Uniform(seed_1_v, seed_2_v, rand_v);
            -- Transform the rand to an integer value between 0 and 65535
            stimulus_v.nb := integer(rand_v*real((2**VAL_N)-1));

            -- Get another random value between 0.0 and 1.0
            Uniform(seed_1_v, seed_2_v, rand_v);
            -- Transform the rand to an integer value between 0 and 7
            stimulus_v.opcode := integer(rand_v*reaL((2**(stimulus_sti.opcode'length))-1));

            -- Stimulus affectation
            stimulus_sti.opcode <= std_logic_vector(to_unsigned(stimulus_v.opcode, stimulus_sti.opcode'length));
            stimulus_sti.na     <= std_logic_vector(to_unsigned(stimulus_v.na, VAL_N));
            stimulus_sti.nb     <= std_logic_vector(to_unsigned(stimulus_v.nb, VAL_N));

            cycle_fall(clk_sim_s, 1);
        end loop;
        ------------------------------------------------------------------------

        -- Fin de la simulation
        sim_end_s <= true;

        wait for 6 ns;

        -- Messages de fin
        logger.final_report;

        wait ; --stop la simulation
    end process stimulus_proc;
    ----------------------------------------------------------------------------

    --| Reference generation process |------------------------------------------
    reference_proc : process is
        variable stimulus_sgn_v  : stimulus_int_t;
        variable stimulus_nsgn_v : stimulus_int_t;
        variable reference_v     : observed_int_t;
        variable result_temp_v   : signed(VAL_N downto 0);
        variable result_v        : signed(VAL_N-1 downto 0);
        variable err_opcode_v    : boolean := false;
    begin

        -- Assignation des references
        reference_ref.result   <= (others => '0');
        reference_ref.z        <= '1';
        reference_ref.dep_sgn  <= '0';
        reference_ref.dep_nsgn <= '0';
        cycle_fall(clk_sim_s, 1);

        while not(sim_end_s) loop
            -- wait a bit to be sure the result is disponible in the dut output
            wait for 1 ns;
            -- Opcode always unsigned
            stimulus_sgn_v.opcode := to_integer(unsigned(stimulus_sti.opcode));
            stimulus_sgn_v.na     := to_integer(signed(stimulus_sti.na));
            stimulus_sgn_v.nb     := to_integer(signed(stimulus_sti.nb));

            stimulus_nsgn_v.opcode := to_integer(unsigned(stimulus_sti.opcode));
            stimulus_nsgn_v.na     := to_integer(unsigned(stimulus_sti.na));
            stimulus_nsgn_v.nb     := to_integer(unsigned(stimulus_sti.nb));


            -- Default value
            reference_v.result_sgn  := 0;
            reference_v.result_nsgn := 0;
            reference_v.z           := '0';
            reference_v.dep_sgn     := '0';
            reference_v.dep_nsgn    := '0';


        --  opcode Opération              result_o
        --    000  Addition               na_i + nb_i
        --    001  Multiplication par 2   na_i * 2
        --    010  Logical AND            na_i AND nb_i
        --    011  Incrementation         nb_i +1
        --    100  Soustraction           na_i - nb_i
        --    101  Soustraction           nb_i - na_i
        --    110  Logical OR             na_i OR nb_i
        --    111  Decrement              na_i - 1

            -- Calcul the result reference depending of the opcode
            case stimulus_sgn_v.opcode is
                when 0 =>
                    reference_v.result_sgn  := stimulus_sgn_v.na  + stimulus_sgn_v.nb;
                    reference_v.result_nsgn := stimulus_nsgn_v.na + stimulus_nsgn_v.nb;
                when 1 =>
                    reference_v.result_sgn  := stimulus_sgn_v.na  * 2;
                    reference_v.result_nsgn := stimulus_nsgn_v.na * 2;
                when 2 =>
                    reference_v.result_sgn  := to_integer(signed(stimulus_sti.na   and stimulus_sti.nb));
                    reference_v.result_nsgn := to_integer(unsigned(stimulus_sti.na and stimulus_sti.nb));
                when 3 =>
                    reference_v.result_sgn  := stimulus_sgn_v.na  + 1;
                    reference_v.result_nsgn := stimulus_nsgn_v.na + 1;
                when 4 =>
                    reference_v.result_sgn  := stimulus_sgn_v.na  - stimulus_sgn_v.nb;
                    reference_v.result_nsgn := stimulus_nsgn_v.na - stimulus_nsgn_v.nb;
                when 5 =>
                    reference_v.result_sgn  := stimulus_sgn_v.nb  - stimulus_sgn_v.na;
                    reference_v.result_nsgn := stimulus_nsgn_v.nb - stimulus_nsgn_v.na;
                when 6 =>
                    reference_v.result_sgn  := to_integer(signed(stimulus_sti.na   or stimulus_sti.nb));
                    reference_v.result_nsgn := to_integer(unsigned(stimulus_sti.na or stimulus_sti.nb));
                when 7 =>
                    reference_v.result_sgn  := stimulus_sgn_v.na  - 1;
                    reference_v.result_nsgn := stimulus_nsgn_v.na - 1;
                when others =>
                    err_opcode_v := true;
            end case;

            -- Calcul the dep reference
            if(err_opcode_v) then --erreur opcode
                reference_v.dep_sgn  := 'X';
                reference_v.dep_nsgn := 'X';
                reference_v.z        := 'X';
            else
                -- Calcul de l'overflow (nombre signes)
                if(stimulus_sgn_v.opcode = 2)or(stimulus_sgn_v.opcode = 6) then
                    -- operation logique -> pas de check depassement
                    reference_v.dep_sgn := '-';
                elsif(reference_v.result_sgn > RES_MAX_SGN)or
                  (reference_v.result_sgn < RES_MIN_SGN)then
                    reference_v.dep_sgn := '1';
                else
                    reference_v.dep_sgn := '0';
                end if;

                -- Calcul du carry/borrow (nombres non signes)
                if(stimulus_nsgn_v.opcode = 4)or(stimulus_nsgn_v.opcode = 5) or(stimulus_nsgn_v.opcode = 7) then
                    if(reference_v.result_nsgn < 0) then
                        reference_v.dep_nsgn := '1'; -- borrow !
                    else
                        reference_v.dep_nsgn := '0';
                    end if;
                elsif(stimulus_sgn_v.opcode = 2)or(stimulus_sgn_v.opcode = 6) then
                    -- operation logique -> pas de check depassement
                    reference_v.dep_nsgn := '-';
                else
                    --addition
                    if(reference_v.result_nsgn > RES_MAX_NSGN) then
                        reference_v.dep_nsgn := '1'; --carry
                    else
                        reference_v.dep_nsgn := '0';
                    end if;
                end if;

                -- one bit greater
                result_temp_v := to_signed(reference_v.result_sgn, result_temp_v'length);
                -- Remove the bit high to fit
                result_v := result_temp_v(result_temp_v'high-1 downto 0);

                --Calcul du flag egal 0
                if(result_v = 0) then
                    reference_v.z := '1';
                else
                    reference_v.z := '0';
                end if;

            end if;

            -- Assignation des references
            reference_ref.result   <= std_logic_vector(result_v);
            reference_ref.z        <= reference_v.z;
            reference_ref.dep_sgn  <= reference_v.dep_sgn;
            reference_ref.dep_nsgn <= reference_v.dep_nsgn;

            cycle_fall(clk_sim_s, 1);

        end loop;
        wait;
    end process reference_proc;
    ----------------------------------------------------------------------------

    --| Verification process |--------------------------------------------------
    verif_proc : process is
        variable stimulus_v  :  stimulus_t(
                                    opcode(2 downto 0),
                                    na(VAL_N-1 downto 0),
                                    nb(VAL_N-1 downto 0)
                                );
        variable observed_v  :  observed_t(
                                    result(VAL_N-1 downto 0)
                                );
        variable reference_v :  observed_t(
                                    result(VAL_N-1 downto 0)
                                );
        variable has_fail_v  : boolean := false;
    begin
        while not(sim_end_s) loop

            cycle_rise(clk_sim_s, 1);
            stimulus_v  := stimulus_sti;
            -- Get observed from dut
            observed_v  := observed_obs;
            -- Get reference from model
            reference_v := reference_ref;

            -- Check
            check(stimulus_v, reference_v, observed_v, has_fail_v);
            if(has_fail_v) then
                error_s <= '1', '0' after CLK_PERIOD/2;
            end if;
        end loop;
        wait;
    end process verif_proc;
    ----------------------------------------------------------------------------

end test_bench;
--------------------------------------------------------------------------------