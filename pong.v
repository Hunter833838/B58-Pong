`timescale 1ns / 1ns // `timescale time_unit/time_precision

//SW[2:0] data inputs
//SW[9] select signal

//LEDR[0] output display

// Part 2 skeleton

module Pong
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
		, LEDR
	);
	output [17:0] LEDR;

	input			CLOCK_50;				//	50 MHz
	input   [16:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = 1'b1;
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(1'b1),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
		
       mainGame(SW,KEY, x, y, colour, CLOCK_50, test);
		 // assign LEDR[5] = test;
endmodule






module mainGame(SW, KEY, x, y, colour, CLOCK_50, test);


	
	 
	 input [17:0] SW;
    input   [3:0]   KEY;
	 input CLOCK_50;
    output reg [2:0] colour;
    output reg [7:0] x;
    output reg [6:0] y;



    integer maxValue;
    integer ball_x = 10;
    integer ball_y = 10;
    reg ball_up;
    reg ball_right;	
	 
	 // ball 2 stuff
    integer ball_x2 = 10;
    integer ball_y2 = 10;
    reg ball_up2;
    reg ball_right2;	
	 // end ball 2 stuff
	 
	 
	 
    integer left_paddle = 50;
	 integer right_paddle = 50;
	 integer top_paddle = 40;
	integer  bottom_paddle = 40;
	
	
   reg [159:0] grid [119:0];
    integer i;
    integer j;
	 integer x_offset;
	 integer y_offset;
    wire clear_a, clear_b;
    assign clear_a = SW[2];
    assign clear_b = SW[3];

//    wire [1:0] select;
//    assign select = SW[1:0];
		
		
		
		
	 //speed selector
	 wire [27:0] speed;
	 SpeedSelect(SW[1:0], speed);
	 
	 wire [27:0] Q;
	 RteDivider(CLOCK_50, 1'b1, speed, Q);
    
	 wire enable;
    assign enable = (Q == 0 ) ? 1 : 0;
	 output reg test;
    //maxValueSelect(select, maxValue);
	
    //need to define internal clock
	 reg r_moved, l_moved;
	
	 reg menuSwitch;
	
	 integer  curr_state; 
    
    localparam  menu     = 0,
                leftLost = 1,
					 rightLost = 2,
                maingame = 3,
					 twoBall = 4,
					 fourPlayer = 5,
					 topLost = 6,
					 bottomLost = 7;
		  
	// curr_state = maingame;
	 			// R
			wire [11:0]textSelect;
			
	// game over for right
	Pixel_On_Text2 #(.displayText("LEFT LOSES (EPIC)")) t1(
		 CLOCK_50,
		 20, // text position.x (top left)
		 20, // text position.y (top l;  // result, 1 if current pixel is on text, 0 otherwise
		 i, // current position.x
		 j, // current position.y
		 textSelect[0]  // result, 1 if current pixel is on text, 0 otherwise
	);	
	
	// game over for left
	Pixel_On_Text2 #(.displayText("RIGHT LOSES (!EPIC)")) t2(
		 CLOCK_50,
		 0, // text position.x (top left)
		 20, // text position.y (top left)
		 i, // current position.x
		 j, // current position.y
		 textSelect[1]  // result, 1 if current pixel is on text, 0 otherwise
	);	

	
	Pixel_On_Text2 #(.displayText("PONG++")) t3(
		 CLOCK_50,
		 60, // text position.x (top left)
		 2, // text position.y (top left)
		 i, // current position.x
		 j, // current position.y
		 textSelect[2]  // result, 1 if current pixel is on text, 0 otherwise
	);
	
	Pixel_On_Text2 #(.displayText("SW[6] - Menu")) t4(
		 CLOCK_50,
		 20, // text position.x (top left)
		 40, // text position.y (top left)
		 i, // current position.x
		 j, // current position.y
		 textSelect[3]  // result, 1 if current pixel is on text, 0 otherwise
	);
	
	Pixel_On_Text2 #(.displayText("KEY[0] - OG Pong")) t5(
		 CLOCK_50,
		 20, // text position.x (top left)
		 15, // text position.y (top left)
		 i, // current position.x
		 j, // current position.y
		 textSelect[4]  // result, 1 if current pixel is on text, 0 otherwise
	);
	
	Pixel_On_Text2 #(.displayText("KEY[1] - Ball x2")) t6(
		 CLOCK_50,
		 20, // text position.x (top left)
		 30, // text position.y (top left)
		 i, // current position.x
		 j, // current position.y
		 textSelect[5]  // result, 1 if current pixel is on text, 0 otherwise
	);
	
	Pixel_On_Text2 #(.displayText("KEY[2] - 4 Player")) t7(
		 CLOCK_50,
		 20, // text position.x (top left)
		 45, // text position.y (top left)
		 i, // current position.x
		 j, // current position.y
		 textSelect[6]  // result, 1 if current pixel is on text, 0 otherwise
	);
	
		Pixel_On_Text2 #(.displayText("TOP LOSES (BONELESS)")) t8(
		 CLOCK_50,
		 0, // text position.x (top left)
		 20, // text position.y (top left)
		 i, // current position.x
		 j, // current position.y
		 textSelect[7]  // result, 1 if current pixel is on text, 0 otherwise
	);
	
	Pixel_On_Text2 #(.displayText("BOTTOM LOSES (uWu)")) t9(
		 CLOCK_50,
		 0, // text position.x (top left)
		 20, // text position.y (top left)
		 i, // current position.x
		 j, // current position.y
		 textSelect[8]  // result, 1 if current pixel is on text, 0 otherwise
	);
	
	Pixel_On_Text2 #(.displayText("R:KEY 0-1, L:KEY 2-3")) t10(
		 CLOCK_50,
		 0, // text position.x (top left)
		 70, // text position.y (top left)
		 i, // current position.x
		 j, // current position.y
		 textSelect[9]  // result, 1 if current pixel is on text, 0 otherwise
	);
	
	Pixel_On_Text2 #(.displayText("T:SW 14-15, B:SW 7-8")) t11(
		 CLOCK_50,
		 0, // text position.x (top left)
		 85, // text position.y (top left)
		 i, // current position.x
		 j, // current position.y
		 textSelect[10]  // result, 1 if current pixel is on text, 0 otherwise
	);



			// I
			//assign grid[5 + x_offset][0 + y_offset] = 1'b1;
    always @(posedge CLOCK_50)
    begin
		 
		  // logic for paddles an ball common to all gamemodes
			if (curr_state == maingame || curr_state == twoBall || curr_state == fourPlayer)//curr_state == maingame)
			begin	
			  if (enable)
			  begin   
			  	menuSwitch = SW[6];
				test = test + 1'b1;
					if(curr_state == fourPlayer) begin
						if (ball_y <= 0 )
							//ball_x = 80;
							curr_state = topLost;
							//ball_right = !ball_right;
						if (ball_y >= 118)
							curr_state = bottomLost;
					end
					
					// ball hits left 
					if (ball_x <= 0 )
						//ball_x = 80;
						curr_state = leftLost;
						//ball_right = !ball_right;
					if (ball_x >= 158)
						curr_state = rightLost;
					// ball hits top or bottom
					if (ball_y == 0 || ball_y == 118)
						ball_up = !ball_up;	
					// move ball
					if (ball_right)begin
						ball_x = ball_x + 1;
						//	 assign grid[ball_x][ball_y] = 1'b1; 
							 end
					else begin
						ball_x = ball_x -1;
							// assign grid[ball_x][ball_y] = 1'b1; 
										end
			
					if (ball_up) begin
						ball_y = ball_y - 1;
							// assign grid[ball_x][ball_y] = 1'b1; 
						end
					else begin
							 ball_y = ball_y + 1;
							// assign grid[ball_x][ball_y] = 1'b1; 
						end

						//right down
					if (right_paddle <= 103 && !KEY[0])
						right_paddle = right_paddle +2;
									//right up
					else if (right_paddle >= 0 && !KEY[1])
						right_paddle = right_paddle - 2;
											// left down
					if (left_paddle <= 103 && !KEY[2])
						left_paddle = left_paddle +2;
									//left up
					else if (left_paddle >= 0 && !KEY[3])
						left_paddle = left_paddle - 2;
						
					// if ball hit right paddle
					if (right_paddle < ball_y && ball_y < right_paddle+ 15 && ball_x == 158)//assign grid[ball_x][ball_y] && ball_right)
					begin
						ball_right = 1'b0;
						ball_x = ball_x - 2;
					end
					// if ball hit left paddle
					else if (left_paddle < ball_y && ball_y < left_paddle + 15 && ball_x == 0)
					begin
						ball_right = 1'b1;
						ball_x = ball_x + 2;
					end
					//add new ball
					
					
					
					// movement for second ball if in twoball state
					if(curr_state == twoBall) begin
					
			
						// ball hits left 
						if (ball_x2 <= 0 )
							//ball_x = 80;
							curr_state = leftLost;
							//ball_right = !ball_right;
						if (ball_x2 >= 158)
							curr_state = rightLost;
						// ball hits top or bottom
						if (ball_y2 == 0 || ball_y2 == 118)
							ball_up2 = !ball_up2;	
						// move ball
						if (ball_right2)begin
							ball_x2 = ball_x2 + 1;
							//	 assign grid[ball_x][ball_y] = 1'b1; 
								 end
						else begin
							ball_x2 = ball_x2 -1;
								// assign grid[ball_x][ball_y] = 1'b1; 
											end
				
						if (ball_up2) begin
							ball_y2 = ball_y2 - 1;
								// assign grid[ball_x][ball_y] = 1'b1; 
							end
						else begin
								 ball_y2 = ball_y2 + 1;
								// assign grid[ball_x][ball_y] = 1'b1; 
							end

							//right down
						
							
						// if ball hit right paddle
						if (right_paddle < ball_y2 && ball_y2 < right_paddle+ 15 && ball_x2 == 158)//assign grid[ball_x][ball_y] && ball_right)
						begin
							ball_right2 = 1'b0;
							ball_x2 = ball_x2 - 2;
						end
						// if ball hit left paddle
						else if (left_paddle < ball_y2 && ball_y2 < left_paddle + 15 && ball_x2 == 0)
						begin
							ball_right2 = 1'b1;
							ball_x2 = ball_x2 + 2;
						end
					
					end
					
				
			
	
		

						

						
						
						//assign grid[ball_x][ball_y] = 1'b1; 
						
					if(curr_state == fourPlayer) begin
