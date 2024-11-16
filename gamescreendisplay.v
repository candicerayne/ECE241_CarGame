module gamescreendisplay(
    input CLOCK_50,
    input RESETN,
    input ENTER,
    input GAME_WIN,
    input GAME_LOSE,
    output [7:0] VGA_R,
    output [7:0] VGA_G,
    output [7:0] VGA_B,
    output VGA_HS,
    output VGA_VS,
    output VGA_BLANK_N,
    output VGA_SYNC_N,
    output VGA_CLK
);
    wire [1:0] SCREEN;

    gamedisplay_fsm fsm (
        .CLOCK_50(CLOCK_50),
        .RESETN(RESETN),
        .ENTER(ENTER),
        .GAME_WIN(GAME_WIN),
        .GAME_LOSE(GAME_LOSE),
        .SCREEN(SCREEN)
    );

    reg [7:0] VGA_COLOR;
    wire [3:0] title_color, background_color, win_color, lose_color;
    wire [4:0] pixel_address;

    assign pixel_address = VGA_X[4:0] + VGA_Y[4:0];

    title tinst (
        .address(pixel_address),
        .clock(CLOCK_50),
        .data(4'b0),
        .wren(1'b0),
        .q(title_color)
    );

    background binst (
        .address(pixel_address),
        .clock(CLOCK_50),
        .data(4'b0),
        .wren(1'b0),
        .q(background_color)
    );

    win winst (
        .address(pixel_address),
        .clock(CLOCK_50),
        .data(4'b0),
        .wren(1'b0),
        .q(win_color)
    );

    lose linst (
        .address(pixel_address),
        .clock(CLOCK_50),
        .data(4'b0),
        .wren(1'b0),
        .q(lose_color)
    );

    always @(*) begin
        case (SCREEN)
            2'b00: VGA_COLOR = {title_color, title_color};   
            2'b01: VGA_COLOR = {background_color, background_color}; 
            2'b10: VGA_COLOR = {win_color, win_color};        
            2'b11: VGA_COLOR = {lose_color, lose_color};   
            default: VGA_COLOR = 8'b000;       
        endcase
    end

    vga_adapter VGA (
        .resetn(RESETN),
        .clock(CLOCK_50),
        .colour(VGA_COLOR),
        .x(VGA_X),
        .y(VGA_Y),
        .plot(1'b1),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_SYNC_N(VGA_SYNC_N),
        .VGA_CLK(VGA_CLK)
    );

    defparam VGA.RESOLUTION = "160x120";
    defparam VGA.MONOCHROME = "FALSE";
    defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
    defparam VGA.BACKGROUND_IMAGE = "black.mif";

endmodule
