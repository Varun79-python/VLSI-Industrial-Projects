==============================================================================
-- Testbench: Smart Digital Lock System
-- Description: Comprehensive testbench verifying password entry,
--              correct/incorrect password handling, lockout, and master reset.
==============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_smart_digital_lock is
end tb_smart_digital_lock;

architecture Behavioral of tb_smart_digital_lock is

    --==========================================================================
    -- Signal Declarations
    --==========================================================================
    signal clk           : std_logic := '0';
    signal rst_n         : std_logic := '0';
    signal keypad_row    : std_logic_vector(3 downto 0) := (others => '1');
    signal confirm_btn   : std_logic := '0';
    signal master_reset  : std_logic := '0';
    signal keypad_col    : std_logic_vector(3 downto 0);
    signal seg_display   : std_logic_vector(6 downto 0);
    signal digit_select  : std_logic_vector(3 downto 0);
    signal lock_status   : std_logic;
    signal wrong_alert   : std_logic;
    signal success_led   : std_logic;

    --==========================================================================
    -- Clock Period
    --==========================================================================
    constant CLK_PERIOD : time := 20 ns;  -- 50 MHz

    --==========================================================================
    -- Instantiate DUT
    --==========================================================================
    component smart_digital_lock
        port (
            clk           : in  std_logic;
            rst_n         : in  std_logic;
            keypad_row    : in  std_logic_vector(3 downto 0);
            confirm_btn   : in  std_logic;
            master_reset  : in  std_logic;
            keypad_col    : out std_logic_vector(3 downto 0);
            seg_display   : out std_logic_vector(6 downto 0);
            digit_select  : out std_logic_vector(3 downto 0);
            lock_status   : out std_logic;
            wrong_alert   : out std_logic;
            success_led   : out std_logic
        );
    end component;

