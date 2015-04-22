// matrix input/output tasks
//////////////////////////////////////////////////////////////////////////////////

`ifndef _matrix_io_vh
`define _matrix_io_vh

integer i, j, k;

task automatic write_matrix_from_array;
  input [128*128*3-1:0] arr;
  input [31:0] m, n;
  ref   clk;
  ref   write, read;
  ref   transpose;
  ref [31:0]  m_dim, n_dim;
  ref [31:0]  m_addr, n_addr;
  ref [31:0]  data_in;
   begin 
      write = 1;
      read = 0;
      transpose = 0;
      
      n_dim = n;
      m_dim = m;
      
      k = 0;
      
      for (i = 0; i < m; i = i + 1)
       begin
          for (j = 0; j < n; j = j + 1)
           begin
              @(posedge clk);
              n_addr = j;
              m_addr = i;
              data_in = {arr[k+31], arr[k+30], arr[k+29], arr[k+28], arr[k+27], arr[k+26], arr[k+25], arr[k+24],
                            arr[k+23], arr[k+22], arr[k+21], arr[k+20], arr[k+19], arr[k+18], arr[k+17], arr[k+16],
                            arr[k+15], arr[k+14], arr[k+13], arr[k+12], arr[k+11], arr[k+10], arr[k+9], arr[k+8],
                            arr[k+7], arr[k+6], arr[k+5], arr[k+4], arr[k+3], arr[k+2], arr[k+1], arr[k]};
              k = k + 32;
          end
       end
       
      @(posedge clk);
      write = 0;
   end
endtask

`endif //_matrix_io_vh