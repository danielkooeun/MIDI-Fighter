// State diagram - control module
	module vgaFSM(CLOCK_50, reset, KEY, kit1, kit2, play, backSound, drawDone, clear, ld, vgaClear, waiting);
	input CLOCK_50;
	input reset;
	input [3:0] KEY;
	input kit1, kit2, play;
	input [7:0] backSound;
	input drawDone;

	// Signal for drawing to load;
	output reg [7:0] ld;
	output reg vgaClear;
	output reg waiting;

	reg [1:0] current, next;

	localparam 	A= 2'b00,
				B= 2'b01,
				C= 2'b10,
				D = 2'b11;


	// State Table
	always@(*) begin
		case (current)

			// INITIAL
			A: next = (~KEY | backSound) ? B : A;

			// DONE
			B: begin
				if (~KEY | backSound) begin
					if (drawDone)
						 next = C;
					else
						next = B;
				end

				else
					next = D;
			
			end

			// HOLD
			C: next = (~KEY | backSound) ? C : D;

			// ERASE
			D: next = (!clear) ? D : A;

			default: next = A;
		endcase
	end

// Datapath controls
	always@(*) begin

		case (current)
			A: waiting = 1;

			B: begin
				waiting = 0;
				if ((kit1  & ~(KEY[0])) | (play) ? backSound == 8'b10000000 : 0) begin
					ld = 8'b00000001;
				end
				else if ((kit1 & ~(KEY[1])) | (play) ? backSound == 8'b01000000 : 0) begin
					ld= 8'b00000010;
				end
				else if ((kit1 & ~(KEY[2])) | (play) ? backSound == 8'b00100000 : 0) begin
					ld = 8'b00000100;
				end
				else if ((kit1 & ~(KEY[3])) | (play) ? backSound == 8'b00010000 : 0) begin
					ld = 8'b00001000;
				end
				else if ((kit2 & ~(KEY[0])) | (play) ? backSound == 8'b00001000 : 0) begin
					ld = 8'b00010000;
				end
				else if ((kit2 & ~(KEY[1])) | (play) ? backSound == 8'b00000100 : 0) begin
					ld = 8'b00100000;
				end
				else if ((kit2 & ~(KEY[2])) | (play) ? backSound == 8'b00000010 : 0) begin 
					ld = 8'b01000000; 
				end
				else if ((kit2 & ~(KEY[3])) | (play) ? backSound == 8'b00000001 : 0) begin
					ld = 8'b10000000;
				end
			end

			D: begin
				ld = 8'b0;
				vgaClear = 1;
			end
		endcase
	end

	always@(posedge CLOCK_50) begin
		if (reset)
			current <= A;
		else
			current <= next;
	end
endmodule