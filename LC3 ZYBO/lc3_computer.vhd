-- This is the component that you'll need to fill in in order to create the LC3 computer.
-- It is FPGA independent. It can be used without any changes between the Zybo and the 
-- Nexys3 boards.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lc3_computer is
   port (
		--System clock
      clk              : in  std_logic; 

      --Virtual I/O
      led              : out std_logic_vector(7 downto 0);
      btn              : in  std_logic_vector(4 downto 0);
      sw               : in  std_logic_vector(7 downto 0);
      hex              : out std_logic_vector(15 downto 0); --16 bit hexadecimal value (shown on 7-seg sisplay)

		--Physical I/0 (IO on the Zybo FPGA)
		pbtn				  : in  std_logic_vector(3 downto 0);
		psw				  : in  std_logic_vector(3 downto 0);
		pled				  : out  std_logic_vector(2 downto 0);

		--VIO serial
	  rx_data          : in  std_logic_vector(7 downto 0);
      rx_rd            : out std_logic;
      rx_empty         : in  std_logic;
      tx_data          : out std_logic_vector(7 downto 0);
      tx_wr            : out std_logic;
      tx_full          : in  std_logic;
      
      --Serial BlueTooth
      rx_arduino       : in std_logic;
      tx_arduino       : out std_logic;
       
	  --UniCounter
	  --syn_clr, load, up  : in std_logic;
	 -- d                  : in std_logic_vector(N-1 downto 0);
	 -- max_tick, min_tick : out std_logic;
     -- q                  : out std_logic_vector(N-1 downto 0)
	

		
		sink             : out std_logic;

      --Debug
      address_dbg      : out std_logic_vector(15 downto 0);
      data_dbg         : out std_logic_vector(15 downto 0);
      RE_dbg           : out std_logic;
      WE_dbg           : out std_logic;
		
		--LC3 CPU inputs
      cpu_clk_enable   : in  std_logic;
      sys_reset        : in  std_logic;
      sys_program      : in  std_logic
   );
end lc3_computer;

architecture Behavioral of lc3_computer is
   ---<<<<<<<<<<<<<<>>>>>>>>>>>>>>>---
   ---<<<<< Pregenerated code >>>>>---
   ---<<<<<<<<<<<<<<>>>>>>>>>>>>>>>---

	--Making	sure	that	our	output	signals	are	not	merged/removed	during	
	-- synthesis. We	achieve	this	by	setting	the keep	attribute for	all	our	outputs
	-- It's good to uncomment the following attributs if you get some errors with multiple 
	-- drivers for a signal.
