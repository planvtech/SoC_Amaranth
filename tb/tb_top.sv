// testbench.v
`timescale 1ns/1ps

module tb_top;
    localparam int unsigned CLOCK_PERIOD = 20ns;
    // toggle with RTC period
    localparam int unsigned RTC_CLOCK_PERIOD = 30.517us;
    
    logic clk,rst_n,rtc_i;       // Declare clk and rst as a reg
    // apb_uart inputs
    logic        rx, tx;
    logic [02:0] ev;
    // apb spi
    wire [03:0] spi_sdo;
    wire [03:0] spi_sdi;
    wire [03:0] spi_csn;

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLOCK_PERIOD/2) clk = ~clk; // 100 MHz clock
    end

    initial begin
        forever begin
            rtc_i = 1'b0;
            #(RTC_CLOCK_PERIOD/2) rtc_i = 1'b1;
            #(RTC_CLOCK_PERIOD/2) rtc_i = 1'b0;
        end
    end

    // reset generation
    initial begin
        rst_n = 1;
        #50 rst_n = 0; 
        #100 rst_n = 1;
    end

    uart_bus #(.BAUD_RATE(115200), .PARITY_EN(0)) i_uart_bus (.rx(tx), .tx(rx), .rx_en(1'b1));

    // Monitor the counter and capture all signals
    initial begin
        automatic string testname      = "";
        automatic string testdir       = "sim/testlist/";
        if (!$value$plusargs("TESTNAME=%s", testname)) begin
            $error("No TESTNAME plusarg given");
        end
        testdir = {testdir,testname,"/main.hex"};
        #100;
        $readmemh(testdir, tb_top.uut.axi_ram.mem);
        $dumpfile("sim/testbench.vcd");
        $dumpvars(0, tb_top.uut.apb_spi_master);
        $dumpvars(0, tb_top.flash);
        #10000000 $finish; // Run simulation for 1,000,000ns (1ms)
    end

    
    // Instantiate the top-level module
    top uut (
      .rst(rst_n), 
      .pwrup_rst_n(rst_n),
      .test_rst_n(rst_n),
      .cpu_rst_n(rst_n),
      .intr(1'b0),
      .rx(rx), 
      .spi_sdi(spi_sdi), 
      .tx(tx), 
      .ev(), 
      .spi_clk(spi_clk), 
      .spi_csn(spi_csn), 
      .spi_sdo(spi_sdo), 
      .spi_mode(), 
      .clk(clk),
      .rtc_clk(rtc_i));

      
    // flash model
    s25fl128s flash
    (
      .SCK     (spi_clk),
      .SI      (spi_sdo[0]),
      .CSNeg   (spi_csn[0]),
      .HOLDNeg (), //Internal pull-up
      .WPNeg   (), //Internal pull-up
      .SO      (spi_sdi[1]),
      .RSTNeg  (1'b1)
    );

endmodule
