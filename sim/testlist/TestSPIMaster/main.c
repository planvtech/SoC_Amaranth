#include <spi.h>
#include <uart.h>
#include <pulpino.h>

const char g_numbers[] = {
                           '0', '1', '2', '3', '4', '5', '6', '7',
                           '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'
                         };

int check_spi_flash();
void load_block(unsigned int addr, unsigned int len, int* dest);
void uart_send_block_done(unsigned int i);
void jump_and_start(volatile int *ptr);

int main()
{
  /* sets direction for SPI master pins with only one CS */
  spi_setup_master(1);
  uart_set_cfg(0,434);
  uart_send("SPI Test \n",11);

  for (int i = 0; i < 3000; i++) {
    //wait some time to have proper power up of external flash
    #ifdef __riscv__
        asm volatile ("nop");
    #else
        asm volatile ("nop");
    #endif
  }

  /* divide sys clock by 4 */
  *(volatile int*) (SPI_REG_CLKDIV) = 4;

  if (check_spi_flash()) {
    uart_send("ERROR: Spansion SPI flash not found\n", 36);
    return 1;
  }



  uart_send("FLASH connected SPI\n", 20);
  uart_wait_tx_done();

  
}

int check_spi_flash() {
  int err = 0;
  int rd_id[1];

  // reads flash ID
  spi_setup_cmd_addr(0x9F, 8, 0, 0);
  spi_set_datalen(32);
  spi_setup_dummy(0, 0);
  spi_start_transaction(SPI_CMD_RD, SPI_CSN0);
  spi_read_fifo(rd_id, 32);

  // id should be 0x0102194D
  if (((rd_id[0] >> 24) & 0xFF) != 0x01)
    err++;

  // check flash model is 128MB or 256MB 1.8V
  if ( (((rd_id[0] >> 8) & 0xFFFF) != 0x0219) &&
       (((rd_id[0] >> 8) & 0xFFFF) != 0x2018) )
    err++;

  return err;
}

void load_block(unsigned int addr, unsigned int len, int* dest) {
  // cmd 0xEB fast read, needs 8 dummy cycles
  spi_setup_cmd_addr(0xEB, 8, ((addr << 8) & 0xFFFFFF00), 32);
  spi_set_datalen(len);
  spi_start_transaction(SPI_CMD_QRD, SPI_CSN0);
  spi_read_fifo(dest, len);
}

void jump_and_start(volatile int *ptr)
{
#ifdef __riscv__
  asm("jalr x0, %0\n"
      "nop\n"
      "nop\n"
      "nop\n"
      : : "r" (ptr) );
#else
  asm("jr\t%0\n"
      "nop\n"
      "nop\n"
      "nop\n"
      : : "r" (ptr) );
#endif
}

void uart_send_block_done(unsigned int i) {
  unsigned int low  = i & 0xF;
  unsigned int high = i >>  4; // /16

  uart_send("Block ", 6);

  uart_send(&g_numbers[high], 1);
  uart_send(&g_numbers[low], 1);

  uart_send(" done\n", 6);

  uart_wait_tx_done();
}