//						if (ball_y <= 0 )
//							//ball_x = 80;
//							curr_state = rightLost;
//							//ball_right = !ball_right;
//						if (ball_y >= 119)
//							curr_state = leftLost;
					
						
						// if ball hit top paddle
						if (top_paddle < ball_x && ball_x < top_paddle+ 20 && ball_y == 0)//assign grid[ball_x][ball_y] && ball_right)
						begin
							ball_up = 1'b0;
							ball_y = ball_y + 2;
						end
						// if ball hit left paddle
						else if (bottom_paddle < ball_x && ball_x < bottom_paddle + 20 && ball_y == 118)
						begin
							ball_up = 1'b1;
							ball_y = ball_y - 2;
						end

						
						
						if (top_paddle <= 138 && SW[14])
							top_paddle = top_paddle +2;
										//right up
						if (top_paddle >= 0 && SW[15])
							top_paddle = top_paddle - 2;
												// left down
						if (bottom_paddle <= 138 && SW[7])
							bottom_paddle = bottom_paddle +2;
										//left up
						if (bottom_paddle >= 0 && SW[8])
							bottom_paddle = bottom_paddle - 2;
						

					
					end
						
						
				end	
				// display the game grid
				else
				begin
					
					// Colours the appropriate pixel
					if (i == ball_x && j == ball_y)
						colour = 3'b111;
					else if(left_paddle < j && j < left_paddle + 15 && i == 0)
						colour = 3'b111;
					else if(right_paddle < j && j < right_paddle+ 15 && i == 158)
						colour = 3'b111;
					else if(curr_state == twoBall && (i == ball_x2 && j == ball_y2))
						colour = 3'b111;
					else if(curr_state == fourPlayer && (top_paddle < i && i < top_paddle+ 20 && j == 0))
						colour = 3'b111;
					else if(curr_state == fourPlayer && (bottom_paddle < i && i < bottom_paddle+ 20 && j == 118))
						colour = 3'b111;
					else
						colour = 3'b000; 	
					// move on to the next pixel to draw
