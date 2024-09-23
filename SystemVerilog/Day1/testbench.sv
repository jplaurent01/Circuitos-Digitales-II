// Code your testbench here
// or browse Examples
class pkt_base;
  int height = 0 ;
  int width = 0;
  int fie_size = 0;
  string name = "";
  
  function new(string name);
    this.name = name;
  endfunction
  
  //Metodo virtual permite que se pueda extender, asi que cualquier clase que la herede puede modificar esta funcion
  virtual function void set_dimensions(int h, int w);
    height = h;
    width = w;
   endfunction
    
  function print_info();
    $display("%s: Height: %0d widht: %0d size: %0d", name, height, width, fie_size);
  endfunction
  
endclass

class image_pkt extends pkt_base;
  int num_pixels;
  
  function new(string name);
    super.new(name);
  endfunction
  
  virtual function void set_dimensions(int h, int w);
    super.set_dimensions(h,w);
    num_pixels = height * width;
  endfunction
  
endclass

module tb;
  //initial siempre se ejecuta en tiempo cero
  initial begin
  //pkt_base b1;
  //b1 = new("pkt1");
  //b1.print_info();
    image_pkt img1;
    img1 = new("img1");
    img1.set_dimensions(10, 10);
    img1.print_info();
   
  end
  
endmodule