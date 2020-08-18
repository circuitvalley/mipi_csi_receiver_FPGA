`timescale 1ns/1ns

/*
MIPI CSI RX to Parallel Bridge (c) by Gaurav Singh www.CircuitValley.com

MIPI CSI RX to Parallel Bridge is licensed under a
Creative Commons Attribution 3.0 Unported License.

You should have received a copy of the license along with this
work.  If not, see <http://creativecommons.org/licenses/by/3.0/>.
*/

/*
MIPI CSI 4 Lane Receiver To Parallel Bridge 
Tested with Lattice MachXO3LF-6900 with IMX219 Camera 
Takes MIPI Clock and 4 Data lane as input convert into Parallel YUV output 
Ouputs 32bit YUV data with Frame sync, lsync and pixel clock 
*/

module mipi_bridge(	clk_i,
					reset_in,
					mipi_clk_in,
					mipi_clk_lpp_io,
					mipi_clk_lpn_io,
					mipi_data_in,
					mipi_data_lpp_io,
					mipi_data_lpn_io,

					pclk_out, 
					data_out,
					fsyn_out,
					lsync_out,

					debug_b8
					);
					
parameter MIPI_LANES = 4;
input clk_i;

input reset_in;
input mipi_clk_in;
inout mipi_clk_lpp_io;
inout mipi_clk_lpn_io;
input [MIPI_LANES-1:0]mipi_data_in;
inout [MIPI_LANES-1:0]mipi_data_lpp_io;
inout [MIPI_LANES-1:0]mipi_data_lpn_io;

output pclk_out;
output [31:0]data_out;
output fsyn_out;
output lsync_out;

output wire [7:0]debug_b8;


wire reset ;
wire [MIPI_LANES-1:0]mipi_data_lpp_in;
wire [MIPI_LANES-1:0]mipi_data_lpn_in;


wire output_clock; 
wire mipi_byte_clock; //byte clock from mipi phy

wire mipi_clk_n_lp;
wire mipi_clk_p_lp;

wire [3:0]is_byte_valid;
wire is_lane_aligned_valid;
wire is_decoded_valid;
wire is_unpacked_valid;
wire is_rgb_valid;
wire is_yuv_valid;

wire mipi_out_clk;

wire [31:0]mipi_data_raw;
wire [31:0]byte_aligned;
wire [31:0]lane_aligned;
wire [31:0]decoded_data;
wire [31:0]packet_length;
wire [39:0]unpacked_data;
wire [119:0]rgb_data;
wire [63:0]yuv_data;

wire byte_aligner_reset = mipi_data_lpn_in[0];
assign reset = mipi_clk_n_lp | !reset_in;

mipi_rx_ddr mipi_rx_ddr_inst_0(	.alignwd(1'b0), 
								.buf_clk_lp0i(mipi_clk_n_lp), 
								.buf_clk_lp0o(), 
								.buf_clk_lp0t(1'b1),
								.buf_clk_lp1i(mipi_clk_p_lp), 
								.buf_clk_lp1o(), 
								.buf_clk_lp1t(1'b1), 
								.clk(mipi_clk_in), 
								.clk_lp0(mipi_clk_lpn_io), 
								.clk_lp1(mipi_clk_lpp_io), 
								.clk_s(clk_i), 
								.init(1'b1), 
								.reset(reset), 
								.rx_ready(), 
								.sclk(mipi_byte_clock), 
								.oclk(mipi_out_clk), //double to mipi_clock
								.buf_data_lp0i(mipi_data_lpn_in), 
								.buf_data_lp0o(4'b0),  
								.buf_data_lp0t(4'b1111), 
								.buf_data_lp1i(mipi_data_lpp_in), 
								.buf_data_lp1o(4'b0), 
								.buf_data_lp1t(4'b1111), 
								.data_lp0(mipi_data_lpn_io), 
								.data_lp1(mipi_data_lpp_io), 
								.datain(mipi_data_in), 
								.q(mipi_data_raw));
							  
							  
mipi_rx_byte_aligner mipi_rx_byte_aligner_0(	.clk_i(mipi_byte_clock),
									.reset_i(byte_aligner_reset),
									.byte_i(mipi_data_raw[7:0]),
									.byte_o( byte_aligned[7:0]),
									.byte_valid_o(is_byte_valid[0]));
					  
					  
mipi_rx_byte_aligner mipi_rx_byte_aligner_1(	.clk_i(mipi_byte_clock),
									.reset_i(byte_aligner_reset),
									.byte_i(mipi_data_raw[15:8]),
									.byte_o(byte_aligned[15:8]),
									.byte_valid_o(is_byte_valid[1]));
					  

mipi_rx_byte_aligner mipi_rx_byte_aligner_2(	.clk_i(mipi_byte_clock),
									.reset_i(byte_aligner_reset),
									.byte_i(mipi_data_raw[23:16]),
									.byte_o( byte_aligned[23:16]),
									.byte_valid_o(is_byte_valid[2]));
					  
mipi_rx_byte_aligner mipi_rx_byte_aligner_3(	.clk_i(mipi_byte_clock),
									.reset_i(byte_aligner_reset),
									.byte_i(mipi_data_raw[31:24]),
									.byte_o( byte_aligned[31:24]),
									.byte_valid_o(is_byte_valid[3]));

mipi_rx_lane_aligner mipi_rx_lane_aligner(	.clk_i(mipi_byte_clock),
									.reset_i(reset),
									.bytes_valid_i(is_byte_valid),
									.byte_i(byte_aligned),
									.lane_valid_o(is_lane_aligned_valid),
									.lane_byte_o(lane_aligned));


mipi_csi_packet_decoder mipi_csi_packet_decoder_0(	.clk_i(mipi_byte_clock),
													.data_valid_i(is_lane_aligned_valid),
													.data_i(lane_aligned),
													.output_valid_o(is_decoded_valid),
													.data_o(decoded_data),
													.packet_length(packet_length));


mipi_rx_raw10_depacker mipi_rx_raw10_depacker_0(.clk_i(mipi_byte_clock),
												.data_valid_i(is_decoded_valid),
												.data_i(decoded_data),
												.output_o(unpacked_data),
												.output_valid_o(is_unpacked_valid));


debayer_filter debayer_filter_0(.clk_i(mipi_byte_clock),
								.reset_i(reset),
								.line_valid_i(is_decoded_valid),
								.data_i(unpacked_data),
								.data_valid_i(is_unpacked_valid),
								.output_o(rgb_data),
								.output_valid_o(is_rgb_valid),
								.debug_out(debug_b8));

rgb_to_yuv rgb_to_yuv_0(.clk_i(mipi_byte_clock),
					    .reset_i(reset),
					    .rgb_i(rgb_data),
					    .rgb_valid_i(is_rgb_valid),
					    .yuv_o(yuv_data),
					    .yuv_valid_o(is_yuv_valid));


output_reformatter out_reformatter_0(.clk_i(mipi_byte_clock),
									 .output_clk_i(mipi_out_clk),
									 .data_i(yuv_data),
									 .data_in_valid_i(is_yuv_valid),
									 .output_o(data_out),
									 .output_valid_o(lsync_out));



assign pclk_out = reset? clk_i: mipi_out_clk ; //output clock always available, slow when there is no mipi frame , fast from mipi_clk when mipi_clock is active
assign fsyn_out = !reset;					  //activate fsync as soon as mipi frame is active

endmodule
