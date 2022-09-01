library IEEE;
use IEEE.std_logic_1164.all;

entity clkUnit is
  
 port (
   clk, reset : in  std_logic;
   enableTX   : out std_logic;
   enableRX   : out std_logic);
    
end clkUnit;

architecture behavorial of clkUnit is

begin
	enableRX <= clk when (reset ='1') else '0' ;

  div : process (clk, reset)
    variable cpt : integer range 0 to 15 := 0;
  begin
  
	if (reset ='0') then 
		enableTX <= '0';
      cpt := 0;
			
   elsif rising_edge(clk) then
	   if(cpt = 15) then
        cpt := 0;
      else
        cpt := cpt + 1;
      end if;
		
      if cpt = 0 then
        enableTX <= '1';
      else
        enableTX <= '0';
      end if;

	end if;
  end process;

end behavorial;