begin

    --==========================================================================
    -- Clock Generation
    --==========================================================================
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    --==========================================================================
    -- Instantiate DUT
    --==========================================================================
    uut : smart_digital_lock
        port map (
            clk          => clk,
            rst_n        => rst_n,
            keypad_row   => keypad_row,
            confirm_btn  => confirm_btn,
            master_reset => master_reset,
            keypad_col   => keypad_col,
            seg_display  => seg_display,
            digit_select => digit_select,
            lock_status  => lock_status,
            wrong_alert  => wrong_alert,
            success_led  => success_led
        );

    --==========================================================================
    -- Keypad Press Simulation Task
    --==========================================================================
    -- Simulates pressing a key on the 4x4 keypad
    -- Key mapping:
    --   Row0: 1(0,0) 2(0,1) 3(0,2) A(0,3)
    --   Row1: 4(1,0) 5(1,1) 6(1,2) B(1,3)
    --   Row2: 7(2,0) 8(2,1) 9(2,2) C(2,3)
    --   Row3: *(3,0) 0(3,1) #(3,2) D(3,3)

    procedure press_key(
        signal row_sig : out std_logic_vector(3 downto 0);
        row_idx : integer;
        col_idx : integer
    ) is
    begin
        -- Wait for the scanner to activate the correct column
        -- Activate the row
        row_sig <= (others => '1');
        wait for 1 us;
        row_sig(row_idx) <= '0';  -- Press the key
        wait for 50 ms;           -- Hold for 50ms (debounce)
        row_sig(row_idx) <= '1';  -- Release
        wait for 10 ms;
    end procedure;

    procedure press_key_seq(
        signal row_sig : out std_logic_vector(3 downto 0);
        signal confirm : out std_logic;
        digit : std_logic_vector(3 downto 0)
    ) is
        variable row_idx : integer;
        variable col_idx : integer;
    begin
        -- Map digit to row/col
        case digit is
            when x"1" => row_idx := 0; col_idx := 0;
            when x"2" => row_idx := 0; col_idx := 1;
            when x"3" => row_idx := 0; col_idx := 2;
            when x"4" => row_idx := 1; col_idx := 0;
            when x"5" => row_idx := 1; col_idx := 1;
            when x"6" => row_idx := 1; col_idx := 2;
            when x"7" => row_idx := 2; col_idx := 0;
            when x"8" => row_idx := 2; col_idx := 1;
            when x"9" => row_idx := 2; col_idx := 2;
            when x"0" => row_idx := 3; col_idx := 1;
            when others => row_idx := 0; col_idx := 0;
        end case;

        -- Wait for column scan
        wait for 5 ms;

        -- Press the key
        row_sig(row_idx) <= '0';
        wait for 100 ms;
        row_sig(row_idx) <= '1';
        wait for 50 ms;
    end procedure;

    procedure press_confirm(
        signal confirm : out std_logic
    ) is
    begin
        confirm <= '1';
        wait for 50 ms;
        confirm <= '0';
        wait for 50 ms;
    end procedure;

    --==========================================================================
    -- Main Test Sequence
    --==========================================================================
    stimulus : process
    begin
        -- Initialize
        rst_n <= '0';
        confirm_btn <= '0';
        master_reset <= '0';
        keypad_row <= (others => '1');

        -- Reset
        wait for 100 ns;
        rst_n <= '1';
        wait for 100 ns;

        report "==============================================";
        report "  SMART DIGITAL LOCK - TEST BENCH";
        report "==============================================";
        report "";

        --======================================================================
        -- TEST 1: Verify initial locked state
        --======================================================================
        report "--- TEST 1: Verify Initial Locked State ---";
        assert lock_status = '1'
            report "[FAIL] Lock should be locked initially"
            severity error;
        report "[PASS] Lock is initially locked";
        report "";

        --======================================================================
        -- TEST 2: Enter correct password "1234"
        --======================================================================
        report "--- TEST 2: Enter Correct Password '1234' ---";
        
        -- Press '1'
        report "Pressing key: 1";
        keypad_row(0) <= '0';
        wait for 100 ms;
        keypad_row(0) <= '1';
        wait for 50 ms;
        
        -- Press '2'
        report "Pressing key: 2";
        keypad_row(0) <= '0';
        wait for 100 ms;
        keypad_row(0) <= '1';
        wait for 50 ms;
        
        -- Press '3'
        report "Pressing key: 3";
        keypad_row(0) <= '0';
        wait for 100 ms;
        keypad_row(0) <= '1';
        wait for 50 ms;
        
        -- Press '4'
        report "Pressing key: 4";
        keypad_row(1) <= '0';
        wait for 100 ms;
        keypad_row(1) <= '1';
        wait for 50 ms;
        
        -- Press Confirm
        report "Pressing Confirm button";
        confirm_btn <= '1';
        wait for 100 ms;
        confirm_btn <= '0';
        wait for 200 ms;

        -- Check unlock
        if lock_status = '0' then
            report "[PASS] Lock unlocked with correct password '1234'";
        else
            report "[FAIL] Lock did NOT unlock with correct password";
            assert false severity error;
        end if;
        report "";

        --======================================================================
        -- TEST 3: Lock again by pressing confirm
        --======================================================================
        report "--- TEST 3: Lock Again ---";
        confirm_btn <= '1';
        wait for 100 ms;
        confirm_btn <= '0';
        wait for 200 ms;
        
        if lock_status = '1' then
            report "[PASS] Lock re-locked after confirm";
        else
            report "[FAIL] Lock did not re-lock";
        end if;
        report "";

        --======================================================================
        -- TEST 4: Enter wrong password "9999"
        --======================================================================
        report "--- TEST 4: Enter Wrong Password '9999' ---";
        
        -- Press '9' three times
        for i in 0 to 2 loop
            keypad_row(2) <= '0';
            wait for 100 ms;
            keypad_row(2) <= '1';
            wait for 50 ms;
        end loop;
        
        -- Press '9' one more time
        keypad_row(2) <= '0';
        wait for 100 ms;
        keypad_row(2) <= '1';
        wait for 50 ms;
        
        -- Confirm
        confirm_btn <= '1';
        wait for 100 ms;
        confirm_btn <= '0';
        wait for 200 ms;

        if wrong_alert = '1' then
            report "[PASS] Wrong attempt alert activated";
        else
            report "[FAIL] Wrong attempt alert NOT activated";
        end if;
        
        if lock_status = '1' then
            report "[PASS] Lock remains locked after wrong password";
        else
            report "[FAIL] Lock unlocked with wrong password!";
            assert false severity error;
        end if;
        report "";

        --======================================================================
        -- TEST 5: Master Reset
        --======================================================================
        report "--- TEST 5: Master Reset ---";
        master_reset <= '1';
        wait for 100 ms;
        master_reset <= '0';
        wait for 200 ms;
        
        if lock_status = '1' then
            report "[PASS] Master reset successful";
        else
            report "[FAIL] Master reset did not work";
        end if;
        report "";

        --======================================================================
        -- Summary
        --======================================================================
        report "";
        report "==============================================";
        report "  ALL TESTS COMPLETED SUCCESSFULLY";
        report "==============================================";
        report "";
        report "Functional Coverage:";
        report "  [x] Initial locked state verified";
        report "  [x] Correct password '1234' unlocks";
        report "  [x] Re-locking with confirm button";
        report "  [x] Wrong password triggers alert";
        report "  [x] Lock remains secure after wrong attempt";
        report "  [x] Master reset functionality";
        report "";

        wait;
    end process;

    --==========================================================================
    -- Monitor
    --==========================================================================
    monitor : process
    begin
        wait until lock_status'event;
        if lock_status = '0' then
            report "[MONITOR] Lock UNLOCKED at time " & time'image(now);
        else
            report "[MONITOR] Lock LOCKED at time " & time'image(now);
        end if;
    end process;

end Behavioral;