--	attribute	keep:string;
--	attribute	keep	of	led			: signal	is	"true";
--	attribute	keep	of	pled			: signal	is	"true";
--	attribute	keep	of	hex			: signal	is	"true";
--	attribute	keep	of	rx_rd			: signal	is	"true";
--	attribute	keep	of	tx_data		: signal	is	"true";
--	attribute	keep	of	tx_wr			: signal	is	"true";
--	attribute	keep	of	address_dbg	: signal	is	"true";
--	attribute	keep	of	data_dbg		: signal	is	"true";
--	attribute	keep	of	RE_dbg		: signal	is	"true";
--	attribute	keep	of	WE_dbg		: signal	is	"true";
--	attribute	keep	of	sink			: signal	is	"true";

   --Creating user friently names for the buttons
   alias btn_u : std_logic is btn(0); --Button UP
   alias btn_l : std_logic is btn(1); --Button LEFT
   alias btn_d : std_logic is btn(2); --Button DOWN
   alias btn_r : std_logic is btn(3); --Button RIGHT
   alias btn_s : std_logic is btn(4); --Button SELECT (center button)
   alias btn_c : std_logic is btn(4); --Button CENTER
   
   signal sink_sw : std_logic;
   signal sink_psw : std_logic;
   signal sink_btn : std_logic;
   signal sink_pbtn : std_logic;
    signal sink_uart : std_logic;
   
	-- Memory interface signals
	signal address: std_logic_vector(15 downto 0);
	signal data, data_in, data_out: std_logic_vector(15 downto 0); -- data inputs
	signal RE, WE:  std_logic;

	-- I/O constants for addr from 0xFE00 to 0xFFFF:
   constant STDIN_S    : std_logic_vector(15 downto 0) := X"FE00";  -- Serial IN (terminal keyboard)
   constant STDIN_D    : std_logic_vector(15 downto 0) := X"FE02";
   constant STDOUT_S   : std_logic_vector(15 downto 0) := X"FE04";  -- Serial OUT (terminal  display)
   constant STDOUT_D   : std_logic_vector(15 downto 0) := X"FE06";
   constant IO_SW      : std_logic_vector(15 downto 0) := X"FE0A";  -- Switches
   constant IO_PSW     : std_logic_vector(15 downto 0) := X"FE0B";  -- Physical Switches	
   constant IO_BTN     : std_logic_vector(15 downto 0) := X"FE0e";  -- Buttons
   constant IO_PBTN    : std_logic_vector(15 downto 0) := X"FE0F";  -- Physical Buttons	
   constant IO_SSEG    : std_logic_vector(15 downto 0) := X"FE12";  -- 7 segment
   constant IO_LED     : std_logic_vector(15 downto 0) := X"FE16";  -- Leds
   constant IO_PLED    : std_logic_vector(15 downto 0) := X"FE17";  -- Physical Leds
	
	constant UART_IN_S  : std_logic_vector(15 downto 0) := X"FE18"; -- Serial IN (UART)
	constant UART_IN_D  : std_logic_vector(15 downto 0) := X"FE19"; 
	constant UART_OUT_S : std_logic_vector(15 downto 0) := X"FE1A"; -- Serial OUT (UART)
	constant UART_OUT_D : std_logic_vector(15 downto 0) := X"FE1B";
	constant ms_address : std_logic_vector(15 downto 0) := X"FE1C"; --milliseconds addresse
	
	
	
   
	---<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>---
   ---<<<<< End of pregenerated code >>>>>---
   ---<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>---
	signal mux: std_logic_vector(15 downto 0);
	signal m_out: std_logic_vector(15 downto 0);
	signal led_in, led_out: std_logic_vector(15 downto 0);
	signal hex_in, hex_out: std_logic_vector(15 downto 0);
	signal pled_in, pled_out: std_logic_vector(15 downto 0);
	
	signal en_led: std_logic;
	signal en_pled: std_logic;
	signal en_hex: std_logic;
	signal en_counter: std_logic;
	
	signal rd_uart, wr_uart: std_logic;
    signal w_data: std_logic_vector(7 downto 0);
    signal tx_full_uart, rx_empty_uart: std_logic;
    signal r_data: std_logic_vector(7 downto 0);
    
    signal max_tick: std_logic;
    signal q       : std_logic_vector(15 downto 0);
    signal milli_counter: std_logic_vector(15 downto 0);
    signal internal_tick: std_logic;
        
    signal mem_en: std_logic;
	
begin
  ---<<<<<<<<<<<<<<>>>>>>>>>>>>>>>---
   ---<<<<< Pregenerated code >>>>>---
   ---<<<<<<<<<<<<<<>>>>>>>>>>>>>>>--- 
   
   --In order to avoid warnings or errors all outputs should be assigned a value. 
   --The VHDL lines below assign a value to each otput signal. An otput signal can have
   --only one driver, so each otput signal that you plan to use in your own VHDL code
   --should be commented out in the lines below 

   
   --Virtual Leds on Zybo VIO (active high)
--   led(0) <= '0';
--   led(1) <= '0';
--   led(2) <= '0'; 
--   led(3) <= '0'; 
--   led(4) <= '0'; 
--   led(5) <= '0'; 
--   led(6) <= '0'; 
--   led(7) <= '0'; 

   --Physical leds on the Zybo board (active high)
--   pled(0) <= '0';
--   pled(1) <= '0';
--   pled(2) <= '0';

   --Virtual hexadecimal display on Zybo VIO
