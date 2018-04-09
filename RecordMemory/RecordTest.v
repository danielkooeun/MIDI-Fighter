module top (CLOCK_50, KEY, SW, LEDR, HEX0, HEX1, HEX3, HEX4);
	input CLOCK_50;
	input [3:0] KEY;
	input [9:0] SW;
	output [2:0] LEDR;
	output [6:0] HEX0, HEX1, HEX3, HEX4;


	wire [7:0] address;
	wire done;
	wire recordOut;


	// counter module for testing recording playback
	reg [23:0] counter;
	reg [7:0] checkadd;
	reg demo;

	always @(posedge CLOCK_50) begin
		if (SW[8]) begin
			counter <= 0;
			checkadd <= 0;
			demo <= 0;
		end

		else if (done & ~demo & SW[0]) begin

			if (counter == 24'b101111101011110000100000) begin
				counter <= 0;

				if (checkadd == 8'b10000000)
						demo <= 1;

				else
						checkadd <= checkadd + 1;
			end

			else
				counter <= counter + 1;

		end

	end

	// Assignments for demo
	record r0(CLOCK_50, SW[9], SW[2], SW[0], SW[1], KEY, checkadd, address, done, recordOut);

	sevensegment hex0(address[3:0], HEX0);
	sevensegment hex1(address[7:4], HEX1);
	sevensegment hex3(checkadd[3:0], HEX3);
	sevensegment hex4(checkadd[7:4], HEX4);
	assign LEDR[0] = recordOut;
	assign LEDR[1] = ~done;
	assign LEDR[2] = ~demo;

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