----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/07/2021 11:40:58 AM
-- Design Name: 
-- Module Name: top_design - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity top_design is
    Port ( 
        
       sys_clk : in STD_LOGIC;
       sys_rst_n : in STD_LOGIC;
        
       key : in STD_LOGIC_VECTOR (0 downto 0);
       led : out STD_LOGIC_VECTOR (1 downto 0);
       
       uart_rx : in STD_LOGIC;
       uart_tx : out STD_LOGIC;
       
       GPIO_1 : in STD_LOGIC_VECTOR (43 downto 0);
       GPIO_2 : out STD_LOGIC_VECTOR (43 downto 0)
   );
end top_design;

architecture Behavioral of top_design is
    signal clock_50,  rstn_50 : std_logic := '0';  
    signal clock_100, rstn_100 : std_logic := '0';
    signal clock_125, rstn_125 : std_logic := '0';
    signal clock_150, rstn_150 : std_logic := '0';
    signal clock_200, rstn_200 : std_logic := '0';
    
    signal heartbeat : std_logic_vector (15 downto 0) := (others => '0');
begin
    clock_50 <= sys_clk;
    rstn_50 <= sys_rst_n;
    rstn_100 <= sys_rst_n;
    rstn_125 <= sys_rst_n;
    rstn_150 <= sys_rst_n;
    rstn_200 <= sys_rst_n;
    
    led(0) <= heartbeat(0);
    led(1) <= heartbeat(4);
    GPIO_2 (15 downto 0) <= heartbeat;
    GPIO_2 (16) <= clock_50;
    GPIO_2 (17) <= clock_100;
    GPIO_2 (18) <= clock_125;
    GPIO_2 (19) <= clock_150;
    GPIO_2 (20) <= clock_200;
    
MMCM_block : block
    signal mmcm_lock, mmcm_psdone,mmcm_rst, t_rst : std_logic := '0';
    signal fd_clock, fd_clock_buf : std_logic := '0';
    signal clock_100_buf : std_logic := '0';
    signal clock_125_buf : std_logic := '0';
    signal clock_150_buf : std_logic := '0';
    signal clock_200_buf : std_logic := '0';
    
    
    signal counter_50 : integer  := 0;
    signal counter_100 : integer  := 0;
    signal counter_125 : integer  := 0;
    signal counter_150 : integer  := 0;
    signal counter_200 : integer  := 0;
    

