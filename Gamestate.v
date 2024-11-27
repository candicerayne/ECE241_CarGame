module Gamestate(CLOCK_50, KEY, SW, PS2_CLK, PS2_DAT,VGA_R, VGA_G, VGA_B,
				VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK, LEDR);
    // port instantiations
    input CLOCK_50;//EnterEn, Load;
    input [2:0] SW;
    input [3:0] KEY;
	 inout PS2_DAT, PS2_CLK;
	 output [7:0] VGA_R;
	 output [7:0] VGA_G;
	 output [7:0] VGA_B;
	 output VGA_HS;
	 output VGA_VS;
	 output VGA_BLANK_N;
	 output VGA_SYNC_N;
	 output VGA_CLK;
	 output [7:0]LEDR;

	 wire HitEn, DriveEn, coin_count, win_screen, lose_screen;
	
	 wire Load, EnterEn, LeftEn, RightEn, max_coin, HSecEn, QSecEn, ESecEn, Reset;
	
	 wire [7:0] X;           // starting x location of object
	 wire [6:0] Y;           // starting y location of object
    wire [7:0] XC;
	 wire [6:0] YC;      // used to access object memory
    wire Ex, Ey;
	 wire [14:0] address;
	
	 wire [2:0] backcolour, titlecolour, wincolour, losecolour;
	 reg [2:0] oColour;
	 wire [7:0] oX;
	 wire [6:0] oY;
	

    // wires and regs
    wire [3:0] Score;
    wire Clock, plot;

    // port assignments
    assign Reset = KEY[0];
	 parameter WIDTH = 8'd160;
	
	 assign LEDR[2:0] = uy;
	 assign X=0;
	 assign Y=0;
	 assign HitEn = KEY[3];
	 assign address = ((YC*WIDTH)+XC);

    // module instantiations
    keyboard kinst(
        .CLOCK_50(CLOCK_50),
        .KEY(KEY[0]),
        .PS2_CLK(PS2_CLK),
        .PS2_DAT(PS2_DAT),
        .EnterEn(EnterEn),
        .LeftEn(LeftEn),
        .RightEn(RightEn)
    );
	 
    speed s1(.CLOCK_50(CLOCK_50), .SW(SW[2:0]), .KEY(KEY[0]), .HSecEn(HSecEn), .QSecEn(QSecEn), .ESecEn(ESecEn));
    select_speed s2(.SW(SW), .HSecEn(HSecEn), .QSecEn(QSecEn), .ESecEn(ESecEn), .Clock(Clock));
	 
	 background b1(address, CLOCK_50, backcolour);
	 title t1(address, CLOCK_50, titlecolour);
	 lose l1(address, CLOCK_50, losecolour);
	 win w1(address, CLOCK_50, wincolour);
	 
    colcount U3 (CLOCK_50, KEY[0], Ex, XC);    // column counter
    // enable XC when VGA plotting starts
    regn U5 (1'b1, KEY[0], plot, CLOCK_50, Ex);
        defparam U5.n = 1;
    rowcount U4 (CLOCK_50, KEY[0], Ey, YC);    // row counter
    // enable YC at the end of each object row
    assign Ey = (XC == 8'd159); //159
	 assign plot = (YC < 7'd120); 
    // the object memorey taks one clock cycle to provide data, so store
    // the current values of (x,y) addresses to remain synchronized
    regn U7 (X+XC, KEY[0], 1'b1, CLOCK_50, oX);
        defparam U7.n = 8;
    regn U8 (Y+YC, KEY[0], 1'b1, CLOCK_50, oY);
        defparam U8.n = 7;
    
	 score s3(.Clock(Clock), .Enable(coin_count), .Resetn(Reset), .Score(Score), .GameOver(max_coin));
	 //hit_detector h1(.CLOCK_50(CLOCK_50), .CoinEn(CoinEn), .PoliceEn(PoliceEn));
	 
	 
	 wire CoinEn, PoliceEn;
	 assign CoinEn = KEY[1];
	 assign PoliceEn = KEY[2];

	 
	  vga_adapter VGA (
			.resetn(KEY[0]),
			.clock(CLOCK_50),
			.colour(oColour),
			.x(oX),
			.y(oY),
			.plot(plot),
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
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
		

    // GameState fsm
    parameter WAIT = 3'b000, DRIVING = 3'b001, HIT = 3'b010, WIN = 3'b100, LOSE = 3'b101;
    reg [2:0] uy, Yy;

    always @(*) begin
    case (uy)
    WAIT:   if (EnterEn)
                Yy = DRIVING;
            else
                Yy = WAIT;
    DRIVING:    if (HitEn)
                    Yy = HIT;
                else
                    Yy = DRIVING;
    HIT:    /*if  (CoinEn)
                Yy = COIN;
            else*/ if (PoliceEn)
                Yy = LOSE;
            else
                Yy = HIT;
  /*  COIN:   if (max_coin)
                Yy = WIN;
            else
                Yy = DRIVING;*/
    WIN:    if (!Reset)
                Yy = WAIT;
            else
                Yy = WIN;
    LOSE:   if (!Reset)
                Yy = WAIT;
            else
                Yy = LOSE;
    default: Yy = WAIT;
    endcase
    end

    always @(posedge Clock) begin
        if (!KEY[0])
            uy <= 3'b0;
        else
            uy <= Yy;
    end

    assign DriveEn =  (uy == DRIVING);
    //assign coin_count = (uy == COIN);
    assign win_screen = (uy == WIN);
    assign lose_screen = (uy == LOSE);
	 
	 
	 
	 parameter TITLE = 2'b00, GAME = 2'b01, WIN_SCREEN = 2'b10, LOSE_SCREEN = 2'b11;
	 reg [1:0] screen, next_screen;
	 // background fsm
	 always @(*) begin
	 case (screen)
		TITLE: if (EnterEn)
					next_screen = GAME;
				else
					next_screen = TITLE;
		GAME: if (win_screen)
					next_screen = WIN_SCREEN;
				else if (lose_screen)
					next_screen = LOSE_SCREEN;
				else
					next_screen = GAME;
		WIN_SCREEN: next_screen = WIN_SCREEN;
		LOSE_SCREEN: next_screen = LOSE_SCREEN;
		default: next_screen = TITLE;
	 endcase
	 end
	 
	 
	 always @(posedge CLOCK_50) begin
		if(!KEY[0])
			screen <= TITLE;
		else
			screen <= next_screen;
	 end
	 
	 
	 wire back, title, wins, loses;
	 assign back = (screen == GAME);
	 assign title = (screen == TITLE);
	 assign wins = (screen == WIN_SCREEN);
	 assign loses = (screen == LOSE_SCREEN);
	 
	 always @(posedge CLOCK_50)
	 begin
		if (back)
			oColour <= backcolour;
		else if  (title)
			oColour <= titlecolour;
		else if  (wins)
			oColour <= wincolour;
		else if  (loses)
			oColour <= losecolour;
		else
			oColour <= 3'b000;
	 end
endmodule

module select_speed(SW, HSecEn, QSecEn, ESecEn, Clock);
    input [2:0] SW;
    input HSecEn, QSecEn, ESecEn;
    output reg Clock;

    always @(*) begin
        case (SW)
        3'b100: Clock = HSecEn;
        3'b010: Clock = QSecEn;
        3'b001: Clock = ESecEn;
        default: Clock = 1'b0;
        endcase
    end
endmodule

module regn(R, Resetn, E, Clock, Q);
    parameter n = 8;
    input [n-1:0] R;
    input Resetn, E, Clock;
    output reg [n-1:0] Q;

    always @(posedge Clock)
        if (!Resetn)
            Q <= 0;
        else if (E)
            Q <= R;
endmodule

module colcount (Clock, Resetn, E, Q);
    input Clock, Resetn, E;
    output reg [7:0] Q;

    always @ (posedge Clock)
        if (Resetn == 0)
            Q <= 0;
        else if (E)
            Q <= Q + 1;
endmodule
module rowcount (Clock, Resetn, E, Q);
    parameter n = 8;
    input Clock, Resetn, E;
    output reg [n-1:0] Q;

    always @ (posedge Clock)
        if (Resetn == 0)
            Q <= 0;
        else if (E)
            Q <= Q + 1;

endmodule
