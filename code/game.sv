module game(
				input  logic		  Clk,
				input  logic		  Reset,
				input  logic		  is_Menu,
				input  logic        frame_clk,
				input  logic [1:0]  AI_Level,
				input  logic [9:0]  ADDR_X,
				input  logic [9:0]  ADDR_Y,
				input  logic [31:0] keycode,
				output logic [11:0] game_pic,
				output logic 		  is_Done
				);
				
	logic [11:0] court_PNG  [76799:0];
	logic [11:0] sprite_PNG [76799:0];
	logic [11:0] temp_PNG;
	logic			 is_player1, is_player2, is_bird, is_play, bird_hit;
	logic			 left_serve, right_serve, left_scored, right_scored, left_reset, right_reset;
	logic			 en_left_swing, en_right_swing, en_left_hit, en_right_hit;
	logic [2:0]  left_score, right_score, left_swing, right_swing, bird_dir;		 
	logic [9:0]  player1_X_Pos, player1_Y_Pos, player2_X_Pos, player2_Y_Pos, bird_X_Pos, bird_Y_Pos, bird_X_Motion, bird_Y_Motion, land_X_Pos;
	
	// sub_module instantiation
	scoreboard sb(.*);
	player1 	  left(.*);
	player2 	  right(.*);
	bird 		  badminton(.*);
	bird_FSM   control(.*);
	parabola	  land(.*);
	
	// assignments for multiple keypress
	assign w_on = (keycode[31:24] == 8'h1A | keycode[23:16] == 8'h1A | keycode[15:8] == 8'h1A | keycode[7:0] == 8'h1A);
	assign a_on = (keycode[31:24] == 8'h04 | keycode[23:16] == 8'h04 | keycode[15:8] == 8'h04 | keycode[7:0] == 8'h04);
	assign s_on = (keycode[31:24] == 8'h16 | keycode[23:16] == 8'h16 | keycode[15:8] == 8'h16 | keycode[7:0] == 8'h16);
	assign d_on = (keycode[31:24] == 8'h07 | keycode[23:16] == 8'h07 | keycode[15:8] == 8'h07 | keycode[7:0] == 8'h07);
	assign i_on = (keycode[31:24] == 8'h0c | keycode[23:16] == 8'h0c | keycode[15:8] == 8'h0c | keycode[7:0] == 8'h0c);
	assign j_on = (keycode[31:24] == 8'h0d | keycode[23:16] == 8'h0d | keycode[15:8] == 8'h0d | keycode[7:0] == 8'h0d);
	assign k_on = (keycode[31:24] == 8'h0e | keycode[23:16] == 8'h0e | keycode[15:8] == 8'h0e | keycode[7:0] == 8'h0e);
	assign l_on = (keycode[31:24] == 8'h0f | keycode[23:16] == 8'h0f | keycode[15:8] == 8'h0f | keycode[7:0] == 8'h0f);
	
	initial begin
	
		$readmemh("txt_files/court.txt", court_PNG);
		$readmemh("txt_files/sprite.txt", sprite_PNG);
		
	end
	
		
	logic frame_clk_delayed, frame_clk_rising_edge;
	
   always_ff @ (posedge Clk) begin // clock update
	 
		frame_clk_delayed <= frame_clk;
      frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
		  
	end

	always_ff @ (posedge Clk) begin
	
		// display the left player score
		if(ADDR_X >= 10'd135 && ADDR_X <= 10'd149 && ADDR_Y >= 10'd8 && ADDR_Y <= 10'd27) begin 
		
			case(left_score)
					
				3'd0: game_pic <= sprite_PNG[ADDR_X + 10'd125 + (ADDR_Y + 10'd193) * 20'd320];
				3'd1: game_pic <= sprite_PNG[ADDR_X + 10'd140 + (ADDR_Y + 10'd193) * 20'd320];
				3'd2: game_pic <= sprite_PNG[ADDR_X + 10'd155 + (ADDR_Y + 10'd193) * 20'd320];
				3'd3: game_pic <= sprite_PNG[ADDR_X + 10'd170 + (ADDR_Y + 10'd193) * 20'd320];
				3'd4: game_pic <= sprite_PNG[ADDR_X + 10'd125 + (ADDR_Y + 10'd213) * 20'd320];
				3'd5: game_pic <= sprite_PNG[ADDR_X + 10'd140 + (ADDR_Y + 10'd213) * 20'd320];
				3'd6: game_pic <= sprite_PNG[ADDR_X + 10'd155 + (ADDR_Y + 10'd213) * 20'd320];
				3'd7: game_pic <= sprite_PNG[ADDR_X + 10'd170 + (ADDR_Y + 10'd213) * 20'd320];
				
			endcase
				
		end
		
		// display the right player score	
		else if(ADDR_X >= 10'd171 && ADDR_X <= 10'd185 && ADDR_Y >= 10'd8 && ADDR_Y <= 10'd27) begin
		
			case(right_score)
					
				3'd0: game_pic <= sprite_PNG[ADDR_X + 10'd89  + (ADDR_Y + 10'd193) * 20'd320];
				3'd1: game_pic <= sprite_PNG[ADDR_X + 10'd104 + (ADDR_Y + 10'd193) * 20'd320];
				3'd2: game_pic <= sprite_PNG[ADDR_X + 10'd119 + (ADDR_Y + 10'd193) * 20'd320];
				3'd3: game_pic <= sprite_PNG[ADDR_X + 10'd134 + (ADDR_Y + 10'd193) * 20'd320];
				3'd4: game_pic <= sprite_PNG[ADDR_X + 10'd89  + (ADDR_Y + 10'd213) * 20'd320];
				3'd5: game_pic <= sprite_PNG[ADDR_X + 10'd104 + (ADDR_Y + 10'd213) * 20'd320];
				3'd6: game_pic <= sprite_PNG[ADDR_X + 10'd119 + (ADDR_Y + 10'd213) * 20'd320];
				3'd7: game_pic <= sprite_PNG[ADDR_X + 10'd134 + (ADDR_Y + 10'd213) * 20'd320];
				
			endcase
				
		end
				
		// display the bird
		else if(is_bird) begin
			
			temp_PNG <= sprite_PNG[(ADDR_X + 10'd3 - bird_X_Pos) + (10'd7 * bird_dir) + (ADDR_Y + 10'd4 - bird_Y_Pos + 10'd232) * 20'd320];
			
			if(temp_PNG != 12'h9cf)
				game_pic <= temp_PNG;
			
			else if(is_player1 || is_player2)
				game_pic <= 0;
				
			else
				game_pic <= court_PNG[ADDR_X + ADDR_Y * 20'd320];
		
		end
		
		// display player 1
		else if(is_player1) begin	
			
			temp_PNG <= sprite_PNG[(ADDR_X + 10'd15 - player1_X_Pos) + (10'd40 * left_swing) + (ADDR_Y + 10'd15 - player1_Y_Pos) * 20'd320];
			
			if(temp_PNG != 12'h9cf)
				game_pic <= temp_PNG;
				
			else
				game_pic <= court_PNG[ADDR_X + ADDR_Y * 20'd320];
		
		end

		// display player 2		
		else if(is_player2) begin	
			
			temp_PNG <= sprite_PNG[(ADDR_X + 10'd15 - player2_X_Pos) + (10'd40 * right_swing) + (ADDR_Y + 10'd15 - player2_Y_Pos + 10'd40) * 20'd320];
			
			if(temp_PNG != 12'h9cf)
				game_pic <= temp_PNG;
				
			else
				game_pic <= court_PNG[ADDR_X + ADDR_Y * 20'd320];
		
		end
		
		// display court
		else
			game_pic <= court_PNG[ADDR_X + ADDR_Y * 20'd320];
	
	end 
	
endmodule


// module for instantiating the scoreboard
module scoreboard(
						input  logic   	Clk,
						input  logic		Reset,
						input  logic		is_Menu,
						input  logic      frame_clk_rising_edge,
						input  logic   	left_scored,
						input  logic   	right_scored,
						output logic 		is_Done,
						output logic[2:0] left_score,
						output logic[2:0] right_score
						); 
						
	logic[2:0] left_score_reg, right_score_reg; // registers to keep track of points of each player
	
	always_ff @ (posedge Clk) begin
	
		if(left_score_reg == 3'b111 || right_score_reg == 3'b111) // game ending conditions
			is_Done <= 1'b1;
		else
			is_Done <= 1'b0;
			
		if(Reset || is_Menu) begin // reset the points of two players to 0 if we are at main menu
		
			left_score_reg  <= 3'b000;
			right_score_reg <= 3'b000;
			
		end
		
		if(left_scored)
			left_score_reg  <= left_score_reg  + 1'b1; // if left player scores a point, add one to the left score register
				
		if(right_scored) 
			right_score_reg <= right_score_reg + 1'b1; // if right player scores a point, add one to the right score register
		
		left_score <= left_score_reg;  // constantly updates the scoreboard to be displayed
		right_score <= right_score_reg;
		
	end
				
endmodule


// module for the left player
module player1(
					input  logic		  Clk,
					input  logic		  Reset,
					input  logic		  is_Menu,
					input  logic        frame_clk_rising_edge,
					input  logic		  left_serve,
					input  logic		  left_reset,
					input  logic 		  w_on, a_on, s_on, d_on,
					input  logic [9:0]  ADDR_X,
					input  logic [9:0]  ADDR_Y,
					input  logic [9:0]  bird_X_Pos,
					input  logic [9:0]  bird_Y_Pos,
					input  logic [31:0] keycode,
					output logic 		  is_player1,
					output logic		  en_left_swing,
					output logic [2:0]  left_swing,
					output logic [9:0]  player1_X_Pos,
					output logic [9:0]  player1_Y_Pos
					);
	
	// define parameters of initial positions, serve positions, and boundaries for player1
	parameter [9:0] player1_init        = 10'd79; 
	parameter [9:0] player1_bound_left  = 10'd9; 
	parameter [9:0] player1_bound_right = 10'd159; 
	parameter [9:0] player1_bound_serve = 10'd79;
	parameter [9:0] player1_bound_floor = 10'd193;
   parameter [9:0] player1_X_Step      = 10'd2;      
   parameter [9:0] player1_Y_Step      = 10'd15;
	parameter [9:0] player_size 			= 10'd15;
	
	
	logic [9:0] player1_X_Motion, player1_Y_Motion;
   logic [9:0] player1_X_Pos_in, player1_X_Motion_in, player1_Y_Pos_in, player1_Y_Motion_in;
	logic			en_swing;
	
	animation leftswing(.*, .player_Y_Pos(player1_Y_Pos), .frame_num(left_swing));
	
	always_ff @ (posedge Clk) begin // position update of player1
	 
		if (Reset) begin
		  
			player1_X_Pos <= 0;
			player1_Y_Pos <= 0;
			player1_X_Motion <= 0;
			player1_Y_Motion <= 0;
			en_left_swing <= 0;
				
      end
		
		else if (is_Menu || left_reset) begin
		  
			player1_X_Pos <= player1_init;
			player1_Y_Pos <= player1_bound_floor;
			player1_X_Motion <= 10'd0;
			player1_Y_Motion <= 10'd0;
			en_left_swing <= 0;
				
      end
		  
		else begin
		  
         player1_X_Pos <= player1_X_Pos_in;
         player1_Y_Pos <= player1_Y_Pos_in;
         player1_X_Motion <= player1_X_Motion_in;
         player1_Y_Motion <= player1_Y_Motion_in;
			en_left_swing <= en_swing;
				
		end
		  
	end
	 
	always_comb begin // drawing condition and boundary and keypress
	
		player1_X_Pos_in = player1_X_Pos;
		player1_Y_Pos_in = player1_Y_Pos;
		player1_X_Motion_in = player1_X_Motion;
		player1_Y_Motion_in = player1_Y_Motion;
		en_swing = 1'b0;
			
		if (frame_clk_rising_edge) begin
		
			if(a_on) begin // Moving to the left by key press
			
				if(player1_X_Pos >= player1_bound_left + player_size)
				
					player1_X_Motion_in = (~player1_X_Step) + 1'b1;
					
				else
				
					player1_X_Motion_in = 0;
				
			end
			
			else if(d_on) begin // Moving to the right by key press
			
				if(left_serve)
			
					if(player1_X_Pos <= player1_bound_serve)
				
						player1_X_Motion_in = player1_X_Step;
											
					else
					
						player1_X_Motion_in = 0;
						
				else
				
					if(player1_X_Pos + player_size <= player1_bound_right)
				
						player1_X_Motion_in = player1_X_Step;
											
					else
					
						player1_X_Motion_in = 0;
				
			end
			
			if(s_on) // perform a swing depending on the position of the bird
       	
				en_swing = 1'b1;
				
			if((!a_on) && (!d_on))
			
				player1_X_Motion_in = 0;
				
			if(player1_Y_Pos < player1_bound_floor)
			
				player1_Y_Motion_in = 10'd1;
			
			else begin
				
				if(w_on)// performing a one time jump 
				
					player1_Y_Motion_in = (~player1_Y_Step) + 1'b1;

				else
			
					player1_Y_Motion_in = 0;
				
			end	
			
		player1_X_Pos_in = player1_X_Pos + player1_X_Motion;
		player1_Y_Pos_in = player1_Y_Pos + player1_Y_Motion;
		
		end
			
	end
		
	int DistX, DistY;
	assign DistX = ADDR_X - player1_X_Pos;
	assign DistY = ADDR_Y - player1_Y_Pos;
	 
	always_comb begin
	
		if ((DistX * DistX) <= (player_size * player_size) && (DistY * DistY) <= (player_size * player_size)) 
			is_player1 = 1'b1;
				
		else
			is_player1 = 1'b0;

	end
					
endmodule
					
					
// module for the right player					
module player2(
					input  logic		  Clk,
					input  logic		  Reset,
					input  logic		  is_Menu,
					input  logic        frame_clk_rising_edge,
					input  logic	 	  right_serve,
					input  logic	 	  en_right_hit,
					input  logic		  left_reset,
					input  logic		  right_reset,
					input  logic 		  i_on, k_on, j_on, l_on,
					input  logic [1:0]  AI_Level,
					input  logic [9:0]  ADDR_X,
					input  logic [9:0]  ADDR_Y,
					input  logic [9:0]  land_X_Pos,
					input  logic [9:0]  bird_Y_Pos,					
					input  logic [31:0] keycode,
					output logic 		  is_player2,
					output logic        en_right_swing,
					output logic [2:0]  right_swing,
					output logic [9:0]  player2_X_Pos,
					output logic [9:0]  player2_Y_Pos
					);
					
	parameter [9:0] player2_init 		   = 10'd239; 
	parameter [9:0] player2_bound_left  = 10'd162; 
	parameter [9:0] player2_bound_right = 10'd309; 
	parameter [9:0] player2_bound_serve = 10'd239; 
	parameter [9:0] player2_bound_floor = 10'd193;
	parameter [9:0] player2_X_Step 	   = 10'd2;      
   parameter [9:0] player2_Y_Step 	   = 10'd15;
	parameter [9:0] player_size 			= 10'd15;
	
	logic [9:0] player2_X_Motion, player2_Y_Motion;
   logic [9:0] player2_X_Pos_in, player2_X_Motion_in, player2_Y_Pos_in, player2_Y_Motion_in;
	logic  		en_swing;
	
	animation rightswing(.*, .player_Y_Pos(player2_Y_Pos), .frame_num(right_swing));
	
	always_ff @ (posedge Clk) begin // position update of player1
	 
		if (Reset) begin
		  
			player2_X_Pos <= 0;
			player2_Y_Pos <= 0;
			player2_X_Motion <= 0;
			player2_Y_Motion <= 0;
			en_right_swing <= 0;
				
      end
		
		else if (is_Menu || right_reset) begin
		  
			player2_X_Pos <= player2_init;
			player2_Y_Pos <= player2_bound_floor;
			player2_X_Motion <= 0;
			player2_Y_Motion <= 0;
			en_right_swing <= 0;
				
      end
		
		else if (AI_Level != 0 && left_reset) begin
		  
			player2_X_Pos <= player2_init;
			player2_Y_Pos <= player2_bound_floor;
			player2_X_Motion <= 0;
			player2_Y_Motion <= 0;
			en_right_swing <= 0;
				
      end
		  
		else begin
		  
         player2_X_Pos <= player2_X_Pos_in;
         player2_Y_Pos <= player2_Y_Pos_in;
         player2_X_Motion <= player2_X_Motion_in;
         player2_Y_Motion <= player2_Y_Motion_in;
			en_right_swing <= en_swing;
				
		end
		  
	end
	 
	always_comb begin // drawing condition and boundary and keypress
	
		player2_X_Pos_in = player2_X_Pos;
		player2_Y_Pos_in = player2_Y_Pos;
		player2_X_Motion_in = player2_X_Motion;
		player2_Y_Motion_in = player2_Y_Motion;
		en_swing = 1'b0;
			
		if (frame_clk_rising_edge) begin
		
			if(AI_Level == 2'b00) begin // Player controlled player2
		
				if(j_on) begin // Moving to the left by key press
				
					if(right_serve)
				
						if(player2_X_Pos >= player2_bound_serve)
						
							player2_X_Motion_in = (~player2_X_Step) + 1'b1;
							
						else
						
							player2_X_Motion_in = 0;
							
					else

						if(player2_X_Pos >= player2_bound_left + player_size)
						
							player2_X_Motion_in = (~player2_X_Step) + 1'b1;
							
						else
						
							player2_X_Motion_in = 0;
					
				end
				
				else if(l_on) begin // Moving to the right by key press
				
					if(player2_X_Pos + player_size <= player2_bound_right)
				
						player2_X_Motion_in = player2_X_Step;
											
					else
					
						player2_X_Motion_in = 0;
					
				end
				
				if(k_on) // perform a swing depending on the position of the bird
				
					en_swing = 1'b1;
				
				if((!j_on) && (!l_on))
			
					player2_X_Motion_in = 0;
						
				if(player2_Y_Pos < player2_bound_floor)
				
					player2_Y_Motion_in = 10'd1;
				
				else begin
					
					if(i_on)// performing a one time jump
					
						player2_Y_Motion_in = (~player2_Y_Step) + 1'b1;
					
					else
				
						player2_Y_Motion_in = 0;
					
				end
			
			end
			
			else begin // AI with different speed
			
				player2_Y_Motion_in = 0; // might change this later depending on the progress

				// move to the bird's X location and swing
				if(player2_X_Pos >= player2_bound_left + player_size &&  player2_X_Pos + player_size <= player2_bound_right && land_X_Pos >= 10'd161) begin
				
					if(player2_X_Pos > (land_X_Pos + 10'd3))
						
						player2_X_Motion_in = ((~AI_Level) + 1'b1) * 2;
					
					else
					
						player2_X_Motion_in = AI_Level * 2;
					
				end
				
				else
				
					player2_X_Motion_in = 0;
					
				if(right_serve)
				
					en_swing = 1'b1;
				
				if(player2_Y_Pos < player2_bound_floor)
			
					player2_Y_Motion_in = 10'd1;
				
				if ((player2_X_Pos - land_X_Pos <= 10'd30) && en_right_swing)
			
					en_swing = 1'b1;
	
			end			
				
			player2_X_Pos_in = player2_X_Pos + player2_X_Motion;
			player2_Y_Pos_in = player2_Y_Pos + player2_Y_Motion;
		
		end
			
	end
		
	int DistX, DistY;
	assign DistX = ADDR_X - player2_X_Pos;
	assign DistY = ADDR_Y - player2_Y_Pos;
	 
	always_comb begin
	
		if ((DistX * DistX) <= (player_size * player_size) && (DistY * DistY) <= (player_size * player_size)) 
			is_player2 = 1'b1;
				
		else
			is_player2 = 1'b0;

	end
					
endmodule


// module for the bird
module bird(
				input  logic		 Clk,
				input  logic		 Reset,
				input  logic       frame_clk_rising_edge,
				input  logic 	    left_serve,
				input  logic 	    right_serve,
				input  logic 		 s_on,				
				input  logic 		 k_on,
				input  logic 		 en_left_hit,
				input  logic 		 en_right_hit,
				input  logic	    en_right_swing,
				input  logic [1:0] AI_Level,
				input  logic [9:0] ADDR_X,
				input  logic [9:0] ADDR_Y,
				input  logic [9:0] player1_X_Pos,
				input  logic [9:0] player1_Y_Pos,
				input  logic [9:0] player2_X_Pos,
				input  logic [9:0] player2_Y_Pos,
				input  logic [9:0] land_X_Pos,
				output logic 	    is_bird,
				output logic		 bird_hit,
				output logic [2:0] bird_dir,
				output logic [9:0] bird_X_Pos,
				output logic [9:0] bird_Y_Pos,
				output logic [9:0] bird_X_Motion,
				output logic [9:0] bird_Y_Motion			
				);
				
	parameter [9:0] bird_X_init 	   = 10'd160; 
	parameter [9:0] bird_Y_init 	   = 10'd120;
	parameter [9:0] bird_bound_left  = 10'd7; 
	parameter [9:0] bird_bound_right = 10'd312; 
	parameter [9:0] bird_bound_floor = 10'd193;
	parameter [9:0] bird_X_Step 		= 10'd6;      
   parameter [9:0] bird_Y_Step 	   = 10'd15;
	parameter [9:0] bird_size 	 		= 10'd3;
	
   logic [9:0] bird_X_Pos_in, bird_X_Motion_in, bird_Y_Pos_in, bird_Y_Motion_in;
	logic [2:0] bird_dir_in;
	logic			bird_hit_in;
	
	// distance calculation for hitting the bird
	logic[9:0] DistB1X,  DistB2X;
	logic S1, S2, left_hit, right_hit, AI_hit;
	assign DistB1X = bird_X_Pos - player1_X_Pos;
	assign DistB2X = bird_X_Pos - player2_X_Pos;
	
	// actual signal for successful hit
	assign S1 = (land_X_Pos - player1_X_Pos <= 10'd30) && (land_X_Pos - player1_X_Pos >= 0);
	assign S2 = (player2_X_Pos - land_X_Pos <= 10'd30) && (player2_X_Pos - land_X_Pos >= 0);
	
	assign left_hit = s_on && S1 && en_left_hit;	
	assign right_hit = (k_on || en_right_swing) && S2 && en_right_hit;
	assign AI_hit =  (AI_Level != 0) && en_right_swing;
	
	always_ff @ (posedge Clk) begin // position update of bird
	 
		if (Reset) begin
		  
			bird_X_Pos <= bird_X_init;
			bird_Y_Pos <= bird_Y_init;
			bird_dir <= 3'b0;
			bird_hit <= 1'b0;
				
      end
		
		else if(left_serve) begin
		
			bird_X_Pos <= player1_X_Pos + 10'd11;
		   bird_Y_Pos <= player1_Y_Pos - 10'd7;
			bird_dir <= 3'd2;
			bird_hit <= 1'b1;
			
		end
			
	   else if(right_serve) begin
			
			bird_X_Pos <= player2_X_Pos - 10'd11;
		   bird_Y_Pos <= player2_Y_Pos - 10'd7;
			bird_dir <= 3'd2;
			bird_hit <= 1'b1;
		
		end
		
		else begin
		  
         bird_X_Pos <= bird_X_Pos_in;
         bird_Y_Pos <= bird_Y_Pos_in;
			bird_dir <= bird_dir_in;
			bird_hit <= bird_hit_in;
				
		end
		
		bird_X_Motion <= bird_X_Motion_in;
      bird_Y_Motion <= bird_Y_Motion_in;
		  
	end
	
	always_comb begin
	
		bird_X_Pos_in = bird_X_Pos;
		bird_Y_Pos_in = bird_Y_Pos;
		bird_X_Motion_in = bird_X_Motion;
		bird_Y_Motion_in = bird_Y_Motion;
		bird_hit_in = 1'b0;
		
		if (frame_clk_rising_edge) begin
		
			if(left_serve || left_hit) begin
			
				bird_X_Motion_in = bird_X_Step;
				bird_Y_Motion_in = (~bird_Y_Step) + 1'b1;
				bird_hit_in = 1'b1;
				
			end
				
			else if(right_serve || right_hit || AI_hit) begin
			
				bird_X_Motion_in = (~bird_X_Step) + 1'b1;
				bird_Y_Motion_in = (~bird_Y_Step) + 1'b1;
				bird_hit_in = 1'b1;
			
			end
			
			// if not hit, then gradually fall while keeping the same X motion
			else begin
				
				bird_Y_Motion_in = bird_Y_Motion + 1'b1;
				
			end
			
			if(bird_X_Pos < 10'd160 && (bird_X_Pos + bird_X_Motion >= 10'd160)) 
			
				bird_X_Pos_in = 10'd160;
				
			else if(bird_X_Pos > 10'd161 && (bird_X_Pos + bird_X_Motion <= 10'd161))
			
				bird_X_Pos_in = 10'd161;
			
			else
				
				bird_X_Pos_in = bird_X_Pos + bird_X_Motion;
				
			bird_Y_Pos_in = bird_Y_Pos + bird_Y_Motion;
		
		end
	
	end
	
	always_comb begin // getting the sprite corresponding coordinates for correct orientation of the bird
	
			  if(bird_X_Motion == 0 		&& bird_Y_Motion >= 10'd200) bird_dir_in = 3'd0; 
		else if(bird_X_Motion <= 10'd200 && bird_Y_Motion == 0		) bird_dir_in = 3'd1;
		else if(bird_X_Motion == 0 		&& bird_Y_Motion <= 10'd200) bird_dir_in = 3'd2;
		else if(bird_X_Motion >= 10'd200 && bird_Y_Motion == 0		) bird_dir_in = 3'd3;
		else if(bird_X_Motion >= 10'd200 && bird_Y_Motion >= 10'd200) bird_dir_in = 3'd4;
		else if(bird_X_Motion <= 10'd200 && bird_Y_Motion >= 10'd200) bird_dir_in = 3'd5;
		else if(bird_X_Motion <= 10'd200 && bird_Y_Motion <= 10'd200) bird_dir_in = 3'd6;
		else if(bird_X_Motion >= 10'd200 && bird_Y_Motion <= 10'd200) bird_dir_in = 3'd7;
		else bird_dir_in = 3'd2;
		
	end
	
	int DistX, DistY;
	assign DistX = ADDR_X - bird_X_Pos;
	assign DistY = ADDR_Y - bird_Y_Pos;
	 
	always_comb begin // draw the bird
	
		if ((DistX * DistX) <= (bird_size * bird_size) && (DistY * DistY) <= (bird_size * bird_size)) 
			is_bird = 1'b1;
				
		else
			is_bird = 1'b0;

	end
				
endmodule	


// state machine for bird
module bird_FSM(
					 input  logic 		 Clk,
					 input  logic 		 Reset,
					 input  logic 		 is_Menu,
					 input  logic 	 	 en_left_swing,
					 input  logic 		 en_right_swing,
					 input  logic[9:0] bird_X_Pos,
					 input  logic[9:0] bird_Y_Pos,
					 output logic 		 left_scored,
					 output logic 		 right_scored,
					 output logic 		 left_serve,
					 output logic 		 right_serve,
					 output logic 		 left_reset,
					 output logic 		 right_reset,
					 output logic 		 en_left_hit,
					 output logic 		 en_right_hit,
					 output logic		 is_play
					);
					
	enum logic[2:0] {
						  LR, RR, LS, RS, LH, RH
						  }State, Next_State;
						  
	always_ff @ (posedge Clk) begin
		
		if(Reset || is_Menu)
			State <= LS;
		
		else
			State <= Next_State;
		
	end
	
	always_comb begin
	
		Next_State = State;
		left_serve = 1'b0;
		right_serve = 1'b0;
		left_scored = 1'b0;
		right_scored = 1'b0;
		left_reset = 1'b0;
		right_reset = 1'b0;
		en_left_hit = 1'b0;
		en_right_hit = 1'b0;
		is_play = 1'b0;
		
		unique case(State)
		
			LR:
				Next_State = LS;
				
			RR:
				Next_State = RS;
				
			LS:
			begin
				if(en_left_swing)
					Next_State = RH;
			end
			
			RS:
			begin
				if(en_right_swing)
					Next_State = LH;
			end
					
			LH:
			begin
				if((bird_X_Pos >= 10'd161 && bird_Y_Pos >= 10'd193) || (bird_X_Pos == 10'd161 && bird_Y_Pos >= 10'd162) || (bird_X_Pos <= 10'd8))
					Next_State = LR;
				else if((bird_X_Pos < 10'd160 && bird_Y_Pos >= 10'd193) || (bird_X_Pos == 10'd160 && bird_Y_Pos >= 10'd162) || (bird_X_Pos >= 10'd312))
					Next_State = RR;
				else if(en_left_swing)
					Next_State = RH;
			end
					
			RH: 
			begin
				if((bird_X_Pos >= 10'd161 && bird_Y_Pos >= 10'd193) || (bird_X_Pos == 10'd161 && bird_Y_Pos >= 10'd162) || (bird_X_Pos <= 10'd8))
					Next_State = LR;
				else if((bird_X_Pos < 10'd160 && bird_Y_Pos >= 10'd193) || (bird_X_Pos == 10'd160 && bird_Y_Pos >= 10'd162) || (bird_X_Pos >= 10'd312))
					Next_State = RR;
				else if(en_right_swing)
					Next_State = LH;
			end
			
		endcase
		
		case(State)
		
			LR:
				left_reset = 1'b1;
				
			RR:
				right_reset = 1'b1;
				
			LS: 
				left_serve = 1'b1;
				
			RS:
				right_serve = 1'b1;
				
			LH:
			begin
			
				en_left_hit = 1'b1;
				is_play = 1'b1;
				
				if((bird_X_Pos < 10'd160 && bird_Y_Pos >= 10'd193) || (bird_X_Pos == 10'd160 && bird_Y_Pos >= 10'd162) || (bird_X_Pos <= 10'd8))
					right_scored = 1'b1;
					
				else if((bird_X_Pos > 10'd161 && bird_Y_Pos >= 10'd193) || (bird_X_Pos == 10'd161 && bird_Y_Pos >= 10'd162) || (bird_X_Pos >= 10'd312))
					left_scored = 1'b1;
					
				else begin
					
					left_scored = 1'b0;
					right_scored = 1'b0;
					
				end
					
			end
			
			RH:
			begin
			
				en_right_hit = 1'b1;
				is_play = 1'b1;
				
				if((bird_X_Pos < 10'd160 && bird_Y_Pos >= 10'd193) || (bird_X_Pos == 10'd160 && bird_Y_Pos >= 10'd162) || (bird_X_Pos <= 10'd8))
					right_scored = 1'b1;
					
				else if((bird_X_Pos > 10'd161 && bird_Y_Pos >= 10'd193) || (bird_X_Pos == 10'd161 && bird_Y_Pos >= 10'd162) || (bird_X_Pos >= 10'd312))
					left_scored = 1'b1;
					
				else begin
					
					left_scored = 1'b0;
					right_scored = 1'b0;
					
				end
					
			end
			
		endcase
		
	end				
					
endmodule
					 

// animation module for player swinging					
module animation(
					  input  logic 	  Clk,
					  input  logic      frame_clk_rising_edge,
					  input  logic 	  en_swing,
					  input  logic[9:0] player_Y_Pos,
					  input  logic[9:0] bird_Y_Pos,
					  output logic[2:0] frame_num
					  );
				
	enum logic[3:0] {
						  rest, 
						  upswing1, upswing2, upswing3, upswing4, upswing5,
						  downswing1, downswing2, downswing3, downswing4, downswing5, downswing6, downswing7
						  }State, Next_State;
						  	
	always_ff @ (posedge Clk) begin
		
		State <= Next_State;
		
	end
	
	always_comb begin
	
		Next_State = State;
		frame_num = 3'd0;
		
		unique case(State)
		
			rest:
				if(en_swing && (bird_Y_Pos >= player_Y_Pos))
					Next_State = downswing1;
				else if(en_swing && (bird_Y_Pos <= player_Y_Pos))
					Next_State = upswing1;
					
			upswing1:
				if(frame_clk_rising_edge)
					Next_State = upswing2;
				
			upswing2:
				if(frame_clk_rising_edge)
					Next_State = upswing3;
			
			upswing3:
				if(frame_clk_rising_edge)
					Next_State = upswing4;
			
			upswing4:
				if(frame_clk_rising_edge)
					Next_State = upswing5;
				
			upswing5:
				if(frame_clk_rising_edge)
					Next_State = rest;
				
			downswing1:
				if(frame_clk_rising_edge)
					Next_State = downswing2;
				
			downswing2:
				if(frame_clk_rising_edge)
					Next_State = downswing3;
			
			downswing3:
				if(frame_clk_rising_edge)
					Next_State = downswing4;
			
			downswing4:
				if(frame_clk_rising_edge)
					Next_State = downswing5;
				
			downswing5:
				if(frame_clk_rising_edge)
					Next_State = downswing6;
				
			downswing6:
				if(frame_clk_rising_edge)
					Next_State = downswing7;
			
			downswing7:
				if(frame_clk_rising_edge)
					Next_State = rest;
		
		endcase
		
		case(State)
		
			rest:;
		
			upswing1, upswing5:
				frame_num = 3'd1;
		
			upswing2, upswing4:
				frame_num = 3'd2;
			
			upswing3:
				frame_num = 3'd3;
				
			downswing1, downswing7:
				frame_num = 3'd4;
				
			downswing2, downswing6:
				frame_num = 3'd5;
				
			downswing3, downswing5:
				frame_num = 3'd6;
				
			downswing4:
				frame_num = 3'd7;
				
		endcase
		
	end
	
endmodule

// module for returning the bird
module parabola(
					 input  logic 		  Clk,
					 input  logic 		  Reset,
					 input  logic		  is_play,
					 input  logic		  bird_hit,
					 input  logic [9:0] bird_X_Pos,
					 input  logic [9:0] bird_X_Motion,
					 input  logic [9:0] bird_Y_Motion,
					 output logic [9:0] land_X_Pos
					);
					
	logic[9:0] land_X_Pos_in;			
				
	always_ff @ (posedge Clk) begin
			
		if(is_play)
		
			land_X_Pos <= land_X_Pos_in;
			
		else
		
			land_X_Pos <= 0;

	end
	
	always_comb begin
	
		if(bird_hit)
		
			land_X_Pos_in = bird_X_Pos - (bird_X_Motion * bird_Y_Motion * 2);
			
		else
		
			land_X_Pos_in = land_X_Pos;
	
	end
			
endmodule
