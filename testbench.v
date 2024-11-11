`timescale 1ns / 1ps

module testbench();
    // reg signals provide inputs to the design under test (DUT)
    reg CLOCK_50, Reset;
    reg [7:0] received_data;
    reg received_data_en;

    // wire signals are used for outputs
    wire EnterEn, LeftEn, RightEn;
	wire [7:0] key_data;

    // instantiate the design under test
    keyboard K1 (CLOCK_50, Reset, received_data, EnterEn, LeftEn, RightEn, received_data_en, key_data);

    // generate a 50MHz periodic Clock waveform
    always
        #10 CLOCK_50 <= ~CLOCK_50;

    // assign signal values at various simulation times
    initial
    begin
        CLOCK_50 <= 1'b0;
        Reset <= 1'b1;
        received_data <= 8'b0;
        received_data_en <= 1'b0;

        // deassert reset
        #10 Reset <= 1'b0;

        // test for enter key:

        // make code: 5A
        #20 received_data <= 8'h5A;
            received_data_en <= 1'b1; // Assert received data
        #20 received_data_en <= 1'b0; // Deassert after one clock cycle
		#20


        // break code: F0,5A
        #20 received_data <= 8'hF0;
        received_data_en <= 1'b1;
        #20 received_data_en <= 1'b0;
        #20 received_data <= 8'h5A;
        received_data_en <= 1'b1;
        #20 received_data_en <= 1'b0;


        // test for left arrow key

        // make code: E0,6B
        #20 received_data <= 8'hE0;
        received_data_en <= 1'b1;
        #20 received_data_en <= 1'b0;
        #20 received_data <= 8'h6B;
        received_data_en <= 1'b1;
        #20 received_data_en <= 1'b0;

        // break code: E0,F0,6B
        #20 received_data <= 8'hE0;
        received_data_en <= 1'b1;
        #20 received_data_en <= 1'b0;
        #20 received_data <= 8'hF0;
        received_data_en <= 1'b1;
        #20 received_data_en <= 1'b0;
        #20 received_data <= 8'h6B;
        received_data_en <= 1'b1;
        #20 received_data_en <= 1'b0;


        // test for right arrow key
        // make code: E0,74
        #20 received_data <= 8'hE0;
        received_data_en <= 1'b1;
        #20 received_data_en <= 1'b0;
        #20 received_data <= 8'h74;
        received_data_en <= 1'b1;
        #20 received_data_en <= 1'b0;

        // break code: E0,F0,74
         #20 received_data <= 8'hE0;
         received_data_en <= 1'b1;
        #20 received_data_en <= 1'b0;
        #20 received_data <= 8'hF0;
        received_data_en <= 1'b1;
        #20 received_data_en <= 1'b0;
        #20 received_data <= 8'h74;
        received_data_en <= 1'b1;
        #20 received_data_en <= 1'b0;
    end
endmodule