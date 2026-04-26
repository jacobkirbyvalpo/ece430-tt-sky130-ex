/*
 * Copyright (c) 2026 Jacob Kirby
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_jacobkirbyvalpo_pm32 (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    wire rst;
    wire start;
    wire done;

    wire [31:0] mc;
    wire [31:0] mp;
    wire [63:0] p;

    assign rst = ~rst_n;
    assign start = ui_in[7];

    assign mc = {25'b0, ui_in[6:0]};
    assign mp = {24'b0, uio_in[7:0]};

    pm32 pm32_inst (
        .clk(clk),
        .rst(rst),
        .start(start),
        .mc(mc),
        .mp(mp),
        .p(p),
        .done(done)
    );

    assign uo_out[6:0] = p[6:0];
    assign uo_out[7] = done;

    assign uio_out = 8'b0;
    assign uio_oe = 8'b0;

    wire _unused = &{ena, p[63:7], 1'b0};

endmodule
