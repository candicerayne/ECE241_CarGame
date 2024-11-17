module gamescreendisplay(
    input CLOCK_50,
    input [0:1] SW, // SW[1]: Reset signal
    input [3:0] KEY, // KEY[0]: GAME_WIN, KEY[1]: GAME_LOSE, KEY[2]: ENTER, KEY[3]: RESETN
    output [7:0] VGA_R,
    output [7:0] VGA_G,
    output [7:0] VGA_B,
    output VGA_HS,
    output VGA_VS,
    output VGA_BLANK_N,
    output VGA_SYNC_N,
    output VGA_CLK
);

    // FSM output
    wire [1:0] SCREEN;

    // Column and Row counters
    wire [2:0] XC;        // Column counter output
    wire [2:0] YC;        // Row counter output
    wire column_done;     // Column counter done signal
    wire row_done;        // Row counter done signal

    // Fixed starting position (0,0)
    wire [7:0] X = 8'd0;    // Start at X = 0
    wire [6:0] Y = 7'd0;    // Start at Y = 0
    wire [7:0] VGA_X = X + XC;
    wire [6:0] VGA_Y = Y + YC;

    // Color signals from different screens
    wire [2:0] title_color, background_color, win_color, lose_color;

    // Selected color
    reg [2:0] selected_color;

    // Instantiate FSM
    gamescreen_fsm fsm_inst (
        .CLOCK_50(CLOCK_50),
        .KEY(KEY),
        .SCREEN(SCREEN)
    );

    // Instantiate Column Counter
    counter column_counter (
        .CLOCK(CLOCK_50),
        .RESETN(SW[1]),
        .ENABLE(1'b1),  // Always enabled
        .COUNT(XC),
        .DONE(column_done)
    );

    // Instantiate Row Counter
    counter row_counter (
        .CLOCK(CLOCK_50),
        .RESETN(SW[1]),
        .ENABLE(column_done), // Increment row only after column finishes
        .COUNT(YC),
        .DONE(row_done)
    );

    // Instantiate different screen memories
    title title_mem ({YC, XC}, CLOCK_50, title_color);
    background background_mem ({YC, XC}, CLOCK_50, background_color);
    win win_mem ({YC, XC}, CLOCK_50, win_color);
    lose lose_mem ({YC, XC}, CLOCK_50, lose_color);

    // Screen selection logic based on FSM state
    always @(*) begin
        case (SCREEN)
            2'b00: selected_color = title_color;       // TITLE_SCREEN
            2'b01: selected_color = background_color;  // BACKGROUND_SCREEN
            2'b10: selected_color = win_color;         // GAME_WIN_SCREEN
            2'b11: selected_color = lose_color;        // GAME_LOSE_SCREEN
            default: selected_color = 3'b000;          // Default to black
        endcase
    end

    // VGA adapter instantiation
    vga_adapter VGA (
        .resetn(KEY[3]),
        .clock(CLOCK_50),
        .colour(selected_color),
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


module counter (
    input CLOCK,
    input RESETN,
    input ENABLE,
    output reg [2:0] COUNT,
    output DONE
);
    always @(posedge CLOCK or negedge RESETN) begin
        if (!RESETN)
            COUNT <= 0;
        else if (ENABLE)
            COUNT <= (DONE) ? 0 : COUNT + 1;
    end

    assign DONE = (COUNT == 3'b111); // Done when count reaches max value (7)
endmodule
