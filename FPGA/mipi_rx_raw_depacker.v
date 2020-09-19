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

module mipi_rx_raw_depacker(	clk_i,
								data_valid_i,
								data_i,
								packet_type_i,
								output_valid_o,
								output_o);

localparam [2:0]TRANSFERS_PERCHUNK= 3'h5; // RAW 10 is packed <Sample0[9:2]> <Sample1[9:2]> <Sample2[9:2]> <Sample3[9:2]> <Sample0[1:0],Sample1[1:0],Sample2[1:0],Sample3[1:0]>
localparam [7:0]MIPI_CSI_PACKET_10bRAW = 8'h2B;
localparam [7:0]MIPI_CSI_PACKET_12bRAW = 8'h2C;
localparam [7:0]MIPI_CSI_PACKET_14bRAW = 8'h2D;

input clk_i;
input data_valid_i;
input [31:0]data_i;
input [2:0]packet_type_i;

output reg output_valid_o;
output reg [63:0]output_o; 

reg [7:0]offset;

reg [7:0]offset_7;
reg [7:0]offset_15;
reg [7:0]offset_23;
reg [7:0]offset_31;
reg [7:0]offset_37;
reg [7:0]offset_43;
reg [7:0]offset_49;
reg [7:0]offset_55;
reg [7:0]offset_71;
reg [7:0]offset_79;
reg [7:0]offset_83;
reg [7:0]offset_87;
reg [7:0]offset_95;
reg [7:0]offset_97;
reg [7:0]offset_99;
reg [7:0]offset_101;
reg [7:0]offset_103;
reg [7:0]offset_107;
reg [7:0]offset_111;
			
			
reg [2:0]byte_count;
reg [31:0]last_data_i[3:0];
reg [1:0]idle_count;

reg data_valid_reg;
reg [31:0]data_reg;
reg [7:0]offset_factor_reg;
reg [2:0]burst_length_reg;
reg [1:0]idle_length_reg;
reg [2:0]packet_type_reg;

wire [7:0]offset_factor;
wire [2:0]burst_length;
wire [1:0]idle_length;
wire [127:0]word;

reg [63:0]output_10b;
reg [63:0]output_12b;
reg [63:0]output_14b;
reg output_valid_reg;
reg output_valid_reg_2;

assign word = {last_data_i[0], last_data_i[1], last_data_i[2],last_data_i[3]}; //would need last bytes as well as current data to get full 4 pixel

