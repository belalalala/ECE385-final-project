module testbench();
/*
timeunit 10ns;

timeprecision 1ns;

logic		   Clk;
logic [9:0] player1_X_Pos;
logic [9:0] player2_X_Pos;
logic [9:0] player1_Y_Pos;
logic [9:0] player2_Y_Pos;
logic [9:0] bird_X_Pos;
logic [9:0] bird_Y_Pos;
logic 		S1;
logic 		S2;
logic 		L1;
logic 		L2;

debug tp(.*);

always begin : CLOCK_GENERATION
#1 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
Clk = 0;
end 

initial begin: TEST_VECTORS
player1_X_Pos = 10'd0;
player2_X_Pos = 10'd0;
player1_Y_Pos = 10'd0;
player2_Y_Pos = 10'd0;
bird_X_Pos    = 10'd0;	
bird_Y_Pos    = 10'd0;		

#4 player1_X_Pos = 10'd93;
	player1_Y_Pos = 10'd193;
	bird_X_Pos = 10'd100;
	bird_Y_Pos = 10'd183;
	
#40;

end
*/   
endmodule
