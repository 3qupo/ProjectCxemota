`timescale 1ns / 1ps

module runner_tb();

reg rstn;               
reg sys_clk;             
reg t_start;             
reg up;                  
wire [5:0] led;         
wire cs;                
reg miso;               
wire mosi;              
wire sclk;              

runner master (
    .led(led),
    .rstn(rstn),
    .sys_clk(sys_clk),
    .t_start(t_start),
    .up(up),
    .cs(cs),
    .miso(miso),
    .mosi(mosi),
    .sclk(sclk)
);

initial begin
    sys_clk = 0;
    forever #5 sys_clk = ~sys_clk; 
end

initial begin
    rstn = 0;
    t_start = 1;
    up = 1;
    miso = 0; 

    #10;
    rstn = 1; 
    #10;
    up = 0;
    #10; 
    up = 1;

    t_start = 0; 
    #10;
    t_start = 1;

    #100;
    $stop;
end

    initial begin
        $dumpfile("./runner_out.vcd");  
        $dumpvars(0, runner_tb);       
        #1000 $finish;                 
    end

endmodule


//`timescale 1ns / 1ps

//module runner_tb();

//  parameter reg_width = 8;
//  reg rstn;
//  reg sys_clk;
//  reg cs;
//  reg mosi;
//  wire [5:0] led;

//  runner_lab #(
//    .reg_width(reg_width)
//  ) slave(
//    .led(led),
//    .rstn(rstn),
//    .sys_clk(sys_clk),
//    .cs(cs),
//    .mosi(mosi),
//    .sclk() 
//  );
//  
//  reg [7:0] _mosi;

//  initial begin
//    sys_clk = 0;
//    forever #5 sys_clk = ~sys_clk;
//  end

//  initial begin
//    rstn = 0;
//    cs = 1;
//    mosi = 0;

//    #10;
//    rstn = 1;
//    #10;

//    cs = 0; 
//    _mosi = 8'b00101010; 

//      mosi = _mosi[0]; 
//      #5; 
//      mosi = _mosi[1]; 
//      #5; 
//      mosi = _mosi[2]; 
//      #5; 
//      mosi = _mosi[3]; 
//      #5; 
//      mosi = _mosi[4];
//      #5; 
//      mosi = _mosi[5];
//      #5; 
//      mosi = _mosi[6]; 
//      #5; 
//      mosi = _mosi[7]; 
//      #5; 

//    cs = 1;
//    #10;

//    if (led != 6'b101010) 
//      $display("Test failed: led = %b, expected led = 101010", led);
//    else
//      $display("Test passed: led = %b", led);

//    #1000;
//    $finish;
//end

//initial begin
//        $dumpfile("./runner_out.vcd"); 
//        $dumpvars(0, runner_tb);       
//        #1000 $finish;                 
//    end

//endmodule
