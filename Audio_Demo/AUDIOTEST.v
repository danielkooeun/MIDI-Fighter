
module ad1 (
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
 *                           Parameter Declarations                          *
 *****************************************************************************/


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
wire [31:0] ramOut;
reg [6:0] address = 7'b1100011;		// max address is 99
reg [6:0] addressCount;
reg [8:0] counter;

// Internal Registers

reg [18:0] delay_cnt;
wire [18:0] delay;

reg snd;

// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/
 
always @(posedge CLOCK_50) begin
	if (SW[9]) begin
		counter <= 0;
		addressCount <= 0;
	end

	else if (counter == 9'b111100000) begin
		counter <= 0;

		if (addressCount == address) begin
			addressCount <= 0;
		end

		else
			addressCount <= addressCount + 1;
	end

	else
		counter <= counter + 1;
end

always @(posedge CLOCK_50)
	if(delay_cnt == delay) begin
		delay_cnt <= 0;
		snd <= !snd;
	end else delay_cnt <= delay_cnt + 1;

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

assign delay = 19'd001000101110111000;

wire [31:0] sound = (~KEY[0] == 0) ? 0 : snd ? 32'd1000000 : -32'd1000000;


assign read_audio_in			= audio_in_available & audio_out_allowed;

assign left_channel_audio_out	= ramOut + sound;
assign right_channel_audio_out	= ramOut + sound;
assign write_audio_out			= audio_in_available & audio_out_allowed & ~KEY[0];

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/
ram	ram_inst (
	.address (addressCount),
	.clock (CLOCK_50),
	.data (0),
	.wren (0),
	.q (ramOut)
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

