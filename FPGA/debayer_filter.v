`timescale 1ns/1ns

/*
MIPI CSI RX to Parallel Bridge (c) by Gaurav Singh www.CircuitValley.com

MIPI CSI RX to Parallel Bridge is licensed under a
Creative Commons Attribution 3.0 Unported License.

You should have received a copy of the license along with this
work.  If not, see <http://creativecommons.org/licenses/by/3.0/>.
*/

/*
Takes 4x10bit pixel from RAW10 depacker module @mipi byte clock output 4x30bit RGB for each pixel , output is delayed by 2 lines 
Implement Basic Debayer filter, As debayer need pixel infrom neighboring pixel which may be on next or previous display line,
so input data is written onto RAM, only 4 lines are stored in RAM at one time and only three of the readable at any give time , RAM to which data is written to can not be read. 
as we have enough info in RAM,4 10bit pixel will be coverted to 4x24bit RGB output
First line is expected to RGRG , second line GBGB
*/

module debayer_filter(clk_i,
					  reset_i,
					  line_valid_i,
					  data_i,
					  data_valid_i,
					  output_valid_o,
					  output_o,
					  debug_out);
					  
localparam INPUT_WIDTH = 40;	//4 x 10bit pixels from raw10 depacker module 
localparam OUTPUT_WIDTH = 120;  //4 x 30bit RGB output 

input clk_i;
input reset_i;
input line_valid_i;
input data_valid_i;
input [(INPUT_WIDTH -1):0] data_i;
output reg output_valid_o;
output reg [(OUTPUT_WIDTH-1):0]output_o;

output reg [7:0]debug_out;



reg [11:0]line_counter; //counts lines of the frame , needed determine if have enough data ins line rams to start outputting RGB data
reg data_valid_reg;

reg [9:0]R1[3:0];
reg [9:0]R2[3:0];
reg [9:0]R3[3:0];
reg [9:0]R4[3:0];

reg [9:0]B1[3:0];
reg [9:0]B2[3:0];
reg [9:0]B3[3:0];
reg [9:0]B4[3:0];

reg [9:0]G1[3:0];
reg [9:0]G2[3:0];
reg [9:0]G3[3:0];
reg [9:0]G4[3:0];

reg [1:0]read_ram_index; 	//which line RAM is being focused to read, not which address is being read from line RAM
reg [3:0]write_ram_select;	//which line RAM is being written
reg [9:0]line_address; 		//which address is being read and written 
reg [(INPUT_WIDTH-1):0]last_ram_outputs[3:0]; //one clock cycle delayed output of line RAMs
reg [(INPUT_WIDTH-1):0]last_ram_outputs_stage2[3:0]; //two clock cycle delayed output of RAMs 

reg [1:0]not_used2b;


wire [(INPUT_WIDTH-1):0]RAM_out[3:0];
wire ram_write_enable;
wire ram_clk;

assign ram_clk = !clk_i; 
assign ram_write_enable = data_valid_i;


//line rams, total 4,
//The way debayer is implemented in this code. Depending on pixel, we need minimum 2 lines and  maximum 3 lines in the ram, To be able to have access to neighboring pixels from previous and next line
//There are many ways to implemented debayer, this code implement simplest possible bare minimum.
// IMX219 Camera only output BGGR as defined by the IMX219 Driver in linux repo MEDIA_BUS_FMT_SBGGR10_1X10,  Camera datasheet incrorrectly defines output as RGGB and GBRG. Data sheet is incorrect in this case.
// Bayer filter type does not affet test pattern. 

line_ram_dp line0(	.WrAddress(line_address), 
					.RdAddress(line_address), 
					.Data(data_i), 
					.WE((|(write_ram_select & 4'b001)) && ram_write_enable), 
					.RdClock(ram_clk),
					.RdClockEn(1'b1),
					.Reset(reset_i),
					.WrClock(ram_clk),
					.WrClockEn(1'b1), 
					.Q(RAM_out[0]));

line_ram_dp line1(	.WrAddress(line_address), 
					.RdAddress(line_address), 
					.Data(data_i), 
					.WE((|(write_ram_select & 4'b0010)) && ram_write_enable), 
					.RdClock(ram_clk),
					.RdClockEn(1'b1),
					.Reset(reset_i),
					.WrClock(ram_clk),
					.WrClockEn(1'b1), 
					.Q(RAM_out[1]));
					
line_ram_dp line2(	.WrAddress(line_address), 
					.RdAddress(line_address), 
					.Data(data_i), 
					.WE((|(write_ram_select & 4'b0100)) && ram_write_enable), 
					.RdClock(ram_clk),
					.RdClockEn(1'b1),
					.Reset(reset_i),
					.WrClock(ram_clk),
					.WrClockEn(1'b1), 
					.Q(RAM_out[2]));

line_ram_dp line3(	.WrAddress(line_address), 
					.RdAddress(line_address), 
					.Data(data_i), 
					.WE((|(write_ram_select & 4'b1000)) && ram_write_enable), 
					.RdClock(ram_clk),
					.RdClockEn(1'b1),
					.Reset(reset_i),
					.WrClock(ram_clk),
					.WrClockEn(1'b1), 
					.Q(RAM_out[3]));


always @(posedge clk_i)	 //address should increment at falling edge of ram_clk. It is inverted from clk_i
begin
	if (reset_i)
	begin
		line_address <= 9'h0;
	end
	else
	begin
		if (!line_valid_i)
		begin
			line_address <= 9'h0;
		end
		else if (data_valid_i)
		begin
			line_address <= line_address + 1'b1;
		end
	end
end


always @(posedge reset_i or posedge line_valid_i)
begin
	if (reset_i)
	begin
		write_ram_select <= 4'b1000;
		line_counter <= 12'b0;
		read_ram_index <= 2'b01;
	end
	else
	begin
		write_ram_select <= {write_ram_select[2:0], write_ram_select[3]};
		read_ram_index <= read_ram_index + 1'b1;
		line_counter <= line_counter + 1'b1;
	end
end


always @(posedge clk_i)
begin
	if (reset_i)
	begin
		output_valid_o <= 1'b0;
		data_valid_reg <= 1'b0;
	end
	else
	begin
		last_ram_outputs[0] <= RAM_out[0];
		last_ram_outputs[1] <= RAM_out[1];
		last_ram_outputs[2] <= RAM_out[2];
		last_ram_outputs[3] <= RAM_out[3];
		
		last_ram_outputs_stage2[0] <= last_ram_outputs[0];
		last_ram_outputs_stage2[1] <= last_ram_outputs[1];
		last_ram_outputs_stage2[2] <= last_ram_outputs[2];
		last_ram_outputs_stage2[3] <= last_ram_outputs[3];
		
		
		if(line_counter > 9'd2)
		begin
			data_valid_reg <= data_valid_i; 
			output_valid_o <= data_valid_reg;
			if (!line_counter[0])	//even
			begin
				B1[0] =  last_ram_outputs[ read_ram_index + 1'd1 ][39:30]; 
				B2[0] =  last_ram_outputs[ read_ram_index + 1'd1 ][39:30];
				B3[0] =  last_ram_outputs[ read_ram_index - 1'd1 ][39:30]; 
				B4[0] =  last_ram_outputs[ read_ram_index - 1'd1 ][39:30];
									
				G1[0] = 		last_ram_outputs[ read_ram_index ][39:30];	
				G2[0] = 		last_ram_outputs[ read_ram_index ][39:30];
				G3[0] = 		last_ram_outputs[ read_ram_index ][39:30];
				G4[0] = 		last_ram_outputs[ read_ram_index ][39:30];
				
				R1[0] = 		last_ram_outputs[ read_ram_index ][29:20]; 
				R2[0] =  last_ram_outputs_stage2[ read_ram_index ][ 9:0 ];
				R3[0] = 		last_ram_outputs[ read_ram_index ][29:20]; 
				R4[0] =  last_ram_outputs_stage2[ read_ram_index ][ 9:0 ];

				B1[1] = last_ram_outputs[ read_ram_index - 1'd1 ][39:30]; 
				B2[1] = last_ram_outputs[ read_ram_index + 1'd1 ][39:30];
				B3[1] = last_ram_outputs[ read_ram_index - 1'd1 ][19:10];
				B4[1] = last_ram_outputs[ read_ram_index + 1'd1 ][19:10];
				
				G1[1] = last_ram_outputs[ read_ram_index		][39:30];	
				G2[1] = last_ram_outputs[ read_ram_index - 1'h1 ][29:20];	
				G3[1] = last_ram_outputs[ read_ram_index + 1'h1 ][29:20];	
				G4[1] = last_ram_outputs[ read_ram_index		][19:10];	
				
				R1[1] = last_ram_outputs[ read_ram_index 		][29:20]; 
				R2[1] = last_ram_outputs[ read_ram_index 		][29:20]; 
				R3[1] = last_ram_outputs[ read_ram_index 		][29:20]; 
				R4[1] = last_ram_outputs[ read_ram_index 		][29:20]; 

				B1[2] = last_ram_outputs[ read_ram_index - 1'd1 ][19:10]; 
				B2[2] = last_ram_outputs[ read_ram_index + 1'd1 ][19:10];
				B3[2] = last_ram_outputs[ read_ram_index - 1'd1 ][19:10]; 
				B4[2] = last_ram_outputs[ read_ram_index + 1'd1 ][19:10];

				G1[2] = last_ram_outputs[ read_ram_index		][19:10];
				G2[2] = last_ram_outputs[ read_ram_index		][19:10];
				G3[2] = last_ram_outputs[ read_ram_index		][19:10];
				G4[2] = last_ram_outputs[ read_ram_index		][19:10];
				
				R1[2] = last_ram_outputs[ read_ram_index 		][ 9:0 ];
				R2[2] = last_ram_outputs[ read_ram_index 		][29:20];
				R3[2] = last_ram_outputs[ read_ram_index 		][ 9:0 ];
				R4[2] = last_ram_outputs[ read_ram_index 		][29:20];
				
				B1[3] = 		 RAM_out[ read_ram_index - 1'd1 ][39:30];	
				B2[3] = last_ram_outputs[ read_ram_index - 1'd1 ][19:10];
				B3[3] = 		 RAM_out[ read_ram_index + 1'd1 ][39:30];
				B4[3] = last_ram_outputs[ read_ram_index + 1'd1	][19:10];
				
				
				G1[3] = last_ram_outputs[ read_ram_index		][19:10];  	
				G2[3] = last_ram_outputs[ read_ram_index - 1'h1	][ 9:0 ];	
				G3[3] = last_ram_outputs[ read_ram_index + 1'h1 ][ 9:0 ];	
				G4[3] = 		 RAM_out[ read_ram_index 		][39:30];
				
				R1[3] = last_ram_outputs[ read_ram_index		][ 9:0 ];
				R2[3] = last_ram_outputs[ read_ram_index		][ 9:0 ];
				R3[3] = last_ram_outputs[ read_ram_index		][ 9:0 ];
				R4[3] = last_ram_outputs[ read_ram_index		][ 9:0 ];
					
			end 	//end even rows
			else
			begin	//odd rows  //First line 
				
				B1[0] = 		last_ram_outputs[ read_ram_index 		][39:30];
				B2[0] = 		last_ram_outputs[ read_ram_index 		][39:30];
				B3[0] = 		last_ram_outputs[ read_ram_index 		][39:30];
				B4[0] = 		last_ram_outputs[ read_ram_index 		][39:30];

				G1[0] = 		last_ram_outputs[ read_ram_index - 1'd1	][39:30];	
				G2[0] = 		last_ram_outputs[ read_ram_index + 1'd1 ][39:30];
				G3[0] = 		last_ram_outputs[ read_ram_index    	][29:20];
				G4[0] =  last_ram_outputs_stage2[ read_ram_index 		][ 9:0 ];
								
				R1[0] =  last_ram_outputs_stage2[ read_ram_index - 1'd1 ][ 9:0 ];
				R2[0] = 		last_ram_outputs[ read_ram_index - 1'd1 ][29:20];
				R3[0] =  last_ram_outputs_stage2[ read_ram_index + 1'd1 ][ 9:0 ];
				R4[0] = 		last_ram_outputs[ read_ram_index + 1'd1 ][29:20];

				
				B1[1] = last_ram_outputs[ read_ram_index 		][39:30]; 
				B2[1] = last_ram_outputs[ read_ram_index 		][19:10];
				B3[1] = last_ram_outputs[ read_ram_index 		][39:30]; 
				B4[1] = last_ram_outputs[ read_ram_index 		][19:10];
				
				G1[1] = last_ram_outputs[ read_ram_index 		][29:20];
				G2[1] = last_ram_outputs[ read_ram_index 		][29:20];	
				G3[1] = last_ram_outputs[ read_ram_index 		][29:20];
				G4[1] = last_ram_outputs[ read_ram_index 		][29:20];
				
				R1[1] = last_ram_outputs[ read_ram_index - 1'd1 ][29:20]; 
				R2[1] = last_ram_outputs[ read_ram_index + 1'd1 ][29:20]; 
				R3[1] = last_ram_outputs[ read_ram_index - 1'd1 ][29:20]; 
				R4[1] = last_ram_outputs[ read_ram_index + 1'd1 ][29:20]; 

				B1[2] = last_ram_outputs[ read_ram_index 		][19:10]; 
				B2[2] = last_ram_outputs[ read_ram_index 		][19:10];
				B3[2] = last_ram_outputs[ read_ram_index 		][19:10];
				B4[2] = last_ram_outputs[ read_ram_index 		][19:10];
				
				G1[2] = last_ram_outputs[ read_ram_index - 1'd1 ][19:10];
				G2[2] = last_ram_outputs[ read_ram_index + 1'd1 ][19:10];
				G3[2] = last_ram_outputs[ read_ram_index 		][29:20];
				G4[2] = last_ram_outputs[ read_ram_index 		][ 9:0 ];
				
				R1[2] = last_ram_outputs[ read_ram_index - 1'd1 ][ 9:0 ];
				R2[2] = last_ram_outputs[ read_ram_index - 1'd1 ][29:20];
				R3[2] = last_ram_outputs[ read_ram_index + 1'd1 ][ 9:0 ];
				R4[2] = last_ram_outputs[ read_ram_index + 1'd1 ][29:20];

				B1[3] = 		 RAM_out[ read_ram_index 		][39:30];
				B2[3] = last_ram_outputs[ read_ram_index 		][19:10];
				B3[3] = 		 RAM_out[ read_ram_index 		][39:30];
				B4[3] = last_ram_outputs[ read_ram_index 		][19:10];
				
				G1[3] = last_ram_outputs[ read_ram_index 		][ 9:0 ]; 
				G2[3] = last_ram_outputs[ read_ram_index 		][ 9:0 ];	
				G3[3] = last_ram_outputs[ read_ram_index 		][ 9:0 ];	
				G4[3] = 		 RAM_out[ read_ram_index 		][ 9:0 ];
				
				R1[3] = last_ram_outputs[ read_ram_index - 1'd1 ][ 9:0 ];
				R2[3] = last_ram_outputs[ read_ram_index + 1'd1 ][ 9:0 ];
				R3[3] = last_ram_outputs[ read_ram_index - 1'd1 ][ 9:0 ]; 
				R4[3] = last_ram_outputs[ read_ram_index + 1'd1 ][ 9:0 ]; 

			end
			
			//debug_out <= R1[0][9:2] & R2[0][9:2] & R3[0][9:2] & R4[0][9:2];
			debug_out <= {{2'd0, R1[1]} + R2[1] + R3[1] + R4[1]} >> 4;
			
			{not_used2b,output_o[119:110]} <= {{2'd0, R1[0]} + R2[0] + R3[0] + R4[0]} >> 2; //R
			{not_used2b,output_o[109:100]} <= {{2'd0, G1[0]} + G2[0] + G3[0] + G4[0]} >> 2; //G
			{not_used2b,output_o[99:90]}   <= {{2'd0, B1[0]} + B2[0] + B3[0] + B4[0]} >> 2; //B

			{not_used2b,output_o[89:80]} <= {{2'd0, R1[1]} + R2[1] + R3[1] + R4[1]} >> 2; //R
			{not_used2b,output_o[79:70]} <= {{2'd0, G1[1]} + G2[1] + G3[1] + G4[1]} >> 2; //G
			{not_used2b,output_o[69:60]} <= {{2'd0, B1[1]} + B2[1] + B3[1] + B4[1]} >> 2; //B
			
			{not_used2b,output_o[59:50]} <= {{2'd0, R1[2]} + R2[2] + R3[2] + R4[2]} >> 2; //R
			{not_used2b,output_o[49:40]} <= {{2'd0, G1[2]} + G2[2] + G3[2] + G4[2]} >> 2; //G
			{not_used2b,output_o[39:30]} <= {{2'd0, B1[2]} + B2[2] + B3[2] + B4[2]} >> 2; //B
			
			{not_used2b,output_o[29:20]} <= {{2'd0, R1[3]} + R2[3] + R3[3] + R4[3]} >> 2; //R
			{not_used2b,output_o[19:10]} <= {{2'd0, G1[3]} + G2[3] + G3[3] + G4[3]} >> 2; //G
			{not_used2b,output_o[9:0]}   <= {{2'd0, B1[3]} + B2[3] + B3[3] + B4[3]} >> 2; //B	
			
			
		end
	end
end




endmodule
