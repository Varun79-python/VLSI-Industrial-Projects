//==============================================================================
// Project 1: FPGA-Based Traffic Light Controller with Priority System
// Description: Controls traffic lights at a 4-way intersection with 
//              emergency vehicle priority override.
// Tools: ModelSim / Vivado / Xilinx ISE
// Author: VLSI Internship Project
//==============================================================================

`timescale 1ns / 1ps

module traffic_light_controller (
    input  wire        clk,          // System clock (e.g., 50 MHz)
    input  wire        rst_n,        // Active-low reset
    input  wire        emergency,    // Emergency vehicle priority signal
    output reg  [2:0]  ns_light,     // North-South light: [2]=Red, [1]=Yellow, [0]=Green
    output reg  [2:0]  ew_light,     // East-West light:   [2]=Red, [1]=Yellow, [0]=Green
    output reg  [3:0]  ns_count,     // NS countdown display
    output reg  [3:0]  ew_count      // EW countdown display
);

    //==========================================================================
    // State Encoding
    //==========================================================================
    localparam [2:0] NS_GREEN  = 3'b000,  // NS=Green,  EW=Red
                     NS_YELLOW = 3'b001,  // NS=Yellow, EW=Red
                     EW_GREEN  = 3'b010,  // NS=Red,    EW=Green
                     EW_YELLOW = 3'b011,  // NS=Red,    EW=Yellow
                     EMERGENCY = 3'b100;  // Emergency override state

    reg [2:0] current_state, next_state;

    //==========================================================================
    // Timing Parameters (in clock cycles)
    // Assuming 1 Hz enable pulse for simplicity; adjust for actual clock
    //==========================================================================
    localparam GREEN_TIME  = 4'd10;  // 10 seconds green
    localparam YELLOW_TIME = 4'd3;   // 3 seconds yellow
    localparam EMERGENCY_TIME = 4'd5; // 5 seconds for emergency

    reg [3:0] timer;
    reg       timer_done;
    reg       emergency_prev;

    //==========================================================================
    // Timer Counter
    //==========================================================================
    reg tick_1hz;       // 1 Hz enable pulse (placeholder)
    reg [25:0] clk_cnt; // Clock divider counter

    // Clock divider: generates 1 Hz tick from 50 MHz clock
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_cnt  <= 26'd0;
            tick_1hz <= 1'b0;
        end else if (clk_cnt == 26'd49_999_999) begin
            clk_cnt  <= 26'd0;
            tick_1hz <= 1'b1;
        end else begin
            clk_cnt  <= clk_cnt + 1'b1;
            tick_1hz <= 1'b0;
        end
    end

    // Timer countdown
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            timer      <= 4'd0;
            timer_done <= 1'b0;
        end else if (tick_1hz) begin
            if (timer == 4'd0) begin
                timer_done <= 1'b1;
            end else begin
                timer      <= timer - 1'b1;
                timer_done <= 1'b0;
            end
        end else begin
            timer_done <= 1'b0;
        end
    end

    //==========================================================================
    // Emergency Edge Detection
    //==========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            emergency_prev <= 1'b0;
        else
            emergency_prev <= emergency;
    end

    //==========================================================================
    // State Register
    //==========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state <= NS_GREEN;
        else if (tick_1hz)
            current_state <= next_state;
    end

    //==========================================================================
    // Next State Logic
    //==========================================================================
    always @(*) begin
        next_state = current_state;
        
        case (current_state)
            NS_GREEN: begin
                if (emergency && !emergency_prev)
                    next_state = EMERGENCY;
                else if (timer_done)
                    next_state = NS_YELLOW;
            end

            NS_YELLOW: begin
                if (emergency && !emergency_prev)
                    next_state = EMERGENCY;
                else if (timer_done)
                    next_state = EW_GREEN;
            end

            EW_GREEN: begin
                if (emergency && !emergency_prev)
                    next_state = EMERGENCY;
                else if (timer_done)
                    next_state = EW_YELLOW;
            end

            EW_YELLOW: begin
                if (emergency && !emergency_prev)
                    next_state = EMERGENCY;
                else if (timer_done)
                    next_state = NS_GREEN;
            end

            EMERGENCY: begin
                if (timer_done && !emergency)
                    next_state = NS_GREEN;
            end

            default: next_state = NS_GREEN;
        endcase
    end

    //==========================================================================
    // Timer Load Logic
    //==========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            timer <= GREEN_TIME;
        end else if (tick_1hz && timer_done) begin
            case (next_state)
                NS_GREEN:  timer <= GREEN_TIME;
                NS_YELLOW: timer <= YELLOW_TIME;
                EW_GREEN:  timer <= GREEN_TIME;
                EW_YELLOW: timer <= YELLOW_TIME;
                EMERGENCY: timer <= EMERGENCY_TIME;
                default:   timer <= GREEN_TIME;
            endcase
        end
    end

    //==========================================================================
    // Output Logic - Traffic Lights
    // Light encoding: [2]=Red, [1]=Yellow, [0]=Green
    //==========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ns_light <= 3'b100;  // NS Red
            ew_light <= 3'b100;  // EW Red
        end else begin
            case (current_state)
                NS_GREEN: begin
                    ns_light <= 3'b001;  // NS Green
                    ew_light <= 3'b100;  // EW Red
                end
                NS_YELLOW: begin
                    ns_light <= 3'b010;  // NS Yellow
                    ew_light <= 3'b100;  // EW Red
                end
                EW_GREEN: begin
                    ns_light <= 3'b100;  // NS Red
                    ew_light <= 3'b001;  // EW Green
                end
                EW_YELLOW: begin
                    ns_light <= 3'b100;  // NS Red
                    ew_light <= 3'b010;  // EW Yellow
                end
                EMERGENCY: begin
                    ns_light <= 3'b100;  // NS Red (all stop for emergency)
                    ew_light <= 3'b100;  // EW Red
                end
                default: begin
                    ns_light <= 3'b100;
                    ew_light <= 3'b100;
                end
            endcase
        end
    end

    //==========================================================================
    // Output Logic - Countdown Displays
    //==========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ns_count <= 4'd0;
            ew_count <= 4'd0;
        end else begin
            case (current_state)
                NS_GREEN, NS_YELLOW: begin
                    ns_count <= timer;
                    ew_count <= 4'd0;
                end
                EW_GREEN, EW_YELLOW: begin
                    ns_count <= 4'd0;
                    ew_count <= timer;
                end
                EMERGENCY: begin
                    ns_count <= timer;
                    ew_count <= timer;
                end
                default: begin
                    ns_count <= 4'd0;
                    ew_count <= 4'd0;
                end
            endcase
        end
    end

endmodule
