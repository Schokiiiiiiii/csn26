-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : UC.vhd
--
-- Description  : UC pour la commande des 3 moteurs pas-a-pas
--
-- Auteur       : ....
-- Date         : 21.05.2024
-- Version      : 1.0
--
-- Utilise dans : Labo moteur pas-à-pas (MSS cplx)
--
--| Modifications |------------------------------------------------------------
-- Version   Auteur      Date               Description
--
--
-------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

--| Entity |-------------------------------------------------------------------
entity UC is
    port(
        -----------------
        --   Entries   --
        -----------------
        -- clock for process
        clk_i                 	: in  std_logic;
        -- asynchronous reset
        rst_i                 	: in  std_logic;
        -- captors
	cap_l_i			: in  std_logic;
	cap_m_i			: in  std_logic;
	cap_r_i			: in  std_logic;
	-- mode chosen (1=auto, 0=manual)
	mode_i			: in  std_logic;
	-- start for auto sequence
	start_i			: in  std_logic;
	-- start for init sequence
	init_i			: in  std_logic;
	-- manual mode runs
	run_l_i			: in  std_logic;
	run_m_i			: in  std_logic;
	run_r_i			: in  std_logic;
	
        ------------
        --   UT   --
        ------------
	-- speed
        min_sp_i                : in  std_logic;
        max_sp_i              	: in  std_logic;
        -- motors
        ml_pres_i             	: in  std_logic;
        mm_pres_i             	: in  std_logic;
        mr_pres_i               : in  std_logic;
        -- number of tours
        tour_in_null_i        	: in  std_logic;
        zero_tour_i           	: in  std_logic;
        last_tour_i           	: in  std_logic;
        mult_tour_i           	: in  std_logic;
        -- detected a tour (encoche = 5)
        det_tour_i            	: in  std_logic;
        
        -----------------
        --   OUTPUTS   --
        -----------------
        -- error
        err_o			: out std_logic;
        -- speed
        incr_sp_o		: out std_logic;
        decr_sp_o		: out std_logic;
        init_sp_o		: out std_logic;
        -- direction
        dir_h_o			: out std_logic;
        dir_a_o			: out std_logic;
        -- motors
        dis_ml_o		: out std_logic;
        en_ml_o			: out std_logic;
        dis_mm_o		: out std_logic;
        en_mm_o			: out std_logic;
        dis_mr_o		: out std_logic;
        en_mr_o			: out std_logic;
        -- number of tours
        init_tour_o		: out std_logic;
        decr_tour_o		: out std_logic;
        -- number of encoches
        init_enc_o		: out std_logic;
        incr_enc_o		: out std_logic
    );
end UC;

--| Architecture |-------------------------------------------------------------
architecture fsm of UC is

    --| Types |----------------------------------------------------------------
    type state_t is (
        -- General state
        RST,
        BEFORE_INIT,
        BEFORE_AUTO,

        -- Init sequence
        INIT_SP_DIR,
        INIT_EN_MOT_L,
        INIT_DIS_MOT_L,
        INIT_EN_MOT_M,
        INIT_DIS_MOT_M,
        INIT_EN_MOT_R,
        INIT_DIS_MOT_R,

        -- Mode Manual
        MAN_SP_DIR,
        MAN_CHK_MODE,
        MAN_DIS_MOT,
        MAN_EN_MOT_M,
        MAN_EN_MOT_LR,
        MAN_EN_MOT_L,
        MAN_EN_MOT_R,

        -- Mode Automatique
        AUTO_EN_MOT_M,
	AUTO_TR_INIT,
	AUTO_ENC_INIT,
	AUTO_WT_DOWN,
	AUTO_ENC_DOWN,
	AUTO_ENC_UP,
	AUTO_CHK_TOUR,
	AUTO_INCR_SP,
	AUTO_DECR_SP,
	AUTO_DECR_TR,
	AUTO_CHK_END,
	AUTO_EN_MOT_L,
	AUTO_EN_MOT_R,
	AUTO_DIS_MOT_R,

        -- Error
        ERR
    );

    --| Signals |--------------------------------------------------------------
    -- State machine
    signal current_state_s   	: state_t;
    signal next_state_s      	: state_t;

    -- Internal signals
    signal disks_free_s		: std_logic;
    signal init_possible_s	: std_logic;
    signal cap_l_free_s		: std_logic;
    signal cap_m_free_s		: std_logic;
    signal cap_r_free_s		: std_logic;
    signal run_m_allowed_s	: std_logic;
    signal run_l_allowed_s	: std_logic;
    signal run_r_allowed_s	: std_logic;
    signal auto_l_running_s 	: std_logic;
    signal auto_m_running_s	: std_logic;
    signal auto_r_running_s	: std_logic;

