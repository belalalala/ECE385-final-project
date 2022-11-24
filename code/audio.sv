module audio(
				 input logic         WE, Clk,
				 input logic  [3:0]  Data_In,
				 input logic  [18:0] ADDR_W,
				 input logic  [18:0] ADDR_R,
				 output logic [15:0] Data_Out
				 );

	logic [3:0] background_audio [0:2099];

	initial begin // read the audio file
	
	 $readmemh("audio_FP.txt", background_audio);
	 
	end


	always_ff @ (posedge Clk) begin

		if(WE)
			background_audio[ADDR_W] <= Data_In;
			
		Data_Out <= {{background_audio[ADDR_R]}, {background_audio[ADDR_R + 2'd1]}, 
						 {background_audio[ADDR_R + 2'd2]}, {background_audio[ADDR_R+2'd3]}};
		
	end

endmodule
