module debug(
				 input  logic		  Clk,
				 input  logic [9:0] player1_X_Pos,
				 input  logic [9:0] player2_X_Pos,
				 input  logic [9:0] player1_Y_Pos,
				 input  logic [9:0] player2_Y_Pos,
				 input  logic [9:0] bird_X_Pos,
				 input  logic [9:0] bird_Y_Pos,
				 output logic 		  S1, S2, L1, L2
				);
				
	int DistB1X, DistB1Y, DistB2X, DistB2Y, Dist1, Dist2;
	assign DistB1X = bird_X_Pos - player1_X_Pos;
	assign DistB1Y = bird_Y_Pos - player1_Y_Pos;
	assign DistB2X = bird_X_Pos - player2_X_Pos;
	assign DistB2Y = bird_Y_Pos - player2_Y_Pos;
	assign Dist1   = (DistB1X * DistB1X) + (DistB1Y * DistB1Y);
	assign Dist2   = (DistB2X * DistB2X) + (DistB2Y * DistB2Y);
	
	// actual signal for successful hit
	assign S1 = Dist1 < 200;
	assign S2 = Dist2 < 200;
	assign L1 = Dist1 > 50;
	assign L2 = Dist2 > 50;
	
endmodule