//					j = j + 1;
//					y = y + 1'b1;
//					if (j == 120)
//					begin
//						i = i + 1;
//						x = x + 1'b1;
//				
//						j = 0;
//						y = 1'b0;	 
//					end	                                                                                          
//					if (i ==160)
//					begin
//						i =0;
//						x = 1'b0;
//					end

				end
			end
		 else if (curr_state == leftLost)
			begin


			if(textSelect[0] || textSelect[3])
			colour = 3'b111;
			else
			colour = 3'b000;


				
			
				if(SW[6] != menuSwitch)
				begin
					ball_x = 80;
					curr_state = menu;
					
				end
			end
			
		else if (curr_state == rightLost)
		begin


		if(textSelect[1] || textSelect[3])
			colour = 3'b111;
			else
			colour = 3'b000;


				
			
				if(SW[6] != menuSwitch)
				begin
					ball_x = 80;
					curr_state = menu;
					
				end
			end
			
		else if (curr_state == topLost)
		begin


		if(textSelect[7] || textSelect[3])
			colour = 3'b111;
			else
			colour = 3'b000;


				
			
				if(SW[6] != menuSwitch)
				begin
					ball_x = 80;
					curr_state = menu;
					
				end
			end
		
		else if (curr_state == bottomLost)
		begin


		if(textSelect[8] || textSelect[3])
			colour = 3'b111;
			else
			colour = 3'b000;


				
			
				if(SW[6] != menuSwitch)
				begin
					ball_x = 80;
					curr_state = menu;
					
				end
			end
			
		else if (curr_state == menu)
		begin
		if(textSelect[2] || textSelect[4] || textSelect[5] || textSelect[6] || textSelect[9] || textSelect[10])
			colour = 3'b111;
			else
			colour = 3'b000;
			ball_x = 63;
			ball_y = 12;
			ball_right = 1'b1; 
			ball_x2 = 112;
			ball_y = 71;
			ball_right2 = 1'b0;
			top_paddle = 90;
			bottom_paddle = 90;
			right_paddle = 70;
			left_paddle = 70;
			
		if(!KEY[0])
				begin

					curr_state = maingame;
					
				end
		if(!KEY[1])
				begin

					curr_state = twoBall;
					
				end
		if(!KEY[2])
				begin

					curr_state = fourPlayer;
					
				end
		end
			
						j = j + 1;
	y = y + 1'b1;
	if (j == 120)
	begin
		i = i + 1;
		x = x + 1'b1;

		j = 0;
		y = 1'b0;	 
	end	   
	if (i ==160)
	begin
		i =0;
		x = 1'b0;
	end
		 end
		 
		 

		 
		 
