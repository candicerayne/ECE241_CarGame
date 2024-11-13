//background_scroll for simulation

module background_scroll(
    CLOCK_50, SW, KEY, VGA_R, VGA_G, VGA_B,
    VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK,
    VGA_X_out, VGA_Y_out, adjusted_Y_out //new outputs for testbench
);

    parameter XSCREEN = 160;       
    parameter YSCREEN = 120;      
    parameter SCROLL_SPEED = 1;    

    input CLOCK_50;
    input [3:0] SW;              
    input [3:0] KEY;
    output [7:0] VGA_R;
    output [7:0] VGA_G;
    output [7:0] VGA_B;
    output VGA_HS;
    output VGA_VS;
    output VGA_BLANK_N;
    output VGA_SYNC_N;
    output VGA_CLK;

    //new outputs for monitoring in the testbench
    output [7:0] VGA_X_out;
    output [6:0] VGA_Y_out;
    output [6:0] adjusted_Y_out;

    reg [7:0] VGA_COLOR;
    reg plot;


    reg [6:0] scroll_offset = 0;


    wire half_sec_enable, quarter_sec_enable, eighth_sec_enable;


    speed speed_control(
        .CLOCK_50(CLOCK_50),
        .SW(SW),
        .LEDR({half_sec_enable, quarter_sec_enable, eighth_sec_enable})
    );

    always @(posedge CLOCK_50) begin
        if (!KEY[0]) begin
            scroll_offset <= 0;      
        end 
        else begin
            if (half_sec_enable || quarter_sec_enable || eighth_sec_enable) begin
                scroll_offset <= scroll_offset + SCROLL_SPEED;
                
                if (scroll_offset >= YSCREEN) begin
                    scroll_offset <= 0;
                end
            end
        end
    end

    wire [6:0] adjusted_Y;
    assign adjusted_Y = (VGA_Y + scroll_offset) % YSCREEN;

    //VGA_X and VGA_Y become internal signals for VGA coordinates
    wire [7:0] VGA_X;
    wire [6:0] VGA_Y;

    //connect internal VGA_X VGA_Y and adjusted_Y to the outputs
    assign VGA_X_out = VGA_X;
    assign VGA_Y_out = VGA_Y;
    assign adjusted_Y_out = adjusted_Y;

    vga_adapter VGA (
        .resetn(KEY[0]),
        .clock(CLOCK_50),
        .colour(VGA_COLOR),
        .x(VGA_X),
        .y(adjusted_Y), // Use adjusted_Y to create scrolling effect
        .plot(plot),
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
    defparam VGA.BACKGROUND_IMAGE = "background.mif";

endmodule
