`timescale 1 ns / 100 ps

`include "matrix_io.sv"

module mn_matrix_tb;

 // declaring inputs
reg   reset_tb, clk_tb;
reg   write_tb, read_tb;
reg   transpose_tb;

reg [7:0]  m_dim_tb, n_dim_tb;
reg [7:0]  m_addr_tb, n_addr_tb;
reg [31:0]  data_in_tb;
	
 // declaring outputs
wire [31:0] data_out_tb;

 // testing variables
integer i, j, k;
integer f;

 //state string
reg [32*8:1] state_string;
	
//instantiating the DUT
 mn_matrix dut (
 .reset(reset_tb),
 .clk(clk_tb),
 .write(write_tb),
 .read(read_tb),
 .m_dim(m_dim_tb),
 .n_dim(n_dim_tb),
 .m_addr(m_addr_tb),
 .n_addr(n_addr_tb),
 .transpose(transpose_tb),
 .data_in(data_in_tb),
 .data_out(data_out_tb)
);

integer clk_cnt, start_clock_cnt, clocks_taken;
 
//generate the clock
 initial
	begin: CLOCK_GENERATOR
	 clk_tb = 0;
	 forever
		begin
			#5 clk_tb = ~ clk_tb;
		end
	end
	
//generate reset stimulus
initial
  begin  : RESET_GENERATOR
    reset_tb = 1;
	   //initialiaze to avoid red
     #6 reset_tb = 0;
  end
 
//generate clock counter
  initial
   begin  : CLK_COUNTER
    clk_cnt = 0;
	@(posedge clk_tb); // wait until a little after the positive edge
    forever
     begin 
	      @(posedge clk_tb);
		    clk_cnt = clk_cnt + 1;
     end 
   end
 
 //initialize output file
  initial
   begin
      f = $fopen("output.txt");
   end
   
 //generate input stimuli
  initial
   begin
     //unique sequence in beginning
//	   @(posedge clk_tb);
      @(negedge reset_tb);
      $fwrite(f, "arr = [1 2 3 4 5 6]\n\n");
      write_matrix_from_array({32'd6, 32'd5, 32'd4, 32'd3, 32'd2, 32'd1}, 3, 2,
                               clk_tb, write_tb, read_tb, transpose_tb, m_dim_tb, n_dim_tb, m_addr_tb, n_addr_tb, data_in_tb);
  	   @(posedge clk_tb);
      read_matrix(3, 2);
      @(posedge clk_tb);
      read_matrix_transpose(3, 2);
   end

task read_matrix;
  input [31:0] n, m;
   begin
      write_tb = 0;
      read_tb = 1;
      transpose_tb = 0;
      
      n_dim_tb = n;
      m_dim_tb = m;
      
      $fwrite(f, "matrix A:\n");
      for (i = 0; i < m; i = i + 1)
       begin
          for (j = 0; j < n; j = j + 1)
           begin
              n_addr_tb = j;
              m_addr_tb = i;
              @(posedge clk_tb);
              #1;
              $fwrite(f, "%d\t", data_out_tb);
           end
          $fwrite(f, "\n");
        end
       $fwrite(f, "\n");
   end
endtask

task read_matrix_transpose;
  input [31:0] n, m;
   begin
      write_tb = 0;
      read_tb = 1;
      transpose_tb = 1;
      
      n_dim_tb = n;
      m_dim_tb = m;
      
      $fwrite(f, "matrix A':\n");
      for (i = 0; i < n; i = i + 1)
       begin
          for (j = 0; j < m; j = j + 1)
           begin
              n_addr_tb = j;
              m_addr_tb = i;
              @(posedge clk_tb);
              #1;
              $fwrite(f, "%d\t", data_out_tb);
           end
          $fwrite(f, "\n");
        end
        $fwrite(f, "\n");
        @(posedge clk_tb);
        #1;
        transpose_tb = 0;
   end
endtask
endmodule //mn_matrix_tb
