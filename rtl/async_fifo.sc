module async_fifo #(
    parameter int DATA_WIDTH = 8,
    parameter int ADDR_WIDTH = 4
) (
    input  logic                  wr_clk,
    input  logic                  rd_clk,
    input  logic                  wr_rst_n,
    input  logic                  rd_rst_n,

    input  logic [DATA_WIDTH-1:0] wr_data,
    input  logic                  wr_en,
    output logic                  full,

    output logic [DATA_WIDTH-1:0] rd_data,
    input  logic                  rd_en,
    output logic                  empty
);

    localparam int DEPTH = 1 << ADDR_WIDTH;

    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    logic [ADDR_WIDTH:0] wr_ptr_bin;
    logic [ADDR_WIDTH:0] wr_ptr_gray;

    logic [ADDR_WIDTH:0] rd_ptr_bin;
    logic [ADDR_WIDTH:0] rd_ptr_gray;

    logic [ADDR_WIDTH:0] rd_ptr_gray_sync1;
    logic [ADDR_WIDTH:0] rd_ptr_gray_sync2;

    logic [ADDR_WIDTH:0] wr_ptr_gray_sync1;
    logic [ADDR_WIDTH:0] wr_ptr_gray_sync2;

    logic [ADDR_WIDTH:0] wr_ptr_bin_next;
    logic [ADDR_WIDTH:0] wr_ptr_gray_next;

    logic [ADDR_WIDTH:0] rd_ptr_bin_next;
    logic [ADDR_WIDTH:0] rd_ptr_gray_next;

    logic full_next;
    logic empty_next;

    assign wr_ptr_bin_next = wr_ptr_bin + ((wr_en && !full) ? 1'b1 : 1'b0);

    assign wr_ptr_gray_next =
        (wr_ptr_bin_next >> 1) ^ wr_ptr_bin_next;

    assign rd_ptr_bin_next = rd_ptr_bin + ((rd_en && !empty) ? 1'b1 : 1'b0);

    assign rd_ptr_gray_next =
        (rd_ptr_bin_next >> 1) ^ rd_ptr_bin_next;

    assign full_next =
        (wr_ptr_gray_next == {
            ~rd_ptr_gray_sync2[ADDR_WIDTH:ADDR_WIDTH-1],
             rd_ptr_gray_sync2[ADDR_WIDTH-2:0]
        });

    assign empty_next =
        (rd_ptr_gray_next == wr_ptr_gray_sync2);

    always_ff @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            wr_ptr_bin  <= '0;
            wr_ptr_gray <= '0;
            full        <= 1'b0;
        end
        else begin
            if (wr_en && !full)
                mem[wr_ptr_bin[ADDR_WIDTH-1:0]] <= wr_data;

            wr_ptr_bin  <= wr_ptr_bin_next;
            wr_ptr_gray <= wr_ptr_gray_next;
            full        <= full_next;
        end
    end

    always_ff @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            rd_ptr_bin  <= '0;
            rd_ptr_gray <= '0;
            rd_data     <= '0;
            empty       <= 1'b1;
        end
        else begin
            if (rd_en && !empty)
                rd_data <= mem[rd_ptr_bin[ADDR_WIDTH-1:0]];

            rd_ptr_bin  <= rd_ptr_bin_next;
            rd_ptr_gray <= rd_ptr_gray_next;
            empty       <= empty_next;
        end
    end

    always_ff @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            rd_ptr_gray_sync1 <= '0;
            rd_ptr_gray_sync2 <= '0;
        end
        else begin
            rd_ptr_gray_sync1 <= rd_ptr_gray;
            rd_ptr_gray_sync2 <= rd_ptr_gray_sync1;
        end
    end

    always_ff @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            wr_ptr_gray_sync1 <= '0;
            wr_ptr_gray_sync2 <= '0;
        end
        else begin
            wr_ptr_gray_sync1 <= wr_ptr_gray;
            wr_ptr_gray_sync2 <= wr_ptr_gray_sync1;
        end
    end

endmodule 