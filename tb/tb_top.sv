// testbench.v
`timescale 1ns/1ps

`include "apb/assign.svh"

module tb_top;
    localparam int unsigned CLOCK_PERIOD = 20ns;
    // toggle with RTC period
    localparam int unsigned RTC_CLOCK_PERIOD = 30.517us;
    
    logic clk,rst_n,rtc_i;       // Declare clk and rst as a reg
    // apb_uart inputs
    logic        penable, pwrite, pready[1:0], pslverr[1:0], rx, tx;
    logic [02:0] ev;
    logic [01:0] psel;
    logic [31:0] prdata [1:0], pwdata;
    logic [11:0] paddr;

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
        $dumpvars(1, tb_top.uut.axi2apb_uart);
        $dumpvars(0, tb_top.uut.apb_uart);
        $dumpvars(0, tb_top.i_uart_bus);
        $dumpvars(1, tb_top.uut.cpu_core);
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
      .spi_sdi(4'd0), 
      .tx(tx), 
      .ev(), 
      .spi_clk(), 
      .spi_csn(), 
      .spi_sdo(), 
      .spi_mode(), 
      .clk(clk),
      .rtc_clk(rtc_i));

endmodule
