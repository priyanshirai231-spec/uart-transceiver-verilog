module uart_transceiver #(
    parameter CLKS_PER_BIT = 868
)(
    input        clk,
    input        rst_n,

    // TX Interface
    input        tx_start,
    input  [7:0] tx_data,
    output       tx,
    output       tx_busy,
    output       tx_done,

    // RX Interface
    input        rx,
    output [7:0] rx_data,
    output       rx_done
);

    uart_tx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) tx_inst (
        .clk(clk),
        .rst_n(rst_n),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .tx_busy(tx_busy),
        .tx_done(tx_done)
    );

    uart_rx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) rx_inst (
        .clk(clk),
        .rst_n(rst_n),
        .rx(rx),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

endmodule