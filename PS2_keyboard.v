
module keytest(
	// Inputs
	CLOCK_50,
	KEY,

	// Bidirectionals
	PS2_CLK,
	PS2_DAT,
	
	// Outputs
	LEDR
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/

// Inputs
input				CLOCK_50;
input		[3:0]	KEY;

// Bidirectionals
inout				PS2_CLK;
inout				PS2_DAT;

// Outputs
output		[2:0]	LEDR;

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/

// Internal Wires
wire		[7:0]	ps2_key_data;
wire				ps2_key_pressed;

// Internal Registers
reg			[7:0]	last_data_received;

// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/

reg EnterEn, LeftEn, RightEn, enter, break;

always @(posedge CLOCK_50) begin
	if (KEY[0] == 1'b0) begin
		EnterEn <= 1'b0;
		LeftEn <= 1'b0;
		RightEn <= 1'b0;
		enter <= 1'b0;
		break <= 1'b0;
	end
	if (ps2_key_pressed) begin
		case (ps2_key_data)
		8'hE0: begin
				enter <= 1'b1;
				break <= 1'b0;
		end
		8'hF0: begin
				break <= 1'b1;
		end
		8'h5A: if (break == 0)
					EnterEn <= 1'b1;
				else begin
					EnterEn <= 1'b0;
					enter <= 1'b0;
					break <= 1'b0;
				end
		8'h6B: if (enter == 1)
					LeftEn <= 1'b1;
				else if (enter == 1 && break == 1) begin
					LeftEn <= 1'b0;
					enter <= 1'b0;
					break <= 1'b0;
				end
		8'h74: if (enter == 1)
					RightEn <= 1'b1;
				else if (enter == 1 && break == 1) begin
					RightEn <= 1'b0;
					enter <= 1'b0;
					break <= 1'b0;
				end
		default: begin
			EnterEn <= 1'b0;
			LeftEn <= 1'b0;
			RightEn <= 1'b0;
		end
		endcase
	end
end

/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

always @(posedge CLOCK_50)
begin
	if (KEY[0] == 1'b0)
		last_data_received <= 8'h00;
	else if (ps2_key_pressed == 1'b1)
		last_data_received <= ps2_key_data;
end

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

assign LEDR[2] = EnterEn;
assign LEDR[1] = LeftEn;
assign LEDR[0] = RightEn;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

PS2_Controller PS2 (
	// Inputs
	.CLOCK_50				(CLOCK_50),
	.reset				(~KEY[0]),

	// Bidirectionals
	.PS2_CLK			(PS2_CLK),
 	.PS2_DAT			(PS2_DAT),

	// Outputs
	.received_data		(ps2_key_data),
	.received_data_en	(ps2_key_pressed)
);

endmodule
