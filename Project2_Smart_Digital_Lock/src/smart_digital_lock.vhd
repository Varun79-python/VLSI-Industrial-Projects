==============================================================================
-- Project 2: Smart Digital Lock System Using VHDL
-- Description: A digital lock that accepts a 4-digit password via keypad,
--              displays on 7-segment, alerts on wrong attempts, and has
--              a master reset feature.
-- Tools: ModelSim / Vivado / Xilinx ISE
-- Author: VLSI Internship Project
==============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity smart_digital_lock is
    port (
        clk           : in  std_logic;                     -- System clock
        rst_n         : in  std_logic;                     -- Active-low reset
        keypad_row    : in  std_logic_vector(3 downto 0);  -- Keypad row inputs
        confirm_btn   : in  std_logic;                     -- Confirm password button
        master_reset  : in  std_logic;                     -- Master reset button
        keypad_col    : out std_logic_vector(3 downto 0);  -- Keypad column outputs
        seg_display   : out std_logic_vector(6 downto 0);  -- 7-segment display
        digit_select  : out std_logic_vector(3 downto 0);  -- Digit select (active low)
        lock_status   : out std_logic;                     -- Lock status (1=locked, 0=unlocked)
        wrong_alert   : out std_logic;                     -- Wrong attempt buzzer
        success_led   : out std_logic                      -- Success LED
    );
end smart_digital_lock;

architecture Behavioral of smart_digital_lock is

    --==========================================================================
    -- State Machine States
    --==========================================================================
    type state_type is (
        st_IDLE,           -- Waiting for keypad input
        st_SCANNING,       -- Scanning keypad
        st_INPUT,          -- Receiving password digits
        st_VERIFY,         -- Verifying password
        st_UNLOCKED,       -- Lock opened
        st_WRONG_ATTEMPT,  -- Wrong password alert
        st_LOCKED_OUT      -- Too many wrong attempts
    );
    signal current_state, next_state : state_type;

    --==========================================================================
    -- Constants
    --==========================================================================
    constant CORRECT_PASSWORD : std_logic_vector(15 downto 0) := x"1234";  -- Default: 1234
    constant MAX_ATTEMPTS     : integer := 3;
    constant LOCKOUT_TIME     : integer := 50000000;  -- 1 second at 50MHz

    --==========================================================================
    -- Signals
    --==========================================================================
    signal entered_password : std_logic_vector(15 downto 0);
    signal digit_count      : integer range 0 to 4;
    signal attempt_count    : integer range 0 to MAX_ATTEMPTS;
    signal lockout_counter  : integer range 0 to LOCKOUT_TIME;
    signal key_pressed      : std_logic;
    signal key_value        : std_logic_vector(3 downto 0);
    signal scan_counter     : integer range 0 to 3;
    signal debounce_counter : integer range 0 to 500000;
    signal confirm_prev     : std_logic;
    signal key_valid        : std_logic;

    --==========================================================================
    -- Seven Segment Encoding (active low: 0 = LED ON)
    --   a
    --  ---
    -- f | | b
    --  -g-
    -- e | | c
    --  ---
    --   d
    --==========================================================================
    function bcd_to_7seg(bcd : std_logic_vector(3 downto 0)) return std_logic_vector is
        variable seg : std_logic_vector(6 downto 0);
    begin
        case bcd is
            when x"0"   => seg := "1000000";  -- 0
            when x"1"   => seg := "1111001";  -- 1
            when x"2"   => seg := "0100100";  -- 2
            when x"3"   => seg := "0110000";  -- 3
            when x"4"   => seg := "0011001";  -- 4
            when x"5"   => seg := "0010010";  -- 5
            when x"6"   => seg := "0000010";  -- 6
            when x"7"   => seg := "1111000";  -- 7
            when x"8"   => seg := "0000000";  -- 8
            when x"9"   => seg := "0010000";  -- 9
            when others => seg := "1111111";  -- OFF
        end case;
        return seg;
    end function;

