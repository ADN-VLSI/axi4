package axi4_pkg;

  typedef struct packed {
    bit [31:0] tx_id;
    bit [63:0] tx_addr;
    bit [7:0]  tx_len;
    bit [2:0]  tx_size;
    bit [1:0]  tx_burst;
    bit        tx_lock;
    bit [3:0]  tx_cache;
    bit [2:0]  tx_prot;
    bit [3:0]  tx_region;
  } exclusive_access_t;

  static exclusive_access_t exclusive_access_records[$];

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

    constraint c_tx_len {tx_size <= $clog2(DATA_WIDTH / 8);}
    constraint c_tx_burst {tx_burst inside {[0 : 2]};}
    constraint c_tx_cache {tx_cache inside {0, 1, 2, 3, 6, 7, 10, 11, 14, 15};}

    // 4KB TX SIZE LIMIT 
    constraint c_4kb_lim {((tx_addr % 4096) + ((tx_len + 1) * (1 << tx_size)) <= 4096);}

    // EXCLUSIVE ACCESS
    constraint c_exclusive_access {
      if (tx_lock) tx_addr % ((tx_len + 1) * (1 << tx_size)) == 0;
      if (tx_lock) ((tx_len + 1) * (1 << tx_size)) inside {1, 2, 4, 8, 16, 32, 64, 128};
      if (tx_lock) tx_cache inside {0, 2};
    }

    // TODO EXCLUSIVE ACCESS WRITE SOFT CONSTRAINTS

    // WRAP BURST
    constraint c_wrap_burst {
      if (tx_burst == 2) ((tx_addr % (1 << tx_size)) == 0);
      if (tx_burst == 2) tx_len inside {1, 3, 7, 15};
    }

    constraint c_ex_write {
      if (tx_write) soft exc_tx_write == tx_write;
      if (tx_write) soft exc_tx_id == tx_id;
      if (tx_write) soft exc_tx_addr == tx_addr;
      if (tx_write) soft exc_tx_len == tx_len;
      if (tx_write) soft exc_tx_size == tx_size;
      if (tx_write) soft exc_tx_burst == tx_burst;
      if (tx_write) soft exc_tx_lock == tx_lock;
      if (tx_write) soft exc_tx_cache == tx_cache;
      if (tx_write) soft exc_tx_prot == tx_prot;
      if (tx_write) soft exc_tx_region == tx_region;
    }


    function automatic void pre_randomize();
      int idx;
      idx = 0;
      exc_tx_write = 0;
      if (exclusive_access_records.size()) begin
        idx = $urandom_range(0, exclusive_access_records.size() - 1);
       // exc_tx_write = $urandom_range(0, 1);
        exc_tx_id = exclusive_access_records[idx].tx_id;
        exc_tx_addr = exclusive_access_records[idx].tx_addr;
        exc_tx_len = exclusive_access_records[idx].tx_len;
        exc_tx_size = exclusive_access_records[idx].tx_size;
        exc_tx_burst = exclusive_access_records[idx].tx_burst;
        exc_tx_lock = exclusive_access_records[idx].tx_lock;
        exc_tx_cache = exclusive_access_records[idx].tx_cache;
        exc_tx_prot = exclusive_access_records[idx].tx_prot;
        exc_tx_region = exclusive_access_records[idx].tx_region;
      end
    endfunction

    function automatic void post_randomize();

      //////////////////////////////////////////////////////////////////////////
      // Trim excess bits
      //////////////////////////////////////////////////////////////////////////

      if (tx_write) begin
        for (int i = 0; i < 32; i++) if (i >= AWID_WIDTH) tx_id[i] = 0;
      end else begin
        for (int i = 0; i < 32; i++) if (i >= ARID_WIDTH) tx_id[i] = 0;
      end

      for (int i = 0; i < 64; i++) if (i >= ADDR_WIDTH) tx_addr[i] = 0;

      for (int i = 0; i < 128; i++) if (i >= USER_REQ_WIDTH) tx_req_user[i] = 0;
      tx_resp_user = 0;
      if (tx_write) begin
        for (int i = 0; i < 16384; i++) begin
          if (i >= (USER_DATA_WIDTH * (tx_len + 1))) tx_data_user[i] = 0;
        end
      end else tx_data_user = '0;

      if (tx_write) begin
        for (int i = 0; i < 32768; i++) if (i >= (DATA_WIDTH * (tx_len + 1))) tx_data[i] = 0;
        for (int i = 0; i < 4096; i++) if (i >= (DATA_WIDTH / 8 * (tx_len + 1))) tx_strb[i] = 0;
      end else begin
        tx_data = '0;
        tx_strb = '0;
      end

    endfunction

    virtual function automatic void record_exclusive_access();
      exclusive_access_t record;
      record.tx_id     = tx_id;
      record.tx_addr   = tx_addr;
      record.tx_len    = tx_len;
      record.tx_size   = tx_size;
      record.tx_burst  = tx_burst;
      record.tx_lock   = tx_lock;
      record.tx_cache  = tx_cache;
      record.tx_prot   = tx_prot;
      record.tx_region = tx_region;
      exclusive_access_records.push_back(record);
    endfunction

    virtual function automatic void erase_exclusive_access(exclusive_access_t record);
      int idx;
      for (idx = 0; idx < exclusive_access_records.size(); idx++) begin
        if (exclusive_access_records[idx] == record) begin
          exclusive_access_records.delete(idx);
          break;
        end
      end
    endfunction

    virtual function automatic string to_string(string hdr = "Sequence");
      string txt;
      $sformat(txt, "AXI %s Item", hdr);
      $sformat(txt, "%s\n TYPE   : %s", txt, tx_write ? "WRITE" : "READ ");
      $sformat(txt, "%s\n ID     : 0x%08x (%0d)", txt, tx_id, tx_id);
      $sformat(txt, "%s\n ADDR   : 0x%016x", txt, tx_addr);
      $sformat(txt, "%s\n LEN    : %0d", txt, tx_len);
      $sformat(txt, "%s\n SIZE   : %0d", txt, tx_size);
      $sformat(txt, "%s\n BURST  : %0d", txt, tx_burst);
      $sformat(txt, "%s\n ACCESS : %s", txt, tx_lock ? "EXCLUSIVE" : "NORMAL   ");
      $sformat(txt, "%s\n CACHE  : 0x%0x", txt, tx_cache);
      case ({
        tx_write, tx_cache
      })
        'b00000, 'b10000:          $sformat(txt, "%s Device Non-bufferable                ", txt);
        'b00001, 'b10001:          $sformat(txt, "%s Device Bufferable                    ", txt);
        'b00010, 'b10010:          $sformat(txt, "%s Normal Non-cacheable Non-bufferable  ", txt);
        'b00011, 'b10011:          $sformat(txt, "%s Normal Non-cacheable Bufferable      ", txt);
        'b01010, 'b10110:          $sformat(txt, "%s Write-Through No-Allocate            ", txt);
        'b01110, 'b00110, 'b10110: $sformat(txt, "%s Write-Through Read-Allocate          ", txt);
        'b01010, 'b11110, 'b11010: $sformat(txt, "%s Write-Through Write-Allocate         ", txt);
        'b01110, 'b11110:          $sformat(txt, "%s Write-Through Read and Write-Allocate", txt);
        'b01011, 'b10111:          $sformat(txt, "%s Write-Back No-Allocate               ", txt);
        'b01111, 'b00111, 'b10111: $sformat(txt, "%s Write-Back Read-Allocate             ", txt);
        'b01011, 'b11111, 'b11011: $sformat(txt, "%s Write-Back Write-Allocate            ", txt);
        'b01111, 'b11111:          $sformat(txt, "%s Write-Back Read and Write-Allocate   ", txt);
        default:                   $sformat(txt, "%s Unknown                              ", txt);
      endcase

      $sformat(txt, "%s\n PROT   : 0b%03b -", txt, tx_prot);
      if (tx_prot[2]) $sformat(txt, "%s PRIVILEGED", txt);
      else $sformat(txt, "%s UNPRIVILEGED", txt);
      if (tx_prot[1]) $sformat(txt, "%s NONSECURE", txt);
      else $sformat(txt, "%s SECURE", txt);
      if (tx_prot[0]) $sformat(txt, "%s INSTRUCTION ACCESS", txt);
      else $sformat(txt, "%s DATA ACCESS", txt);

      $sformat(txt, "%s\n QOS    : %0d", txt, tx_qos);
      $sformat(txt, "%s\n REGION : %0d", txt, tx_region);
      $sformat(txt, "%s\n REQUSR : 0x%0x", txt, tx_req_user);
      $display("\n %d size of queue", exclusive_access_records.size());

      return txt;
    endfunction

  endclass

endpackage
