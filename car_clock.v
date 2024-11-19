speed s1(.CLOCK_50(CLOCK_50), SW, HSecEn, QSecEn, ESecEn);
select_speed s2(.SW(SW), .HSecEn(HSecEn), .QSecEn(QSecEn), .ESecEn(ESecEn), .Clock(Clock));


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
