`timescale 1ns/1ns

/*
MIPI CSI RX to Parallel Bridge (c) by Gaurav Singh www.CircuitValley.com

MIPI CSI RX to Parallel Bridge is licensed under a
Creative Commons Attribution 3.0 Unported License.

You should have received a copy of the license along with this
work.  If not, see <http://creativecommons.org/licenses/by/3.0/>.
*/

/*
Received Raw unaligned bits from DDR RX module outputs Aligned bytes
Bytes on MIPI lane does not have any defined byte boundary so this modules Looks for always constant first byte 0xB8 on wire, 
once 0xB8 is found, byte boundary offset is determined, set output valid to active and start outputting correct bytes
stays reset when data lane are in MIPI LP state , modules will omit maximum 2 last bytes because of reset constrains. 

V1.1 Sep 2020, Same functionality but achieve better timings. 
*/


module mipi_rx_byte_aligner(
						clk_i,
						reset_i,
						byte_i,
						byte_o,
						byte_valid_o
						);
						
localparam [7:0]SYNC_BYTE = 8'hB8;		
				
input clk_i;
input reset_i;
input [7:0]byte_i;
output reg [7:0]byte_o;
output reg byte_valid_o;

reg [2:0]offset;
reg [3:0]i;
reg [7:0] last_byte;
wire [16:0]word;

reg [7:0] output_reg;
reg valid_reg;
reg valid_reg_stage2;		//needed to keep byte_valid_o high for one extra clock
assign word = {byte_i, last_byte};


always @(negedge clk_i or posedge reset_i)
begin
	if (reset_i)
	begin
		valid_reg <= 1'b0;
		last_byte <= 8'h0;
		offset <= 3'h0;
		output_reg <= SYNC_BYTE; //first byte output is always sync byte once byte_valid_o is high
	end
	else
	begin
		
		last_byte <= byte_i;

		
		if (!valid_reg) 
		begin
		 for (i= 8'h0; i < 8; i = i + 1'h1) //need to have loop 8 time not 9 because if input bytes are already aligned they will fall on last_byte or byte_i
			begin
				if ((word[(i ) +: 8] == SYNC_BYTE))
					begin
						valid_reg <= 1'b1;
						offset  <= i[2:0];
					end
			end
		end
		else
		begin
			output_reg <= word[offset +:8]; // from offset 8bits upwards
		end
	end
	
end


always @(negedge clk_i )
begin
	if (reset_i)
	begin
		byte_o <= 8'h0;
		byte_valid_o <= 1'b0;
		valid_reg_stage2 <= 1'b0;
	end
	else
	begin
		byte_o <= output_reg;
		valid_reg_stage2 <= valid_reg;
		byte_valid_o <= valid_reg | valid_reg_stage2;
	end
end
endmodule