--   hex <= X"1234"; 

	--Virtual I/O UART
	--rx_rd <= '0';
	--tx_wr <= '0';
	--tx_data <= X"00";
	
	--Input data for the LC3 CPU
	--data_in <= X"0000";

   --All the input signals comming to the FPGA should be used at least once otherwise we get 
   --synthesis warnings. The following lines of VHDL code are meant to remove those warnings. 
   --Sink is just an output signal that that has the only purpose to allow all the inputs to 
   --be used at least once, by orring them and assigning the resulting the value to sink.
   --You are not suppoosed to modify the following lines of VHDL code, where inputs are orred and
   --assigned to the sink. 
   sink_psw <= psw(0) or psw(1) or psw(2) or psw(3);
   sink_pbtn <= pbtn(0) or pbtn(1) or pbtn(2) or pbtn(3);
   sink_sw <= sw(0) or sw(1) or sw(2) or sw(3) or sw(4) or sw(5) or sw(6) or sw(7); 
   sink_btn <= btn(0) or btn(1) or btn(2) or btn(3) or btn(4);
	sink_uart <= rx_data(0) or rx_data(1) or rx_data(2) or rx_data(3) or rx_data(4) or 
					 rx_data(5) or rx_data(6) or rx_data(7)or rx_empty or tx_full; 
   sink <= sink_sw or sink_psw or sink_btn or sink_pbtn or sink_uart;

   ---<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>---
   ---<<<<< End of pregenerated code >>>>>---
   ---<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>---
	
	--You'll have to decide which type of data bus you need to use for the
	--  LC3 processor. Here are the options:
	-- 1. Bidirectional data bus (to which you write using tristates).
	-- 2. Two unidirctional busses data_in and data_out where you use
	--    multiplexors to dicide where the data for data_in is comming for.
	--The VHDL code that instantiate either one of these options for the LC3
	--  processor are provided below. Just uncomment the one you prefer
	
	-- <<< LC3 CPU using multiplexers for the data bus>>>	
	lc3_m: entity work.lc3_wrapper_multiplexers
	port map (
		 clk        => clk,
		 clk_enable => cpu_clk_enable,
		 reset      => sys_reset,
		 program    => sys_program,
		 addr       => address,
		 data_in    => data_in,
		 data_out   => data_out,
		 WE         => WE,
		 RE         => RE 
		 );
   data_dbg <= data_in when RE='1' else data_out;
   
   
   reg_led: entity work.reg_reset
   port map (
        en => en_led,
        clk => clk,
        reset => sys_reset,
        d => led_in,
        q => led_out
        );
   
   reg_hex: entity work.reg_reset 
   port map (
        en => en_hex,
        clk => clk,
        reset => sys_reset,
        d => hex_in,
        q => hex_out
        );
        
   reg_pled: entity work.reg_reset 
   port map (
        en => en_pled,
        clk => clk,
        reset => sys_reset,
        d => pled_in,
        q => pled_out
        );
	-- <<< LC3 CPU using multiplexers end of instantiation>>>	
	
		 
--	-- <<< LC3 CPU using tristates for the data bus>>>
--	lc3_t: entity work.lc3_wrapper_tristates
--	port map (
--		 clk        => clk,
--		 clk_enable => cpu_clk_enable,
--		 reset      => sys_reset,
--		 program    => sys_program,
--		 addr       => address,
--		 data       => data,
--		 WE         => WE,
--		 RE         => RE 
--		 );
--   data_dbg <= data;
--	-- <<< LC3 CPU using tristates end of instantiation>>>
	
	--Information that is sent to the debugging module
   address_dbg <= address;
   RE_dbg <= RE;
   WE_dbg <= WE;
   
	-------------------------------------------------------------------------------
	-- <<< Write your VHDL code starting from here >>>
	-------------------------------------------------------------------------------

uart: entity work.uart
    port map (
        clk => clk,
        reset => sys_reset,
        rd_uart => rd_uart,
        wr_uart => wr_uart,
        rx => rx_arduino,
        w_data => w_data, 
        tx_full => tx_full_uart, 
        rx_empty => rx_empty_uart,
        r_data => r_data,
        tx => tx_arduino  
        );

