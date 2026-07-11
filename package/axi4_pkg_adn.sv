/*
package axi4_pkg_adn;


    class axi4_seq_item #(
      parameter int AWID_WIDTH      = 0,
      parameter int ARID_WIDTH      = 0,
      parameter int ADDR_WIDTH      = 1,
      parameter int DATA_WIDTH      = 8,
      parameter int USER_REQ_WIDTH  = 0,
      parameter int USER_RESP_WIDTH = 0,
      parameter int USER_DATA_WIDTH = 0
  );

    rand bit           tx_write;

    rand bit [   31:0] tx_id;
    rand bit [   63:0] tx_addr;
    rand bit [    7:0] tx_len;
    rand bit [    2:0] tx_size;
    rand bit [    1:0] tx_burst;
    rand bit           tx_lock;
    rand bit [    3:0] tx_cache;
    rand bit [    2:0] tx_prot;
    rand bit [    3:0] tx_qos;
    rand bit [    3:0] tx_region;

    rand bit [  127:0] tx_req_user;
    rand bit [ 4095:0] tx_resp_user;
    rand bit [16383:0] tx_data_user;

    rand bit [32767:0] tx_data;
    rand bit [ 4095:0] tx_strb;

    bit      [   31:0] exc_tx_write;
    bit      [   31:0] exc_tx_id;
    bit      [   63:0] exc_tx_addr;
    bit      [    7:0] exc_tx_len;
    bit      [    2:0] exc_tx_size;
    bit      [    1:0] exc_tx_burst;
    bit                exc_tx_lock;
    bit      [    3:0] exc_tx_cache;
    bit      [    2:0] exc_tx_prot;
    bit      [    3:0] exc_tx_region;




    constraint c_tx_size {
        tx_size <= bit'($clog2(DATA_WIDTH / 8));
    }

    constraint c_tx_burst {
        tx_burst inside {[0:2]};
    }









    function automatic void post_randomize();
      if(tx_write) begin 
        for (int i = 0; i < 32; i++) if(i>=AWID_WIDTH) tx_id[i] = 0;
      end else for (int i = 0; i < 32; i++) if(i>=ARID_WIDTH) tx_id[i] = 0;

        for (int i = 0; i < 64; i++) if(i>=ADDR_WIDTH) tx_addr[i] = 0;

        if(tx_burst == 2) 
         







    endfunction






    endclass : axi4_seq_item







endpackage : axi4_pkg_adn
*/