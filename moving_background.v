module background_scroll(
    CLOCK_50, SW, KEY, VGA_R, VGA_G, VGA_B,
    VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK
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

    wire [7:0] VGA_X;
    wire [6:0] VGA_Y;
    reg [7:0] VGA_COLOR;
    reg plot;

    reg [6:0] scroll_offset = 0;

    wire half_sec_enable, quarter_sec_enable, eighth_sec_enable;


    speed s1(.CLOCK_50(CLOCK_50), .SW(SW), .LEDR({half_sec_enable, quarter_sec_enable, eighth_sec_enable})
    );

    always @(posedge CLOCK_50) begin
        if (!KEY[0]) begin
            scroll_offset <= 0; 
        end else begin
            if (half_sec_enable && SW[3]) begin
                scroll_offset <= scroll_offset + SCROLL_SPEED;
            end else if (quarter_sec_enable && SW[2]) begin
                scroll_offset <= scroll_offset + SCROLL_SPEED;
            end else if (eighth_sec_enable && SW[1]) begin
                scroll_offset <= scroll_offset + SCROLL_SPEED;
            end

            //wrap aroound
            if (scroll_offset >= YSCREEN) begin
                scroll_offset <= 0;
            end
        end
    end

    wire [6:0] adjusted_Y;
    assign adjusted_Y = (VGA_Y + scroll_offset) % YSCREEN;

    // VGA adapter instantiation
    vga_adapter VGA (
        .resetn(KEY[0]),
        .clock(CLOCK_50),
        .colour(VGA_COLOR),
        .x(VGA_X),
        .y(adjusted_Y), // use adjusted_Y to create scrolling
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
