module datapath(CLOCK_50, reset, ld, vgaClear, waiting, vgaWrite, vgaOutput, drawDone, clear, x_out, y_out);

	input CLOCK_50;
	input	reset;
	input [7:0] ld;
	input vgaClear;
	input waiting;

	reg [2:0] vgaColor;

	output reg vgaWrite;
	output reg [2:0] vgaOutput;
	output reg drawDone;
	output reg clear;

	output reg [7:0] x_out;
	output reg [6:0] y_out;

	wire [7:0] x_initial1 = 8'b00000000;
	wire [5:0] y_initial1 = 6'b110000;

	wire [6:0] x_initial2 = 7'b0000000;
	wire [5:0] y_initial2 = 6'b110011;

	wire [6:0] x_initial3 = 7'b1010000;
	wire [5:0] y_initial3 = 6'b110011;

	wire [7:0] x_initial4 = 8'b01101101;
	wire [5:0] y_initial4 = 6'b110011;

	wire [7:0] x_initial5 = 8'b00000000;
	wire [6:0] y_initial5 = 7'b1010001;

	wire [7:0] x_initial6 = 8'b00000000;
	wire [6:0] y_initial6 = 7'b1010101;

	wire [7:0] x_initial7 = 8'b01001110;
	wire [6:0] y_initial7 = 7'b1010101;

	wire [7:0] x_initial8 = 8'b01101011;
	wire [6:0] y_initial8 = 7'b1010011;

	reg [7:0] xcounter = 8'b00000000;
	reg [6:0] ycounter = 7'b0000000;
	
	mem1 m1(
		.address(coordinates1),
		.clock(CLOCK_50),
		.data(0),
		.wren(0),
		.q((ld == 8'b00000001) ? vgaColor : 0)
		);
	mem2 m2(
		.address(coordinates2),
		.clock(CLOCK_50),
		.data(0),
		.wren(0),
		.q((ld == 8'b00000010) ? vgaColor : 0)
		);
	mem3 m3(
		.address(coordinates3),
		.clock(CLOCK_50),
		.data(0),
		.wren(0),
		.q((ld == 8'b00000100) ? vgaColor : 0)
		);
	mem4 m4(
		.address(coordinates4),
		.clock(CLOCK_50),
		.data(0),
		.wren(0),
		.q((ld == 8'b00001000) ? vgaColor : 0)
		);
	mem5 m5(
		.address(coordinates5),
		.clock(CLOCK_50),
		.data(0),
		.wren(0),
		.q((ld == 8'b00010000) ? vgaColor : 0)
		);
	mem6 m6(
		.address(coordinates6),
		.clock(CLOCK_50),
		.data(0),
		.wren(0),
		.q((ld == 8'b00100000) ? vgaColor : 0)
		);
	mem7 m7(
		.address(coordinates7),
		.clock(CLOCK_50),
		.data(0),
		.wren(0),
		.q((ld == 8'b01000000) ? vgaColor : 0)
		);
	mem8 m8(
		.address(coordinates8),
		.clock(CLOCK_50),
		.data(0),
		.wren(0),
		.q((ld == 8'b10000000) ? vgaColor : 0)
		);

	always @ (posedge CLOCK_50) begin

		if (reset) begin
			vgaColor = 0;
			drawDone = 0;
			xcounter = 0;
			ycounter = 0;
		end

		else begin
			if (waiting)
				clear <= 0;

			if ( ld ) begin
				vgaWrite <= 1;
				vgaOutput = vgaColor;

				if (drawDone) begin
					drawDone <= 1'b0;
				end 
			
				if (ld == 8'b00000001) begin
					xcounter <= xcounter + 1;

					if (xcounter >= 6'b110101) begin 
						xcounter <= 0;
						ycounter <= ycounter + 1;
					end

					if (ycounter >= 7'b1000111)
						drawDone <= 1'b1;
			
					x_out <= x_initial1 + xcounter;
					y_out <= y_initial1 + ycounter;
				end
				
				else if (ld == 8'b00000010) begin
					xcounter <= xcounter + 1;

					if (xcounter >= 7'b1010001) begin 
						xcounter <= 0;
						ycounter <= ycounter + 1;
					end

					if (ycounter >= 7'b1000100)
						drawDone <= 1'b1;
			
					x_out <= x_initial2 + xcounter;
					y_out <= y_initial2 + ycounter;
				end
				
				else if (ld == 8'b00000100)begin
					xcounter <= xcounter + 1;

					if (xcounter >= 7'b1001111) begin 
						xcounter <= 0;
						ycounter <= ycounter + 1;
					end

					if (ycounter >= 7'b1000100)
						drawDone <= 1'b1;
			
					x_out <= x_initial3 + xcounter;
					y_out <= y_initial3 + ycounter;
				end
				
				else if (ld == 8'b00001000)begin
					xcounter <= xcounter + 1;

					if (xcounter >= 6'b110010) begin 
						xcounter <= 0;
						ycounter <= ycounter + 1;
					end

					if (ycounter >= 7'b1000100)
						drawDone <= 1'b1;
			
					x_out <= x_initial4 + xcounter;
					y_out <= y_initial4 + ycounter;
				end
				
				else if (ld == 8'b00010000)begin
					xcounter <= xcounter + 1;

					if (xcounter >= 6'b110110) begin 
						xcounter <= 0;
						ycounter <= ycounter + 1;
					end

					if (ycounter >= 6'b100110)
						drawDone <= 1'b1;
			
					x_out <= x_initial5 + xcounter;
					y_out <= y_initial5 + ycounter;
				end

				else if (ld == 8'b00100000)begin
					xcounter <= xcounter + 1;

					if (xcounter >= 7'b1001101) begin 
						xcounter <= 0;
						ycounter <= ycounter + 1;
					end

					if (ycounter >= 6'b100010)
						drawDone <= 1'b1;
			
					x_out <= x_initial6 + xcounter;
					y_out <= y_initial6 + ycounter;
				end


				else if (ld == 8'b01000000) begin
					xcounter <= xcounter + 1;

					if (xcounter >= 7'b1010001) begin 
						xcounter <= 0;
						ycounter <= ycounter + 1;
					end

					if (ycounter >= 6'b100010)
						drawDone <= 1'b1;
			
					x_out <= x_initial7 + xcounter;
					y_out <= y_initial7 + ycounter;
				end
				

				else if (ld == 8'b10000000)begin
					xcounter <= xcounter + 1;

					if (xcounter >= 6'b110100) begin 
						xcounter <= 0;
						ycounter <= ycounter + 1;
					end

					if (ycounter >= 6'b100100)
						drawDone <= 1'b1;
			
					x_out <= x_initial8 + xcounter;
					y_out <= y_initial8 + ycounter;
				end

			end

			if (vgaClear) begin
				vgaWrite <= 0;
				drawDone <= 0;
				clear <= 1;
			end
		end
	
		if (drawDone) begin
			vgaWrite <= 0;
			x_out <= 0;
			y_out <= 0;
			xcounter <= 0;
			ycounter <= 0;
		end
	
end

endmodule