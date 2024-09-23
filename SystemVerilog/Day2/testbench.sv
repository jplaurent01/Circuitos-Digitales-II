`include "image_pkt.sv"
// Code your testbench here
// or browse Examples
module tb;
  
  initial begin
    image_pkt img1;
    img1 = new(20, 20);
    img1.initialize_header();
    img1.randomize_pixels();
    //img1.generate_checker();
    img1.save_file("saved_file.bmp");

    
  end
endmodule