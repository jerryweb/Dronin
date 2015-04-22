`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Southern California
// Engineer: Anta Imata Safo
// 
// Design Name:    Predictor-Corrector Implementation
// Module Name:    matrix_add
//////////////////////////////////////////////////////////////////////////////////

`include "../matrix_construct/matrix_io.sv"

module mn_add(reset, clk, start, m1_dim, n1_dim, matrix1_in, m2_dim, n2_dim, matrix2_in, matrix_out);

 // inputs
input       reset, clk;
input       start;
input [7:0] m1_dim, n1_dim;
input [7:0] m2_dim, n2_dim;
input [128*128*3-1:0]   matrix1_in, matrix2_in;

 // outputs
output	[128*128*3-1:0] matrix_out;

 // regs
reg [1:0]               state;
reg [128*128*32-1:0]    matrix_out;

 // loop integers
integer i, j, k;

 //state machine states
localparam
 IDLE       = 2'b01,
 COMPUTE    = 2'b10,
 UNKN       = 2'bxx;
 
 // matrix instantiation
reg     write1, write2;
reg     read1, read2;
reg     transpose1, transpose2;

reg [7:0] m1_dim, n1_dim;
reg [7:0] m2_dim, n2_dim;

reg [7:0]  m_addr, n_addr;

reg [31:0]  data1_in, data2_in;
wire [31:0] data1_out, data2_out;

mn_matrix matrix1(
.reset(reset),
.clk(clk),
.write(write1),
.read(read1),
.m_dim(m1_dim),
.n_dim(n1_dim),
.m_addr(m_addr),
.n_addr(n_addr),
.transpose(transpose1),
.data_in(data1_in),
.data_out(data1_out)
);

mn_matrix matrix2(
.reset(reset),
.clk(clk),
.write(write2),
.read(read2),
.m_dim(m2_dim),
.n_dim(n2_dim),
.m_addr(m_addr),
.n_addr(n_addr),
.transpose(transpose2),
.data_in(data2_in),
.data_out(data2_out)
);

always @(posedge clk, posedge reset) //asynchronous active_high Reset
 begin
    if (reset) 
	 begin
	    for (i = 0; i < 128; i = i + 1)
        begin
            matrix_out[i] = 32'd0;
        end
	end
    else // under positive edge of the clock
     begin
        case (state)
            IDLE:
                m_addr <= 0;
                n_addr <= 0;
                
                if (start && m1_dim == m2_dim && n1_dim == n2_dim)
                begin
                    write_matrix_from_array(matrix1_in, m1_dim, n1_dim, clk, write1, read1, transpose1, m1_dim, n1_dim, m_addr, n_addr, data1_in);
                    write_matrix_from_array(matrix2_in, m1_dim, n2_dim, clk, write2, read2, transpose2, m2_dim, n2_dim, m_addr, n_addr, data2_in);
                    
                    k <= 0;
                    state <= COMPUTE;
                end
            COMPUTE:
                begin            
                    matrix_out[k+31:k] <= data1_out + data2_out;
                    // move column
                    n_addr <= n_addr + 1;
                    // move row
                    if (n_addr == (n_dim - 1))
                    begin
                        n_addr <= 0;
                        m_addr <= m_addr + 1;
                    end
                    k <= k + 32;
                    
                    if (n_addr == (n_dim - 1) && m_addr == (m_addr - 1))
                        state <= IDLE;
                end
        endcase
    end
end // end of always procedural block 
endmodule
