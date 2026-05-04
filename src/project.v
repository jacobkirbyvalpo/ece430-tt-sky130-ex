`default_nettype none

module tt_um_health_monitor_decoder (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    wire [2:0] heart_rate_sw;
    wire [2:0] oxygen_rate_sw;
    wire [1:0] display_select;
    wire [2:0] blood_pressure_sw;

    reg [7:0] heart_bpm;
    reg [7:0] oxygen_pct;
    reg [7:0] bp_sys;
    reg [7:0] bp_dia;
    reg [7:0] selected_value;

    reg hb_alarm;
    reg oxygen_alarm;
    reg bp_alarm;

    assign heart_rate_sw     = ui_in[2:0];
    assign oxygen_rate_sw    = ui_in[5:3];
    assign display_select    = ui_in[7:6];
    assign blood_pressure_sw = uio_in[2:0];

    always @* begin
        case (heart_rate_sw)
            3'b000: heart_bpm = 8'd40;
            3'b001: heart_bpm = 8'd55;
            3'b010: heart_bpm = 8'd70;
            3'b011: heart_bpm = 8'd85;
            3'b100: heart_bpm = 8'd100;
            3'b101: heart_bpm = 8'd120;
            3'b110: heart_bpm = 8'd140;
            3'b111: heart_bpm = 8'd180;
            default: heart_bpm = 8'd0;
        endcase

        case (oxygen_rate_sw)
            3'b000: oxygen_pct = 8'd85;
            3'b001: oxygen_pct = 8'd88;
            3'b010: oxygen_pct = 8'd90;
            3'b011: oxygen_pct = 8'd93;
            3'b100: oxygen_pct = 8'd96;
            3'b101: oxygen_pct = 8'd98;
            3'b110: oxygen_pct = 8'd99;
            3'b111: oxygen_pct = 8'd100;
            default: oxygen_pct = 8'd0;
        endcase

        case (blood_pressure_sw)
            3'b000: begin
                bp_sys = 8'd85;
                bp_dia = 8'd55;
            end
            3'b001: begin
                bp_sys = 8'd95;
                bp_dia = 8'd65;
            end
            3'b010: begin
                bp_sys = 8'd110;
                bp_dia = 8'd70;
            end
            3'b011: begin
                bp_sys = 8'd120;
                bp_dia = 8'd80;
            end
            3'b100: begin
                bp_sys = 8'd130;
                bp_dia = 8'd85;
            end
            3'b101: begin
                bp_sys = 8'd140;
                bp_dia = 8'd90;
            end
            3'b110: begin
                bp_sys = 8'd150;
                bp_dia = 8'd95;
            end
            3'b111: begin
                bp_sys = 8'd160;
                bp_dia = 8'd100;
            end
            default: begin
                bp_sys = 8'd0;
                bp_dia = 8'd0;
            end
        endcase

        hb_alarm = (heart_bpm < 8'd60) || (heart_bpm > 8'd100);
        oxygen_alarm = oxygen_pct < 8'd92;

        bp_alarm = (bp_sys < 8'd90) || (bp_sys > 8'd140) ||
                   (bp_dia < 8'd60) || (bp_dia > 8'd90);

        case (display_select)
            2'b00: selected_value = heart_bpm;
            2'b01: selected_value = oxygen_pct;
            2'b10: selected_value = bp_sys;
            2'b11: selected_value = bp_dia;
            default: selected_value = 8'd0;
        endcase
    end

    assign uo_out = selected_value;

    assign uio_out[3:0] = 4'b0000;
    assign uio_out[4] = hb_alarm;
    assign uio_out[5] = oxygen_alarm;
    assign uio_out[6] = bp_alarm;
    assign uio_out[7] = hb_alarm | oxygen_alarm | bp_alarm;

    assign uio_oe = 8'b11110000;

    wire _unused = &{ena, clk, rst_n, uio_in[7:3], 1'b0};

endmodule
