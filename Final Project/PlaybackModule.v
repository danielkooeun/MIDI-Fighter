module playback (CLOCK_50, reset, play, sound, channel1, a, b, c, d, e, f, g, h, address, hex0display, hex1display);
	input CLOCK_50;
	input reset;
	input play;
	input [3:0] sound;
	input channel1;

	output reg a, b, c, d, e, f, g, h;
	output reg [7:0] address;
 	
	// Counter components
	reg [22:0] counter;
	reg done;

	// Timer for time keeping in base10
	reg [3:0] hex0timer;
	output reg [3:0] hex0display;
	output reg [1:0] hex1display;


	localparam	final = channel1 ? 8'b01111000 : 8'b11110000;		// counts to 12 or 24 seconds

	always @(posedge CLOCK_50) begin

		if (reset) begin
			counter <= 0;
			address <= 0;
			done <= 0;
			hex0timer <= 0;
			hex0display <= 0;
			hex1display <= 0;
		end

		else if (done) begin
			counter <= 0;
			address <= 0;
			done <= 0;
			hex0timer <= 0;
			hex0display <= 0;
			hex1display <= 0;
		end

		else if (play & !done) begin

			// 0.1 second
			if (counter == 23'b10011000100101101000000) begin
				counter <= 0;
				hex0timer <= hex0timer + 1;

				if (address == (channel1 ? 8'b01111000 : 8'b11110000))
					done <= 1;

				else
					address <= address + 1;
			end

			else
				counter <= counter + 1;

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

	always @(play) begin
		case (sound)
			4'b0001: begin
				a = 1;
				{b, c, d, e, f, g, h} = 7'b0;
			end

			4'b0010: begin
				b = 1;
				{a, c, d, e, f, g, h} = 7'b0;
			end

			4'b0100: begin
				c = 1;
				{a, b, d, e, f, g, h} = 7'b0;
			end

			4'b0111: begin
				d = 1;
				{a, b, c, e, f, g, h} = 7'b0;
			end

			4'b1001: begin
				e = 1;
				{a, b, c, d, f, g, h} = 7'b0;
			end

			4'b1010: begin
				f = 1;
				{a, b, c, d, e, g, h} = 7'b0;
			end

			4'b1100: begin
				g = 1;
				{a, b, c, d, e, f, h} = 7'b0;
			end

			4'b1111: begin
				h = 1;
				{a, b, c, d, e, f, g} = 7'b0;
			end

			default: {a, b, c, d, e, f, g, h} = 8'b0;
		endcase
	end


endmodule