begin

   MMCME2_ADV_inst : MMCME2_ADV
   generic map (
      BANDWIDTH => "OPTIMIZED",      -- Jitter programming (OPTIMIZED, HIGH, LOW)
      CLKFBOUT_MULT_F => 15.0,        -- Multiply value for all CLKOUT (2.000-64.000).
      CLKFBOUT_PHASE => 0.0,         -- Phase offset in degrees of CLKFB (-360.000-360.000).
      -- CLKIN_PERIOD: Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
      CLKIN1_PERIOD => 20.0,
      CLKIN2_PERIOD => 0.0,
      -- CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for CLKOUT (1-128)
      CLKOUT1_DIVIDE => 6,
      CLKOUT2_DIVIDE => 5,
      CLKOUT3_DIVIDE => 4,
      CLKOUT4_DIVIDE => 1,
      CLKOUT5_DIVIDE => 1,
      CLKOUT6_DIVIDE => 1,
      CLKOUT0_DIVIDE_F => 7.5,       -- Divide amount for CLKOUT0 (1.000-128.000).
      -- CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for CLKOUT outputs (0.01-0.99).
      CLKOUT0_DUTY_CYCLE => 0.5,
      CLKOUT1_DUTY_CYCLE => 0.5,
      CLKOUT2_DUTY_CYCLE => 0.5,
      CLKOUT3_DUTY_CYCLE => 0.5,
      CLKOUT4_DUTY_CYCLE => 0.5,
      CLKOUT5_DUTY_CYCLE => 0.5,
      CLKOUT6_DUTY_CYCLE => 0.5,
      -- CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for CLKOUT outputs (-360.000-360.000).
      CLKOUT0_PHASE => 0.0,
      CLKOUT1_PHASE => 0.0,
      CLKOUT2_PHASE => 0.0,
      CLKOUT3_PHASE => 0.0,
      CLKOUT4_PHASE => 0.0,
      CLKOUT5_PHASE => 0.0,
      CLKOUT6_PHASE => 0.0,
      CLKOUT4_CASCADE => FALSE,      -- Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
      COMPENSATION => "ZHOLD",       -- ZHOLD, BUF_IN, EXTERNAL, INTERNAL
      DIVCLK_DIVIDE => 1,            -- Master division value (1-106)
      -- REF_JITTER: Reference input jitter in UI (0.000-0.999).
      REF_JITTER1 => 0.0,
      REF_JITTER2 => 0.0,
      STARTUP_WAIT => FALSE,         -- Delays DONE until MMCM is locked (FALSE, TRUE)
      -- Spread Spectrum: Spread Spectrum Attributes
      SS_EN => "FALSE",              -- Enables spread spectrum (FALSE, TRUE)
      SS_MODE => "CENTER_HIGH",      -- CENTER_HIGH, CENTER_LOW, DOWN_HIGH, DOWN_LOW
      SS_MOD_PERIOD => 10000,        -- Spread spectrum modulation period (ns) (VALUES)
      -- USE_FINE_PS: Fine phase shift enable (TRUE/FALSE)
      CLKFBOUT_USE_FINE_PS => FALSE,
      CLKOUT0_USE_FINE_PS => FALSE,
      CLKOUT1_USE_FINE_PS => FALSE,
      CLKOUT2_USE_FINE_PS => FALSE,
      CLKOUT3_USE_FINE_PS => FALSE,
      CLKOUT4_USE_FINE_PS => FALSE,
      CLKOUT5_USE_FINE_PS => FALSE,
      CLKOUT6_USE_FINE_PS => FALSE
   )
   port map (
      -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
      CLKOUT0 => clock_100_buf,           -- 1-bit output: CLKOUT0
      CLKOUT0B => open,         -- 1-bit output: Inverted CLKOUT0
      CLKOUT1 => clock_125_buf,           -- 1-bit output: CLKOUT1
      CLKOUT1B => open,         -- 1-bit output: Inverted CLKOUT1
      CLKOUT2 => clock_150_buf,           -- 1-bit output: CLKOUT2
      CLKOUT2B => open,         -- 1-bit output: Inverted CLKOUT2
      CLKOUT3 => clock_200_buf,           -- 1-bit output: CLKOUT3
      CLKOUT3B => open,         -- 1-bit output: Inverted CLKOUT3
      CLKOUT4 => open,           -- 1-bit output: CLKOUT4
      CLKOUT5 => open,           -- 1-bit output: CLKOUT5
      CLKOUT6 => open,           -- 1-bit output: CLKOUT6
      -- DRP Ports: 16-bit (each) output: Dynamic reconfiguration ports
      DO => open,                     -- 16-bit output: DRP data
      DRDY => open,                 -- 1-bit output: DRP ready
      -- Dynamic Phase Shift Ports: 1-bit (each) output: Ports used for dynamic phase shifting of the outputs
      PSDONE => mmcm_psdone,             -- 1-bit output: Phase shift done
      -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
      CLKFBOUT => fd_clock_buf,         -- 1-bit output: Feedback clock
      CLKFBOUTB => open,       -- 1-bit output: Inverted CLKFBOUT
      -- Status Ports: 1-bit (each) output: MMCM status ports
      CLKFBSTOPPED => open, -- 1-bit output: Feedback clock stopped
      CLKINSTOPPED => open, -- 1-bit output: Input clock stopped
      LOCKED => mmcm_lock,             -- 1-bit output: LOCK
      -- Clock Inputs: 1-bit (each) input: Clock inputs
      CLKIN1 => clock_50,             -- 1-bit input: Primary clock
      CLKIN2 => '0',             -- 1-bit input: Secondary clock
      -- Control Ports: 1-bit (each) input: MMCM control ports
      CLKINSEL => '1',         -- 1-bit input: Clock select, High=CLKIN1 Low=CLKIN2
      PWRDWN => '0',             -- 1-bit input: Power-down
      RST => mmcm_rst,                   -- 1-bit input: Reset
      -- DRP Ports: 7-bit (each) input: Dynamic reconfiguration ports
      DADDR => "0000000",               -- 7-bit input: DRP address
      DCLK => '0',                 -- 1-bit input: DRP clock
      DEN => '0',                   -- 1-bit input: DRP enable
      DI => X"0000",                     -- 16-bit input: DRP data
      DWE => '0',                   -- 1-bit input: DRP write enable
      -- Dynamic Phase Shift Ports: 1-bit (each) input: Ports used for dynamic phase shifting of the outputs
      PSCLK => '0',               -- 1-bit input: Phase shift clock
      PSEN => '0',                 -- 1-bit input: Phase shift enable
      PSINCDEC => '0',         -- 1-bit input: Phase shift increment/decrement
      -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
      CLKFBIN => fd_clock            -- 1-bit input: Feedback clock
   );


    mmcm_bufg_feedback : BUFG port map (I => fd_clock_buf ,  O => fd_clock);
    mmcm_bufg_100 : BUFG port map (I => clock_100_buf ,  O => clock_100);
    mmcm_bufg_125 : BUFG port map (I => clock_125_buf ,  O => clock_125);
    mmcm_bufg_150 : BUFG port map (I => clock_150_buf ,  O => clock_150); 
    mmcm_bufg_200 : BUFG port map (I => clock_200_buf ,  O => clock_200); 
   -- End of MMCME2_BASE_inst instantiation
      
    process(clock_50, rstn_50)
		
    begin
        if (rstn_50 = '0') then
            heartbeat(0) <= '1';
            counter_50 <= 0;
        elsif (rising_edge(clock_50)) then
            if(counter_50 = 29999999) then
                heartbeat(0) <= not heartbeat(0);
                counter_50 <= 0;
	    else
	        counter_50 <= counter_50 + 1;
            end if;
        end if;
    end process;
    
    process(clock_100, rstn_100)
		
    begin
        if (rstn_100 = '0') then
            heartbeat(1) <= '1';
            counter_100 <= 0;
        elsif (rising_edge(clock_100)) then
            if(counter_100 = 29999999) then
                heartbeat(1) <= not heartbeat(1);
                counter_100 <= 0;
	    else
	        counter_100 <= counter_100 + 1;
            end if;
        end if;
    end process;
    
    process(clock_125, rstn_125)
		
    begin
        if (rstn_125 = '0') then
            heartbeat(2) <= '1';
            counter_125 <= 0;
        elsif (rising_edge(clock_125)) then
            if(counter_125 = 29999999) then
                heartbeat(2) <= not heartbeat(2);
                counter_125 <= 0;
	    else
	        counter_125 <= counter_125 + 1;
            end if;
        end if;
    end process;
    
    process(clock_200, rstn_200)
		
    begin
        if (rstn_200 = '0') then
            heartbeat(4) <= '1';
            counter_200 <= 0;
        elsif (rising_edge(clock_200)) then
            if(counter_200 = 29999999) then
                heartbeat(4) <= not heartbeat(4);
                counter_200 <= 0;
	    else
	        counter_200 <= counter_200 + 1;
            end if;
        end if;
    end process;
    
    process(clock_150, rstn_150)
		
    begin
        if (rstn_150 = '0') then
            heartbeat(3) <= '1';
            counter_150 <= 0;
        elsif (rising_edge(clock_150)) then
            if(counter_150 = 29999999) then
                heartbeat(3) <= not heartbeat(3);
                counter_150 <= 0;
	    else
	        counter_150 <= counter_150 + 1;
            end if;
        end if;
    end process;


   end block MMCM_block;
   
   
   
end Behavioral;
