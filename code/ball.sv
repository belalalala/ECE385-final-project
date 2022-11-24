module  ball ( input         Clk,               
                             Reset,             
                             frame_clk,         
					input [7:0]   keycode,
               input [9:0]   DrawX, DrawY,      
               output logic  is_ball            
              );
    
    parameter [9:0] Ball_X_Center = 10'd320; 
    parameter [9:0] Ball_Y_Center = 10'd240; 
    parameter [9:0] Ball_X_Min = 10'd0;      
    parameter [9:0] Ball_X_Max = 10'd639;    
    parameter [9:0] Ball_Y_Min = 10'd0;      
    parameter [9:0] Ball_Y_Max = 10'd479;    
    parameter [9:0] Ball_X_Step = 10'd1;      
    parameter [9:0] Ball_Y_Step = 10'd1;      
    parameter [9:0] Ball_Size = 10'd4;        
    
    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion;
    logic [9:0] Ball_X_Pos_in, Ball_X_Motion_in, Ball_Y_Pos_in, Ball_Y_Motion_in;
    
    logic frame_clk_delayed, frame_clk_rising_edge;
    always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    end

    always_ff @ (posedge Clk)
    begin
        if (Reset)
        begin
            Ball_X_Pos <= Ball_X_Center;
            Ball_Y_Pos <= Ball_Y_Center;
            Ball_X_Motion <= 10'd0;
            Ball_Y_Motion <= Ball_Y_Step;
        end
        else
        begin
            Ball_X_Pos <= Ball_X_Pos_in;
            Ball_Y_Pos <= Ball_Y_Pos_in;
            Ball_X_Motion <= Ball_X_Motion_in;
            Ball_Y_Motion <= Ball_Y_Motion_in;
        end
    end

    always_comb
    begin

        Ball_X_Pos_in = Ball_X_Pos;
        Ball_Y_Pos_in = Ball_Y_Pos;
        Ball_X_Motion_in = Ball_X_Motion_in;
        Ball_Y_Motion_in = Ball_Y_Motion_in;
        
        if (frame_clk_rising_edge)
        begin
				if(keycode == 8'h1A) // W
				begin
                Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
					 Ball_X_Motion_in = 0;
				end
            else if(keycode == 8'h16 ) // S
				begin 									
                Ball_Y_Motion_in = Ball_Y_Step;
					 Ball_X_Motion_in = 0;
				end
				else if(keycode == 8'h04) // A
				begin
                Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
					 Ball_Y_Motion_in = 0;
				end
            else if(keycode == 8'h07)  // D
				begin
                Ball_X_Motion_in = Ball_X_Step;
					 Ball_Y_Motion_in = 0;
				end

            if( Ball_Y_Pos + Ball_Size >= Ball_Y_Max )
				begin
                Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
					 Ball_X_Motion_in = 0;
				end
            else if ( Ball_Y_Pos <= Ball_Y_Min + Ball_Size )
				begin
                Ball_Y_Motion_in = Ball_Y_Step;
					 Ball_X_Motion_in = 0;
				end
				if( Ball_X_Pos + Ball_Size >= Ball_X_Max ) 
				begin
                Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
					 Ball_Y_Motion_in = 0;
				end
            else if ( Ball_X_Pos <= Ball_X_Min + Ball_Size )
				begin
                Ball_X_Motion_in = Ball_X_Step;
					 Ball_Y_Motion_in = 0;
				end

            Ball_X_Pos_in = Ball_X_Pos + Ball_X_Motion;
            Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;
        end

    end

    int DistX, DistY, Size;
    assign DistX = DrawX - Ball_X_Pos;
    assign DistY = DrawY - Ball_Y_Pos;
    assign Size = Ball_Size;
    always_comb begin
        if ( ( DistX*DistX + DistY*DistY) <= (Size*Size) ) 
            is_ball = 1'b1;
        else
            is_ball = 1'b0;
    end
    
endmodule
