module uart_tx #(
    parameter CLKS_PER_BIT = 868 // e.g., 100MHz clock / 115200 baud ~= 868
)(
    input            clk,
    input            rst_n,
    input            tx_start,
    input      [7:0] tx_data,
    output reg       tx,
    output reg       tx_busy,
    output reg       tx_done
);

    localparam IDLE  = 3'b000;
    localparam START = 3'b001;
    localparam DATA  = 3'b010;
    localparam STOP  = 3'b011;
    localparam CLEAN = 3'b100;

    reg [2:0]  state;
    reg [15:0] clk_count;
    reg [2:0]  bit_index;
    reg [7:0]  data_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            tx        <= 1'b1; // Idle line is HIGH
            tx_busy   <= 1'b0;
            tx_done   <= 1'b0;
            clk_count <= 16'd0;
            bit_index <= 3'd0;
            data_reg  <= 8'd0;
        end else begin
            case (state)
                IDLE: begin
                    tx        <= 1'b1;
                    tx_done   <= 1'b0;
                    clk_count <= 16'd0;
                    bit_index <= 3'd0;
                    if (tx_start) begin
                        tx_busy  <= 1'b1;
                        data_reg <= tx_data;
                        state    <= START;
                    end else begin
                        tx_busy  <= 1'b0;
                    end
                end

                START: begin
                    tx <= 1'b0; // Start bit is LOW
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1'b1;
                    end else begin
                        clk_count <= 16'd0;
                        state     <= DATA;
                    end
                end

                DATA: begin
                    tx <= data_reg[bit_index];
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1'b1;
                    end else begin
                        clk_count <= 16'd0;
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1'b1;
                        end else begin
                            bit_index <= 3'd0;
                            state     <= STOP;
                        end
                    end
                end

                STOP: begin
                    tx <= 1'b1; // Stop bit is HIGH
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1'b1;
                    end else begin
                        clk_count <= 16'd0;
                        tx_done   <= 1'b1;
                        state     <= CLEAN;
                    end
                end

                CLEAN: begin
                    tx_done <= 1'b0;
                    tx_busy <= 1'b0;
                    state   <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule