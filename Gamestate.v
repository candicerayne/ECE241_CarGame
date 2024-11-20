module GameState(CLOCK_50, KEY, SW, DriveEn, coin_count, win_screen, lose_screen);
    // port instantiations
    input CLOCK_50;//EnterEn, Load;
    input [2:0] SW;
    input [0:0] KEY;
    output DriveEn, coin_count, win_screen, lose_screen;
	wire HitEn, DriveEn, coin_count, win_screen, lose_screen;
	
	wire Load, EnterEn, LeftEn, RightEn, max_coin, CoinEn, PoliceEn, HSecEn, QSecEn, ESecEn;

    // wires and regs
    wire [3:0] Score;
    wire Clock;

    // port assignments
    assign Reset = KEY[0];

    // module instantiations
    keyboard k1(.CLOCK_50(CLOCK_50), .KEY(Reset), .PS2_CLK(PS2_CLK), PS2_DAT(PS2_DAT), .EnterEn(EnterEn), .LeftEn(LeftEn), .RightEn(RightEn));
    speed s1(.CLOCK_50(CLOCK_50), .SW(SW), .KEY(KEY[0]), .HSecEn(HSecEn), .QSecEn(QSecEn), .ESecEn(ESecEn));
    select_speed s2(.SW(SW), .HSecEn(HSecEn), .QSecEn(QSecEn), .ESecEn(ESecEn), .Clock(Clock));
    score s3(.CLOCK_50(CLOCK_50), .Enable(coin_count), .Resetn(Reset), .Score(Score), .GameOver(max_coin));
    hit_detector h1(.CLOCK_50(CLOCK_50), .CoinEn(CoinEn), .PoliceEn(PoliceEn));

    // GameState fsm
    parameter WAIT = 3'b000, LOAD = 3'b001, DRIVING = 3'b010, HIT = 3'b011, COIN = 3'b100, WIN = 3'b101, LOSE = 3'b110;
    reg [2:0] y, Y;

    always @(*) begin
    case (y)
    WAIT:   if (EnterEn)
                Y = LOAD;
            else
                Y = WAIT;
    LOAD:   if (Load)           // Load speed and pixels onto screen
                Y = DRIVING;
            else
                Y = LOAD;
    DRIVING:    if (HitEn)
                    Y = HIT;
                else
                    Y = DRIVING;
    HIT:    if  (CoinEn)
                Y = COIN;
            else if (PoliceEn)
                Y = LOSE;
            else
                Y = HIT;
    COIN:   if (max_coin)
                Y = WIN;
            else
                Y = DRIVING;
    WIN:    if (Reset)
                Y = WAIT;
            else
                Y = WIN;
    LOSE:   if (Reset)
                Y = WAIT;
            else
                Y = LOSE;
    default: Y = WAIT;
    endcase
    end

    always @(posedge Clock) begin
        if (Reset == 1'b1)
            y <= 3'b0;
        else
            y <= Y;
    end

    assign DriveEn = (y == LOAD) || (y == DRIVING);
    assign coin_count = (y == COIN);
    assign win_screen = (y == WIN);
    assign lose_screen = (y == LOSE);
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
