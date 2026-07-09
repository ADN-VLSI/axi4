module hello;

  initial begin
    axi4_pkg::axi4_seq_item #(3, 3, 32, 64, 8, 8, 8) item;
    repeat (3) begin
      item = new();
      item.randomize() with {
        item.tx_write == 0;
        item.tx_lock == 1;
      };
      item.record_exclusive_access();
      $display("\n\n%s\n\n", item.to_string());
    end
    repeat (2) begin
      item = new();
      item.randomize() with {
        item.tx_write == 1;
        item.tx_lock == 1;
      };
      $display("\n\n%s\n\n", item.to_string());
    end
    $display("BAICCHA GASI");
    $finish;
  end

endmodule
