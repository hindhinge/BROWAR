--Rados³aw Sawicki
--243153
--Linia produkcyjna browaru
--PN 14:15
--02.01.2020r.


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
 
ENTITY BROWAR_test IS
END BROWAR_test;
 
ARCHITECTURE behavior OF BROWAR_test IS 
 
    COMPONENT BROWAR
    PORT(
         CLK : IN  std_logic;
         RESET : IN  std_logic;
         START : IN  std_logic;
         POZIOM_PIWA_H : IN  std_logic;
         POZIOM_PIWA_L : IN  std_logic;
         CZTEROPAKI : out std_logic_vector(3 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal RESET : std_logic := '0';
   signal START : std_logic := '0';
   signal POZIOM_PIWA_H : std_logic := '0';
   signal POZIOM_PIWA_L : std_logic := '0';

	signal CZTEROPAKI : std_logic_vector(3 downto 0);
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: BROWAR PORT MAP (
          CLK => CLK,
          RESET => RESET,
          START => START,
          POZIOM_PIWA_H => POZIOM_PIWA_H,
          POZIOM_PIWA_L => POZIOM_PIWA_L,
          CZTEROPAKI => CZTEROPAKI
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin			
		reset <= '1';
      wait for clk_period * 0.3;	
		reset <= '0';START <= '1';
		wait for clk_period * 2.3;
		POZIOM_PIWA_L <= '1';
		wait for clk_period;
		POZIOM_PIWA_L <= '0';
		wait for clk_period;
		POZIOM_PIWA_H <= '1';
		wait for clk_period * 5;
		START <= '0';
		wait for clk_period * 3;
		START <= '1';
		wait for clk_period * 15;
		POZIOM_PIWA_H <= '0';
		wait for clk_period * 20;
		POZIOM_PIWA_L <= '1';
		wait for clk_period * 30;
		reset <= '1';
      wait for clk_period * 2.3;	
		reset <= '0';START <= '1';
		wait for clk_period * 2.3;
		wait for clk_period * 5;
		POZIOM_PIWA_H <= '1';
		wait for clk_period * 5;


		assert false severity failure;
   end process;

END;