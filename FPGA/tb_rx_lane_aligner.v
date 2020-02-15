`timescale 1ns/1ns

module tb_rx_lane_aligner;
	reg clk;
	reg [3:0]bytes_valid;
	reg  [31:0]bytes_i;
	wire [31:0]bytes_o;
	wire synced;
	reg reset;
	
wire reset_g;
GSR GSR_INST (.GSR (reset_g));
PUR PUR_INST (.PUR (reset_g)); 

rx_lane_aligner ins1(	.clk_i(clk),
						.reset_i(reset),
						.bytes_valid_i(bytes_valid),
						.byte_i(bytes_i),
						.lane_valid_o(synced),
						.lane_byte_o(bytes_o));

task sendbytes;
	input [31:0]bytes;
	begin
	bytes_i = bytes;
	clk = 1'b0;
	#4
	clk = 1'b1;
	#4;
	end
endtask

initial begin
		clk = 1'b0;
		bytes_valid = 4'h0;
		#50

		sendbytes(32'h00000000);
		reset = 1'h1;
		sendbytes(32'h00000000);
		reset = 1'h0;
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		bytes_valid[1] = 1'h1;
		sendbytes(32'h0000B800);
		sendbytes(32'h00001100);
		sendbytes(32'h00002200);
		sendbytes(32'h00003300);
		bytes_valid[2] = 1'h1;
		bytes_valid[3] = 1'h1;
		sendbytes(32'hB8B84400);
		bytes_valid[0] = 1'h1;
		sendbytes(32'h111155B8);
		sendbytes(32'h22226611);
		sendbytes(32'h33337722);
		sendbytes(32'h44448833);
		bytes_valid[1] = 1'h0;
		sendbytes(32'h55556644);
		sendbytes(32'h66667755);
		sendbytes(32'h77778866);

		sendbytes(32'h88889977);
		bytes_valid[2] = 1'h0;
		bytes_valid[3] = 1'h0;
		
		sendbytes(32'h9999AA88);
		bytes_valid[0] = 1'h0;
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		bytes_valid[1] = 1'h1;
		sendbytes(32'h0000B800);
		sendbytes(32'h00001100);
		bytes_valid[2] = 1'h1;
		bytes_valid[3] = 1'h1;
		sendbytes(32'hB8B82200);
		bytes_valid[0] = 1'h1;
		sendbytes(32'h111133B8);
		sendbytes(32'h22224411);
		sendbytes(32'h33335522);
		sendbytes(32'h4444663);
		sendbytes(32'h5555774);
		sendbytes(32'h66668855);
		bytes_valid[1] = 1'h0;
		sendbytes(32'h77778866);

		sendbytes(32'h88889977);
		bytes_valid[2] = 1'h0;
		bytes_valid[3] = 1'h0;
		
		sendbytes(32'h9999AA88);
		bytes_valid[0] = 1'h0;
		

end

endmodule
