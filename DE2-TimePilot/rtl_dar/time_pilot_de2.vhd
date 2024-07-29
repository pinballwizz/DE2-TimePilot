---------------------------------------------------------------------------------
-- DE10_lite Top level for Time pilot by Dar (darfpga@aol.fr) (29/10/2017)
-- http://darfpga.blogspot.fr
---------------------------------------------------------------------------------
-- Educational use only
-- Do not redistribute synthetized file with roms
-- Do not redistribute roms whatever the form
-- Use at your own risk
---------------------------------------------------------------------------------
-- Use time_pilot_lite.sdc to compile (Timequest constraints)
-- /!\
-- Don't forget to set device configuration mode with memory initialization 
--  (Assignments/Device/Pin options/Configuration mode)
---------------------------------------------------------------------------------
--
-- Main features :
--  PS2 keyboard input @gpio pins 35/34 (beware voltage translation/protection) 
--  Audio pwm output   @gpio pins 1/3 (beware voltage translation/protection) 
--
-- Uses 1 pll for 12MHz and 14MHz generation from 50MHz
--
-- Board key :
--   0 : reset game
--
-- Keyboard players inputs :
--
--   F3 : Add coin
--   F2 : Start 2 players
--   F1 : Start 1 player
--   SPACE       : Fire  
--   RIGHT arrow : rotate right
--   LEFT  arrow : rotate left
--   UP    arrow : rotate up 
--   DOWN  arrow : rotate down
--
-- Other details : see time_pilot.vhd
-- For USB inputs and SGT5000 audio output see my other project: xevious_de10_lite
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
--use work.usb_report_pkg.all;

entity time_pilot_de2 is
port(
	clock_50  		: in std_logic;
-- max10_clk2_50  : in std_logic;
-- adc_clk_10     : in std_logic;
-- ledr           : out std_logic_vector(9 downto 0);
	key            : in std_logic_vector(1 downto 0);
-- sw             : in std_logic_vector(9 downto 0);

-- dram_ba    : out std_logic_vector(1 downto 0);
-- dram_ldqm  : out std_logic;
-- dram_udqm  : out std_logic;
-- dram_ras_n : out std_logic;
-- dram_cas_n : out std_logic;
-- dram_cke   : out std_logic;
-- dram_clk   : out std_logic;
-- dram_we_n  : out std_logic;
-- dram_cs_n  : out std_logic;
-- dram_dq    : inout std_logic_vector(15 downto 0);
-- dram_addr  : out std_logic_vector(12 downto 0);

-- hex0 : out std_logic_vector(7 downto 0);
-- hex1 : out std_logic_vector(7 downto 0);
-- hex2 : out std_logic_vector(7 downto 0);
-- hex3 : out std_logic_vector(7 downto 0);
-- hex4 : out std_logic_vector(7 downto 0);
-- hex5 : out std_logic_vector(7 downto 0);

	ps2_clk : in std_logic;
	ps2_dat : inout std_logic;
	
	sram_addr : out std_logic_vector(17 downto 0);
	sram_dq   : inout std_logic_vector(15 downto 0);
	sram_we_n : out std_logic;
	sram_oe_n : out std_logic;
	sram_ub_n : out std_logic;
	sram_lb_n : out std_logic;
	sram_ce_n : out std_logic; 
 
 	vga_r     : out std_logic_vector(9 downto 0);
	vga_g     : out std_logic_vector(9 downto 0);
	vga_b     : out std_logic_vector(9 downto 0);
	vga_clk   : out std_logic;
	vga_blank : out std_logic;
	vga_hs    : out std_logic;
	vga_vs    : out std_logic;
	vga_sync  : out std_logic;

	i2c_sclk : out std_logic;
	i2c_sdat : inout std_logic;
 
	aud_adclrck : out std_logic;
	aud_adcdat  : in std_logic;
	aud_daclrck : out std_logic;
	aud_dacdat  : out std_logic;
	aud_xck     : out std_logic;
	aud_bclk    : out std_logic
 
-- gsensor_cs_n : out   std_logic;
-- gsensor_int  : in    std_logic_vector(2 downto 0); 
-- gsensor_sdi  : inout std_logic;
-- gsensor_sdo  : inout std_logic;
-- gsensor_sclk : out   std_logic;

-- arduino_io      : inout std_logic_vector(15 downto 0); 
-- arduino_reset_n : inout std_logic;
 
-- gpio          : inout std_logic_vector(35 downto 0)
);
end time_pilot_de2;

