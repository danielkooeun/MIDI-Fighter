
module drumkit (
	// Inputs
	CLOCK_50,
	KEY,

	AUD_ADCDAT,

	// Bidirectionals
	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,

	FPGA_I2C_SDAT,

	// Outputs
	AUD_XCK,
	AUD_DACDAT,

	FPGA_I2C_SCLK,
	SW
);

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input				CLOCK_50;
input		[3:0]	KEY;
input		[9:0]	SW;

input				AUD_ADCDAT;

// Bidirectionals
inout				AUD_BCLK;
inout				AUD_ADCLRCK;
inout				AUD_DACLRCK;

inout				FPGA_I2C_SDAT;

// Outputs
output				AUD_XCK;
output				AUD_DACDAT;

output				FPGA_I2C_SCLK;

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
// Internal Wires
wire				audio_in_available;
wire		[31:0]	left_channel_audio_in;
wire		[31:0]	right_channel_audio_in;
wire				read_audio_in;

wire				audio_out_allowed;
wire		[31:0]	left_channel_audio_out;
wire		[31:0]	right_channel_audio_out;
wire				write_audio_out;

// Added components
wire [31:0] sound;
reg [11:0] address = 12'd2838;		// max address
reg [11:0] addressCount;
reg [11:0] counter;

// Internal Registers
reg play;

// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/
//  TODO: Set up finite state machine here


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/
 
always @(posedge CLOCK_50) begin
	if (SW[9]) begin
		counter <= 0;
		addressCount <= 0;
		play <= 1;
	end

	else if (counter == 12'b100000000000 & ~KEY[0]) begin
		counter <= 0;

		if (addressCount == address) begin
			addressCount <= address;
			play <= 0;
		end

		else
			addressCount <= addressCount + 1;
	end

	else if (~KEY[0])
		counter <= counter + 1;
end

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/


assign read_audio_in			= audio_in_available & audio_out_allowed;

assign left_channel_audio_out	= sound;
assign right_channel_audio_out	= sound;
assign write_audio_out			= audio_in_available & audio_out_allowed & ~KEY[0] & play;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

// RAM INSTANTIATIONS
// NEED TO MAKE ONE FOR EACH KEY PRESS MODULE
ram	ram_inst (
	.address (addressCount),
	.clock (CLOCK_50),
	.data (0),
	.wren (0),
	.q (sound)
);
	
 
Audio_Controller Audio_Controller (
	// Inputs
	.CLOCK_50						(CLOCK_50),
	.reset						(SW[9]),

	.clear_audio_in_memory		(),
	.read_audio_in				(read_audio_in),
	
	.clear_audio_out_memory		(),
	.left_channel_audio_out		(left_channel_audio_out),		// here
	.right_channel_audio_out	(right_channel_audio_out),		// here
	.write_audio_out			(write_audio_out),

	.AUD_ADCDAT					(AUD_ADCDAT),

	// Bidirectionals
	.AUD_BCLK					(AUD_BCLK),
	.AUD_ADCLRCK				(AUD_ADCLRCK),
	.AUD_DACLRCK				(AUD_DACLRCK),


	// Outputs
	.audio_in_available			(audio_in_available),
	.left_channel_audio_in		(left_channel_audio_in),		// here
	.right_channel_audio_in		(right_channel_audio_in),		// here

	.audio_out_allowed			(audio_out_allowed),

	.AUD_XCK					(AUD_XCK),
	.AUD_DACDAT					(AUD_DACDAT)

);

avconf #(.USE_MIC_INPUT(1)) avc (
	.FPGA_I2C_SCLK					(FPGA_I2C_SCLK),
	.FPGA_I2C_SDAT					(FPGA_I2C_SDAT),
	.CLOCK_50					(CLOCK_50),
	.reset						(SW[9])
);

endmodule


// MUX controller for Switches
module SwitchControl (SW, kit1, kit2, record, playback);
 input [3:0] SW;
 output reg kit1, kit2, record, playback;

 always @(*) begin
 	if (SW[0] & !SW[1] & !SW[2] & !SW[3]) begin
 		kit1 = 1;
 		kit2 = 0;
 		record = 0;
 		playback = 0;
 	end

 	else if (SW[1] & !SW[0] & !SW[2] & !SW[3]) begin
 		kit1 = 0;
 		kit2 = 1;
 		record = 0;
 		playback = 0;
 	end

 	else if (SW[2] & !SW[0] & !SW[1] & !SW[3]) begin
 		kit1 = 0;
 		kit2 = 0;
 		record = 1;
 		playback = 0;
 	end

 	else if (SW[2] & SW[0] & !SW[1] & !SW[3]) begin
 		kit1 = 1;
 		kit2 = 0;
 		record = 1;
 		playback = 0;
 	end

 	else if (SW[2] & SW[1] & !SW[0] & !SW[3]) begin
 		kit1 = 0;
 		kit2 = 1;
 		record = 1;
 		playback = 0;
 	end

 	else if (SW[3] & !SW[0] & !SW[1] & !SW[2]) begin
 		kit1 = 0;
 		kit2 = 0;
 		record = 0;
 		playback = 1;
 	end
 end

endmodule



/* module KitControl (CLOCK_50, KEY, kit1, kit2, other);
	input [3:0] KEY;
	input kit1, kit2, record, play;

	reg [2:0] current, next;

	localparam	none = 2'b00,
							KEY_PRESS_WAIT = 2'b01,
							KEY_PRESS = 2'b10,
							KEY_PRESS_DONE = 2'b11;

	always @(posedge CLOCK_50) begin
		case (current)
			none:;
			KEY_PRESS_WAIT:;
			KEY_PRESS:;
			KEY_PRESS_DONE:;
			default: next = none;
		endcase
	end

endmodule */