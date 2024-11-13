module score(CLOCK_50, Enable, Resetn, Score, GameOver);
    input CLOCK_50, Enable, Resetn;
    output reg [3:0] Score;
    output reg GameOver;

    always @(posedge CLOCK_50) begin
        if (Resetn == 0) begin
            Score <= 4'b0;
            GameOver <= 1'b0;
        end
        else if (Score == 4'b1010)
            GameOver <= 1'b1;
        else if (Enable && GameOver == 1'b0)
            Score <= Score + 1'b1;
    end
endmodule