architecture struct of time_pilot_de2 is

-- clocks

 signal clock_36  : std_logic;
 signal clock_18  : std_logic;
 signal clock_12  : std_logic;
 signal clock_9   : std_logic;
 signal clock_6   : std_logic;

 signal clock_14  : std_logic;
 signal reset     : std_logic;
 
-- signal max3421e_clk : std_logic;
 
 signal r         : std_logic_vector(4 downto 0);
 signal g         : std_logic_vector(4 downto 0);
 signal b         : std_logic_vector(4 downto 0);
 signal video_clk : std_logic;
 signal csync     : std_logic;
 signal hsync     : std_logic;   -- mod from somhic
 signal vsync     : std_logic;   -- mod from somhic
 signal blankn    : std_logic;
 
 -- video signals   -- mod from somhic
 -- signal clock_vga       : std_logic;   
 signal vga_g_i         : std_logic_vector(5 downto 0);   
 signal vga_r_i         : std_logic_vector(5 downto 0);   
 signal vga_b_i         : std_logic_vector(5 downto 0);   
 signal vga_r_o         : std_logic_vector(5 downto 0);   
 signal vga_g_o         : std_logic_vector(5 downto 0);   
 signal vga_b_o         : std_logic_vector(5 downto 0);   
 signal hsync_o         : std_logic;   
 signal vsync_o         : std_logic;   
 signal blankn_o        : std_logic;

 signal vga_r_c         : std_logic_vector(3 downto 0);
 signal vga_g_c         : std_logic_vector(3 downto 0);
 signal vga_b_c         : std_logic_vector(3 downto 0);
 signal vga_hs_c        : std_logic;
 signal vga_vs_c        : std_logic;
 
 signal audio           : std_logic_vector(10 downto 0);
 signal sound_string		: std_logic_vector(31 downto 0);
 
-- signal pwm_accumulator : std_logic_vector(12 downto 0);

 alias reset_n         : std_logic is key(0);
 --alias ps2_clk         : std_logic is gpio(35); --gpio(0);
 --alias ps2_dat         : std_logic is gpio(34); --gpio(1);
-- alias pwm_audio_out_l : std_logic is gpio(1);  --gpio(2);
-- alias pwm_audio_out_r : std_logic is gpio(3);  --gpio(3);
 
 signal kbd_intr      : std_logic;
 signal kbd_scancode  : std_logic_vector(7 downto 0);
 signal joyPCFRLDU : std_logic_vector(7 downto 0);
-- signal keys_HUA      : std_logic_vector(2 downto 0);

-- signal start : std_logic := '0';
-- signal usb_report : usb_report_t;
-- signal new_usb_report : std_logic := '0';
 
signal dbg_cpu_addr : std_logic_vector(15 downto 0);
signal slot      	  : std_logic_vector(2 downto 0) := (others => '0');

  component scandoubler        -- mod from somhic
    port (
    clk_sys : in std_logic;
    scanlines : in std_logic_vector (1 downto 0);
    ce_x1 : in std_logic;
    ce_x2 : in std_logic;
    hs_in : in std_logic;
    vs_in : in std_logic;
    r_in : in std_logic_vector (5 downto 0);
    g_in : in std_logic_vector (5 downto 0);
    b_in : in std_logic_vector (5 downto 0);
    hs_out : out std_logic;
    vs_out : out std_logic;
    r_out : out std_logic_vector (5 downto 0);
    g_out : out std_logic_vector (5 downto 0);
    b_out : out std_logic_vector (5 downto 0)
  );
end component;

begin

reset <= not reset_n;

-- tv15Khz_mode <= sw();

--arduino_io not used pins
--arduino_io(7) <= '1'; -- to usb host shield max3421e RESET
--arduino_io(8) <= 'Z'; -- from usb host shield max3421e GPX
--arduino_io(9) <= 'Z'; -- from usb host shield max3421e INT
--arduino_io(13) <= 'Z'; -- not used
--arduino_io(14) <= 'Z'; -- not used

-- Clock 12.288MHz for time_pilot core, 14.318MHz for sound_board
clocks : entity work.de2_timeplt_clk
port map(
 inclk0 => clock_50,
 c0 => clock_36,
 locked => open --pll_locked
);

