//==============================================================================
// Module: Seven Segment Decoder
// Description: Converts 4-bit binary to 7-segment display output
//              Used for traffic light countdown display
//==============================================================================

`timescale 1ns / 1ps

module seven_segment_decoder (
    input  wire [3:0] binary_in,   // 4-bit binary input (0-9)
    output reg  [6:0] seg_out      // 7-segment output (a,b,c,d,e,f,g)
);

    //==========================================================================
    // 7-Segment Encoding (active low: 0 = LED ON)
    //   a
    //  ---
    // f | | b
    //  -g-
    // e | | c
    //  ---
    //   d
    //==========================================================================
    always @(*) begin
        case (binary_in)
            4'd0: seg_out = 7'b1000000;  // 0
            4'd1: seg_out = 7'b1111001;  // 1
            4'd2: seg_out = 7'b0100100;  // 2
            4'd3: seg_out = 7'b0110000;  // 3
            4'd4: seg_out = 7'b0011001;  // 4
            4'd5: seg_out = 7'b0010010;  // 5
            4'd6: seg_out = 7'b0000010;  // 6
            4'd7: seg_out = 7'b1111000;  // 7
            4'd8: seg_out = 7'b0000000;  // 8
            4'd9: seg_out = 7'b0010000;  // 9
            default: seg_out = 7'b1111111; // OFF (blank)
        endcase
    end

endmodule
