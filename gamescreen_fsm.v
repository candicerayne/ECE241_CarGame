module gamescreen_fsm(
    input CLOCK_50, 
    input [3:0] KEY,
    output reg [1:0] SCREEN 
);

	 wire GAME_WIN;
	 wire GAME_LOSE;
	 wire ENTER;
	 wire RESETN;

	 assign GAME_WIN = KEY[0];
	 assign GAME_LOSE = KEY[1];
	 assign ENTER = KEY[2];
	 assign RESETN = KEY[3];

    parameter TITLE_SCREEN = 2'b00;
    parameter BACKGROUND_SCREEN = 2'b01;
    parameter GAME_WIN_SCREEN = 2'b10;
    parameter GAME_LOSE_SCREEN = 2'b11;

    reg [1:0] current_state, next_state;

    always @(posedge CLOCK_50 or negedge RESETN) begin
        if (!RESETN)
            current_state <= TITLE_SCREEN;
        else
            current_state <= next_state;
    end


    always @(*) begin
        case (current_state)
            TITLE_SCREEN: begin
                if (ENTER)
                    next_state = BACKGROUND_SCREEN;
                else
                    next_state = TITLE_SCREEN;
            end

            BACKGROUND_SCREEN: begin
                if (GAME_WIN)
                    next_state = GAME_WIN_SCREEN;
                else if (GAME_LOSE)
                    next_state = GAME_LOSE_SCREEN;
                else
                    next_state = BACKGROUND_SCREEN;
            end
 
            GAME_WIN_SCREEN: begin
                if (RESETN)
                    next_state = TITLE_SCREEN;
                else
                    next_state = GAME_WIN_SCREEN;
            end

            GAME_LOSE_SCREEN: begin
                if (RESETN)
                    next_state = TITLE_SCREEN;
                else
                    next_state = GAME_LOSE_SCREEN;
            end

            default: next_state = TITLE_SCREEN;
        endcase
    end

    always @(*) begin
        SCREEN = current_state;
    end

endmodule
