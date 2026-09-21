`timescale 1ns/1ps

module async_fifo_assertion_tb;

localparam int DATA_WIDTH = 8;
localparam int ADDR_WIDTH = 4;

logic wr_clk;
logic rd_clk;
logic wr_rst_n;
logic rd_rst_n;

logic [DATA_WIDTH-1:0] wr_data;
logic wr_en;
logic full;

logic [DATA_WIDTH-1:0] rd_data;
logic rd_en;
logic empty;

async_fifo #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH)
) dut (
    .wr_clk(wr_clk),
    .rd_clk(rd_clk),
    .wr_rst_n(wr_rst_n),
    .rd_rst_n(rd_rst_n),
    .wr_data(wr_data),
    .wr_en(wr_en),
    .full(full),
    .rd_data(rd_data),
    .rd_en(rd_en),
    .empty(empty)
);

always #5 wr_clk = ~wr_clk;
always #7 rd_clk = ~rd_clk;

always @(posedge wr_clk) begin
    if (wr_rst_n) begin
        if (full && wr_en)
            $display("WRITE BLOCKED: FIFO FULL");

        if (full && empty)
            $error("ASSERTION FAILED: FIFO cannot be FULL and EMPTY");
    end
end

always @(posedge rd_clk) begin
    if (rd_rst_n) begin
        if (empty && rd_en)
            $display("READ BLOCKED: FIFO EMPTY");

        if (full && empty)
            $error("ASSERTION FAILED: FIFO cannot be FULL and EMPTY");
    end
end

initial begin
    $dumpfile("async_fifo_assertion.vcd");
    $dumpvars(0, async_fifo_assertion_tb);

    wr_clk = 1'b0;
    rd_clk = 1'b0;

    wr_rst_n = 1'b0;
    rd_rst_n = 1'b0;

    wr_data = 8'h00;
    wr_en = 1'b0;
    rd_en = 1'b0;

    #50;

    wr_rst_n = 1'b1;
    rd_rst_n = 1'b1;

    if (!empty)
        $error("ASSERTION FAILED: FIFO is not EMPTY after reset");
    else
        $display("RESET EMPTY CHECK PASSED");

    wr_data = 8'hA5;
    wr_en = 1'b1;

    @(posedge wr_clk);
    wr_en = 1'b0;

    repeat (4)
        @(posedge rd_clk);

    if (empty)
        $error("ASSERTION FAILED: FIFO remained EMPTY after write");
    else
        $display("WRITE STATE CHECK PASSED");

    rd_en = 1'b1;

    @(posedge rd_clk);
    rd_en = 1'b0;

    repeat (4)
        @(posedge rd_clk);

    if (!empty)
        $error("ASSERTION FAILED: FIFO is not EMPTY after read");
    else
        $display("READ STATE CHECK PASSED");

    if (full && empty)
        $error("ASSERTION FAILED: FIFO FULL and EMPTY simultaneously");
    else
        $display("FULL/EMPTY MUTUAL EXCLUSION CHECK PASSED");

    $display("ASYNC FIFO ASSERTION TEST COMPLETED");
    $display("TEST PASSED");

    #100;
    $finish;
end

endmodule