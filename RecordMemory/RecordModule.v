module record (CLOCK_50, reset, record, kit1, kit2, KEY, checkadd, address, done, recordOut);
	input CLOCK_50;
	input reset;
	input record, kit1, kit2;
	input [3:0] KEY;
	input [7:0] checkadd;

	// Hold sound data to be recorded
	//reg [3:0] recSound;
	reg recKEY; 
	output reg done;

	// RateDividing / Counter
	reg [23:0] counter;
	output reg [7:0] address;
	reg [7:0] maxAddress = 8'b10000000;

	output recordOut;


	// Assigns 3-bit for every sound
	/* always @(*) begin
		case (KEY)
			4'b0001: recSound = kit1 ? 4'b0001 : 4'b1001;
			4'b0010: recSound = kit1 ? 4'b0011 : 4'b1011;
			4'b0100: recSound = kit1 ? 4'b0101 : 4'b1101;
			4'b1000: recSound = kit1 ? 4'b0111 : 4'b1111;
			default: recSound = 4'b0000;
		endcase
	end
	
	*/


	always @(posedge CLOCK_50) begin

		if (reset) begin
			counter <= 0;
			address <= 0;
			done <= 0;
			recKEY <= 0;
		end

		else if (record & ~done) begin

			if (counter == 24'b101111101011110000100000) begin
				counter <= 0;
				recKEY <= 0;

				if (address == maxAddress)
					done <= 1;

				else
					address <= address + 1;
			end

			else begin
				counter <= counter + 1;

				if (~KEY[0])
					recKEY <= 1;
			end

		end
	end


// Memory module with 128 words x 1-bit
RecordMemory	recordmem (
	.address (~done ? address : checkadd),
	.clock (CLOCK_50),
	.data (~done ? recKEY : 0),
	.wren (~done ? record : 0),
	.q (recordOut)
);


endmodule