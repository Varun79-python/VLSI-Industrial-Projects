//==============================================================================
// Top Module: Traffic Light Controller System
// Description: Top-level module integrating traffic light controller
//              with 7-segment display decoders for countdown
//==============================================================================

`timescale 1ns / 1ps

module traffic_light_top (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        emergency,
    output wire [2:0]  ns_light,
    output wire [2:0]  ew_light,
    output wire [6:0]  ns_seg,      // NS countdown 7-segment
    output wire [6:0]  ew_seg       // EW countdown 7-segment
);

    wire [3:0] ns_count;
    wire [3:0] ew_count;

    //==========================================================================
    // Traffic Light Controller Instance
    //==========================================================================
    traffic_light_controller u_controller (
        .clk       (clk),
        .rst_n     (rst_n),
        .emergency (emergency),
        .ns_light  (ns_light),
        .ew_light  (ew_light),
        .ns_count  (ns_count),
        .ew_count  (ew_count)
    );

    //==========================================================================
    // 7-Segment Decoder for NS Display
    //==========================================================================
    seven_segment_decoder u_ns_display (
        .binary_in (ns_count),
        .seg_out   (ns_seg)
    );

    //==========================================================================
    // 7-Segment Decoder for EW Display
    //==========================================================================
    seven_segment_decoder u_ew_display (
        .binary_in (ew_count),
        .seg_out   (ew_seg)
    );

endmodule
