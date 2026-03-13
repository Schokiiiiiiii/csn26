--------------------------------------------------------------------------------
-- HEIG-VD
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
--------------------------------------------------------------------------------
-- REDS Institute
-- Reconfigurable Embedded Digital Systems
--------------------------------------------------------------------------------
--
-- File      : common_pkg.vhd
-- Author    : L. Fournier
-- Date      : 16.01.2023
--
-- Context   :
--
-- Use       :
--
---| Description |--------------------------------------------------------------
--
--
--| Modifications |-------------------------------------------------------------
-- Ver        Date              Person             Comments
-- 0.0        16.01.2023        LFR                Empty version
--------------------------------------------------------------------------------

--| Library |-------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
use work.project_logger_pkg.all;
--------------------------------------------------------------------------------

--| Package declaration |-------------------------------------------------------
package common_pkg is

    --| Types |-------------------------------------------------------------
    type stimulus_t is record
        opcode : std_logic_vector;
        na     : std_logic_vector;
        nb     : std_logic_vector;
    end record;

    type observed_t is record
        result   : std_logic_vector;
        z        : std_logic;
        dep_nsgn : std_logic;
        dep_sgn  : std_logic;
    end record;
    ----------------------------------------------------------------------------

    --| Constants |-------------------------------------------------------------
    constant CLK_PERIOD : time := 10 ns;
    ----------------------------------------------------------------------------

    --| Procedures |------------------------------------------------------------
    -- simulator cycle
    procedure cycle_fall(signal clk      : in std_logic;
                                nb_cycle : in integer := 1);
        -- simulator cycle
    procedure cycle_rise(signal clk      : in std_logic;
                                nb_cycle : in integer := 1);
    -- Vector to string conversion
    procedure vec_to_string(variable vector    : in  std_logic_vector;
                            variable my_string : out string);
    -- check procedure
    procedure check(variable stimulus  : in  stimulus_t;
                    variable reference : in  observed_t;
                    variable observed  : in  observed_t;
                    variable has_fail  : out boolean);

    procedure check(variable reference : in  integer;
                    variable observed  : in  integer;
                    variable has_fail  : out boolean);

    procedure check(variable reference : in std_logic_vector;
                    variable observed  : in std_logic_vector;
                    variable has_fail  : out boolean);

    procedure check(variable reference : in std_logic;
                    variable observed  : in std_logic;
                    variable has_fail  : out boolean);
    ----------------------------------------------------------------------------

    --| Fonctions |-------------------------------------------------------------
    function ilog( x   : natural;
                  base : natural := 2) return natural;
    ----------------------------------------------------------------------------

end common_pkg;
--------------------------------------------------------------------------------