assign offset_factor = (packet_type_i == (MIPI_CSI_PACKET_10bRAW & 8'h07))? 8'd8: (packet_type_i == (MIPI_CSI_PACKET_12bRAW & 8'h07))? 8'd16:8'd24;
					   
assign burst_length =  ((packet_type_i == (MIPI_CSI_PACKET_10bRAW & 8'h07)) || (packet_type_i == (MIPI_CSI_PACKET_14bRAW & 8'h07)))? 8'd5:8'd3;		   
						
assign idle_length =  ((packet_type_i == (MIPI_CSI_PACKET_10bRAW & 8'h07)) || (packet_type_i == (MIPI_CSI_PACKET_12bRAW & 8'h07)))? 2'd1: 2'd3;

reg [15:0]pixel_counter_depacker;

always @(posedge clk_i)
begin
	output_10b[63:48] <= 	{word [(offset_71) -:8], 	word [(offset_97) -:2]} << 6; 		//lane 1 	TODO:Reverify 
	output_10b[47:32] <= 	{word [(offset_79) -:8], 	word [(offset_99) -:2]} << 6;		
	output_10b[31:16] <= 	{word [(offset_87) -:8], 	word [(offset_101) -:2]} << 6;
	output_10b[15:0]  <= 	{word [(offset_95) -:8], 	word [(offset_103) -:2]} << 6;		//lane 4
	output_12b[63:48] <= 	{word [(offset_71) -:8], 	word [(offset_83) -:4]} << 4; 		//lane 1
	output_12b[47:32] <= 	{word [(offset_79) -:8], 	word [(offset_87) -:4]} << 4;
	output_12b[31:16] <= 	{word [(offset_95) -:8], 	word [(offset_107) -:4]} << 4;
	output_12b[15:0]  <= 	{word [(offset_103) -:8], 	word [(offset_111) -:4]} << 4;		//lane 4
	output_14b[63:48] <= 	{word [offset_7 -:8], 	word [(offset_37) -:6]} << 2; 		//lane 1
	output_14b[47:32] <= 	{word [offset_15 -:8], 	word [(offset_43) -:6]} << 2;
	output_14b[31:16] <= 	{word [offset_23 -:8], 	word [(offset_49) -:6]} << 2;
	output_14b[15:0]  <= 	{word [offset_31 -:8], 	word [(offset_55) -:6]} << 2;		//lane 4
	
	if (packet_type_reg == (MIPI_CSI_PACKET_10bRAW & 8'h07))
	begin
		output_o <= output_10b;
	end
	else if (packet_type_reg == (MIPI_CSI_PACKET_12bRAW & 8'h07))
	begin		
		output_o <= output_12b;
	end
	else // if (packet_type_i == (MIPI_CSI_PACKET_14bRAW & 8'h07))
	begin
		output_o <= output_14b;
	end
	
end


always @(posedge clk_i)
begin
	
		output_valid_reg_2 <= output_valid_reg;
		output_valid_o <= output_valid_reg_2;
		
		if (output_valid_reg)
		begin
			
			offset_7  <= offset_7 + offset_factor_reg;
			offset_15 <= offset_15 + offset_factor_reg;
			offset_23 <= offset_23 + offset_factor_reg;
			offset_31 <= offset_31 + offset_factor_reg;
			offset_37 <= offset_37 + offset_factor_reg;
			offset_43 <= offset_43 + offset_factor_reg;
			offset_49 <= offset_49 + offset_factor_reg;
			offset_55 <= offset_55 + offset_factor_reg;
			offset_71 <= offset_71 + offset_factor_reg;
			offset_79 <= offset_79 + offset_factor_reg;
			offset_83 <= offset_83 + offset_factor_reg;
			offset_87 <= offset_87 + offset_factor_reg;
			offset_95 <= offset_95 + offset_factor_reg;
			offset_97 <= offset_97 + offset_factor_reg;
			offset_99 <= offset_99 + offset_factor_reg;
			offset_101 <= offset_101 + offset_factor_reg;
			offset_103 <= offset_103 + offset_factor_reg;
			offset_107 <= offset_107 + offset_factor_reg;
			offset_111 <= offset_111 + offset_factor_reg;
			
		end
		else
		begin
			offset_7  <= 8'd7;
			offset_15 <= 8'd15;
			offset_23 <= 8'd23;
			offset_31 <= 8'd31;
			offset_37 <= 8'd37;
			offset_43 <= 8'd43;
			offset_49 <= 8'd49;
			offset_55 <= 8'd55;
			offset_71 <= 8'd71;
			offset_79 <= 8'd79;
			offset_83 <= 8'd83;
			offset_87 <= 8'd87;
			offset_95 <= 8'd97;
			offset_97 <= 8'd97;
			offset_99 <= 8'd99;
			offset_101 <= 8'd101;
			offset_103 <= 8'd103;
			offset_107 <= 8'd107;
			offset_111 <= 8'd111;
		end
end

always @(posedge clk_i )//or negedge data_valid_reg)
begin
	
	if (data_valid_reg)
	begin

		
		last_data_i[0] <= data_reg;
		last_data_i[1] <= last_data_i[0];
		last_data_i[2] <= last_data_i[1];
		last_data_i[3] <= last_data_i[2];
		pixel_counter_depacker <= pixel_counter_depacker + 1'b1;
		//RAW 10 , Byte1 -> Byte2 -> Byte3 -> Byte4 -> [ LSbB1[1:0] LSbB2[1:0] LSbB3[1:0] LSbB4[1:0] ]
		

		if (byte_count < (burst_length_reg))
		begin
			byte_count <= byte_count + 1'd1;
			idle_count <= idle_length_reg - 1'b1;			
			
			output_valid_reg <= 1'b1;
			
		end
		else
		begin
			idle_count <= idle_count - 1'b1;
			if (!idle_count)
			begin
				byte_count <= 4'b1;		//set to 1 to enable output_valid_o with next edge
			end

			output_valid_reg <= 1'h0;
		end


	end
	else
	begin
		pixel_counter_depacker <= 0; 
		last_data_i[0] <= 32'h0;
		last_data_i[1] <= 32'h0;
		last_data_i[2] <= 32'h0;
		last_data_i[3] <= 32'h0;

		
		byte_count <= burst_length;

		if (packet_type_i == (MIPI_CSI_PACKET_14bRAW & 8'h07))		// for 14bit need to wait for 3 sample while 12bit and 10bit only need 1 sample delay
		begin
			idle_count <= 3'd2;
		end
		else
		begin 
			idle_count <= 3'b0;	//need to be zero to wait for 1 sample after data become valid	
		end
		
		output_valid_reg <= 1'h0;
		offset_factor_reg <= offset_factor;
		burst_length_reg <= burst_length;
		idle_length_reg <= idle_length;
		packet_type_reg <= packet_type_i;
	end
end

always @(posedge clk_i)
begin
		data_valid_reg <= data_valid_i;
		data_reg <= data_i;

end
endmodule
