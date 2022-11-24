module background(
						input 				  Clk,
						input logic  [9:0]  ADDR_X,
						input logic  [9:0]  ADDR_Y,
						output logic [11:0] menu_pic,
						output logic [11:0] level_pic,
						output logic [11:0] result_pic
						);
										
	menu 	 menu_0 (.*);
	level  level_0 (.*);
	result result_0 (.*);
	
endmodule

module menu(
				input 				  Clk,
				input logic  [9:0]  ADDR_X,
				input logic  [9:0]  ADDR_Y,
				output logic [11:0] menu_pic
				);

	logic [11:0] menu_PNG [76799:0];			
				
	initial begin // read in the main menu picture
	
		$readmemh("txt_files/menu.txt", menu_PNG);
		
	end

	always_ff @ (posedge Clk) begin // project the main menu onto the monitor with conditional signals
	
		menu_pic <= menu_PNG[ADDR_X + ADDR_Y * 20'd320];
	
	end
	
endmodule

module level(
				 input 				  Clk,
				 input logic  [9:0]  ADDR_X,
				 input logic  [9:0]  ADDR_Y,
				 output logic [11:0] level_pic
				 );

	logic [11:0] level_PNG [76799:0];			
				
	initial begin // read in the level selection picture
	
		$readmemh("txt_files/level.txt", level_PNG);
		
	end

	always_ff @ (posedge Clk) begin // project the level selection onto the monitor with conditional signals
	
		level_pic <= level_PNG[ADDR_X + ADDR_Y * 20'd320];
	
	end
	
endmodule

module result(
				  input 				  Clk,
				  input logic  [9:0]  ADDR_X,
				  input logic  [9:0]  ADDR_Y,
				  output logic [11:0] result_pic
				  );

	logic [11:0] result_PNG [76799:0];			
				
	initial begin // read in the result picture
	
		$readmemh("txt_files/result.txt", result_PNG);
		
	end

	always_ff @ (posedge Clk) begin // project the result onto the monitor with conditional signals
	
		result_pic <= result_PNG[ADDR_X + ADDR_Y * 20'd320];
	
	end
	
endmodule

