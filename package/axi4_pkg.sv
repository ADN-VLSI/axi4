package axi4_pkg;

  class axi4_seq_item;

    rand bit           tx_write;

    rand bit [   31:0] tx_id;
    rand bit [   63:0] tx_addr;
    rand bit [    7:0] tx_len;
    rand bit [    3:0] tx_size;
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

    int                AWID_WIDTH          = 8;
    int                ARID_WIDTH          = 8;
    int                ADDR_WIDTH          = 8;
    int                DATA_WIDTH          = 8;
    int                USER_REQ_WIDTH      = 8;
    int                USER_RESP_WIDTH     = 8;
    int                USER_DATA_WIDTH     = 8;

    bit                ALLOW_ILLEGAL_BURST = 0;

    constraint generic_width_c {
      if (tx_write && (AWID_WIDTH < 32)) tx_id[31:AWID_WIDTH] == '0;

      if (!tx_write && (ARID_WIDTH < 32)) tx_id[31:ARID_WIDTH] == '0;

      if (ADDR_WIDTH < 64) tx_addr[63:ADDR_WIDTH] == '0;

      if (USER_REQ_WIDTH < 128) tx_req_user[127:USER_REQ_WIDTH] == '0;

      if (tx_write && (USER_RESP_WIDTH < 16)) tx_resp_user[4095:USER_RESP_WIDTH] == '0;

      if (USER_DATA_WIDTH < 131072) tx_data_user[131071:(USER_DATA_WIDTH*(tx_len+1))] == '0;

      if (tx_write) tx_data[32767:(DATA_WIDTH*(tx_len+1))] == '0;
    }

    // if (!ALLOW_ILLEGAL_BURST) tx_burst inside {[0:2]};
  endclass

endpackage
