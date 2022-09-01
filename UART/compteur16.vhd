library IEEE;
use IEEE.std_logic_1164.all;

entity compteur16 is
    port (
      reset         : in  std_logic;
      enable        : in std_logic;         
      rxd           : in std_logic;         
      tmpclk        : out  std_logic;
      tmprxd        : out std_logic);

end compteur16;

architecture behavorial of compteur16 is
    -- etats
    type t_etats is (repos, debut_start, debut_compteur);
    -- signaux
    signal etat : t_etats;
    signal cpt_rxd_envoie : natural;
    
begin

    process(reset, enable)

    variable cpt : natural;

    begin

        if (reset = '0') then
            tmpclk <= '0';
            tmprxd <= '1';
            cpt := 7;
            cpt_rxd_envoie <= 11;
            etat <= repos;

        elsif (rising_edge(enable)) then

            case etat is

                when repos =>
                    tmpclk <= '1';
                    if (rxd = '0') then 
                    --bit de start détecté = 0
                        etat <= debut_start;
                    end if;
                    
                when debut_start =>
                    if (cpt = 0) then
                        tmprxd <= rxd;
                        cpt := 15; 
                        -- compter 16 tops de enable autant de fois que possible après les 8
                        etat <= debut_compteur; 
                        --avant d'avoir une trame
                    else 
                        cpt := cpt - 1; 
                        --compter 8 tops de enable
                    end if;

                when debut_compteur => 
                    if (cpt = 0) then
                        if (cpt_rxd_envoie = 0) then
                            cpt_rxd_envoie <= 11;
                            cpt := 7;
                            etat <= repos;
                        else 
                            tmpclk <= '1';
                            tmprxd <= rxd;
                            cpt_rxd_envoie <= cpt_rxd_envoie - 1;
                            cpt := 15;
                        end if;
                    else 
                        tmpclk <= '0'; 
                        cpt := cpt - 1;
                    end if;

                
            end case;
        end if;
    end process;
end behavorial;
                            




