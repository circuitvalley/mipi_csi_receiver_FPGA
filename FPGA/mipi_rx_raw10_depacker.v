`timescale 1ns/1ns

/*
MIPI CSI RX to Parallel Bridge (c) by Gaurav Singh www.CircuitValley.com

MIPI CSI RX to Parallel Bridge is licensed under a
Creative Commons Attribution 3.0 Unported License.

You should have received a copy of the license along with this
work.  If not, see <http://creativecommons.org/licenses/by/3.0/>.
*/

/*
Receives 4 lane raw mipi bytes from packet decoder, rearrange bytes to output 4 pixel 10bit each 
output is one clock cycle delayed, because the way , MIPI RAW10 is packed 
output come in group of 5x40bit chunk on each clock cycle, output_valid_o remains active only while 20 pixel chunk is outputted 
*/

module mipi_rx_raw10_depacker(	clk_i,
								data_valid_i,
								data_i,
								output_valid_o,
								output_o);

localparam [2:0]BYTES_PERPACK = 3'h5; // RAW 10 is packed <Sample0[9:2]> <Sample1[9:2]> <Sample2[9:2]> <Sample3[9:2]> <Sample0[1:0],Sample1[1:0],Sample2[1:0],Sample3[1:0]>
input clk_i;
input data_valid_i;
input [31:0]data_i;
output reg output_valid_o;
output reg [39:0]output_o; 

reg [7:0]offset;
reg [2:0]byte_count;
reg [31:0]last_data_i;

wire [63:0]word;
assign word = {data_i,last_data_i}; //would need last bytes as well as current data to get full 4 pixel

always @(posedge clk_i)
begin
	
	if (data_valid_i)
	begin
		last_data_i <= data_i;
		//RAW 10 , Byte1 -> Byte2 -> Byte3 -> Byte4 -> [ LSbB1[1:0] LSbB2[1:0] LSbB3[1:0] LSbB4[1:0] ]
		output_o[39:30] <= 	{word [(offset + 7) -:8], 	word [(offset + 39) -:2]}; 		//lane 1
		output_o[29:20] <= 	{word [(offset + 15) -:8], 	word [(offset + 37) -:2]};		
		output_o[19:10] <= 	{word [(offset + 23) -:8], 	word [(offset + 35) -:2]};
		output_o[9:0] 	<= 	{word [(offset + 31) -:8], 	word [(offset  + 33) -:2]};		//lane 4
		
		if (byte_count < (BYTES_PERPACK))
		begin
			byte_count <= byte_count + 1'd1;
			if (byte_count )
			begin
				offset <= ((offset + 8'd8) & 8'h1F);
				output_valid_o <= 1'h1;
			end
		end
		else
		begin
			
			offset <= 8'h0;
			byte_count <= 4'b1;		//this byte is the first byte
			output_valid_o <= 1'h0;
		end
	end
	else
	begin
		output_o <= 40'h0;
		last_data_i <= 1'h0;
		offset <= 8'h0;
		byte_count <= 3'b0;
		output_valid_o <= 1'h0;
	end
end

endmodule