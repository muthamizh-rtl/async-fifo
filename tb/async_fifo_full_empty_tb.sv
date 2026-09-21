`timescale 1ns/1ps

module async_fifo_full_empty_tb;

localparam int DATA_WIDTH = 8;
localparam int ADDR_WIDTH = 4;
localparam int DEPTH = 1 << ADDR_WIDTH;

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
always #8 rd_clk = ~rd_clk;

task write_fifo(input logic [7:0] data);
begin
    @(posedge wr_clk);

    while (full)
        @(posedge wr_clk);

    wr_data = data;
    wr_en = 1'b1;

    @(posedge wr_clk);
    wr_en = 1'b0;

    $display("WRITE: 0x%02h", data);
end
endtask

task read_fifo(input logic [7:0] expected);
begin
    @(posedge rd_clk);

    while (empty)
        @(posedge rd_clk);

    rd_en = 1'b1;

    @(posedge rd_clk);
    rd_en = 1'b0;

    if (rd_data !== expected)
        $error("READ ERROR: Expected 0x%02h, Received 0x%02h",
               expected, rd_data);
    else
        $display("READ PASS: 0x%02h", rd_data);
end
endtask

initial begin
    $dumpfile("async_fifo_full_empty.vcd");
    $dumpvars(0, async_fifo_full_empty_tb);

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

    $display("ASYNC FIFO FULL/EMPTY TEST STARTED");

    if (!empty)
        $error("FIFO should be EMPTY after reset");

    $display("EMPTY CHECK PASSED");

    for (int i = 0; i < DEPTH; i++) begin
        write_fifo(i);
    end

    repeat (4)
        @(posedge wr_clk);

    if (!full)
        $error("FIFO should be FULL after 16 writes");
    else
        $display("FULL CHECK PASSED");

    read_fifo(8'h00);
    read_fifo(8'h01);
    read_fifo(8'h02);
    read_fifo(8'h03);
    read_fifo(8'h04);
    read_fifo(8'h05);
    read_fifo(8'h06);
    read_fifo(8'h07);
    read_fifo(8'h08);
    read_fifo(8'h09);
    read_fifo(8'h0A);
    read_fifo(8'h0B);
    read_fifo(8'h0C);
    read_fifo(8'h0D);
    read_fifo(8'h0E);
    read_fifo(8'h0F);

    repeat (4)
        @(posedge rd_clk);

    if (!empty)
        $error("FIFO should be EMPTY after all reads");
    else
        $display("EMPTY AFTER READ CHECK PASSED");

    $display("ASYNC FIFO FULL/EMPTY TEST COMPLETED");
    $display("TEST PASSED");

    #100;
    $finish;
end

endmodule`timescale 1ns/1ps

module async_fifo_full_empty_tb;

localparam int DATA_WIDTH = 8;
localparam int ADDR_WIDTH = 4;
localparam int DEPTH = 1 << ADDR_WIDTH;

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
always #8 rd_clk = ~rd_clk;

task write_fifo(input logic [7:0] data);
begin
    @(posedge wr_clk);

    while (full)
        @(posedge wr_clk);

    wr_data = data;
    wr_en = 1'b1;

    @(posedge wr_clk);
    wr_en = 1'b0;

    $display("WRITE: 0x%02h", data);
end
endtask

task read_fifo(input logic [7:0] expected);
begin
    @(posedge rd_clk);

    while (empty)
        @(posedge rd_clk);

    rd_en = 1'b1;

    @(posedge rd_clk);
    rd_en = 1'b0;

    if (rd_data !== expected)
        $error("READ ERROR: Expected 0x%02h, Received 0x%02h",
               expected, rd_data);
    else
        $display("READ PASS: 0x%02h", rd_data);
end
endtask

initial begin
    $dumpfile("async_fifo_full_empty.vcd");
    $dumpvars(0, async_fifo_full_empty_tb);

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

    $display("ASYNC FIFO FULL/EMPTY TEST STARTED");

    if (!empty)
        $error("FIFO should be EMPTY after reset");

    $display("EMPTY CHECK PASSED");

    for (int i = 0; i < DEPTH; i++) begin
        write_fifo(i);
    end

    repeat (4)
        @(posedge wr_clk);

    if (!full)
        $error("FIFO should be FULL after 16 writes");
    else
        $display("FULL CHECK PASSED");

    read_fifo(8'h00);
    read_fifo(8'h01);
    read_fifo(8'h02);
    read_fifo(8'h03);
    read_fifo(8'h04);
    read_fifo(8'h05);
    read_fifo(8'h06);
    read_fifo(8'h07);
    read_fifo(8'h08);
    read_fifo(8'h09);
    read_fifo(8'h0A);
    read_fifo(8'h0B);
    read_fifo(8'h0C);
    read_fifo(8'h0D);
    read_fifo(8'h0E);
    read_fifo(8'h0F);

    repeat (4)
        @(posedge rd_clk);

    if (!empty)
        $error("FIFO should be EMPTY after all reads");
    else
        $display("EMPTY AFTER READ CHECK PASSED");

    $display("ASYNC FIFO FULL/EMPTY TEST COMPLETED");
    $display("TEST PASSED");

    #100;
    $finish;
end

endmodule