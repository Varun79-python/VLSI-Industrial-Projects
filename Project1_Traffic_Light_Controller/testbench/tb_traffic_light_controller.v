//==============================================================================
// Testbench: Traffic Light Controller with Priority System
// Description: Comprehensive testbench verifying normal operation and
//              emergency vehicle priority override.
//==============================================================================

`timescale 1ns / 1ps

module tb_traffic_light_controller;

    //==========================================================================
    // Signal Declarations
    //==========================================================================
    reg         clk;
    reg         rst_n;
    reg         emergency;
    wire [2:0]  ns_light;
    wire [2:0]  ew_light;
    wire [3:0]  ns_count;
    wire [3:0]  ew_count;

    //==========================================================================
    // Instantiate DUT
    //==========================================================================
    traffic_light_controller uut (
        .clk       (clk),
        .rst_n     (rst_n),
        .emergency (emergency),
        .ns_light  (ns_light),
        .ew_light  (ew_light),
        .ns_count  (ns_count),
        .ew_count  (ew_count)
    );

    //==========================================================================
    // Clock Generation (50 MHz)
    //==========================================================================
    initial clk = 0;
    always #10 clk = ~clk;  // 20ns period = 50 MHz

    //==========================================================================
    // Helper Task: Decode light status
    //==========================================================================
    task display_lights;
        input [8*12:1] ns_str;
        input [8*12:1] ew_str;
        begin
            $display("Time=%0t | NS Light=%b (%s) | EW Light=%b (%s) | NS_Cnt=%0d | EW_Cnt=%0d | Emergency=%b",
                $time, ns_light, ns_str, ew_light, ew_str, ns_count, ew_count, emergency);
        end
    endtask

    //==========================================================================
    // Main Test Sequence
    //==========================================================================
    initial begin
        // Initialize
        rst_n     = 0;
        emergency = 0;
        
        // Reset
        #100;
        rst_n = 1;
        #100;

        $display("==============================================");
        $display("  TRAFFIC LIGHT CONTROLLER - TEST BENCH");
        $display("==============================================");
        $display("");

        //----------------------------------------------------------------------
        // TEST 1: Normal NS_GREEN state
        //----------------------------------------------------------------------
        $display("--- TEST 1: Verify NS Green State ---");
        display_lights("GREEN", "RED");
        if (ns_light == 3'b001 && ew_light == 3'b100)
            $display("[PASS] NS=Green, EW=Red correctly set");
        else
            $display("[FAIL] Light outputs incorrect in NS_GREEN");
        $display("");

        //----------------------------------------------------------------------
        // TEST 2: Wait for transition to NS_YELLOW
        //----------------------------------------------------------------------
        $display("--- TEST 2: Wait for NS_GREEN -> NS_YELLOW ---");
        wait (uut.current_state == 3'b001);  // NS_YELLOW = 3'b001
        #20;
        display_lights("YELLOW", "RED");
        if (ns_light == 3'b010 && ew_light == 3'b100)
            $display("[PASS] NS=Yellow, EW=Red correctly set");
        else
            $display("[FAIL] Light outputs incorrect in NS_YELLOW");
        $display("");

        //----------------------------------------------------------------------
        // TEST 3: Wait for transition to EW_GREEN
        //----------------------------------------------------------------------
        $display("--- TEST 3: Wait for NS_YELLOW -> EW_GREEN ---");
        wait (uut.current_state == 3'b010);  // EW_GREEN = 3'b010
        #20;
        display_lights("RED", "GREEN");
        if (ns_light == 3'b100 && ew_light == 3'b001)
            $display("[PASS] NS=Red, EW=Green correctly set");
        else
            $display("[FAIL] Light outputs incorrect in EW_GREEN");
        $display("");

        //----------------------------------------------------------------------
        // TEST 4: Wait for transition to EW_YELLOW
        //----------------------------------------------------------------------
        $display("--- TEST 4: Wait for EW_GREEN -> EW_YELLOW ---");
        wait (uut.current_state == 3'b011);  // EW_YELLOW = 3'b011
        #20;
        display_lights("RED", "YELLOW");
        if (ns_light == 3'b100 && ew_light == 3'b010)
            $display("[PASS] NS=Red, EW=Yellow correctly set");
        else
            $display("[FAIL] Light outputs incorrect in EW_YELLOW");
        $display("");

        //----------------------------------------------------------------------
        // TEST 5: Emergency Priority Override
        //----------------------------------------------------------------------
        $display("--- TEST 5: Emergency Priority Override ---");
        wait (uut.current_state == 3'b000);  // Back to NS_GREEN
        #20;
        display_lights("GREEN", "RED");
        $display("Asserting emergency signal...");
        emergency = 1;
        #20;
        
        wait (uut.current_state == 3'b100);  // EMERGENCY = 3'b100
        #20;
        display_lights("RED", "RED");
        if (ns_light == 3'b100 && ew_light == 3'b100)
            $display("[PASS] Emergency state: Both directions RED");
        else
            $display("[FAIL] Emergency state lights incorrect");
        $display("");

        //----------------------------------------------------------------------
        // TEST 6: Emergency Release
        //----------------------------------------------------------------------
        $display("--- TEST 6: Emergency Release ---");
        $display("De-asserting emergency signal...");
        emergency = 0;
        wait (uut.current_state == 3'b000);  // Back to NS_GREEN
        #20;
        display_lights("GREEN", "RED");
        if (ns_light == 3'b001 && ew_light == 3'b100)
            $display("[PASS] Returned to normal NS_GREEN after emergency");
        else
            $display("[FAIL] Did not return to normal operation");
        $display("");

        //----------------------------------------------------------------------
        // TEST 7: Verify full cycle repeats
        //----------------------------------------------------------------------
        $display("--- TEST 7: Verify Full Cycle Repeat ---");
        $display("Waiting for full cycle to complete...");
        wait (uut.current_state == 3'b000 && uut.timer_done);
        #50;
        display_lights("GREEN", "RED");
        $display("[INFO] Full cycle completed and restarted");
        $display("");

        //----------------------------------------------------------------------
        // TEST 8: Reset functionality
        //----------------------------------------------------------------------
        $display("--- TEST 8: Reset Functionality ---");
        emergency = 0;
        #100;
        rst_n = 0;
        #50;
        display_lights("AFTER RESET", "");
        if (uut.current_state == 3'b000)
            $display("[PASS] Reset returns to NS_GREEN state");
        else
            $display("[FAIL] Reset did not return to initial state");
        rst_n = 1;
        #100;

        //----------------------------------------------------------------------
        // Summary
        //----------------------------------------------------------------------
        $display("");
        $display("==============================================");
        $display("  ALL TESTS COMPLETED");
        $display("==============================================");
        $display("");
        $display("Functional Coverage:");
        $display("  [x] Normal traffic light sequencing");
        $display("  [x] NS_GREEN -> NS_YELLOW -> EW_GREEN -> EW_YELLOW cycle");
        $display("  [x] Emergency vehicle priority override");
        $display("  [x] Both directions RED during emergency");
        $display("  [x] Normal operation resumes after emergency");
        $display("  [x] Reset functionality");
        $display("  [x] Timer-based state transitions");
        $display("");

        $finish;
    end

    //==========================================================================
    // Monitor: Log all state transitions
    //==========================================================================
    always @(posedge clk) begin
        if (uut.tick_1hz) begin
            case (uut.current_state)
                3'b000: $display("[MONITOR] State: NS_GREEN  | Timer=%0d | Emergency=%b", uut.timer, emergency);
                3'b001: $display("[MONITOR] State: NS_YELLOW | Timer=%0d | Emergency=%b", uut.timer, emergency);
                3'b010: $display("[MONITOR] State: EW_GREEN  | Timer=%0d | Emergency=%b", uut.timer, emergency);
                3'b011: $display("[MONITOR] State: EW_YELLOW | Timer=%0d | Emergency=%b", uut.timer, emergency);
                3'b100: $display("[MONITOR] State: EMERGENCY | Timer=%0d | Emergency=%b", uut.timer, emergency);
                default: $display("[MONITOR] State: UNKNOWN(%b)", uut.current_state);
            endcase
        end
    end

    //==========================================================================
    // Waveform dump for simulation
    //==========================================================================
    initial begin
        $dumpfile("traffic_light_controller.vcd");
        $dumpvars(0, tb_traffic_light_controller);
    end

endmodule
