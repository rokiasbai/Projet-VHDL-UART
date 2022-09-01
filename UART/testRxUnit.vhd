LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY testRxUnit IS
END testRxUnit;
 
ARCHITECTURE behavior OF testRxUnit IS 

COMPONENT RxUnit
    PORT (
      clk, reset                : in  std_logic;
      enable                    : in std_logic; 
      read                      : in std_logic;        
      rxd                       : in std_logic;         
      data                      : out  std_logic_vector(7 downto 0);
      FErr, OErr, DRdy          : out std_logic);
end COMPONENT;

COMPONENT clkUnit
	PORT(
		clk, reset : in  std_logic;
   enableTX   : out std_logic;
   enableRX   : out std_logic
		);
	END COMPONENT; 

signal clk : std_logic := '0';
signal reset : std_logic := '0';
signal read : std_logic := '0';
signal rxd : std_logic := '0';
signal data : std_logic_vector(7 downto 0) := (others => '0');
signal FErr : std_logic;
signal OErr : std_logic;
signal DRdy : std_logic;

signal lettre : std_logic_vector(7 downto 0) := (others => '0');

signal enableTX : std_logic;
signal enableRX : std_logic;


-- Clock period definitions
constant clk_period : time := 10 ns;


BEGIN

    RxUnit0: RxUnit PORT MAP (
        clk => clk,
        reset => reset,            
        enable => enableRX,
        read => read,       
        rxd => rxd,       
        data => data,
        FErr => FErr, 
        OErr => OErr, 
        DRdy => DRdy
    );

    clkUnit0: clkUnit PORT MAP(
      clk => clk,
      reset => reset,
      enableTX => enableTX,
      enableRX => enableRX
	  );

    -- Clock process definitions
   clk_process :process
   begin
     clk <= '0';
     wait for clk_period/2;
     clk <= '1';
     wait for clk_period/2;
   end process;


    -- Stimulus process
   stim_proc: process
   begin

    -- initialisation
    wait for 100 ns;
    rxd <= '1';
    read <= '0';
    reset <= '1';

    ---------Premier test, tout est bon
     --bit de start
		wait until enableTX = '1';
		rxd <= '0';
		wait until enableTX = '0';

    --lettre
    lettre <= "10000001";
    for i in 7 downto 0 loop
      wait until enableTX = '1';
      rxd <= lettre(i);
      wait until enableTX = '0';
    end loop;

    --bit de parite
		wait until enableTX = '1';
		rxd <= '0';
		wait until enableTX = '0';

    -- bit de stop (et read)
		wait until enableTX = '1';
		rxd <= '1';
    read <= '1';
		wait until enableTX = '0';



---------deuxième test, read vaut 0
    wait for clk_period*50;
    read <= '1';


     --bit de start
		wait until enableTX = '1';

		rxd <= '0';
		wait until enableTX = '0';

    --lettre
    lettre <= "11100101";
    for i in 7 downto 0 loop
      wait until enableTX = '1';
      rxd <= lettre(i);
      wait until enableTX = '0';
    end loop;

    --bit de parite
		wait until enableTX = '1';
		rxd <= '0';
		wait until enableTX = '0';

    -- bit de stop 
		wait until enableTX = '1';
		rxd <= '1';
    read <= '0';
		wait until enableTX = '0';

---------troisième test test, parite faux

    wait for clk_period*50;


     --bit de start
		wait until enableTX = '1';
		rxd <= '0';
		wait until enableTX = '0';

    --lettre
    lettre <= "11100101";
    for i in 7 downto 0 loop
      wait until enableTX = '1';
      rxd <= lettre(i);
      wait until enableTX = '0';
    end loop;

    --bit de parite faux
		wait until enableTX = '1';
		rxd <= '1';
		wait until enableTX = '0';

    -- bit de stop --on pourrait l'enlever
		wait until enableTX = '1';
		rxd <= '1';
		wait until enableTX = '0';

    ---------quatrième test test,stop faux

    wait for clk_period*50;


     --bit de start
		wait until enableTX = '1';
		rxd <= '0';
		wait until enableTX = '0';

    --lettre
    lettre <= "11100101";
    for i in 7 downto 0 loop
      wait until enableTX = '1';
      rxd <= lettre(i);
      wait until enableTX = '0';
    end loop;

    --bit de parite 
		wait until enableTX = '1';
		rxd <= '0';
		wait until enableTX = '0';

    -- bit de stop --on pourrait l'enlever
		wait until enableTX = '1';
		rxd <= '0';
		wait until enableTX = '0';

    wait;

     end process;
    
END;

     
     




