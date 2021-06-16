--------------------------------------------------------------------------------
--  T-FLIP-FLOP TESTBENCH
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--------------------------------------------------------------------------------
entity t_flip_flop_tb is

end t_flip_flop_tb;

architecture t_flip_flop_tb_arch of t_flip_flop_tb is
    constant period : time := 20 ns;

    component t_flip_flop 
        generic (
            initial : std_logic
        );

        port (
            clk :  in std_logic;
            t   :  in std_logic;
            q   : out std_logic
        );
    end component;

    signal clk : std_logic := '0'; -- clock begins low
    signal t   : std_logic := '0'; -- t begins low
    signal q   : std_logic;
    
begin
    UUT : t_flip_flop
        generic map (
            initial => '0'
        )
        port map (
            clk => clk,
            t   => t,
            q   => q
        );
        
    -- clock generation
    clk <= not clk after period / 2;

    process
    begin
        -- initialization value test
        wait for 0 ns;
        assert q = '0'
        report "failed: ""initialization value test""" severity error;

        -- retain state on clock when t = '0'
        wait until falling_edge(clk);
        assert q = '0'
        report "failed: ""retain state on clock when t = '0'""" severity error;

        -- set q <= '1' on clk when t = '1' and q = '0'
        t <= '1';
        wait until falling_edge(clk);
        assert q = '1'
        report "failed: ""set q <= '1' on clk when t = '1' and q = '0'""" severity error;

        -- set q <= '0' on clk when t = '1' and q = '1'
        wait until falling_edge(clk);
        assert q = '0'
        report "failed: ""set q <= '0' on clk when t = '1' and q = '1'""" severity error;

        -- finish test
        t <= '0';
        wait;
    end process;
end t_flip_flop_tb_arch;