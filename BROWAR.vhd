--Rados³aw Sawicki
--243153
--Linia produkcyjna browaru
--PN 14:15
--02.01.2020r.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity BROWAR is --Deklaracja entity linii produkcyjnej zawieraj¹ce piêæ wejœc oraz jedno wyjœcie
	port( CLK,RESET : in std_logic;
			START : in std_logic;
			POZIOM_PIWA_H : in std_logic;
			POZIOM_PIWA_L : in std_logic;
			CZTEROPAKI : out std_logic_vector(3 downto 0));
end entity BROWAR;

architecture BROWAR_a of BROWAR is

type STANY is (stop,napelnianie,warzenie,kup_butelki,butelkowanie,kapslowanie,kup_kapsle,pakowanie,mycie); --Deklaracja wszystkich stanów wykorzystywanych w automacie oraz wszystkich sygna³ów wewnêtrznych
signal stan,stan_nast: STANY;
signal czyste: std_logic := '0'; --Okreœla czy kadŸ do warzenia jest czysta; 0 = brudna, nie mo¿na warzyæ piwa, 1 = mo¿na warzyæ, zmiana nastêpuje w stanie ,,mycie"
signal czas_warzenia: std_logic_vector(3 downto 0) := "0000"; --Warzenie piwa obywa siê do momentu przyjêcia wartoœci ,,1111" przez ten sygna³
signal butelkie: std_logic_vector(3 downto 0) := "0000"; --butelkiEmpty; iloœæ pustych butelek w magazynie
signal butelkif: std_logic_vector(7 downto 0) := "00000000"; --butelkiFull; iloœæ pe³nych, niezakapslowanych butelek w magazynie
signal butelkic: std_logic_vector(7 downto 0) := "00000000"; --butelkiCapped' iloœæ pe³nych, zakapslowanych butelek w magazynie (gotowe do pakowania)
signal kapsle: std_logic_vector(3 downto 0) := "0000"; --Iloœc kapsli w magazynie
signal czteropaki_wew: std_logic_vector(3 downto 0) := "0000"; --Stan wewnêtrzny opisuj¹cy iloœæ spakowanych czteropaków gotowych do wysy³ki

