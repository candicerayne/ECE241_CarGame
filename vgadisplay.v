module vgadisplay(
    input iResetn,
    input iClock,
    input [1:0] lane_select,   // Input to select the lane
    output [8:0] oX,           // VGA pixel coordinates
    output [7:0] oY,
    output [2:0] oColour,      // VGA pixel colour (0-7)
    output oPlot
);
    // Internal signals
    wire ld_draw, ld_background;
    wire [16:0] address;
    reg [8:0] car_x_position;
    reg [7:0] car_y_position;

    // Control module
    ctrl C0(
        .iClock(iClock),
        .iResetn(iResetn),
        .ld_draw(ld_draw),
        .ld_background(ld_background)
    );

    // Datapath module
    data D0(
        .iClock(iClock),
        .iResetn(iResetn),
        .ld_draw(ld_draw),
        .ld_background(ld_background),
        .lane_select(lane_select),
        .oX(oX),
        .oY(oY),
        .oColour(oColour),
        .oPlot(oPlot),
        .car_x_position(car_x_position),
        .car_y_position(car_y_position),
        .address(address)
    );

endmodule

module data(
    input iClock,
    input iResetn,
    input ld_draw,
    input ld_background,
    input [1:0] lane_select,   // Input for lane selection
    output reg [8:0] oX,       // VGA pixel X-coordinate
    output reg [7:0] oY,       // VGA pixel Y-coordinate
    output reg [2:0] oColour,  // VGA pixel colour
    output reg oPlot,          // VGA plot enable signal
    output reg [16:0] address
);

    // Car dimensions
    localparam CAR_WIDTH = 10; 
    localparam CAR_HEIGHT = 20;

    // Lane positions
    localparam LANE_1_X = 40;
    localparam LANE_2_X = 80;
    localparam LANE_3_X = 120;

    reg [8:0] xCount;
    reg [7:0] yCount;

    // Memory for car and background
    wire [2:0] car_color;
    wire [2:0] background_col;

    car car_mem(
        .address(address),
        .clock(iClock),
        .q(car_color)
    );

    background bg_mem(
        .address(address),
        .clock(iClock),
        .q(background_col)
    );

    // Determine car position based on lane selection
    always @(posedge iClock or negedge iResetn) begin
        if (!iResetn) begin
            car_x_position <= 0;
            car_y_position <= 0;
        end 
        else if (ld_draw) begin
            case (lane_select)
                2'b00: car_x_position <= LANE_1_X;
                2'b01: car_x_position <= LANE_2_X;
                2'b10: car_x_position <= LANE_3_X;
                default: car_x_position <= LANE_2_X;
            endcase
            car_y_position <= 90; 
        end
    end

    // Draw logic
    always @(posedge iClock) begin
    if (~iResetn) begin
        // Initialization on reset
        oPlot <= 1'b0;
        oColour <= 3'b000;
        oX <= 9'b000000000;
        oY <= 8'b00000000;
        counter <= 9'd00000;
        xCount <= 9'd0;
        yCount <= 8'd0;
        address <= 17'd0;
    end else if (ld_draw) begin
        // Drawing the car
        oPlot <= 1'b1;
        if (counter < (CAR_WIDTH * CAR_HEIGHT)) begin
            oX <= car_x_position + (counter % CAR_WIDTH);
            oY <= car_y_position + (counter / CAR_WIDTH);
            oColour <= car_color; // Fetch car pixel from memory
            counter <= counter + 1;
        end else begin
            // Reset counter after finishing car drawing
            counter <= 9'd0;
        end
    end else if (ld_background) begin
        // Drawing the background
        oPlot <= 1'b1;
        if (xCount < 160 && yCount < 120) begin
            oX <= xCount;
            oY <= yCount;
            oColour <= background_col; // Fetch background pixel from memory
            if (xCount == 159) begin
                xCount <= 9'd0;
                yCount <= yCount + 1;
            end else begin
                xCount <= xCount + 1;
            end
        end else begin
            // Reset counters after finishing background drawing
            xCount <= 9'd0;
            yCount <= 8'd0;
        end
    end else begin
        // Idle state
        oPlot <= 1'b0;
    end
end

endmodule
