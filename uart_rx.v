module uart_rx #(
    parameter CLKS_PER_BIT = 868
)(
    input            clk,
    input            rst_n,
    input            rx,
    output reg [7:0] rx_data,
    output reg       rx_done
);

    localparam IDLE  = 3'b000;
    localparam START = 3'b001;
    localparam DATA  = 3'b010;
    localparam STOP  = 3'b011;
    localparam CLEAN = 3'b100;

    reg [2:0]  state;
    reg [15:0] clk_count;
    reg [2:0]  bit_index;
    reg [7:0]  rx_byte;

    // Double flop synchronization for RX line
    reg rx_sync_1, rx_sync;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_sync_1 <= 1'b1;
            rx_sync   <= 1'b1;
        end else begin
            rx_sync_1 <= rx;
            rx_sync   <= rx_sync_1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            rx_done   <= 1'b0;
            rx_data   <= 8'd0;
            clk_count <= 16'd0;
            bit_index <= 3'd0;
            rx_byte   <= 8'd0;
        end else begin
            case (state)
                IDLE: begin
                    rx_done   <= 1'b0;
                    clk_count <= 16'd0;
                    bit_index <= 3'd0;
                    // Detect start bit (Falling edge to 0)
                    if (rx_sync == 1'b0) begin
                        state <= START;
                    end
                end

                // Sample in middle of start bit to ensure valid bit
                START: begin
                    if (clk_count == (CLKS_PER_BIT - 1) / 2) begin
                        if (rx_sync == 1'b0) begin
                            clk_count <= 16'd0;
                            state     <= DATA;
                        end else begin
                            state <= IDLE; // False start bit
                        end
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                // Sample in middle of each data bit
                DATA: begin
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1'b1;
                    end else begin
                        clk_count          <= 16'd0;
                        rx_byte[bit_index] <= rx_sync;
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1'b1;
                        end else begin
                            bit_index <= 3'd0;
                            state     <= STOP;
                        end
                    end
                end

                STOP: begin
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1'b1;
                    end else begin
                        rx_done   <= 1'b1;
                        rx_data   <= rx_byte;
                        clk_count <= 16'd0;
                        state     <= CLEAN;
                    end
                end

                CLEAN: begin
                    rx_done <= 1'b0;
                    state   <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule