module audio_controller(
								input logic  Clk, 
								input logic  Reset,
								input logic  AUD_DACLRCK, 
								input logic  AUD_ADCLRCK, 
								input logic  AUD_BCLK,
								output logic AUD_DACDAT, 
								output logic AUD_XCK, 
								output logic I2C_SCLK, 
								output logic I2C_SDAT
								);
	
	audio_interface audio_int(
									  .LDATA(LDATA),
									  .RDATA(RDATA),
									  .clk(Clk),
									  .Reset(Reset),
									  .INIT(INIT),
									  .INIT_FINISH(INIT_FINISH),
									  .adc_full(adc_full),
									  .data_over(data_over),
									  .AUD_MCLK(AUD_XCK),
									  .AUD_BCLK(AUD_BCLK),
									  .AUD_ADCDAT(AUD_ADCDAT),
									  .AUD_DACDAT(AUD_DACDAT),
									  .AUD_ADCLRCK(AUD_ADCLRCK),
									  .AUD_DACLRCK(AUD_DACLRCK),
									  .I2C_SDAT(I2C_SDAT),
									  .I2C_SCLK(I2C_SCLK),
									  .ADCDATA(ADCDATA)
									  );
									  
	audio audio_0 (.Data_In(4'b0), .ADDR_W(19'b0), .ADDR_R(ADDR_Count), .WE(1'b0), .*);

	enum logic [3:0] {Rest, Initial, Fetch, DAC} State, Next_state;

	logic 		 INIT, INIT_FINISH, data_over, adc_full, AUD_ADCDAT;
	logic [31:0] ADCDATA;
	logic [15:0] LDATA, RDATA, LDATA_in, RDATA_in, Data_Out;
	logic [19:0] ADDR_Count;

	always_ff @(posedge Clk) begin
	
		if (Reset) begin
		
			State <= Rest;
			LDATA <= 0;
			RDATA <= 0;
			
		end
			
		else begin
		
			State <= Next_state;
			LDATA <= LDATA_in;
			RDATA <= RDATA_in;
			
		end
		
	end


	always_ff @(posedge data_over) begin
	
		if(Reset)
			ADDR_Count <= 6'b0;
			
		else
			ADDR_Count <= ADDR_Count + 3'd4;
			
	end

	always_comb begin
	
		INIT = 1'b0;
		Next_state = State;
		LDATA_in = LDATA;
		RDATA_in = RDATA;
		
		case(State)
		
			Rest: 	
				Next_state = Initial;
				
			Initial: 
			begin 
			
				if(INIT_FINISH)
					Next_state = Fetch;
					
			end
			
			Fetch: 
			begin
			
				if(data_over)
					Next_state = DAC;
					
			end
			
			DAC: 
			begin
			
				if(~data_over)
					Next_state = Fetch;
					
			end 

		endcase		
	
		case(State)
		
			Initial: INIT = 1'b1;
			
			DAC: 
			begin
			
				LDATA_in = Data_Out;
				RDATA_in = Data_Out;
				
			end

		endcase
	end

endmodule
