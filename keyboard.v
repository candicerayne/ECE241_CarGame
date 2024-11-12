module keyboard(CLOCK_50, Reset, EnterEn, LeftEn, RightEn);
    // make code -> when key is pressed

    // enter make code: 5A
    // enter break code: F0,5A
    // left arrow key make code: E0,6B
    // left arrow key break code: E0,F0,6B
    // right arrow key make code: E0,74
    // right arrow key break code: E0,F0,74

    input CLOCK_50, Reset;
    output reg EnterEn, LeftEn, RightEn;    // key enable signals


    wire [7:0] received_data;
    reg [7:0] key_data;
    wire received_data_en;


    // Unused
    wire [7:0] the_command;
    wire send_command, PS2_CLK, PS2_DAT, command_was_sent, error_communication_timed_out;


    PS2_Controller keyb(CLOCK_50, Reset, the_command, send_command, PS2_CLK, PS2_DAT, command_was_sent, error_communication_timed_out, received_data, received_data_en);


    // shift register to load in received_data bit when received_en is high
    // shift reg in Altera_UP_PS2_Data_In.v loads val into received_data[0] only
    always @(posedge CLOCK_50) begin
        if (Reset)
            key_data <= 8'h0;
        else if (received_data_en) begin
            key_data <= received_data;
        end
    end

    // State machine to detect make and break codes
    parameter ENTER = 8'h5A, LEFT = 8'h6B, RIGHT = 8'h74, EXTENDED = 8'hE0, BREAK = 8'hF0,      // key codes
                IDLE = 2'b00, KEY_PRESSED = 2'b01, EXT_MAKE_CODE = 2'b10, BREAK_CODE = 2'b11;                        // state codes

    reg [1:0] y, Y;     // current and next state
	reg enter_en, left_en, right_en;

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
					enter_en = 1'b1;
					left_en = 1'b0;
					right_en = 1'b0;
					Y = IDLE;
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
                                enter_en = 1'b0;
				left_en = 1'b1;
				right_en = 1'b0;
                                Y = IDLE;
                            end
                            else if (key_data == RIGHT) begin        // key_data = E0,74
                                enter_en = 1'b0;
				left_en = 1'b0;
				right_en = 1'b1;
                                Y = IDLE;
                            end
                            else if (key_data == BREAK)
                                Y = BREAK_CODE;
                            else
                                Y = EXT_MAKE_CODE;
                        end
        BREAK_CODE: begin
                        if (key_data == ENTER) begin
                            enter_en = 1'b0;
			    left_en = 1'b0;
			    right_en = 1'b0;
                            Y = IDLE;
                        end
                        else if (key_data == LEFT) begin
			    enter_en = 1'b0;
                            left_en = 1'b0;
			    right_en = 1'b0;
                            Y = IDLE;
                        end
                        else if (key_data == RIGHT) begin
			    enter_en = 1'b0;
			    left_en = 1'b0;
                            right_en = 1'b0;
                            Y = IDLE;
                        end
                        else
                            Y = BREAK_CODE;
                    end
        default: begin
            Y = IDLE;
            enter_en = 1'b0;
            left_en = 1'b0;
            right_en = 1'b0;
        end
        endcase
    end

    always @(posedge CLOCK_50) begin
        if (Reset) begin
            y <= IDLE;
	    EnterEn <= 1'b0;
            LeftEn <= 1'b0;
            RightEn <= 1'b0;
		end
        else
            y <= Y;
	    EnterEn <= enter_en;
            LeftEn <= left_en;
            RightEn <= right_en;
    end
endmodule
