module keyboard(CLOCK_50, SW, PS2_CLK, PS2_DAT, LEDR);
    // make code -> when key is pressed

    // enter make code: 5A
    // enter break code: F0,5A
    // left arrow key make code: E0,6B
    // left arrow key break code: E0,F0,6B
    // right arrow key make code: E0,74
    // right arrow key break code: E0,F0,74

    input CLOCK_50;
    //output reg EnterEn, LeftEn, RightEn;    // key enable signals
	reg EnterEn, LeftEn, RightEn;
	output [2:0] LEDR;
	input [0:0] SW;
	inout PS2_CLK, PS2_DAT;


   wire [7:0] received_data;
   reg [7:0] key_data;
   wire received_data_en;


    PS2_Controller keyb(.CLOCK_50(CLOCK_50), .reset(~SW[0]), .PS2_CLK(PS2_CLK), .PS2_DAT(PS2_DAT), .received_data(received_data), .received_data_en(received_data_en));


    // shift register to load in received_data bit when received_en is high
    // shift reg in Altera_UP_PS2_Data_In.v loads val into received_data[0] only
    always @(posedge CLOCK_50) begin
        if (SW[0]) begin
            key_data <= 8'h0;
				end
        else if (received_data_en) begin
            key_data <= received_data;
        end
    end

    // State machine to detect make and break codes
    parameter ENTER = 8'h5A, LEFT = 8'h6B, RIGHT = 8'h74, EXTENDED = 8'hE0, BREAK = 8'hF0,      	// key codes
                IDLE = 3'b000, KEY_PRESSED = 3'b001, EXT_MAKE_CODE = 3'b010, BREAK_CODE = 3'b011, ENTER_KEY = 3'b100, LEFT_KEY = 3'b101, RIGHT_KEY = 3'b110;           // state codes

    reg [1:0] y, Y;     // current and next state

    always @(*) begin
        case (y)
        IDLE:   begin
                    if (received_data_en)
			Y = KEY_PRESSED;
                    else
                        Y = IDLE;
                end
		KEY_PRESSED: begin
				if (key_data == ENTER) begin             // key_data = 5A
					Y = ENTER_KEY;
				end
				 else if (key_data == EXTENDED)
					Y = EXT_MAKE_CODE;
				else if (key_data == BREAK)
					Y = BREAK_CODE;
				else
					Y = IDLE;
			     end
        EXT_MAKE_CODE:  begin
                            if (key_data == LEFT) begin              // key_data = E0,6B
				Y = LEFT_KEY;
                            end
                            else if (key_data == RIGHT) begin        // key_data = E0,74
				  Y = RIGHT_KEY;
                            end
                            else if (key_data == BREAK)
                                Y = BREAK_CODE;
                            else
                                Y = EXT_MAKE_CODE;
                        end
        BREAK_CODE: begin
                        if (key_data == ENTER || key_data == LEFT || key_data == RIGHT) begin
                            Y = IDLE;
                        end
                        else
                            Y = BREAK_CODE;
                    end
		  ENTER_KEY:	begin
				if (received_data_en)
					Y = IDLE;
				else
					Y = ENTER_KEY;
			end
	     LEFT_KEY:	begin
			if (received_data_en)
				Y = IDLE;
			else
				Y = LEFT_KEY;
		end
		  RIGHT_KEY:	begin
				if (received_data_en)
					Y = IDLE;
				else
					Y = RIGHT_KEY;
			end
        default: begin
		Y = IDLE;
  	end
        endcase
    end

    always @(posedge CLOCK_50) begin
        if (SW[0]) begin
            y <= IDLE;
		end
        else
            y <= Y;
    end
	 
	 
	 //assign EnterEn = (y == ENTER_KEY);
	 //assign LeftEn = (y == LEFT_KEY);
	 //assign RightEn = (y == RIGHT_KEY);
	 
	 assign LEDR[2] = (y == ENTER_KEY);
	 assign LEDR[1] = (y == LEFT_KEY);
	 assign LEDR[0] = (y == RIGHT_KEY);
endmodule