--| Package body |--------------------------------------------------------------
package body common_pkg is

    --| Procedures |------------------------------------------------------------
    -- simulator cycle
    procedure cycle_fall(signal clk      : in std_logic;
                                nb_cycle : in integer := 1) is
    begin
        for i in 1 to nb_cycle loop
            wait until falling_edge(clk);
        end loop;
    end cycle_fall;

    procedure cycle_rise(signal clk      : in std_logic;
                                nb_cycle : in integer := 1) is
    begin
        for i in 1 to nb_cycle loop
            wait until rising_edge(clk);
        end loop;
    end cycle_rise;

    -- Vector to string converstion
    procedure vec_to_string(variable vector    : in  std_logic_vector;
                            variable my_string : out string) is
    	   variable string_v : string(vector'length downto 1) := (others => NUL);
    begin
        string_v := (others => NUL);
        for i in vector'length downto 1 loop
            string_v(i) := std_logic'image(vector((i-1)))(2);
        end loop;

        my_string := string_v;
    end vec_to_string;

    -- check procedure
    procedure check(variable stimulus  : in  stimulus_t;
                    variable reference : in  observed_t;
                    variable observed  : in  observed_t;
                    variable has_fail  : out boolean) is
        variable reference_str_v : string(reference.result'length downto 1) := (others => NUL);
        variable observed_str_v  : string(observed.result'length downto 1)  := (others => NUL);
    begin
        vec_to_string(reference.result, reference_str_v);
        vec_to_string(observed.result, observed_str_v);
        has_fail := false;
        if(reference.result /= observed.result) then
            logger.log_error("" & CR &
                             "Erreur sur result :" & CR &
                             "Opcode = " & integer'image(to_integer(unsigned(stimulus.opcode))) & CR &
                             ">> Result observe = " & observed_str_v & CR &
                             ">> Result attendu = " & reference_str_v
                            );
            has_fail := true;
        end if;

        if(reference.dep_nsgn /= '-') then
            if(reference.dep_nsgn /= observed.dep_nsgn) then
                logger.log_error("" & CR &
                    "Erreur sur dep_nsgn : " & CR &
                    "Opcode = " & integer'image(to_integer(unsigned(stimulus.opcode))) & CR &
                    "Result = " & observed_str_v & CR &
                    ">> dep_nsgn observe = " & std_logic'image(observed.dep_nsgn) & CR &
                    ">> dep_nsgn attendu = " & std_logic'image(reference.dep_nsgn)
                );
                has_fail := true;
            end if;
        end if;

        if(reference.dep_sgn /= '-') then
            if(reference.dep_sgn /= observed.dep_sgn) then
                logger.log_error("" & CR &
                    "Erreur sur dep_sgn :" & CR &
                    "Opcode = " & integer'image(to_integer(unsigned(stimulus.opcode))) & CR &
                    "Result = " & observed_str_v & CR &
                    ">> dep_sgn observe = " & std_logic'image(observed.dep_sgn) & CR &
                    ">> dep_sgn attendu = " & std_logic'image(reference.dep_sgn)
                );
                has_fail := true;
            end if;
        end if;

        if(reference.z /= observed.z) then
                logger.log_error("" & CR &
                    "Erreur sur zero : " & CR &
                    "Opcode = " & integer'image(to_integer(unsigned(stimulus.opcode))) & CR &
                    "Result = " & observed_str_v & CR &
                    ">> z observe = " & std_logic'image(observed.z) & CR &
                    ">> z attendu = " & std_logic'image(reference.z)
                );
            has_fail := true;
        end if;
    end check;

    procedure check(variable reference : in  integer;
                    variable observed  : in  integer;
                    variable has_fail  : out boolean) is
    begin
        has_fail := false;
        if(reference /= observed) then
            logger.log_error("Ref = " & integer'image(reference) & " /= " & integer'image(observed) & " =  observed");
            has_fail := true;
        end if;
    end check;

    procedure check(variable reference : in  std_logic_vector;
                    variable observed  : in  std_logic_vector;
                    variable has_fail  : out boolean) is
        variable reference_str_v : string(reference'length downto 1) := (others => NUL);
        variable observed_str_v  : string(observed'length downto 1)  := (others => NUL);

    begin
        has_fail := false;
        vec_to_string(reference, reference_str_v);
        vec_to_string(observed, observed_str_v);
        if(reference /= observed) then
            logger.log_error("Ref = " & reference_str_v & " /= " & observed_str_v & " =  observed");
            has_fail := true;
        end if;
    end check;

    procedure check(variable reference : in  std_logic;
                    variable observed  : in  std_logic;
                    variable has_fail  : out boolean) is
    begin
        has_fail := false;
        if(reference /= observed) then
            logger.log_error("Ref = " & std_logic'image(reference) & " /= " & std_logic'image(observed) & " =  observed");
            has_fail := true;
        end if;
    end check;
    ----------------------------------------------------------------------------

    --| Fonctions |-------------------------------------------------------------
    -- integer logarithm (rounded down) [MR version]
    function ilog(x    : natural;
                  base : natural := 2) return natural is
        variable y : natural := 1;
    begin
        y := 1;  --Mod EMI 26.03.2009
        while(x > base**y) loop
            y := y+1;
        end loop;

        if(x < base**y) then
            y:=y-1;
        end if;

        return y;
    end ilog;
    ----------------------------------------------------------------------------

end common_pkg;
--------------------------------------------------------------------------------