begin
    --| Internal signals logic binding |----------------------------------------------------
    disks_free_s <= '1' when (cap_l_i = '0' and cap_m_i = '0' and cap_r_i = '0') else
                    '0';
    
    init_possible_s <= '1' when (cap_m_free_s = '1' or (cap_l_free_s = '1' and cap_r_free_s = '1')) else
                       '0';
    
    cap_l_free_s <= not cap_l_i;
    cap_m_free_s <= not cap_m_i;
    cap_r_free_s <= not cap_r_i;
    
    run_m_allowed_s <= '1' when (run_m_i = '1' and run_l_i = '0' and run_r_i = '0') and
                                (cap_l_free_s = '1' and cap_r_free_s = '1') else
                       '0';
    run_l_allowed_s <= '1' when (run_l_i = '1' and run_m_i = '0') and
                                (cap_m_free_s = '1') else
                       '0';
    run_r_allowed_s <= '1' when (run_r_i = '1' and run_m_i = '0') and 
                                (cap_m_free_s = '1') else
                       '0';
    
    auto_l_running_s <= '1' when (ml_pres_i = '1' and mm_pres_i = '0' and mr_pres_i = '0') else
                        '0';
    auto_m_running_s <= '1' when (ml_pres_i = '0' and mm_pres_i = '1' and mr_pres_i = '0') else
                        '0';
    auto_r_running_s <= '1' when (ml_pres_i = '0' and mm_pres_i = '0' and mr_pres_i = '1') else
                        '0';
    

    --| Update state proc |----------------------------------------------------
    -- This process update the state of the state machine
    fsm_reg : process(clk_i, rst_i) is
    begin
        if(rst_i = '1') then
            current_state_s <= RST;
        elsif(rising_edge(clk_i)) then
            current_state_s <= next_state_s;
        end if;
    end process fsm_reg;
    ---------------------------------------------------------------------------

    --| Decodeur etats futures et sorties |---------------------------------------------------
    dec_fut_sort : process(current_state_s,
                           cap_l_i,
			   cap_m_i,
			   cap_r_i,
			   mode_i,
			   start_i,
			   init_i,
			   run_l_i,
			   run_m_i,
			   run_r_i,
			   min_sp_i,
			   max_sp_i,
			   ml_pres_i,
			   mm_pres_i,
			   mr_pres_i,
			   tour_in_null_i,
			   zero_tour_i,
			   last_tour_i,
			   mult_tour_i,
			   det_tour_i,
			   disks_free_s,
                           init_possible_s,
                           cap_l_free_s,
                           cap_m_free_s,
                           cap_r_free_s,
                           run_m_allowed_s,
                           run_l_allowed_s,
                           run_r_allowed_s,
                           auto_l_running_s,
                           auto_m_running_s,
                           auto_r_running_s) is
    begin
        -- Default values for generated signal
        next_state_s    <= RST;
        err_o		<= '0';
        incr_sp_o	<= '0';
        decr_sp_o	<= '0';
        init_sp_o	<= '0';
        dir_h_o		<= '0';
        dir_a_o		<= '0';
        dis_ml_o	<= '0';
        en_ml_o		<= '0';
        dis_mm_o	<= '0';
        en_mm_o		<= '0';
        dis_mr_o	<= '0';
        en_mr_o		<= '0';
        init_tour_o	<= '0';
        decr_tour_o	<= '0';
        init_enc_o	<= '0';
        incr_enc_o	<= '0';

        case(current_state_s) is
        --| Init |-------------------------------------------------------------
            when RST =>
            
                next_state_s <= BEFORE_INIT;
        
            when BEFORE_INIT =>
	        dis_ml_o <= '1';
	        dis_mm_o <= '1';
                dis_mr_o <= '1';
                
                if (init_possible_s = '1') then
                    next_state_s <= INIT_SP_DIR;
                else
                    next_state_s <= ERR;
                end if;

            when BEFORE_AUTO =>
	        dis_ml_o <= '1';
	        dis_mm_o <= '1';
	        dis_mr_o <= '1';

	        if (start_i = '1') then
	        
	            if (disks_free_s = '1') then
	            
	                if (tour_in_null_i = '0') then -- can start auto mode
	                    next_state_s <= AUTO_EN_MOT_M; 
	                else 
	                    if (init_possible_s = '1') then -- no turns, go back to init loop
	                        next_state_s <= INIT_SP_DIR;
	                    else -- -- no turns, cannot init, go to error
	                        next_state_s <= ERR;
	                    end if;
	                end if;

		    else -- disks not free, go to before init
		        next_state_s <= BEFORE_INIT; 
		    end if;
		    
	        elsif (init_i = '1') then -- init requested, go to before init
		    next_state_s <= BEFORE_INIT;
	        elsif (mode_i = '0') then -- changed mode, go to manual
		    next_state_s <= MAN_SP_DIR;
	        else -- still in auto, stay in before auto
		    next_state_s <= BEFORE_AUTO;
	        end if;


        --| Init sequence |----------------------------------------------------
            when INIT_SP_DIR =>
                dir_a_o <= '1';
                init_sp_o <= '1';
                
                if (cap_l_i = '1') then
                    next_state_s <= INIT_EN_MOT_L;
                elsif (cap_m_i = '1') then
                    next_state_s <= INIT_EN_MOT_M;
                elsif (cap_r_i = '1') then
                    next_state_s <= INIT_EN_MOT_R;
                elsif (init_i = '0' and mode_i = '0') then -- all motors init done
                    next_state_s <= MAN_SP_DIR;
                else
                    next_state_s <= BEFORE_AUTO;
                end if;
                    
            when INIT_EN_MOT_L =>
                en_ml_o <= '1';
                
                if (cap_l_i = '0') then
                    next_state_s <= INIT_DIS_MOT_L;
                else
                    next_state_s <= INIT_EN_MOT_L;
                end if;
                
            when INIT_DIS_MOT_L =>
                dis_ml_o <= '1';
                
                if (cap_m_i = '1') then
                    next_state_s <= INIT_EN_MOT_M;
                elsif (cap_r_i = '1') then
                    next_state_s <= INIT_EN_MOT_R;
                elsif (init_i = '0' and mode_i = '0') then -- all motors init done
                    next_state_s <= MAN_SP_DIR;
                else
                    next_state_s <= BEFORE_AUTO;
                end if;
                
            when INIT_EN_MOT_M =>
                en_mm_o <= '1';
                
                if (cap_m_i = '0') then
                    next_state_s <= INIT_DIS_MOT_M;
                else
                    next_state_s <= INIT_EN_MOT_M;
                end if;
                
            when INIT_DIS_MOT_M => 
                dis_mm_o <= '1';
                
                if (cap_r_i = '1') then
                    next_state_s <= INIT_EN_MOT_R;
                elsif (init_i = '0' and mode_i = '0') then -- all motors init done
                    next_state_s <= MAN_SP_DIR;
                else
                    next_state_s <= BEFORE_AUTO;
                end if;
                
            when INIT_EN_MOT_R =>
                en_mr_o <= '1';
                
                if (cap_r_i = '0') then -- hole detected
                    next_state_s <= INIT_DIS_MOT_R; 
                else -- disk detected / maintain
                    next_state_s <= INIT_EN_MOT_R; 
                end if;
                
            when INIT_DIS_MOT_R =>
                dis_mr_o <= '1';
                
                if (init_i = '0' and mode_i = '0') then -- all motors init done
                    next_state_s <= MAN_SP_DIR;
                else
                    next_state_s <= BEFORE_AUTO;
                end if;
                

        --| Manual sequence |--------------------------------------------------
            when MAN_SP_DIR =>
                dir_a_o <= '1';
                init_sp_o <= '1';
                
                next_state_s <= MAN_CHK_MODE; -- always go to main decision node for MAN
                
            when MAN_CHK_MODE =>
            
                if (mode_i = '1' or init_i = '1') then -- selected auto mode
                
                    if (init_possible_s = '1') then -- go into init
                        next_state_s <= INIT_SP_DIR;
                    else -- got into error
                        next_state_s <= ERR;
                    end if;	
                    
                elsif (run_l_allowed_s = '1' and
                       run_m_allowed_s = '0' and
                       run_r_allowed_s = '1') then -- left/right
                       
                    next_state_s <= MAN_EN_MOT_LR;
                    
                elsif (run_l_allowed_s = '1' and
                       run_m_allowed_s = '0' and
                       run_r_allowed_s = '0') then -- left
                       
                    next_state_s <= MAN_EN_MOT_L;
                    
                elsif (run_l_allowed_s = '0' and
                       run_m_allowed_s = '1' and
                       run_r_allowed_s = '0') then -- middle
                
                    next_state_s <= MAN_EN_MOT_M;
                    
                elsif (run_l_allowed_s = '0' and
                       run_m_allowed_s = '0' and
                       run_r_allowed_s = '1') then -- right
                
                    next_state_s <= MAN_EN_MOT_R;
                    
                else -- no change of mode and nothing allowed
                    next_state_s <= MAN_DIS_MOT;
                end if;
                    
	    when MAN_EN_MOT_LR =>
	        en_ml_o  <= '1';
	        dis_mm_o <= '1';
	        en_mr_o  <= '1';
	        
	        next_state_s <= MAN_CHK_MODE;
	        
	    when MAN_EN_MOT_L =>
	        en_ml_o  <= '1';
	        dis_mm_o <= '1';
	        dis_mr_o <= '1';
	        
	        next_state_s <= MAN_CHK_MODE;
	        
	    when MAN_EN_MOT_M =>
	        dis_ml_o <= '1';
	        en_mm_o  <= '1';
	        dis_mr_o <= '1';
	        
	        next_state_s <= MAN_CHK_MODE;
	        
	    when MAN_EN_MOT_R =>
	        dis_ml_o <= '1';
	        dis_mm_o <= '1';
	        en_mr_o  <= '1';
	        
	        next_state_s <= MAN_CHK_MODE;
	        
	    when MAN_DIS_MOT =>
	        dis_ml_o <= '1';
	        dis_mm_o <= '1';
	        dis_mr_o <= '1';
	        
	        next_state_s <= MAN_CHK_MODE;

        --| Automatic sequence |-----------------------------------------------
            when AUTO_EN_MOT_M =>
                dir_h_o <= '1';
                init_sp_o <= '1';
                en_mm_o <= '1';
                
                next_state_s <= AUTO_TR_INIT;
                
            when AUTO_TR_INIT =>
                init_tour_o <= '1';
                
                next_state_s <= AUTO_ENC_INIT;
                
            when AUTO_ENC_INIT =>
                init_enc_o <= '1';
                
                next_state_s <= AUTO_WT_DOWN;
                
            when AUTO_WT_DOWN =>
                
                if (disks_free_s = '0') then -- once disks are not free -> left encoche
                    next_state_s <= AUTO_ENC_DOWN;
                else -- wait to leave current encoche
                    next_state_s <= AUTO_WT_DOWN;
                end if;
                
            when AUTO_ENC_DOWN => 
                
                if (disks_free_s = '1') then -- once disks are free again -> new encoche
                    next_state_s <= AUTO_ENC_UP;
                else -- wait to detect new encoche
                    next_state_s <= AUTO_ENC_DOWN;
                end if;
                
            when AUTO_ENC_UP => -- necessary to give one clock to update enc
                incr_enc_o <= '1';
            
                next_state_s <= AUTO_CHK_TOUR;
                
            when AUTO_CHK_TOUR =>
                
                if (det_tour_i = '1') then -- -- check if we finished a tour
                    next_state_s <= AUTO_DECR_TR; 
                elsif (mult_tour_i = '1' and max_sp_i = '0') then -- increase speed
                    next_state_s <= AUTO_INCR_SP;
                elsif (mult_tour_i = '0' and min_sp_i = '0') then -- decrease speed
                    next_state_s <= AUTO_DECR_SP;
                else
                    next_state_s <= AUTO_WT_DOWN;
                end if;
                
            when AUTO_INCR_SP =>
                incr_sp_o <= '1';
                
                next_state_s <= AUTO_WT_DOWN;
                
            when AUTO_DECR_SP =>
                decr_sp_o <= '1';
                
                next_state_s <= AUTO_WT_DOWN;
                
            when AUTO_DECR_TR =>
                decr_tour_o <= '1';
                
                next_state_s <= AUTO_CHK_END;
                
            when AUTO_CHK_END =>
            
                if (zero_tour_i = '1') then
                    if (disks_free_s = '1' and auto_m_running_s = '1') then
                        next_state_s <= AUTO_EN_MOT_L;
                    elsif (disks_free_s = '1' and auto_l_running_s = '1') then 
                        next_state_s <= AUTO_EN_MOT_R;
                    elsif (disks_free_s = '1' and auto_r_running_s = '1') then 
                        next_state_s <= AUTO_DIS_MOT_R;
                    else
                        next_state_s <= ERR;
                    end if;
                else
                    next_state_s <= AUTO_ENC_INIT;
                end if;
                
            when AUTO_EN_MOT_L =>
                dis_mm_o <= '1';
                dir_a_o <= '1';
                en_ml_o <= '1';
                
                next_state_s <= AUTO_TR_INIT;
                
            when AUTO_EN_MOT_R =>
                dis_ml_o <= '1';
                dir_h_o <= '1';
                en_mr_o <= '1';
                
                next_state_s <= AUTO_TR_INIT;
                
            when AUTO_DIS_MOT_R =>
                dis_mr_o <= '1';
                
                if (init_possible_s = '1') then
                    next_state_s <= INIT_SP_DIR;
                else
                    next_state_s <= ERR;
                end if;

        --| Error |-----------------------------------------------------------
            when ERR =>
                dis_ml_o <= '1';
                dis_mm_o <= '1';
                dis_mr_o <= '1';
                err_o <= '1';
                
                if (init_i = '1' and init_possible_s = '1') then
                    next_state_s <= INIT_SP_DIR;
                else
                    next_state_s <= ERR;
                end if;

        --| For others state |-------------------------------------------------
            when others =>
                -- others signals at default value
                next_state_s <= RST;
		err_o		<= '0';
		incr_sp_o	<= '0';
		decr_sp_o	<= '0';
		init_sp_o	<= '0';
		dir_h_o		<= '0';
		dir_a_o		<= '0';
		dis_ml_o	<= '0';
		en_ml_o		<= '0';
		dis_mm_o	<= '0';
		en_mm_o		<= '0';
		dis_mr_o	<= '0';
		en_mr_o		<= '0';
		init_tour_o	<= '0';
		decr_tour_o	<= '0';
		init_enc_o	<= '0';
		incr_enc_o	<= '0';

        end case;
    end process dec_fut_sort;

    --| Outputs affectation |--------------------------------------------------



end fsm;
