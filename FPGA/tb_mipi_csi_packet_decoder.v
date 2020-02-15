`timescale 1ns/1ns

module tb_mipi_csi_packet_decoder;
	reg clk;
	reg reset;
	reg input_valid;
	reg  [31:0]bytes_i;
	wire [31:0]bytes_o;
	wire synced;
	wire [31:0]packet_length;
	
wire reset_g;
GSR GSR_INST (.GSR (reset_g));
PUR PUR_INST (.PUR (reset_g)); 

mipi_csi_packet_decoder dec1(.clk_i(clk),
							 .data_valid_i(input_valid),
							 .data_i(bytes_i),
							 .output_valid_o(synced),
							 .data_o(bytes_o),
							 .packet_length(packet_length));

task sendbytes;
	input [31:0]bytes;
	begin
	bytes_i = bytes;
	clk = 1'b1;
	#4
	clk = 1'b0;
	#4;
	end
endtask

task sendpacket;
	reg [31:0]i;
	for ( i= 32'b0; i < 32'h980; i = i + 4)
	begin
		sendbytes(i*10000);
	end
endtask

initial begin
		clk = 1'b0;
		input_valid = 1'h0;
		#50
		reset = 1'b0;
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		input_valid = 1'h1;
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		sendbytes(32'hB8B8B8B8);
		sendbytes(32'hAB09602B);
		sendpacket();
		input_valid = 1'h0;
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		
		reset = 1'b1;
end

endmodule