begin

    --==========================================================================
    -- Keypad Scanning Process
    --==========================================================================
    -- 4x4 Keypad Layout:
    --   Col0 Col1 Col2 Col3
    -- Row0:  1    2    3    A
    -- Row1:  4    5    6    B
    -- Row2:  7    8    9    C
    -- Row3:  *    0    #    D

    process(clk, rst_n)
    begin
        if rst_n = '0' then
            keypad_col <= (others => '1');
            scan_counter <= 0;
            key_pressed <= '0';
            key_value <= (others => '0');
            debounce_counter <= 0;
            key_valid <= '0';
        elsif rising_edge(clk) then
            key_pressed <= '0';
            key_valid <= '0';

            -- Scan each column
            case scan_counter is
                when 0 =>
                    keypad_col <= "1110";
                    if keypad_row(0) = '0' then key_value <= x"1"; key_pressed <= '1'; end if;
                    if keypad_row(1) = '0' then key_value <= x"4"; key_pressed <= '1'; end if;
                    if keypad_row(2) = '0' then key_value <= x"7"; key_pressed <= '1'; end if;
                    if keypad_row(3) = '0' then key_value <= x"E"; key_pressed <= '1'; end if;
                when 1 =>
                    keypad_col <= "1101";
                    if keypad_row(0) = '0' then key_value <= x"2"; key_pressed <= '1'; end if;
                    if keypad_row(1) = '0' then key_value <= x"5"; key_pressed <= '1'; end if;
                    if keypad_row(2) = '0' then key_value <= x"8"; key_pressed <= '1'; end if;
                    if keypad_row(3) = '0' then key_value <= x"0"; key_pressed <= '1'; end if;
                when 2 =>
                    keypad_col <= "1011";
                    if keypad_row(0) = '0' then key_value <= x"3"; key_pressed <= '1'; end if;
                    if keypad_row(1) = '0' then key_value <= x"6"; key_pressed <= '1'; end if;
                    if keypad_row(2) = '0' then key_value <= x"9"; key_pressed <= '1'; end if;
                    if keypad_row(3) = '0' then key_value <= x"F"; key_pressed <= '1'; end if;
                when 3 =>
                    keypad_col <= "0111";
                    if keypad_row(0) = '0' then key_value <= x"A"; key_pressed <= '1'; end if;
                    if keypad_row(1) = '0' then key_value <= x"B"; key_pressed <= '1'; end if;
                    if keypad_row(2) = '0' then key_value <= x"C"; key_pressed <= '1'; end if;
                    if keypad_row(3) = '0' then key_value <= x"D"; key_pressed <= '1'; end if;
                when others =>
                    keypad_col <= "1111";
            end case;

            -- Debounce
            if key_pressed = '1' then
                if debounce_counter < 500000 then
                    debounce_counter <= debounce_counter + 1;
                else
                    key_valid <= '1';
                    debounce_counter <= 0;
                end if;
            else
                debounce_counter <= 0;
            end if;

            -- Scan counter
            if scan_counter = 3 then
                scan_counter <= 0;
            else
                scan_counter <= scan_counter + 1;
            end if;
        end if;
    end process;

    --==========================================================================
    -- State Register
    --==========================================================================
    process(clk, rst_n, master_reset)
    begin
        if rst_n = '0' or master_reset = '1' then
            current_state <= st_IDLE;
            entered_password <= (others => '0');
            digit_count <= 0;
            attempt_count <= 0;
            lockout_counter <= 0;
            confirm_prev <= '0';
        elsif rising_edge(clk) then
            confirm_prev <= confirm_btn;

            case current_state is
                when st_IDLE =>
                    entered_password <= (others => '0');
                    digit_count <= 0;
                    if key_valid = '1' and key_value >= x"0" and key_value <= x"9" then
                        current_state <= st_INPUT;
                    end if;

                when st_INPUT =>
                    if key_valid = '1' and key_value >= x"0" and key_value <= x"9" then
                        entered_password <= entered_password(11 downto 0) & key_value;
                        digit_count <= digit_count + 1;
                    end if;

                    if confirm_btn = '1' and confirm_prev = '0' then
                        if digit_count = 4 then
                            current_state <= st_VERIFY;
                        end if;
                    end if;

                    if key_valid = '1' and key_value = x"E" then
                        entered_password <= (others => '0');
                        digit_count <= 0;
                    end if;

                when st_VERIFY =>
                    if entered_password = CORRECT_PASSWORD then
                        current_state <= st_UNLOCKED;
                    else
                        attempt_count <= attempt_count + 1;
                        if attempt_count >= MAX_ATTEMPTS - 1 then
                            current_state <= st_LOCKED_OUT;
                            lockout_counter <= LOCKOUT_TIME;
                        else
                            current_state <= st_WRONG_ATTEMPT;
                        end if;
                    end if;

                when st_UNLOCKED =>
                    if confirm_btn = '1' then
                        current_state <= st_IDLE;
                        entered_password <= (others => '0');
                        digit_count <= 0;
                    end if;

                when st_WRONG_ATTEMPT =>
                    if debounce_counter < 500000 then
                        debounce_counter <= debounce_counter + 1;
                    else
                        debounce_counter <= 0;
                        current_state <= st_IDLE;
                        entered_password <= (others => '0');
                        digit_count <= 0;
                    end if;

                when st_LOCKED_OUT =>
                    if lockout_counter > 0 then
                        lockout_counter <= lockout_counter - 1;
                    else
                        current_state <= st_IDLE;
                        attempt_count <= 0;
                        entered_password <= (others => '0');
                        digit_count <= 0;
                    end if;

                when others =>
                    current_state <= st_IDLE;
            end case;
        end if;
    end process;

    --==========================================================================
    -- Output Logic
    --==========================================================================
    process(current_state, entered_password, digit_count, key_value, key_valid)
    begin
        lock_status <= '1';
        wrong_alert <= '0';
        success_led <= '0';
        seg_display <= (others => '1');
        digit_select <= (others => '1');

        case current_state is
            when st_IDLE =>
                lock_status <= '1';
                seg_display <= "0111111";  -- dash

            when st_INPUT =>
                lock_status <= '1';
                -- Show current digit count
                case digit_count is
                    when 0 => digit_select <= "1111";
                    when 1 =>
                        digit_select <= "1110";
                        seg_display <= bcd_to_7seg(key_value when key_valid = '1' else x"1");
                    when 2 =>
                        digit_select <= "1101";
                        seg_display <= bcd_to_7seg(key_value when key_valid = '1' else x"2");
                    when 3 =>
                        digit_select <= "1011";
                        seg_display <= bcd_to_7seg(key_value when key_valid = '1' else x"3");
                    when 4 =>
                        digit_select <= "0111";
                        seg_display <= bcd_to_7seg(key_value when key_valid = '1' else x"4");
                    when others =>
                        digit_select <= "1111";
                end case;

            when st_VERIFY =>
                lock_status <= '1';

            when st_UNLOCKED =>
                lock_status <= '0';
                success_led <= '1';
                seg_display <= "1000000";  -- O

            when st_WRONG_ATTEMPT =>
                lock_status <= '1';
                wrong_alert <= '1';
                seg_display <= "0000110";  -- E for error

            when st_LOCKED_OUT =>
                lock_status <= '1';
                wrong_alert <= '1';
                seg_display <= "0000110";  -- E for error

            when others =>
                lock_status <= '1';
        end case;
    end process;

end Behavioral;
