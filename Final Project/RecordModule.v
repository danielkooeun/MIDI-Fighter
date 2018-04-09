module record (CLOCK_50, reset, KEY, record, play, kit1, kit2, channel1, playAddress, playhex0, playhex1, sound, HEX0, HEX1, HEX3, LEDR, Msound);
	input CLOCK_50;
	input reset;
	input [3:0] KEY;
	input record, play, kit1, kit2;

	// Two recording channels determined by this input
	input channel1;

	input [7:0] playAddress;
	input [3:0] playhex0;
	input playhex1;

	output [3:0] sound;
	output [6:0] HEX0, HEX1, HEX3;
	output [9:0] LEDR;

	// Hold sound data to be recorded
	reg [3:0] keySound;
	reg [3:0] recKey;
	reg recDone;

	// RateDividing / Counter
	reg [22:0] counter;				// Counts to 10011000100101101000000 = 5 mill.
	reg [7:0] address;

	// For Metronome feature
	reg [2:0] Mcounting;
	reg Mplay;
	output [4:0] Msound;

	// Timer for time keeping in base10
	reg [3:0] hex0timer;
	reg [3:0] hex0display;
	reg [1:0] hex1display;

	localparam	final = channel1 ? 8'b01111000 : 8'b11110000,		// counts to 12 or 24 seconds
							Mfinal = 12'b110111001000;


	// Assigns 3-bit for every sound
	always @(*) begin
		case (~KEY)
			4'b0001: keySound = kit1 ? 4'b0001 : 4'b1001;
			4'b0010: keySound = kit1 ? 4'b0010 : 4'b1010;
			4'b0100: keySound = kit1 ? 4'b0100 : 4'b1100;
			4'b1000: keySound = kit1 ? 4'b0111 : 4'b1111;
		endcase
	end

	always @(posedge CLOCK_50) begin

		if (reset) begin
			counter <= 0;
			address <= 0;
			recDone <= 0;
			recKey <= 0;
			hex0timer <= 0;
			hex0display <= 0;
			hex1display <= 0;
			Mcounting <= 0;
			Mplay <= 0;
		end

		else if (record & !recDone) begin

			// 0.1 second
			if (counter == 23'b10011000100101101000000) begin
				counter <= 0;
				hex0timer <= hex0timer + 1;
				Mcounting <= Mcounting + 1;

				if (Mplay)
					Mplay <= 0;

				else if (Mcounting == 3'b101) begin
					Mcounting <= 0;
					Mplay <= 1;
				end


				if (address == (channel1 ? 8'b01111000 : 8'b11110000))
					recDone <= 1;

				else
					address <= address + 1;

				recKey <= 0;
			end

			else begin
				counter <= counter + 1;

				if (~KEY)
					recKey <= keySound;
			end

			if (hex0timer == 4'b1010) begin
				hex0timer <= 0;
				hex0display <= hex0display + 1;
			end

			if (hex0display == 4'b1010) begin
				hex0display <= 0;
				hex1display <= hex1display + 1;
			end

		end
	end



	// Metronome Component
	reg Mstart, Mdone;
	reg [11:0] Mcounter;
	reg [11:0] Maddress;

	always @(posedge CLOCK_50) begin
		if (Mplay)
			Mstart <= 1;
	
		if (reset) begin
			Mcounter <= 0;
			Maddress <= 0;
			Mdone <= 0;
			Mstart <= 0;
		end

		else if (Mdone & Mstart & record) begin
			Mcounter <= 0;
			Maddress <= 0;
			Mdone <= 0;
			Mstart <= 0;
		end

		else if (Mcounter == 12'b100000100100 & Mstart & record) begin
			Mcounter <= 0;

			if (Maddress != Mfinal)
				Maddress <= Maddress + 1;

			else
				Mdone <= 1;

		end

		else if (Mstart & record)
			Mcounter <= Mcounter + 1;

	end



	// Memory module with 128 words x 1-bit
	RecordMemory	recordmem (
		// Make this use the same address counter - repeitive code
		.address (record ? address : playAddress),
		.clock (CLOCK_50),
		.data (record ? recKey : 0),
		.wren (record ? 1 : 0),
		.q (sound)
	);

	metronome mn0 (
		.address (Maddress),
		.clock (CLOCK_50),
		.q (Msound)
	);


	// Display for timekeeping while recording
	sevensegment hex0(record ? hex0display : playhex0, HEX0);
	sevensegment hex1(record ? {2'b00, hex1display} : {2'b00, playhex1}, HEX1);
	sevensegment hex3(channel1? 4'b0001 : 4'b0010, HEX3);

	assign LEDR[3:0] = sound;
	assign LEDR[7:4] = recKey;
	assign LEDR[9] = recDone;
endmodule


// HEX Display
module sevensegment(INPUTS,OUTPUTS);
	input [3:0] INPUTS;
	output [6:0] OUTPUTS;
	wire w, x, y, z;
	
	assign w = INPUTS[3];
	assign x = INPUTS[2];
	assign y = INPUTS[1];
	assign z = INPUTS[0];
	
	assign OUTPUTS[0] = (~w&~x&~y&z)|(~w&x&~y&~z)|(w&~x&y&z)|(w&x&~y&z);
	assign OUTPUTS[1] = (~w&x&~y&z)|(~w&x&y&~z)|(w&~x&y&z)|(w&x&~y&~z)|(w&x&y&~z)|(w&x&y&z);
	assign OUTPUTS[2] = (~w&~x&y&~z)|(w&x&~y&~z)|(w&x&y&~z)|(w&x&y&z);
	assign OUTPUTS[3] = (~w&~x&~y&z)|(~w&x&~y&~z)|(~w&x&y&z)|(w&~x&y&~z)|(w&x&y&z);
	assign OUTPUTS[4] = (~w&~x&~y&z)|(~w&~x&y&z)|(~w&x&~y&~z)|(~w&x&~y&z)|(~w&x&y&z)|(w&~x&~y&z);
	assign OUTPUTS[5] = (~w&~x&~y&z)|(~w&~x&y&~z)|(~w&~x&y&z)|(~w&x&y&z)|(w&x&~y&z);
	assign OUTPUTS[6] = (~w&~x&~y&~z)|(~w&~x&~y&z)|(~w&x&y&z)|(w&x&~y&~z);

endmodule