-- create other clocks
process (clock_36)
begin

 if rising_edge(clock_36) then 
	clock_12 <= '0';
	clock_18  <= not clock_18;

	if slot = "101" then slot <= (others => '0');
	else slot <= std_logic_vector(unsigned(slot) + 1);
	end if;   
	
	if slot = "100" or slot = "001" then clock_6 <= not clock_6;	end if;
	if slot = "100" or slot = "001" then clock_12  <= '1';	end if;	

 end if;
end process;

-- SRAM is always enabled
sram_ce_n <= '0';
sram_lb_n <= '0';
sram_oe_n <= '0';
sram_ub_n <= '0';
sram_we_n <= '1';

-- Time pilot
time_pilot : entity work.time_pilot
port map(
 clock_12   => clock_12,
 clock_14   => clock_18,
 reset      => reset,
 
-- tv15Khz_mode => tv15Khz_mode,
 video_r      => r,
 video_g      => g,
 video_b      => b,
 video_csync  => csync,
 video_blankn => blankn,
 video_hs     => hsync,
 video_vs     => vsync,
 audio_out    => audio,
 
 rom_bus_addr_o => sram_addr(16 downto 0),
 rom_bus_do     => sram_dq(7 downto 0),
 
 dip_switch_1 => X"FF", -- Coinage_B / Coinage_A
 dip_switch_2 => X"4F", -- Sound(8)/Difficulty(7-5)/Bonus(4)/Cocktail(3)/lives(2-1)
 
 start2      => joyPCFRLDU(7),
 start1      => joyPCFRLDU(6),
 coin1       => joyPCFRLDU(5),
 
 fire1       => joyPCFRLDU(4),
 right1      => joyPCFRLDU(3),
 left1       => joyPCFRLDU(2),
 down1       => joyPCFRLDU(1),
 up1         => joyPCFRLDU(0),

 fire2       => joyPCFRLDU(4),
 right2      => joyPCFRLDU(3),
 left2       => joyPCFRLDU(2),
 down2       => joyPCFRLDU(1),
 up2         => joyPCFRLDU(0),

 dbg_cpu_addr => dbg_cpu_addr
);

	vga_clk <= clock_12;
	vga_sync <=  '0';
	vga_blank <= '1';

vga_r_i <= r & "0" when blankn = '1' else "000000";
vga_g_i <= g & "0"  when blankn = '1' else "000000";
vga_b_i <= b & "0"  when blankn = '1' else "000000";

-- vga scandoubler
scandoubler_inst :  scandoubler
  port map (
    clk_sys => clock_12,     --clock_18, video_clk i clock_36 no funciona
    scanlines => "00",       --(00-none 01-25% 10-50% 11-75%)
    ce_x1 => clock_6,     
    ce_x2 => '1',
    hs_in => hsync,
    vs_in => vsync,
    r_in => vga_r_i,
    g_in => vga_g_i,
    b_in => vga_b_i,
    hs_out => hsync_o,
    vs_out => vsync_o,
    r_out => vga_r_o,
    g_out => vga_g_o,
    b_out => vga_b_o
  );

 process (clock_12)
begin
		if rising_edge(clock_12) then
        --VGA adapt video to 4 for lite / 10 bits color only for de2
        vga_r  <= vga_r_o & "0000";
        vga_g  <= vga_g_o & "0000";
        vga_b  <= vga_b_o & "0000";
        vga_hs <= hsync_o;       
        vga_vs <= vsync_o; 	    	
			
		end if;
end process; 

sound_string <= "00" & audio & "000" & "00" & audio & "000";

wm8731_dac : entity work.wm8731_dac
port map(
 clk18MHz => clock_18,
 sampledata => sound_string,
 i2c_sclk => i2c_sclk,
 i2c_sdat => i2c_sdat,
 aud_bclk => aud_bclk,
 aud_daclrck => aud_daclrck,
 aud_dacdat => aud_dacdat,
 aud_xck => aud_xck
); 

-- get scancode from keyboard
--process (reset, clock_12)
--begin
--	if reset='1' then
--		clock_6  <= '0';
--	else 
--		if rising_edge(clock_12) then
--				clock_6  <= not clock_6;
--		end if;
--	end if;
--end process;

keyboard : entity work.io_ps2_keyboard
port map (
  clk       => clock_6, -- synchrounous clock with core
  kbd_clk   => ps2_clk,
  kbd_dat   => ps2_dat,
  interrupt => kbd_intr,
  scancode  => kbd_scancode
);

