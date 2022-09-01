library IEEE;
use IEEE.std_logic_1164.all;

entity RxUnit is
    port (
      clk, reset                : in  std_logic;
      enable                    : in std_logic; 
      read                      : in std_logic;        
      rxd                       : in std_logic;         
      data                      : out  std_logic_vector(7 downto 0);
      FErr, OErr, DRdy          : out std_logic );
end RxUnit;

architecture arch_RxUnit of RxUNit is

    component compteur16
        port (
            reset         : in  std_logic;
            enable        : in std_logic;         
            rxd           : in std_logic;         
            tmpclk        : out  std_logic;
            tmprxd        : out std_logic);
        end component;


    -- etats
    type t_etats is (repos, data_out, parite, stop, transmission, check_read);
    -- signaux
    signal etat : t_etats;
    signal tmpclk_int : std_logic;
    signal tmprxd_int : std_logic;
    signal verif_parite : std_logic;
    signal cpt_data : natural; --pour bien envoyer les 8 bits de données
    signal data_int : std_logic_vector(7 downto 0);
    
begin
    --instantiation du composant compteur16
    compteur16int : compteur16
    port map(reset, enable, rxd, tmpclk_int, tmprxd_int);

    process (clk,reset)
    begin
        if (reset = '0') then

            --on initialise les ports
            data <= (others => '0');
            FErr <= '0';
            OErr <= '0';
            DRdy <= '0';

            --on initialise les signaux internes
            verif_parite <= '0';
            cpt_data <= 7;
            data_int <= (others => '0');
            etat <= repos;


        elsif (rising_edge(clk)) then
            case etat is 
                --repos: on remet à valeur les variables et on attend le bit de start (0) 
                when repos =>
                    --on remet à 0 les différentes valeurs
                    FErr <= '0';
                    DRdy <= '0';
                    OErr <= '0';
                    data_int <= (others => '0');
                    --on attend bit de parite (0) et la prochaine montée de tmpclk
                    if (tmprxd_int = '0' and tmpclk_int = '1') then
                    -- bit de start detecté
                        etat <= data_out;
                    end if;
                     
                --data_out: on récupère les 8 bits de données à chaque monté de tmpclk_int
                --et on recrée un bit de parite pour faire une comparaison
                when data_out => 
                    if (tmpclk_int = '1') then --on attend la montée de tmpclk
                        if (cpt_data = 0) then --dernier bit à envoyer
                            cpt_data <= 7;
                            data_int(cpt_data) <= tmprxd_int;
                            verif_parite <= verif_parite xor data_int(cpt_data);
                            etat <= parite;
                        else
                            data_int(cpt_data) <= tmprxd_int;
                            verif_parite <= verif_parite xor data_int(cpt_data);            
                            cpt_data <= cpt_data - 1;
                        end if;
                    end if;

                --Parite: on vérifie que le bit de verif_parite est bon (=tmprxd)
                when parite =>
                    if (tmpclk_int = '1') then
                        if (tmprxd_int = verif_parite) then --pas erreur du bit de parite
                            etat <= stop;
                        else 
                            FErr <= '1';
                            etat <= repos;
                        end if;
                    end if;
                    
                    

                --stop: on récupère le bit de stop, si il vaut 0, on met FErr à 1 et on retourne à l'état repos
                --sinon, on peut transmettre. 
                when stop =>
                    verif_parite <= '0';
                    if (tmpclk_int = '1') then
                        if (tmprxd_int = '0') then --erreur du bit de stop 
                            FErr <= '1';
                            etat <= repos;
                        else
                            etat <= transmission;
                        end if;
                    end if;

                --transmission: on remplit le vecteur data et on met DRdy à 1
                when transmission =>
                    if (tmpclk_int = '1') then
                        DRdy <= '1';
                        data <= data_int;
                        etat <= check_read;
                    end if;

                --check_read: on vérifie read = 1, sinon OErr = 1
                when check_read =>
                    DRdy <= '0';
                    if (read = '0') then 
                        OErr <= '1'; --erreur de transmission
                        etat <= repos;
                    else 
                        etat <= repos;
                    end if;
                                    
            end case;

        end if;
    end process;
        
end arch_RxUnit;