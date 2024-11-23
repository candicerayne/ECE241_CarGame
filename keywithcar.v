/*
*   Displays a pattern, which is read from a small memory, at (x,y) on the VGA output.
*   To set coordinates, first place the desired value of y onto SW[6:0] and press KEY[1].
*   Next, place the desired value of x onto SW[7:0] and then press KEY[2]. The (x,y)
*   coordinates are displayed (in hexadecimal) on (HEX3-2,HEX1-0). Finally, press KEY[3]
*   to draw the pattern at location (x,y).
*/
module vga_demo(CLOCK_50, SW, KEY,
				VGA_R, VGA_G, VGA_B,
				VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK, PS2_CLK, PS2_DAT);
	
	input CLOCK_50;	
	input [2:0] SW;
	input [3:0] KEY;
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_HS;
	output VGA_VS;
	output VGA_BLANK_N;
	output VGA_SYNC_N;
	output VGA_CLK;
	inout PS2_CLK, PS2_DAT;	
	
	 reg [7:0] X;           // starting x location of object
	 reg [6:0] Y;           // starting y location of object
    wire [2:0] XC, YC;      // used to access object memory
    wire Ex, Ey, By, Bx;
	 wire [7:0] cVGA_X;       // x location of each object pixel
	 wire [6:0] cVGA_Y;       // y location of each object pixel
	 wire [2:0] carcolour;   // color of each object pixel
	wire [7:0] bVGA_X;       // x location of each object pixel
	wire [6:0] bVGA_Y;       // y location of each object pixel
	wire [2:0] backcolour;   // color of each object pixel
	reg [2:0] oColour;
	reg [7:0] oX;
	reg [6:0] oY;
	
   

    count U3 (CLOCK_50, KEY[0], Ex, XC);    // column counter
        defparam U3.n = 3;
    // enable XC when VGA plotting starts
    regn U5 (1'b1, KEY[0], 1'b1, CLOCK_50, Ex);
        defparam U5.n = 1;
    count U4 (CLOCK_50, KEY[0], Ey, YC);    // row counter
        defparam U4.n = 3;
    // enable YC at the end of each object row
    assign Ey = (XC == 3'b111);

    car5 U6 ({YC,XC}, CLOCK_50, carcolour);
    // the object memory takes one clock cycle to provide data, so store
    // the current values of (x,y) addresses to remain synchronized
    regn U7 (X + XC, KEY[0], 1'b1, CLOCK_50, cVGA_X);
        defparam U7.n = 8;
    regn U8 (Y + YC, KEY[0], 1'b1, CLOCK_50, cVGA_Y);
        defparam U8.n = 7;
		  
    assign plot = 1'b1;
	 
	 
	 wire EnterEn, LeftEn, RightEn;
	 wire HSecEn, QSecEn, ESecEn, Clock;
	 
	 // Keyboard module instance
    keyboard kinst(
        .CLOCK_50(CLOCK_50),
        .KEY(KEY[0]),
        .PS2_CLK(PS2_CLK),
        .PS2_DAT(PS2_DAT),
        .EnterEn(EnterEn),
        .LeftEn(LeftEn),
        .RightEn(RightEn)
    );
	 
	 speed s1(.CLOCK_50(CLOCK_50), .SW(SW), .KEY(KEY[0]), .HSecEn(HSecEn), .QSecEn(QSecEn), .ESecEn(ESecEn));
	 select_speed s2(.SW(SW), .HSecEn(HSecEn), .QSecEn(QSecEn), .ESecEn(ESecEn), .Clock(Clock));
	 
	 

	 // Determine car position based on lane selection
	reg current, next;
	reg [7:0] next_X;
	reg [6:0] next_Y;
	//reg resetb;
	
	always @(LeftEn, RightEn, current)
	begin
	case (current)
	2'b00:	if (plot) begin
					next_X = 8'd75;
					next_Y = 7'd70;
					next = 2'b01;
				end 
				else begin
					next_X = 8'd0;
					next_Y = 7'd0;
					next = 2'b00;
				end 
	2'b01: begin
			if (LeftEn == 1'b1) begin
				next_X = X - 8'd35;
				next_Y = 7'd70;
				next = 2'b01;
				end
			else if (RightEn == 1'b1) begin
				next_X = X + 8'd35;
				next_Y = 7'd70;
				next = 2'b01;
				end
			else begin
				next_X = X;
				next_Y = 7'd70;
				next = 2'b01;
				end
			next = 2'b01;
			end
	default: begin
				next = 2'b00;
				next_X = 8'd75;
				next_Y = 7'd70;
				end
	endcase
	end
		
	always @(posedge Clock)
	begin
		if (KEY[0] == 1'b0) begin
			current <= 0;
			X <= 8'd75;
			Y <= 7'd70;
			end
		else begin
			current <= next;
			X <= next_X;
			Y <= next_Y;
		end
	end
	
	reg [1:0] draw, next_draw;
	
always @(posedge CLOCK_50 or negedge KEY[0]) begin
    if (!KEY[0]) begin
        draw <= 2'b00;
        oColour <= carcolour;
        oX <= cVGA_X;
        oY <= cVGA_Y;
    end else begin
        case (draw)
        2'b00: begin
            // Draw the car
            oColour <= carcolour; // Car's actual color
            oX <= cVGA_X;
            oY <= cVGA_Y;
            draw <= 2'b01;
        end
        2'b01: begin
            // Erase the car (draw black square)
            oColour <= 3'b000; // Black
            oX <= cVGA_X;
            oY <= cVGA_Y;
            draw <= 2'b00; // Cycle back to drawing state
        end
        default: begin
            draw <= 2'b00; // Default to drawing state
        end
        endcase
    end

	
	always @(posedge CLOCK_50)
	begin
	if (KEY[0])
		draw <= 2'b00;
	else
		draw <= next_draw;
	end

    // connect to VGA controller
    vga_adapter VGA (
			.resetn(KEY[0]),
			.clock(CLOCK_50),
			.colour(oColour),
			.x(oX),
			.y(oY),
			.plot(1'b1),
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

module count (Clock, Resetn, E, Q);
    parameter n = 8;
    input Clock, Resetn, E;
    output reg [n-1:0] Q;

    always @ (posedge Clock)
        if (Resetn == 0)
            Q <= 0;
        else if (E)
                Q <= Q + 1;
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
        default: Clock = 3'b000;
        endcase
    end
endmodule

