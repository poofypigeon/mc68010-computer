--< PLRU_POLICY_TB >----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library user_library;
use user_library.one_hot.all;
--+---------------------------------------------------------------------------------------------
--|
--+---------------------------------------------------------------------------------------------
entity plru_policy_tb is

end plru_policy_tb;

architecture plru_policy_tb_arch of plru_policy_tb is
    constant period : time := 20 ns;

    signal clk : std_ulogic := '0';

    signal toggle_in        : std_ulogic_vector(0 to 15);
    signal block_to_replace : one_hot(0 to 15);

begin
    UUT : entity work.plru_policy
        generic map (height => 4)
        port map (
            clk => clk,

            toggle_in   => toggle_in,
            block_to_replace => block_to_replace
        );

    clk <= not clk after period / 2;

    process
        type stimulus is record 
            toggle_bit      : integer;
            resulting_state : integer;
        end record stimulus;

        type stimulus_file_type is file of integer;
        file stimulus_file : stimulus_file_type 
            open read_mode is "test/stimulus/plru.stim";

        variable i             : integer;
        variable temp_stimulus : stimulus;
    begin
        -- initialize to state of 0
        wait for 1 ns;
        assert to_integer(block_to_replace) = 0
        report "FAILED: initialize to state of 0, got: " & integer'image(to_integer(block_to_replace)) severity error;

        i := 0;
        while not endfile(stimulus_file) loop
            read(stimulus_file, temp_stimulus.toggle_bit);
            read(stimulus_file, temp_stimulus.resulting_state);

            toggle_in <= to_one_hot(temp_stimulus.toggle_bit, 16);
            wait until falling_edge(clk);

            assert to_integer(block_to_replace) = temp_stimulus.resulting_state
            report "FAILED: at stim " & integer'image(i) & " with block_to_replace = " 
                 & integer'image(to_integer(block_to_replace))
            severity error;

            -- verbose report
            report integer'image(i) & "; " 
            & integer'image(to_integer(toggle_in)) & "; " 
            & integer'image(to_integer(block_to_replace));

            i := i + 1;
        end loop;

        -- finish test
        wait; 
    end process;
    
end plru_policy_tb_arch;