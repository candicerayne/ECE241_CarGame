module speed(CLOCK_50, SW, LEDR);
    input CLOCK_50;
    input [3:0] SW;
    output [2:0] LEDR;
	 
	 assign HEnable = SW[3] && !SW[2] && !SW[1] && !SW[0];
	 assign QEnable = !SW[3] && SW[2] && !SW[1] && !SW[0];
	 assign EEnable = !SW[3] && !SW[2] && SW[1] && !SW[0];


    half_second h1(CLOCK_50, SW[0], HEnable, QEnable, EEnable, LEDR[2]);
    quarter_second q1(CLOCK_50, SW[0], HEnable, QEnable, EEnable, LEDR[1]);
    eigth_second e1(CLOCK_50, SW[0], HEnable, QEnable, EEnable, LEDR[0]);
endmodule

module half_second(Clock, Resetn, HEnable, QEnable, EEnable, HSecEn);
    input Clock, Resetn, HEnable, QEnable, EEnable;
    output reg HSecEn;
    reg [25:0] count;

    always @(posedge Clock)
    begin
        if (Resetn == 1'b0) begin
            count <= 26'b0;
            HSecEn <= 1'b0;
        end
        else if (HEnable && !QEnable && !EEnable) begin
            count <= count + 1'b1;

            if (count == 26'b1011111010111100001000000) begin           // 25000000
                count <= 26'b0;
                HSecEn <= 1'b1;
            end
            else
                HSecEn <= 1'b0;
        end
    end
endmodule

module quarter_second(Clock, Resetn, HEnable, QEnable, EEnable, QSecEn);
   input Clock, Resetn, HEnable, QEnable, EEnable;
   output reg QSecEn;
   reg [25:0] count;

   always @ (posedge Clock) 
   begin
       if (Resetn == 1'b1) begin
            count <= 26'b0;
            QSecEn <= 1'b0;
        end
        else if (!HEnable && QEnable && !EEnable) begin
            count <= count + 1'b1;

            if (count == 26'b101111101011110000100000) begin            // 12500000
                count <= 26'b00;
                QSecEn <= 1'b1;
            end
            else
                QSecEn <= 1'b0;
        end
   end
endmodule

module eigth_second(Clock, Resetn, HEnable, QEnable, EEnable, ESecEn);
   input Clock, Resetn, HEnable, QEnable, EEnable;
   output reg ESecEn;
   reg [25:0] count;

   always @ (posedge Clock) 
   begin
       if (Resetn == 1'b1) begin
            count <= 26'b0;
            ESecEn <= 1'b0;
        end
        else if (!HEnable && !QEnable && EEnable) begin
            count <= count + 1'b1;

            if (count == 26'b10111110101111000010000) begin            // 6250000
                count <= 26'b00;
                ESecEn <= 1'b1;
            end
            else
                ESecEn <= 1'b0;
        end
   end
endmodule
