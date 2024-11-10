module keyboard(CLOCK_50, Reset, EnterEn, LeftEn, RightEn);
    // make code -> when key is pressed

    // enter make code: 5A
    // left arrow key make code: E0,6B
    // right arrow key make code: E0,74

    input CLOCK_50, Reset;
    output reg EnterEn, LeftEn, RightEn;    // key enable signals

    wire [7:0] received_data;

    // Unused
    wire [7:0] the_command;
    wire send_command, PS2_CLK, PS2_DAT, command_was_sent, error_communication_timed_out, received_data_en;

    PS2_Controller keyb(CLOCK_50, Reset, the_command, send_command, PS2_CLK, PS2_DAT, command_was_sent, error_communication_timed_out, received_data, received_data_en);

    parameter ENTER = 'h5A, LEFT = 'h6B, RIGHT = 'h74;

    always @(*) begin
        case (received_data)
            ENTER: EnterEn = 1'b1;      // enter key
            LEFT: LeftEn = 1'b1;        // left arrow key
            RIGHT: RightEn = 1'b1;      // right arrow key
            default: begin
                EnterEn = 1'b0;
                LeftEn = 1'b0;
                RightEn = 1'b0;
            end
        endcase
    end
endmodule