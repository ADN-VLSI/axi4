module hello;

initial begin
    axi4_pkg::axi4_seq_item item;
    repeat (10) begin
      item = new();
      item.randomize();
    end
    $display("MARA KHAI NAI");
    $finish;
  end

endmodule
