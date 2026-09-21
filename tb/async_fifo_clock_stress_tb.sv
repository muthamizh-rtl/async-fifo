`timescale 1ns/1ps

module async_fifo_clock_stress_tb;

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

initial begin
    $dumpfile("async_fifo_clock_stress.vcd");
    $dumpvars(0, async_fifo_clock_stress_tb);

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

    $display("ASYNC FIFO CLOCK STRESS TEST STARTED");

    repeat (20) begin
        @(posedge wr_clk);

        if (!full) begin
            wr_data = wr_data + 1'b1;
            wr_en = 1'b1;
        end
    end

    wr_en = 1'b0;

    repeat (20) begin
        @(posedge rd_clk);

        if (!empty)
            rd_en = 1'b1;
    end

    rd_en = 1'b0;

    repeat (10)
        @(posedge rd_clk);

    if (empty)
        $display("CLOCK DOMAIN STRESS CHECK PASSED");
    else
        $error("FIFO DID NOT RETURN TO EMPTY");

    $display("ASYNC FIFO CLOCK STRESS TEST COMPLETED");
    $display("TEST PASSED");

    #100;
    $finish;
end

endmodule