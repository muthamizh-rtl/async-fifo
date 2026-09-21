`timescale 1ns/1ps

module async_fifo_random_tb;

localparam int DATA_WIDTH = 8;
localparam int ADDR_WIDTH = 4;
localparam int DEPTH = 1 << ADDR_WIDTH;
localparam int TEST_COUNT = 100;

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

logic [DATA_WIDTH-1:0] expected_queue[$];

int write_count;
int read_count;
int error_count;

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
    if (wr_rst_n && wr_en && !full) begin
        expected_queue.push_back(wr_data);
        write_count++;
    end
end

always @(posedge rd_clk) begin
    if (rd_rst_n && rd_en && !empty) begin
        if (expected_queue.size() == 0) begin
            $error("REFERENCE MODEL ERROR: Read occurred with empty queue");
            error_count++;
        end
        else begin
            if (rd_data !== expected_queue[0]) begin
                $error("DATA ERROR: Expected 0x%02h, Received 0x%02h",
                       expected_queue[0], rd_data);
                error_count++;
            end
            else begin
                $display("READ PASS: 0x%02h", rd_data);
            end

            expected_queue.pop_front();
            read_count++;
        end
    end
end

initial begin

    $dumpfile("async_fifo_random.vcd");
    $dumpvars(0, async_fifo_random_tb);

    wr_clk = 1'b0;
    rd_clk = 1'b0;

    wr_rst_n = 1'b0;
    rd_rst_n = 1'b0;

    wr_data = 8'h00;
    wr_en = 1'b0;
    rd_en = 1'b0;

    write_count = 0;
    read_count = 0;
    error_count = 0;

    #50;

    wr_rst_n = 1'b1;
    rd_rst_n = 1'b1;

    $display("ASYNC FIFO RANDOM TEST STARTED");

    fork

        begin
            repeat (TEST_COUNT) begin
                @(posedge wr_clk);

                if (!full && ($urandom_range(0, 1) == 1)) begin
                    wr_data = $urandom_range(0, 255);
                    wr_en = 1'b1;
                end
                else begin
                    wr_en = 1'b0;
                end
            end

            wr_en = 1'b0;
        end

        begin
            repeat (TEST_COUNT * 2) begin
                @(posedge rd_clk);

                if (!empty && ($urandom_range(0, 1) == 1))
                    rd_en = 1'b1;
                else
                    rd_en = 1'b0;
            end

            rd_en = 1'b0;
        end

    join

    repeat (20)
        @(posedge rd_clk);

    rd_en = 1'b1;

    repeat (DEPTH) begin
        @(posedge rd_clk);

        if (empty)
            rd_en = 1'b0;
    end

    rd_en = 1'b0;

    repeat (10)
        @(posedge rd_clk);

    $display("WRITE COUNT = %0d", write_count);
    $display("READ COUNT  = %0d", read_count);
    $display("ERROR COUNT = %0d", error_count);
    $display("REMAINING QUEUE = %0d", expected_queue.size());

    if ((error_count == 0) && (expected_queue.size() == 0))
        $display("RANDOM TEST PASSED");
    else
        $error("RANDOM TEST FAILED");

    $display("ASYNC FIFO RANDOM TEST COMPLETED");

    #100;
    $finish;

end

endmodule