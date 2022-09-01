library IEEE;
use IEEE.std_logic_1164.all;

entity UARTunit is
  port (
    clk, reset : in  std_logic;
    cs, rd, wr : in  std_logic;
    RxD        : in  std_logic;
    TxD        : out std_logic;
    IntR, IntT : out std_logic;         
    addr       : in  std_logic_vector(1 downto 0);
    data_in    : in  std_logic_vector(7 downto 0);
    data_out   : out std_logic_vector(7 downto 0));
end UARTunit;


architecture UARTunit_arch of UARTunit is

  -- a completer avec l'interface des differents composants
  -- de l'UART
	component clkUnit 
		port (
			clk, reset : in  std_logic;
			enableTX   : out std_logic;
			enableRX   : out std_logic);
		end component;
		
	component TxUnit
		port (
			clk, reset : in std_logic;
			enable : in std_logic;
			ld : in std_logic;
			txd : out std_logic;
			regE : out std_logic;
			bufE : out std_logic; --'0' = occupe
			data : in std_logic_vector(7 downto 0));
		end component;
		
	component ctrlUnit 
		port (
			 clk, reset       : in  std_logic;
			 rd, cs           : in  std_logic;
			 DRdy, FErr, OErr : in  std_logic;
			 BufE, RegE       : in  std_logic;
			 IntR             : out std_logic;
			 IntT             : out std_logic;
			 ctrlReg          : out std_logic_vector(7 downto 0));
		end component;
			
	component RxUnit is
		port (
			 clk, reset       : in  std_logic;
			 enable           : in  std_logic;
			 read             : in  std_logic;
			 rxd              : in  std_logic;
			 data             : out std_logic_vector(7 downto 0);
			 Ferr, OErr, DRdy : out std_logic);
		end component;
	
	
  signal lecture, ecriture : std_logic;
  signal donnees_recues : std_logic_vector(7 downto 0);
  signal registre_controle : std_logic_vector(7 downto 0);

  -- a completer par les signaux internes manquants
	signal enableRXint : std_logic;
	signal enableTXint : std_logic;
	signal Ferrint : std_logic;
	signal OErrint : std_logic;
	signal DRdyint : std_logic;
	signal BufEint : std_logic;
	signal RegEint : std_logic;
	
  begin  -- UARTunit_arch

    lecture <= '1' when cs = '0' and rd = '0' else '0';
    ecriture <= '1' when cs = '0' and wr = '0' else '0';
    data_out <= donnees_recues when lecture = '1' and addr = "00"
                else registre_controle when lecture = '1' and addr = "01"
                else "00000000";
  
    -- a completer par la connexion des differents composants
	clkUnit0 : clkUnit 
	port map (clk, reset, enableTXint, enableRXint);
	
	TxUnit0 : TxUnit
	port map (clk, reset, enableTXint, ecriture ,TxD,
		RegEint,BufEint,data_in);
		
	RxUnit0 : RxUnit
	port map (clk, reset, enableRXint, lecture, RxD, 
		donnees_recues, Ferrint, OErrint, DRdyint);
	
	ctrlUnit0 : ctrlUnit 
	port map (clk, reset, rd, cs,DRdyint,
		Ferrint, OErrint, BufEint, RegEint, 
		IntR, IntT, registre_controle);
			
  end UARTunit_arch;
