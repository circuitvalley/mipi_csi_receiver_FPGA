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
stays reset when data lane are in MIPI LP state  
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

// TODO: Optimize first byte output;

assign word = {byte_i, last_byte};
always @(negedge clk_i)
begin
	if (reset_i)
	begin
		last_byte <= 8'h0;
		byte_valid_o <= 1'b0;
		offset <= 3'h0;
	end
	else
	begin

		last_byte <= byte_i;
		
		if (!byte_valid_o)
		begin
		 for (i= 8'h0; i < 8; i = i + 1'h1)
			begin
				if ( (word[(i + 1'h1 ) +: 8] == SYNC_BYTE))
					begin
						byte_valid_o <= 1'h1;
						offset  <= i[2:0] + 1'b1;
						byte_o <=  SYNC_BYTE; //first byte output if sync found is always going to be the syncbyte itself
					end
			end
		end
		else
		begin
				byte_o <= word[offset +:8]; // from offset 8bits upwards
		end
	end
	
end
						
endmodule
						
						
