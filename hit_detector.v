module hit_detector(CLOCK_50, EnterEn, x_car, x_po, y_po, x_coin, y_coin, CoinEn, PoliceEn);
    input CLOCK_50, EnterEn;
    input [4:0] x_car, x_po, y_po;
    input [2:0] x_coin, y_coin;
    output reg CoinEn, PoliceEn;

    parameter IDLE = 2'b00, NO_HIT = 2'b01, COIN = 2'b10, POLICE = 2'b11;
    reg [1:0] current, next;
    always @(*) begin
    case (current)
        IDLE: begin
            if (EnterEn)
                next = NO_HIT;
            else
                next = IDLE;
        end
        NO_HIT: begin
                if ((y_po = 7'd70) && (x_car > x_po) && (x_car < x_po + 5'd20))  // police <- car
                    next = POLICE;
                else if ((y_po = 7'd70) && (x_po < x_car + 5'd20) && (x_po > x_car))  // car -> police
                    next = POLICE;
                else if ((y_coin = 7'd70) && (x_car > x_coin) && (x_car < x_coin + 3'd8)) // 8x8
                    next = COIN;
                else if ((y_coin = 7'd70) && (xx_coin < x_car + 3'd8) && (x_coin > x_car)) // 8x8
                    next = COIN;
                else
                    next = NO_HIT;
        end
        COIN: begin
                next = NO_HIT;
        end
        POLICE: begin
                next = NO_HIT;
        end
        default: next = IDLE;
    endcase
    end

    always @(posedge CLOCK_50)
    begin
        if (KEY[0] == 1'b0)
            current <= 2'b00;
        else
            current <= next;
    end

    assign CoinEn = (current == COIN);
    assign PoliceEn = (current == POLICE);
endmodule
