module  color_mapper (             
							 input logic			is_Menu,
							 input logic			is_Game,
							 input logic			is_Level,
							 input logic			is_Result,
							 input logic  [11:0] menu_pic,
							 input logic  [11:0] game_pic,
							 input logic  [11:0] level_pic,
							 input logic  [11:0] result_pic,
                      input logic  [9:0]  DrawX, DrawY,       
                      output logic [7:0]  VGA_R, VGA_G, VGA_B 
                     );
    
    logic [7:0] Red, Green, Blue;
    
    assign VGA_R = Red;
    assign VGA_G = Green;
    assign VGA_B = Blue;
    
    always_comb begin
		if(is_Menu == 1'b1) begin// show the menu screen if we are at the main menu state

			Red   = {menu_pic[11:8], menu_pic[11:8]};
			Green = {menu_pic[7:4] , menu_pic[7:4] };
			Blue  = {menu_pic[3:0] , menu_pic[3:0] };
			
      end 
		  
		else if(is_Game == 1'b1) begin // if we are in game, show the court as well as volatile objects

			Red   = {game_pic[11:8], game_pic[11:8]}; 
         Green = {game_pic[7:4] , game_pic[7:4] };
         Blue  = {game_pic[3:0] , game_pic[3:0] };
			
		end
		
		else if(is_Level == 1'b1) begin// if we are choosing level, show level selection screen

		   Red   = {level_pic[11:8], level_pic[11:8]};
         Green = {level_pic[7:4] , level_pic[7:4] };
         Blue  = {level_pic[3:0] , level_pic[3:0] };
			
		end
		
		else if(is_Result == 1'b1) begin// if we are done, show the result screen
	
		   Red   = {result_pic[11:8], result_pic[11:8]};
         Green = {result_pic[7:4] , result_pic[7:4] };
         Blue  = {result_pic[3:0] , result_pic[3:0] };
			
		end
		
      else begin//otherwise just display white screen indicating a bug somewhere
		
          Red   = 8'hff; 
          Green = 8'hff; 
          Blue  = 8'hff;
			 
      end
		
    end 
    
endmodule
