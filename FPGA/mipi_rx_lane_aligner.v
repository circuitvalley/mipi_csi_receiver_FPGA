`timescale 1ns/1ns

/*
MIPI CSI RX to Parallel Bridge (c) by Gaurav Singh www.CircuitValley.com

MIPI CSI RX to Parallel Bridge is licensed under a
Creative Commons Attribution 3.0 Unported License.

You should have received a copy of the license along with this
work.  If not, see <http://creativecommons.org/licenses/by/3.0/>.
*/

/*
Receives multiple lane, byte aligned data from mipi rx byte aligner @mipi byte clock  outputs lane aligned data 
in a multi-lane mipi bus, data on different lane may appear at different offset so this module will wait till of the all lanes have valid output 
start outputting lane aligned data so byte x from all the lanes outputted at same timescale

V1.1 Sep 2020 Heavy Timing optimizations 
*/

module mipi_rx_lane_aligner	(	clk_i,
							reset_i,
							bytes_valid_i,
							byte_i,
							lane_valid_o,
							lane_byte_o);

input reset_i;
		
localparam [3:0]ALIGN_DEPTH = 4'h7; //how many byte misalignment is allowed, whole package length must be also longer than this 
localparam [2:0]LANES = 3'h4;		//mipi csi have 2 or 4 lanes 


input clk_i;
input [(LANES-1):0]bytes_valid_i;
input [((8*LANES)-1):0]byte_i;
output reg [((8*LANES)-1):0]lane_byte_o;
output reg lane_valid_o;


reg [(8*LANES)-1:0]last_bytes[(ALIGN_DEPTH-1):0];
reg [2:0]sync_byte_index[(LANES-1):0];
reg [2:0]sync_byte_index_reg[(LANES-1):0];
reg [2:0]offset;

reg [3:0]valid;
reg lane_valid_reg;
reg [3:0]i;

// TODO: Find why async reset with !(|bytes_valid_i) cause whole system reset;

always @(posedge clk_i)
begin
lane_byte_o = {last_bytes[sync_byte_index_reg[3]][31:24],
						last_bytes[sync_byte_index_reg[2]][23:16],
						last_bytes[sync_byte_index_reg[1]][15:8],
						last_bytes[sync_byte_index_reg[0]][7:0]};
end 
always @(posedge clk_i) 
begin
	if (reset_i )
	begin
		for (i= 4'h0; i < ALIGN_DEPTH; i = i + 1'h1)
		begin
			last_bytes[i] <= 8'h0;
		end
	end
	else
	begin
				
		last_bytes[0] <= byte_i;
		
		for (i= 1'b1; i < (ALIGN_DEPTH); i = i + 1'h1)
		begin
			last_bytes[i] <= last_bytes[i-1'h1];
		end

	end
end


always @(posedge clk_i)
begin
	if (reset_i )
	begin
		valid <= 4'b0;
	end
	else
	begin
		valid <= bytes_valid_i;
	end
end

always @(posedge clk_i ) 
begin
	if (reset_i || (!lane_valid_o && (!(|valid)))) //always reset when lane_valid_o is active, valid
	begin		
		for (i= 4'h0; i <LANES; i = i + 1'h1)
		begin
			sync_byte_index[i] <= ALIGN_DEPTH - 1'b1;
		end
		offset <=  ALIGN_DEPTH - 2'h2;
	end
	else
	begin
		offset <= offset - 1'b1;
		for (i= 4'h0; i < LANES; i = i + 1'h1)			
		begin	
			sync_byte_index[i] <= sync_byte_index[i] - !valid[i]; //count delay of each sync, first one will be 0 delay, last one will max
		end	
	end
end


always @(posedge clk_i)
begin
	if (reset_i)
	begin
		for (i= 4'h0; i < LANES; i = i + 1'h1)			
		begin	
			sync_byte_index_reg[i] <= 3'h0;
		end	
		lane_valid_o <= 1'h0;
	end
	else
	begin
		lane_valid_reg <=( &valid)? 1'h1:(lane_valid_o && |valid)? 1'h1 : 1'h0; //one clock delay to the last packet
		lane_valid_o <= lane_valid_reg;
		if (!lane_valid_reg)
		begin
			for (i= 4'h0; i < LANES; i = i + 1'h1)			
			begin	
				sync_byte_index_reg[i] <= sync_byte_index[i] - offset;
			end	
		end
	end
end

endmodule
