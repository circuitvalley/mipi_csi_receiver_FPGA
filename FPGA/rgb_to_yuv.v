`timescale 1ns/1ns

/*
MIPI CSI RX to Parallel Bridge (c) by Gaurav Singh www.CircuitValley.com

MIPI CSI RX to Parallel Bridge is licensed under a
Creative Commons Attribution 3.0 Unported License.

You should have received a copy of the license along with this
work.  If not, see <http://creativecommons.org/licenses/by/3.0/>.
*/

/*
received 4 pixel 120bit RGB from the Debayer filter output 64bit 4pixel yuv422 
Calculation is done based on integer YUV formula from the YUV wiki page 
*/

module rgb_to_yuv(clk_i, //data changes on rising edge , latched in on falling edge
				  reset_i,
				  rgb_i,
				  rgb_valid_i,
				  yuv_o,
				  yuv_valid_o);
				  
localparam PIXEL_DEPTH = 4'd10; //10bit per color				  
localparam PIXEL_PER_CLK = 4'd4;  //4pixels per clock cycle comes , should be even
input clk_i;
input reset_i;
input [((PIXEL_DEPTH * PIXEL_PER_CLK * 3) - 1'd1):0]rgb_i;
input rgb_valid_i;

output reg [((PIXEL_PER_CLK * 2 * 8) - 1'd1):0]yuv_o;
output reg yuv_valid_o;

reg [7:0]Y[3:0]; // result 
reg [7:0]U[3:0];
reg [7:0]V[3:0];


//from YUV wiki page full swing
// Y = ((77 R + 150G + 29B + 128) >>10)
// U = ((-43R - 84G + 127B + 128) >>10) + 128
// V = ((127R -106G -21B +128) >>10) + 128

reg [23:0]not_used24; //to suppress warning from the tool 

always @(negedge  clk_i)
begin
	yuv_valid_o <= rgb_valid_i; 
	
	{not_used24,Y[0]} =  (( 77 * rgb_i[110 +: 10]) + (150 * rgb_i[100 +: 10]) + (29 * rgb_i[90  +: 10]) + 18'd128) >> 10;
	{not_used24,U[0]} = (((127 * rgb_i[90  +: 10]) - (43  * rgb_i[110 +: 10]) - (84 * rgb_i[100 +: 10]) + 18'd128) >> 10 ) + 32'd128;
	{not_used24,V[0]} = (((127 * rgb_i[110 +: 10]) - (106 * rgb_i[100 +: 10]) - (21 * rgb_i[90  +: 10]) + 18'd128) >> 10 ) + 32'd128;
	
	{not_used24,Y[1]} =  (( 77 * rgb_i[80  +: 10]) + (150 * rgb_i[70  +: 10]) + (29 * rgb_i[60  +: 10]) + 18'd128) >> 10;
	//U[1] and V[1]  not need to yuv422 sub sampling
	
	{not_used24,Y[2]} =  (( 77 * rgb_i[50 +: 10]) + (150 * rgb_i[40 +: 10]) + (29 * rgb_i[30 +: 10]) + 18'd128) >> 10;
	{not_used24,U[2]} = (((127 * rgb_i[30 +: 10]) - ( 43 * rgb_i[50 +: 10]) - (84 * rgb_i[40 +: 10]) + 18'd128) >> 10 ) + 32'd128;
	{not_used24,V[2]} = (((127 * rgb_i[50 +: 10]) - (106 * rgb_i[40 +: 10]) - (21 * rgb_i[30 +: 10]) + 18'd128) >> 10 ) + 32'd128;
	
	{not_used24,Y[3]} =  (( 77 * rgb_i[20 +: 10]) + (150 * rgb_i[10 +: 10]) + (29 * rgb_i[0 +: 10])  + 18'd128) >> 10;
	//U[3] and V[3]  not need to yuv422 sub sampling

	yuv_o <= { Y[0], U[0], Y[1], V[0],		Y[2], U[2], Y[3], V[2]};
	
end

endmodule