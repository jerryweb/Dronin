`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Southern California
// Engineer: Anta Imata Safo
// 
// Design Name:    Predictor-Corrector Implementation
// Module Name:    matrix_construct
//////////////////////////////////////////////////////////////////////////////////

module mn_matrix(reset, clk, write, read, m_dim, n_dim, m_addr, n_addr, transpose, data_in, data_out);

 // inputs
input   reset, clk;
input   write, read;
input   transpose;
input [7:0]     m_dim, n_dim;
input [7:0]     m_addr, n_addr;
input [31:0]    data_in;
 // outputs
output	[31:0]	data_out;

 // regs
reg [31:0]      data_out;
reg [31:0]      matrix [128-1:0][128-1:0];

 // loop integers
integer i, j;

always @(posedge clk, posedge reset) //asynchronous active_high Reset
 begin
    if (reset) 
	 begin
	    for (i = 0; i < 128; i = i + 1)
            for (j = 0; j < 128; j = j + 1)
                matrix[i][j] = 32'd0;
	 end
    else // under positive edge of the clock
     begin
        if (write && m_addr < m_dim && n_addr < n_dim)
            matrix[m_addr][n_addr] <= data_in;
	   else if (read && !transpose && m_addr < m_dim && n_addr < n_dim)
            data_out <= matrix[m_addr][n_addr];
	   else if (read && transpose && m_addr < n_dim && n_addr < m_dim)
            data_out <= matrix[n_addr][m_addr];
     end
 end // end of always procedural block 
endmodule