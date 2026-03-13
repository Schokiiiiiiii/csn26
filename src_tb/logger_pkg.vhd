--------------------------------------------------------------------------------
-- HEIG-VD
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
--------------------------------------------------------------------------------
-- REDS Institute
-- Reconfigurable Embedded Digital Systems
--------------------------------------------------------------------------------
--
-- File      : logger_pkg.vhd
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
use std.textio.all;
--------------------------------------------------------------------------------

--| Package declaration |-------------------------------------------------------
package logger_pkg is

    --| Types |-----------------------------------------------------------------
    type logger_t is protected

        -- Sets the verbosity, any logging messages below the severity given as
        -- a parameter will be muted.
        procedure set_verbosity(constant severity_i : in severity_level := note);

        -- Logs a note
        procedure log_note(constant message : in string := "");

        -- Logs a warning
        procedure log_warning(constant message : in string := "");

        -- Logs an error
        procedure log_error(constant message : in string := "");

        -- Logs a failure
        procedure log_failure(constant message : in string := "");

        -- Prints a final report (also appended to file)
        procedure final_report;

    end protected logger_t;
    ----------------------------------------------------------------------------

end logger_pkg;
--------------------------------------------------------------------------------

--| Package body |--------------------------------------------------------------
package body logger_pkg is

    --| Types |-----------------------------------------------------------------
    type logger_t is protected body

        --| Internal types |----------------------------------------------------
        type string_ptr_t is access string;
        ------------------------------------------------------------------------

        --| Internal variables |------------------------------------------------
        variable nb_notes    : natural := 0;
        variable nb_warnings : natural := 0;
        variable nb_errors   : natural := 0;
        variable verbosity_severity : severity_level := note;
        ------------------------------------------------------------------------

        procedure logger_report(constant message    : in string;
                                constant severity_i : in severity_level := note) is
            -- Add a timestamp to the message.
            variable timed_message : string_ptr_t := new string'(" @ " & time'image(now) & " " & message);
            variable final_message : string_ptr_t;
        begin

            -- Generate a message with an appropriate label.
            case(severity_i) is
                when note =>
                    final_message := new string'(">> [NOTE]    : " & timed_message.all);
                when warning =>
                    final_message := new string'(">> [WARNING] : " & timed_message.all);
                when error =>
                    final_message := new string'(">> [ERROR]   : " & timed_message.all);
                when failure =>
                    final_message := new string'(">> [FAILURE] : " & timed_message.all);
            end case;

            -- Report the message and if the file is open write to file.
            report final_message.all severity severity_i;

            -- Free the memory
            deallocate(timed_message);
            deallocate(final_message);

        end logger_report;


        procedure set_verbosity(constant severity_i : in severity_level := note) is
        begin
            verbosity_severity := severity_i;
        end set_verbosity;

        procedure log_note(constant message : in string := "") is
        begin
            case verbosity_severity is
                when note =>
                    logger_report(message, note);
                when others =>
            end case;
            nb_notes := nb_notes + 1;
        end log_note;

        procedure log_warning(constant message : in string := "") is
        begin
            case verbosity_severity is
                when note | warning =>
                    logger_report(message, warning);
                when others =>
            end case;
            nb_warnings := nb_warnings + 1;
        end log_warning;

        procedure log_error(constant message : in string := "") is
        begin
            case verbosity_severity is
                when note | warning | error =>
                    logger_report(message, error);
                when others =>
            end case;
            nb_errors := nb_errors + 1;
        end log_error;

        procedure log_failure(constant message : in string := "") is
        begin
            logger_report(message, failure);
        end log_failure;

        procedure final_report is
        begin
            if(nb_errors = 0) then
                logger_report(CR & "+--------------------+" & CR &
                "| FINAL REPORT       |" & CR & "|--------------------+" & CR &
                "| Nb warnings = " & natural'image(nb_warnings) & CR &
                "| Nb errors   = " & natural'image(nb_errors) & CR & "|" & CR &
                "| Verbosity level is : " &
                severity_level'image(verbosity_severity) & CR & "|" & CR &
                "| *** VOUS ETES LES MEILLEURS *** " & CR &
                "| *** Bravo, pas d'erreurs    *** " & CR &
                "| " & CR &
                "| END OF SIMULATION");
            else
                logger_report(CR & "+--------------------+" & CR &
                "| FINAL REPORT       |" & CR & "|--------------------+" & CR &
                "| Nb warnings = " & natural'image(nb_warnings) & CR &
                "| Nb errors   = " & natural'image(nb_errors) & CR & "|" & CR &
                "| Verbosity level is : " &
                severity_level'image(verbosity_severity) & CR & "|" & CR &
                "| *** VOUS AVEZ ENCORE UN PEU DE TRAVAIL *** " & CR &
                "| *** COURAGE                            *** " & CR &
                "| " & CR &
                "| END OF SIMULATION");
            end if;

        end final_report;

    end protected body logger_t;
    ----------------------------------------------------------------------------

end logger_pkg;
--------------------------------------------------------------------------------