-- translate scancode to joystick
joystick : entity work.kbd_joystick
port map (
  clk           => clock_6, -- synchrounous clock with core
  kbdint        => kbd_intr,
  kbdscancode   => std_logic_vector(kbd_scancode), 
  joyPCFRLDU => joyPCFRLDU
);

-- usb host for max3421e arduino shield (modified)

--max3421e_clk <= clock_11;
--usb_host : entity work.usb_host_max3421e
--port map(
-- clk     => max3421e_clk,
-- reset   => reset,
-- start   => start,
-- 
-- usb_report => usb_report,
-- new_usb_report => new_usb_report,
-- 
-- spi_cs_n  => arduino_io(10), 
-- spi_clk   => arduino_io(13),
-- spi_mosi  => arduino_io(11),
-- spi_miso  => arduino_io(12)
--);

-- usb keyboard report decoder

--keyboard_decoder : entity work.usb_keyboard_decoder
--port map(
-- clk     => max3421e_clk,
-- 
-- usb_report => usb_report,
-- new_usb_report => new_usb_report,
-- 
-- joyBCPPFRLDU  => joyBCPPFRLDU
--);

-- usb joystick decoder (konix drakkar wireless)

--joystick_decoder : entity work.usb_joystick_decoder
--port map(
-- clk     => max3421e_clk,
-- 
-- usb_report => usb_report,
-- new_usb_report => new_usb_report,
-- 
-- joyBCPPFRLDU  => open --joyBCPPFRLDU
--);

-- debug display

--ledr(8 downto 0) <= joyBCPPFRLDU;
--
--h0 : entity work.decodeur_7_seg port map(dbg_cpu_addr( 3 downto  0),hex0);
--h1 : entity work.decodeur_7_seg port map(dbg_cpu_addr( 7 downto  4),hex1);
--h2 : entity work.decodeur_7_seg port map(dbg_cpu_addr(11 downto  8),hex2);
--h3 : entity work.decodeur_7_seg port map(dbg_cpu_addr(15 downto 12),hex3);
--h4 : entity work.decodeur_7_seg port map(usb_report(to_integer(unsigned(sw))+0)(3 downto 0),hex4);
--h5 : entity work.decodeur_7_seg port map(usb_report(to_integer(unsigned(sw))+0)(7 downto 4),hex5);

-- audio for sgtl5000 

--sample_data <= "00" & audio & "000" & "00" & audio & "000";				

-- Clock 1us for ym_8910

--p_clk_1us_p : process(max10_clk1_50)
--begin
--	if rising_edge(max10_clk1_50) then
--		if cnt_1us = 0 then
--			cnt_1us  <= 49;
--			clk_1us  <= '1'; 
--		else
--			cnt_1us  <= cnt_1us - 1;
--			clk_1us <= '0'; 
--		end if;
--	end if;	
--end process;	 

-- sgtl5000 (teensy audio shield on top of usb host shield)

--e_sgtl5000 : entity work.sgtl5000_dac
--port map(
-- clock_18   => clock_18,
-- reset      => reset,
-- i2c_clock  => clk_1us,  
--
-- sample_data  => sample_data,
-- 
-- i2c_sda   => arduino_io(0), -- i2c_sda, 
-- i2c_scl   => arduino_io(1), -- i2c_scl, 
--
-- tx_data   => arduino_io(2), -- sgtl5000 tx
-- mclk      => arduino_io(4), -- sgtl5000 mclk 
-- 
-- lrclk     => arduino_io(3), -- sgtl5000 lrclk
-- bclk      => arduino_io(6), -- sgtl5000 bclk   
-- 
-- -- debug
-- hex0_di   => open, -- hex0_di,
-- hex1_di   => open, -- hex1_di,
-- hex2_di   => open, -- hex2_di,
-- hex3_di   => open, -- hex3_di,
-- 
-- sw => sw(7 downto 0)
--);

-- pwm sound output

--process(clock_14)  -- use same clock as time_pilot_sound_board
--begin
--  if rising_edge(clock_14) then
--    pwm_accumulator  <=  std_logic_vector(unsigned('0' & pwm_accumulator(11 downto 0)) + unsigned(audio & "00"));
--  end if;
--end process;

--pwm_audio_out_l <= pwm_accumulator(12);
--pwm_audio_out_r <= pwm_accumulator(12); 


end struct;
