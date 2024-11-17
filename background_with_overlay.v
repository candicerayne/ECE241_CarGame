module background_with_overlay(
    CLOCK_50, SW, KEY, VGA_R, VGA_G, VGA_B,
    VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK
);

    parameter XSCREEN = 160; 
    parameter YSCREEN = 120;  
    parameter policecar_WIDTH = 30; 
    parameter policecar_HEIGHT = 30;

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

   
    reg [7:0] policecar_X = 0;
    reg [6:0] policecar_Y = 0;

   
    wire [3:0] policecar_color;
    wire [4:0] policecar_address;
    wire policecar_active;


    wire enable_movement;

 
    speed speedinst(
        .CLOCK_50(CLOCK_50),
        .SW(SW),
        .LEDR(enable_movement)
    );


    policecar policecarmeminst (
        .address(policecar_address),
        .clock(CLOCK_50),
        .data(4'b0),   
        .wren(1'b0),      
        .q(policecar_color) 
    );

  
    always @(posedge CLOCK_50) begin
        if (!KEY[0]) begin
            policecar_X <= 20; 
            policecar_Y <= 0; 
        end 
        else if (enable_movement) begin
            policecar_X <= (policecar_X + 1) % XSCREEN;  
            policecar_Y <= (policecar_Y + 1) % YSCREEN;  
        end
    end

    assign policecar_active = (VGA_X >= policecar_X && VGA_X < policecar_X + policecar_WIDTH &&
                               VGA_Y >= policecar_Y && VGA_Y < policecar_Y + policecar_HEIGHT);

    assign policecar_address = (VGA_Y - policecar_Y) * policecar_WIDTH + (VGA_X - policecar_X);

    reg [3:0] VGA_COLOUR;
    always @(*) begin
        if (policecar_active)
            VGA_COLOUR = policecar_color;
        else
            VGA_COLOUR = 4'b0000;
    end

    // VGA Adapter instantiation
    vga_adapter VGA (
        .resetn(KEY[0]),
        .clock(CLOCK_50),
        .colour(VGA_COLOUR),
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
    defparam VGA.BACKGROUND_IMAGE = "background.mif"; 

endmodule
