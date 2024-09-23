//Almacena datos de manera continua mediante packed
typedef struct packed {              // Total: 54 bytes
  bit  [31:0]  important_colors;     // Important colors 
  bit  [31:0]  num_colors;           // Number of colors  
  bit  [31:0]   y_resolution_ppm;    // Pixels per meter
  bit  [31:0]   x_resolution_ppm;    // Pixels per meter
  bit  [31:0]  image_size_bytes;     // Image size in bytes
  bit  [31:0]  compression;          // Compression type
  bit  [15:0]  bits_per_pixel;       // Bits per pixel
  bit  [15:0]  num_planes;           // Number of color planes
  bit  [31:0]   height_px;           // Height of image
  bit  [31:0]   width_px;            // Width of the image
  bit  [31:0]  dib_header_size;      // DIB Header size in bytes (40 bytes)
  bit  [31:0]  offset;               // Offset to image data in bytes from beginning of file (54 bytes)
  bit  [15:0]  reserved2;            // Not used
  bit  [15:0]  reserved1;            // Not used
  bit  [31:0]  size;                 // File size in bytes
  bit  [15:0]  bmp_type;             // Magic identifier: 0x4d42
} BMPHeader;

//Para poder acceder a cada uno de los valores del registro, usar pack para poder acceder a cada uno de esos registros.
typedef union {
    BMPHeader header;
    bit[7:0] bytes[54];
} header_union;

class image_pkt;
    // Define your class members and methods here
    // For simplicity, let's assume the BMP file has fixed dimensions and a single color.
    int width;
    int height;
    header_union u;
    byte pixel_bytes[$];

    // Constructor
    function new(int width_, int height_);
        width = width_;
        height = height_;
    endfunction
	//Funcion inicializa todos los datos del header
    function initialize_header;
        //Initialize bmp header
        u.header.bmp_type = 31'h4d42;
      	//*4 numero de bytes por pixel
        u.header.size = 54+width*height*4;
        $display("FILE SIZE: %0d", u.header.size);
        u.header.reserved1 = 0;
        u.header.reserved2 = 0;
        u.header.offset = 54;
        u.header.dib_header_size= 40;     // DIB Header size in bytes (40 bytes)
        u.header.width_px = width;        // Width of the image
        u.header.height_px = height;      // Height of image
        u.header.num_planes = 1;          // Number of color planes
        u.header.bits_per_pixel = 24;     // Bits per pixel
        u.header.compression = 0;         // Compression type
        u.header.image_size_bytes = width*height*4; // Image size in bytes
        $display("IMAGE_SIZE_BYTES : %0d", u.header.image_size_bytes);
        u.header.x_resolution_ppm = 0;    // Pixels per meter
        u.header.y_resolution_ppm = 0;    // Pixels per meter
        u.header.num_colors=  0;          // Number of colors  
        u.header.important_colors = 0;    // Important colors 
    endfunction
  
    //EXERCISE1: Generate image with a specific color
    //EXERCISE2: Generate image with a checkered pattern
  
    function void randomize_pixels();
      bit [23:0] color; // Single color represented in RGB format
      int number_of_bytes;
      int pad_bytes;
      
      for (int i = 0; i < height; i++) begin
            number_of_bytes = 0;
            for (int j = 0; j <  width; j++) begin
                color = $urandom_range(24'h000000, 24'hFFFFFF);
                pixel_bytes.push_back(color[23:16]);
                pixel_bytes.push_back(color[15:8]);
                pixel_bytes.push_back(color[7:0]);
                $display("C %c", color); //TODO: make this variable
                number_of_bytes = number_of_bytes+ u.header.bits_per_pixel/8; //TODO: can bits per pixel be non multiple of 8?
            end
            $display("ROW%0d: number_of_bytes %0d ", i, number_of_bytes);
            pad_bytes = 4-number_of_bytes%4;
            $display("Need to pad : %0d bytes", pad_bytes);

            repeat(pad_bytes) begin
              pixel_bytes.push_back(8'h00);  //PAD with 00s
            end
        end
    endfunction
  
    // Function to generate the BMP file and save
    function void save_file(string filename);
        int file;

        // Open the file for writing
        file = $fopen(filename, "w");

        // Write BMP header to the file
        foreach(u.bytes[i]) begin
            $fwrite(file, "%c", u.bytes[i]);
        end
      
        foreach( pixel_bytes[k] ) begin
            $fwrite(file, "%c", pixel_bytes[k]);
        end
      
        // Close the file
        $fclose(file);
    endfunction
endclass