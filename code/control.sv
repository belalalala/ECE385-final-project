module control(
					input logic 		 Reset,
					input logic 		 Clk,
					input logic [31:0] keycode,
					input logic 		 is_Done,
					
					output logic 		 is_Menu,
					output logic 		 is_Game,
					output logic 		 is_Level,
					output logic 		 is_Result,						
					output logic[1:0]  AI_Level
										
					);

	enum logic[2:0] {	
						  main_Menu,
						  choose_Level,
						  game0, game1, game2, game3,
						  result
					    }
					    State, Next_State;
	
	always_ff @ (posedge Clk) begin
	
		if(Reset) begin
		
			State <= main_Menu;
			
		end
		
		else 
			
			State <= Next_State;
		
	end
	
	always_comb begin
	
		is_Menu = 1'b0;
		is_Game = 1'b0;
		is_Level = 1'b0;
		is_Result = 1'b0;
		Next_State = State;
		AI_Level = 2'd0;
					  
		unique case(State)

			main_Menu: // Press M for multiplayer and N for singleplayer
			begin
				if(keycode[7:0] == 8'h10) Next_State = game0;
				else if(keycode[7:0] == 8'h11) Next_State = choose_Level;
			end
										
			choose_Level: // State for player to choose AI difficulty
			begin
				if(keycode[7:0] == 8'h1e)
					Next_State = game1;
				else if(keycode[7:0] == 8'h1f)
					Next_State = game2;
				else if(keycode[7:0] == 8'h20)
					Next_State = game3;	
			end
			
			game0, game1, game2, game3: 
				if(is_Done) Next_State = result;

			result: // if either player wins, enter the result state
				if(keycode[7:0] == 8'h28) Next_State = main_Menu; // press enter for returning to main menu
				
		endcase
		
		case(State)
		
			main_Menu:
				is_Menu = 1'b1; 
				
			choose_Level:
				is_Level = 1'b1;
				
			game0:
			begin
				is_Game = 1'b1;
				AI_Level = 2'd0;
			end
			
			game1:
			begin
				is_Game = 1'b1;
				AI_Level = 2'd1;
			end			
				
			game2:
			begin
				is_Game = 1'b1;
				AI_Level = 2'd2;
			end
			
			game3:
			begin
				is_Game = 1'b1;
				AI_Level = 2'd3;
			end
			
			result:
				is_Result = 1'b1;
			
		endcase
		
	end
			
endmodule