begin
--CZTEROPAKI <= czteropaki_wew;
reg: process(CLK,RESET) --Proces aktualizuj¹cy aktualny stan maszyny
	begin
	if(RESET = '1') then
		stan <= stop;
	elsif(CLK'Event and CLK ='1') then
		stan <= stan_nast;
	end if;
end process reg;

komb:process(stan,START,POZIOM_PIWA_H,POZIOM_PIWA_L,czas_warzenia,butelkie,butelkif,butelkic,kapsle) --G³ówny proces zarz¹dzaj¹cy przejœciami pomiêdzy stanami
	begin
	stan_nast <= stan;
	case stan is
		when stop =>
			if(START = '0') then 
				stan_nast <= stop;
			elsif(czyste = '1' and START = '1') then
				stan_nast <= napelnianie;
			elsif(czyste = '0' and START = '1') then
				stan_nast <= mycie;
			end if;
			
		when mycie =>
			if(START = '0') then 
				stan_nast <= stop;
			elsif(czyste = '1' and START = '1') then
				stan_nast <= napelnianie;
			elsif (czyste = '0' and START = '1') then
				czyste <= '1';
				stan_nast <= napelnianie;
			elsif (czyste = '1' and START = '0') then
				stan_nast <= stop;
			else
				stan_nast <= stop;
			end if;
			
		when napelnianie =>
			if(START = '0') then 
				stan_nast <= stop;
			elsif(POZIOM_PIWA_H = '1') then
				stan_nast <= warzenie;
			else
				stan_nast <= napelnianie;
			end if;
		
		when warzenie =>
			if(START = '0') then 
				stan_nast <= stop;
			elsif(czas_warzenia < "1111") then
				stan_nast <= warzenie;
			elsif (czas_warzenia = "1111" and poziom_piwa_L = '0' and butelkie > "0000") then
				czyste <= '0';
				stan_nast <= butelkowanie;
			elsif (czas_warzenia = "1111" and poziom_piwa_L = '0' and butelkie = "0000") then
				czyste <= '0';
				stan_nast  <= kup_butelki;
			else
				stan_nast <= stop;
			end if;
		
		when kup_butelki =>
			if(START = '0') then 
				stan_nast <= stop;
			elsif(butelkie = "0000") then
				stan_nast <= kup_butelki;
			elsif(butelkie = "1111" and POZIOM_PIWA_L = '0') then
				stan_nast  <= butelkowanie;
			else 
				stan_nast  <= stop;
			end if;
		
		when butelkowanie =>
			if(START = '0') then 
				stan_nast <= stop;
			elsif(butelkie > "0000" and poziom_piwa_L = '0') then
				stan_nast <= butelkowanie;
			elsif(butelkie = "0000" and poziom_piwa_L ='0') then
				stan_nast <= kup_butelki;
			elsif(poziom_piwa_L ='1' and kapsle > "0000") then
				stan_nast <= kapslowanie;
			elsif(poziom_piwa_L ='1' and kapsle = "0000") then
				stan_nast <= kup_kapsle;
			else
				stan_nast <= stop;
			end if;
			
		when kup_kapsle =>
			if(START = '0') then 
				stan_nast <= stop;
			elsif(kapsle > "0000" and poziom_piwa_L = '1') then
				stan_nast <= kapslowanie;
			elsif(kapsle = "0000") then
				stan_nast <= kup_kapsle;
			else
				stan_nast <= stop;
			end if;
		
		when kapslowanie => 
			if(START = '0') then 
				stan_nast <= stop;
			elsif(kapsle = "0000" and poziom_piwa_L = '1') then
				stan_nast <= kup_kapsle;
			elsif(butelkif > "00000000" and kapsle > "0000") then
				stan_nast <= kapslowanie;
			elsif(butelkif = "00000000") then
				stan_nast <= pakowanie;
			else
				stan_nast <= stop;
			end if;
		
		when pakowanie =>
			if(START = '0') then 
				stan_nast <= stop;
			elsif(butelkic >= "00000100") then
				stan_nast <= pakowanie;
			elsif(butelkic < "00000100") then
				stan_nast <= mycie;
			else 
				stan_nast <= stop;
			end if;
		
		
		when others =>
			stan_nast <= stop;
	end case;
end process komb;

licznik:process(CLK,RESET) --Proces odpowiedzialny za obliczanie wartoœci stanów wewnêtrznych
	begin
	if (RESET ='1') then
		czteropaki_wew <= "0000";
		czas_warzenia <= "0000";
		butelkie <= "0000";
		butelkif <= "00000000";
		butelkic <= "00000000";
		kapsle <= "0000";
		czas_warzenia <= "0000";
	elsif (CLK'event and CLK = '1') then
		if(stan = warzenie AND czas_warzenia < "1111") then
			czas_warzenia <= czas_warzenia + "01";
		elsif(stan = kup_butelki AND butelkie = "0000") then
			butelkie <= "1111";
		elsif(stan = butelkowanie AND butelkie > "0000") then
			butelkie <= butelkie - 1;
			butelkif <= butelkif + 1;
		elsif(stan = kup_kapsle AND kapsle = "0000") then
			kapsle <= "1111";
		elsif(stan = kapslowanie AND butelkif > "00000000") then
			butelkif <= butelkif - 1;
			butelkic <= butelkic + 1;
		elsif(stan = pakowanie AND butelkic >= "00000100") then
			butelkic <= butelkic - "100";
			czteropaki_wew <= czteropaki_wew + "01";
			--CZTEROPAKI <= czteropaki_wew; 
		elsif(stan = mycie) then
			czas_warzenia <= "0000";
		end if;
	end if;
end process licznik;
CZTEROPAKI <= czteropaki_wew;       

end architecture BROWAR_a;