module top (
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
	SW,
	HEX0,
	HEX1,
	HEX3,
	LEDR,

	// VGA
	VGA_CLK,   						//	VGA Clock
	VGA_HS,							//	VGA H_SYNC
	VGA_VS,							//	VGA V_SYNC
	VGA_BLANK_N,						//	VGA BLANK
	VGA_SYNC_N,						//	VGA SYNC
	VGA_R,   						//	VGA Red[9:0]
	VGA_G,	 						//	VGA Green[9:0]
	VGA_B   						//	VGA Blue[9:0]
);


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
	output [6:0] HEX0, HEX1, HEX3;
	output [9:0] LEDR;


	// VGA
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]




	// Internal Wires
	wire				audio_in_available;
	wire		[31:0]	left_channel_audio_in;
	wire		[31:0]	right_channel_audio_in;
	wire				read_audio_in;

	wire				audio_out_allowed;
	wire		[31:0]	left_channel_audio_out;
	wire		[31:0]	right_channel_audio_out;
	wire				write_audio_out;

	// My inputs and outputs
	wire kit1, kit2, record, play;
	kitSelect ks0(SW, kit1, kit2, record, play);




	// Sound Modules
	wire playa, donea;
	assign playa = ((kit1 & ~KEY[0]) | backa);
	wire [4:0] sounda;
	sounda sa0(CLOCK_50, SW[9], playa, sounda, donea);


	wire playb, doneb;
	assign playb = ((kit1 & ~KEY[1]) | backb);
	wire [4:0] soundb;
	soundb sb0(CLOCK_50, SW[9], playb, soundb, doneb);


	wire playc, donec;
	assign playc = ((kit1 & ~KEY[2]) | backc);
	wire [4:0] soundc;
	soundc sc0(CLOCK_50, SW[9], playc, soundc, donec);


	wire playd, doned;
	assign playd = ((kit1 & ~KEY[3]) | backd);
	wire [4:0] soundd;
	soundd sd0(CLOCK_50, SW[9], playd, soundd, doned);


	wire playe, donee;
	assign playe = ((kit2 & ~KEY[0]) | backe);
	wire [4:0] sounde;
	sounde se0(CLOCK_50, SW[9], playe, sounde, donee);


	wire playf, donef;
	assign playf = ((kit2 & ~KEY[1]) | backf);
	wire [4:0] soundf;
	soundf sf0(CLOCK_50, SW[9], playf, soundf, donef);


	wire playg, doneg;
	assign playg = ((kit2 & ~KEY[2]) | backg);
	wire [4:0] soundg;
	soundg sg0(CLOCK_50, SW[9], playg, soundg, doneg);


	wire playh, doneh;
	assign playh = ((kit2 & ~KEY[3]) | backh);
	wire [4:0] soundh;
	soundh sh0(CLOCK_50, SW[9], playh, soundh, doneh);


	wire [31:0] soundOutput;
	soundToPlay sp0(KEY, kit1, kit2, play, backa, backb, backc, backd, backe, backf, backg, backh, sounda, soundb, soundc, soundd, sounde, soundf, soundg, soundh, Msound, soundOutput);




	// Record Module
	wire [3:0] recSound;
	wire [4:0] Msound;
	record rc0(CLOCK_50, SW[9], KEY, record, play, kit1, kit2, !SW[5], playAddress, playhex0, playhex1, recSound, HEX0, HEX1, HEX3, LEDR, Msound);




	// Playback Module
	wire [7:0] playAddress;
	wire [3:0] playhex0;
	wire [1:0] playhex1;
	wire backa, backb, backc, backd, backe, backf, backg, backh;
	playback pb0(CLOCK_50, SW[9], play, recSound, !SW[5], backa, backb, backc, backd, backe, backf, backg, backh, playAddress, playhex0, playhex1);




	// VGA Modules
	wire clearSignal;
	wire [7:0] ld;
	wire vgaClear, waiting;
	vgaFSM vf0 (CLOCK_50, SW[9], KEY, kit1, kit2, play, {backa, backb, backc, backd, backe, backf, backg, backh}, drawDone, clearSignal, ld, vgaClear, waiting);


	wire vgaWrite;
	wire drawDone;
	wire [2:0] vgaOutput;
	wire [7:0] x;
	wire [6:0] y;
	datapath dp0(CLOCK_50, reset, ld, vgaClear, waiting, vgaWrite, vgaOutput, drawDone, clearSignal, x, y);


	assign read_audio_in			= audio_in_available & audio_out_allowed;

	assign left_channel_audio_out	= soundOutput;
	assign right_channel_audio_out	= soundOutput;
	assign write_audio_out			= audio_in_available & audio_out_allowed;


		
	 
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


	// VGA MODULE
	vga_adapter VGA(
			.resetn(!SW[9] | clearSignal),
			.clock(CLOCK_50),
			.colour(vgaOutput),
			.x(x),
			.y(y),
			.plot(vgaWrite),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "241F.mif";


endmodule


module kitSelect (SW, kit1, kit2, record, play);
	input [3:0] SW;
	output reg kit1, kit2, record, play;

	// Manages different states for switches - record, play, kit1-2
	always @(*) begin
		if (SW[0] & !SW[1] & !SW[2] & !SW[3]) begin
			kit1 = 1;
			kit2 = 0;
			record = 0;
			play = 0;
		end

		else if (SW[1] & !SW[0] & !SW[2] & !SW[3]) begin
			kit1 = 0;
			kit2 = 1;
			record = 0;
			play = 0;
		end

		else if (SW[2] & !SW[0] & !SW[1] & !SW[3]) begin
			kit1 = 0;
			kit2 = 0;
			record = 1;
			play = 0;
		end

		else if (SW[2] & SW[0] & !SW[1] & !SW[3]) begin
			kit1 = 1;
			kit2 = 0;
			record = 1;
			play = 0;
		end

		else if (SW[2] & SW[1] & !SW[0] & !SW[3]) begin
			kit1 = 0;
			kit2 = 1;
			record = 1;
			play = 0;
		end

		else if (SW[3] & !SW[0] & !SW[1] & !SW[2]) begin
			kit1 = 0;
			kit2 = 0;
			record = 0;
			play = 1;
		end

		else begin
			kit1 = 0;
			kit2 = 0;
			record = 0;
			play = 0;
		end
	end
endmodule


module playDetect (CLOCK_50, reset, sound, playSound);
	input CLOCK_50;
	input reset;
	input [3:0] sound;
	output reg playSound;

	// FSM for detecting sound inputs from memory
	localparam	waiting = 2'b00,
				play = 2'b01,
				done = 2'b10;

	reg [1:0] current, next;
	reg [3:0] currentSound;

	// TODO : CHECK FOR FSM CHECKING PROCESS FOR SOUND OUTPUT!
	// TODO : WILL HAVE TO MODIFY FOR END OF SOUND CLIP
	always @(*) begin
		case (current)
			// Currently at 0 -> waiting for sound
			waiting: next = !sound ? waiting : play;

			// Found 1
			play: next = (currentSound == sound ) ? play : !sound ? done : play;

			done: next = (currentSound != sound) ? play : (!sound) ? waiting : done;

			default: next = waiting;
		endcase
	end

	// Control Signals
	always @(*) begin
		case (current)
			waiting: playSound = 0;
			play: playSound = 1;
			done: playSound = 0;
			default: playSound = 0;
		endcase
	end

	always @(posedge CLOCK_50) begin
		currentSound <= sound;

		if (reset)
			current <= waiting;
		else
			current <= next;
	end
endmodule

// SOUND SELECT MAY CAUSE ERROR DUE TO DEFAULT CASE -> CHECK TODO
module soundToPlay (KEY, kit1, kit2, play, backa, backb, backc, backd, backe, backf, backg, backh, a, b, c, d, e, f, g, h, Msound, soundOutput);
	input [3:0] KEY;
	input kit1, kit2, play;
	input backa, backb, backc, backd, backe, backf, backg, backh;
	input [4:0] a, b, c, d, e, f, g, h, Msound;
	output [31:0] soundOutput;

	reg [4:0] sounda;
	reg [4:0] soundb;

	always @(!play) begin
		case (~KEY)
		4'b0000: sounda = Msound;
		4'b0001: sounda = kit1 ? a : kit2 ? e : 0;
		4'b0010: sounda = kit1 ? b : kit2 ? f : 0;
		4'b0100: sounda = kit1 ? c : kit2 ? g : 0;
		4'b1000: sounda = kit1 ? d : kit2 ? h : 0;
		default: sounda = 0;
		endcase
	end

	always @(play) begin
		if (backa)
			soundb = a;

		else if (backb)
			soundb = b;

		else if (backc)
			soundb = c;

		else if (backd)
			soundb = d;

		else if (backe)
			soundb = e;

		else if (backf)
			soundb = f;

		else if (backg)
			soundb = g;

		else if (backh)
			soundb = h;

		else
			soundb = 0;
	end

	assign soundOutput = {play ? soundb : sounda, 21'b0};
endmodule