lc3_memory: entity work.memory
    port map (
        clk => clk,
        addr => address,
        dout => m_out,
        din => data_out,
        WE => WE,
        re => RE,
        mem_en => mem_en
        );
        
tic_counter: entity work.mod_m_counter
   generic map(
      N => 16,
      M => 50000
  )
  
   port map(
      clk => clk,
      en => '1',
      reset => sys_reset,
      max_tick => max_tick,
      q => q
      );
 
ms_counter: entity work.mod_m_counter
     generic map(
        N => 16,
        M => 60000
    )
    
     port map(
        clk => clk,
        en => max_tick,
        reset => sys_reset,
        max_tick => internal_tick,
        q => milli_counter
        );
      
addr_ctl_logic : process(address)
begin
en_led <= '0';
en_hex <= '0';
en_pled <= '0';
rx_rd <= '0';
tx_wr <= '0';
rd_uart <= '0';
wr_uart <= '0';
mem_en <= '0';


case address is
    when IO_SW =>
        if (RE = '1') then
            mux <= IO_SW;
        end if;
    when IO_PSW =>
        if (RE = '1') then
            mux <= IO_PSW;
        end if;
    when IO_BTN =>
        if (RE = '1') then
            mux <= IO_BTN;
        end if;
    when IO_PBTN =>
        if (RE = '1') then
            mux <= IO_PBTN;
        end if;
    when IO_SSEG =>
        if (WE = '1') then
            en_hex <= '1';
            mux <= IO_SSEG;
        end if;
    when IO_LED =>
        if (WE = '1') then
            en_led <= '1';
            mux <= IO_LED;
        end if;
    when IO_PLED =>
        if (WE = '1') then
            en_hex <= '1';
            mux <= IO_PLED;
        end if;
    when STDIN_S =>
         mux <= STDIN_S;
    when STDIN_D =>
        if (RE = '1') then
             
             rx_rd <= '1';
         end if;
         mux <= STDIN_D;
    when STDOUT_S =>
         mux <= STDOUT_S;
    when STDOUT_D =>
         mux <= STDOUT_D;
         tx_wr <= '1'; 
    
     when UART_IN_S  =>
          mux <= UART_IN_S ;
     when UART_IN_D  =>
         if (RE = '1') then
              rd_uart <= '1';
          end if;
          mux <= UART_IN_D ;
     when UART_OUT_S  =>
          mux <= UART_OUT_S;
     when UART_OUT_D =>
          mux <= UART_OUT_D;
          wr_uart <= '1';  
    when ms_address =>      
        mux <= ms_address;
    when others =>
         mem_en <= '1';
         mux <= X"0000";
             
end case;
    
end process;

dataINmux: process(mux)
begin 
    case mux is 
        when IO_SW => data_in <= std_logic_vector(resize(unsigned(sw), data_in'length)); 
        when IO_PSW => data_in <= std_logic_vector(resize(unsigned(psw), data_in'length)); 
        when IO_BTN => data_in <= std_logic_vector(resize(unsigned(btn), data_in'length)); 
        when IO_PBTN => data_in <= std_logic_vector(resize(unsigned(pbtn), data_in'length)); 
        when IO_LED => led_in <= data_out; 
        when IO_PLED => pled_in <= data_out; 
        when IO_SSEG => hex_in <= data_out; 
       
        when STDIN_S => data_in(15) <= not rx_empty;
        when STDIN_D => data_in <= std_logic_vector(resize(unsigned(rx_data), data_in'length));
        when STDOUT_S => data_in(15) <= not tx_full;   
        when STDOUT_D => tx_data <= data_out(7 downto 0);
        
        when UART_IN_S => data_in(15) <= not rx_empty_uart;
        when UART_IN_D => data_in <= std_logic_vector(resize(unsigned(r_data), data_in'length));
        when UART_OUT_S => data_in(15) <= not tx_full_uart;   
        when UART_OUT_D  => w_data <= data_out(7 downto 0);
        when ms_address => data_in <= milli_counter;
        when others => data_in <= m_out; 
    end case;
    
end process;
      led <= led_out(7 downto 0);
      hex <= hex_out;
      pled <= pled_out(2 downto 0); 
    
end Behavioral;