endmodule

//module maxValueSelect(select, maxValue);
//    input [1:0] select;
//    output reg [31:0] maxValue;
//    always @(*)
//    begin
//    	case(select[1:0])
//    		2'b00: maxValue = 'd0; //no prefix defaults to 32 bit
//    		2'b01: maxValue = 'd49999999;
//    		2'b10: maxValue = 'd99999999;
//    		2'b11: maxValue = 'd199999999;
//    	endcase
//    end
//endmodule

module RteDivider(clk, reset, timer, Q);
	input clk, reset;
	input [27:0] timer;
	output reg [27:0] Q;

	always @(posedge clk)
	begin
		if(reset == 1'b0) 
			Q <= 0;
		else if(Q == 0)
			Q <= timer;
		else 
			Q <= Q - 1'b1;
	end
endmodule

module SpeedSelect(select, maxValue);
    input [1:0] select;
    output reg [27:0] maxValue;
    always @(*)
    begin
    	case(select[1:0])
    		2'b00: maxValue = 27'b000000100011111100000111111; //Easy
    		2'b01: maxValue = 27'b000000011011111100000111111; //Medium
    		2'b10: maxValue = 27'b000000010000000000000111111; //Hard
    		2'b11: maxValue = 27'b000000001111111100000111111; //Really Hard
    	endcase
    end
endmodule








