`timescale 1ns / 1ps

module background_scroll_tb();

    reg CLOCK_50;
    reg [3:0] SW;
    reg [3:0] KEY;


    wire [7:0] VGA_X;
    wire [6:0] VGA_Y;
    wire [6:0] adjusted_Y;

    background_scroll s1(
        .CLOCK_50(CLOCK_50),
        .SW(SW),
        .KEY(KEY),
        .VGA_R(),   
        .VGA_G(),
        .VGA_B(),
        .VGA_HS(),
        .VGA_VS(),
        .VGA_BLANK_N(),
        .VGA_SYNC_N(),
        .VGA_CLK()
    );

    always
        #10 CLOCK_50 = ~CLOCK_50;

    initial 
    begin
        CLOCK_50 <= 0;
        #10 SW[3]=0;  
        #10 SW[3]=1;       

        //test half-second
        SW = 4'b0100;          
        #10000000;            

        //test quarter-second
        SW = 4'b0010;    
        #10000000;         

        //test eighth-second
        SW = 4'b0001;         
        #1000000;

    end
endmodule
