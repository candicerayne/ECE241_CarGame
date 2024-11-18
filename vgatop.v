module vgatop(
    input CLOCK_50,
    input [0:0] KEY,
    inout PS2_CLK,
    inout PS2_DAT,
    output VGA_R, 
    output VGA_G, 
    output VGA_B,
    output VGA_HS, 
    output VGA_VS, 
    output VGA_BLANK,
    output VGA_SYNC,
    output VGA_CLK
);
    // Signals for keyboard
    wire EnterEn, LeftEn, RightEn;
    reg [1:0] lane_select;  

    // VGA signals
    wire [8:0] oX;
    wire [7:0] oY;
    wire [2:0] oColour;
    wire oPlot;

    // Keyboard module instance
    keyboard kinst(
        .CLOCK_50(CLOCK_50),
        .KEY(KEY),
        .PS2_CLK(PS2_CLK),
        .PS2_DAT(PS2_DAT),
        .EnterEn(EnterEn),
        .LeftEn(LeftEn),
        .RightEn(RightEn)
    );

    // VGA display module instance
    vgadisplay vgainst(
        .iResetn(KEY[0]),
        .iClock(CLOCK_50),
        .lane_select(lane_select),
        .oX(oX),
        .oY(oY),
        .oColour(oColour),
        .oPlot(oPlot)
    );

    // Lane selection logic
    always @(posedge CLOCK_50 or negedge KEY[0]) begin
        if (!KEY[0]) begin
            lane_select <= 2'b01; // Default lane (center)
        end else begin
            if (LeftEn && lane_select > 0)
                lane_select <= lane_select - 1;
            else if (RightEn && lane_select < 2)
                lane_select <= lane_select + 1;
        end
    end

    // VGA adapter instance
      vga_adapter VGA (
			.resetn(KEY[0]),
			.clock(CLOCK_50),
			.colour(VGA_COLOR),
			.x(VGA_X),
			.y(VGA_Y),
			.plot(~KEY[3]),
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK_N(VGA_BLANK_N),
			.VGA_SYNC_N(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "background.mif";

endmodule
