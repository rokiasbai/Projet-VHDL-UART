library IEEE;
use IEEE.std_logic_1164.all;

entity TxUnit is
  port (
    clk, reset : in std_logic;
    enable : in std_logic;
    ld : in std_logic;
    txd : out std_logic;
    regE : out std_logic;
    bufE : out std_logic; --'0' = occupe
    data : in std_logic_vector(7 downto 0));
end TxUnit;

architecture behavorial of TxUnit is
type t_etats is(premier, deuxieme, troisieme, quatrieme, cinquieme, sixieme);
signal etat : t_etats;
signal registreT : std_logic_vector(7 downto 0);--registre de data
signal bufferT : std_logic_vector(7 downto 0);--registre de data
signal parite : std_logic;--bit de parité
signal bufEbis : std_logic;--signal interne permet l'utilisation du buffer dans fonction conditionnelle

--signaux si besoin
begin
process (clk,reset)
--variables si besoin
variable cpt : natural;

begin
	if (reset ='0') then 
		txd <='1';
		regE<='1';
		bufE<='1';
		bufEbis <='1';
		registreT<= (others => '0');
		cpt := 7;
		parite <= '0';
		etat <= premier;
	
	--Si le buffer est vide et qu'on veut load une data à l'étape 3, 4, 5 ou 6 alors on remplit le buffer 
	elsif (rising_edge(clk)) then 
		if ((etat = troisieme or etat =quatrieme or etat =cinquieme or etat =sixieme) and bufEbis ='1' and ld='1') then 
			bufferT <= data;
			bufE <='0';
			bufEbis<='0';
		end if;
		
		case etat is

			--état de repos si ld='0' quand ld='1' on met la data dans le buffer
			when premier => 
				if (ld='1') then 
					bufferT<=data;
					bufEbis<='0';
					bufE <= '0';
					etat <= deuxieme;
				end if;

			--on fait passer la data du buffer au registre et on vide le buffer.
			when deuxieme =>
				registreT<=bufferT;
				regE<='0';
				bufEbis<= '1';
				bufE <= '1';
				etat <= troisieme;

			--on envoie le bit de start et on initialise le compteur à 7
			when troisieme =>
				if (enable ='1') then 
					txd <='0';
					parite <= '0'; --réinitialisation du bit de parite
					cpt := 7;
					etat <= quatrieme;
				end if;

			--On envoie les données au travers de TxD
			when quatrieme =>
				if (enable ='1') then
					--Une fois que toute les données sont envoyées, on vide le registre
					if (cpt=0) then
					    txd<=registreT(cpt);
						parite<= parite xor registreT(cpt);
						regE<='1';
						etat <= cinquieme;
					--On envoie sur TxD bit par bit et on met à jours le bit de parité
					else
						txd<=registreT(cpt);
						parite<= parite xor registreT(cpt);
						cpt:=cpt-1;
					end if;
				end if;

			--Envoie du bit de parite
			when cinquieme =>
				if (enable ='1') then 
					txd <=parite;
					etat <= sixieme;
				end if;
			
			--Envoie du bit de stop et on passe à l'étape 2 si buffer non vide ou étape 1 sinon
			when sixieme =>
				if (enable = '1') then 
					txd <= '1';
					if (bufEbis ='0') then 
						etat <= deuxieme;
					else 
						etat <= premier;
					end if;
				end if;

			end case;
		end if;
	end process;
end behavorial;
