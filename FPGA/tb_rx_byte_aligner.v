`timescale 1ns/1ns

module tb_rx_byte_aligner;
	
	reg clk;
	reg reset;
	reg  [7:0]byte_i;
	wire [7:0]byte_o;
	wire synced;

wire reset_g;
GSR GSR_INST (.GSR (reset_g));
PUR PUR_INST (.PUR (reset_g)); 


rx_byte_aligner inst1(	.clk_i(clk),
						.reset_i(reset),
						.byte_i(byte_i),
						.byte_o(byte_o),
						.byte_valid_o(synced));
						
task sendbyte;
	input [7:0]byte;
	begin
	byte_i = byte;
	clk = 1'b1;
	#4
	clk = 1'b0;
	#4;
	end
endtask

initial begin
		clk = 1'b1;
		reset = 1'b1;
		#50
		reset = 1'b0;
		sendbyte(8'h00);
		sendbyte(8'h00);
		sendbyte(8'h00);
		sendbyte(8'h00);
		sendbyte(8'h00);
		sendbyte(8'h77);
		sendbyte(8'h25);
		sendbyte(8'h42);
		sendbyte(8'hCE);
		sendbyte(8'h22);
		sendbyte(8'h22);
		sendbyte(8'h22);
		sendbyte(8'h62);
		sendbyte(8'h30);
		sendbyte(8'h22);
		sendbyte(8'h02);
		reset = 1'h1;
		#50
		reset = 1'b0;
		sendbyte(8'h00);
		sendbyte(8'h00);
		sendbyte(8'h00);
		sendbyte(8'h00);
		sendbyte(8'h00);
		sendbyte(8'h70);
		sendbyte(8'h41);
		sendbyte(8'hA0);
		sendbyte(8'h22);
		sendbyte(8'h72);
		sendbyte(8'h22);
		sendbyte(8'h22);
		sendbyte(8'h22);
		sendbyte(8'h3A);
		sendbyte(8'h22);
		sendbyte(8'h22);
		reset = 1'h1;
		
		#50
		reset = 1'b0;
		sendbyte(8'h00);
		sendbyte(8'h00);
		sendbyte(8'h00);
		sendbyte(8'h00);
		sendbyte(8'h00);
		sendbyte(8'h5C);
		sendbyte(8'h95);
		sendbyte(8'h08);
		sendbyte(8'h1F);
		sendbyte(8'h08);
		sendbyte(8'h08);
		sendbyte(8'h88);
		sendbyte(8'h08);
		sendbyte(8'h17);
		sendbyte(8'h08);
		sendbyte(8'h08);
		reset = 1'h1;
		
			#50
		reset = 1'b0;
		sendbyte(8'h00);
		sendbyte(8'h00);
		sendbyte(8'h00);
		sendbyte(8'h00);
		sendbyte(8'h00);
		sendbyte(8'h5C);
		sendbyte(8'h30);
		sendbyte(8'h88);
		sendbyte(8'h08);
		sendbyte(8'hA9);
		sendbyte(8'h88);
		sendbyte(8'h88);
		sendbyte(8'h08);
		sendbyte(8'h17);
		sendbyte(8'h08);
		sendbyte(8'h08);
		reset = 1'h1;
			#50
		reset = 1'b0;
		sendbyte(8'h00);
		sendbyte(8'h00);
		sendbyte(8'h00);
		sendbyte(8'h00);
		sendbyte(8'h00);
		sendbyte(8'hE0); 
		sendbyte(8'h82);
		sendbyte(8'h45);
		sendbyte(8'h40);
		sendbyte(8'hC4);
		sendbyte(8'h45);
		sendbyte(8'h40);
		sendbyte(8'h08);
		sendbyte(8'h17);
		sendbyte(8'h08);
		sendbyte(8'h08);
		reset = 1'h1;	
		
end

endmodule