`timescale 1ns/1ps

module uart_tb;

    localparam CLKS_PER_BIT = 16;
    localparam CLK_PERIOD   = 10; // 100 MHz clock (10ns period)

    reg        clk;
    reg        rst_n;
    reg        tx_start;
    reg  [7:0] tx_data;
    wire       tx;
    wire       tx_busy;
    wire       tx_done;

    wire       rx;
    wire [7:0] rx_data;
    wire       rx_done;

    // Loopback: TX connects directly to RX
    assign rx = tx;

    // Instantiate Transceiver
    uart_transceiver #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .tx_busy(tx_busy),
        .tx_done(tx_done),
        .rx(rx),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    // Clock generator (100 MHz)
    always #(CLK_PERIOD / 2) clk = ~clk;

    // Task to send a byte
    task send_byte(input [7:0] data);
        begin
            @(posedge clk);
            tx_data  <= data;
            tx_start <= 1'b1;
            @(posedge clk);
            tx_start <= 1'b0;
        end
    endtask

    initial begin
        // Waveform dump for GTKWave / ModelSim
        $dumpfile("uart_waves.vcd");
        $dumpvars(0, uart_tb);

        // Initialization
        clk      = 0;
        rst_n    = 0;
        tx_start = 0;
        tx_data  = 8'd0;

        // Apply reset
        #(CLK_PERIOD * 5);
        rst_n = 1;
        #(CLK_PERIOD * 5);

        // Test 1: Send 0xA5
        $display("[%0t ns] Sending 0xA5...", $time);
        send_byte(8'hA5);

        @(posedge rx_done);
        if (rx_data === 8'hA5)
            $display("[%0t ns] SUCCESS: Received matching byte 0x%h", $time, rx_data);
        else
            $display("[%0t ns] ERROR: Expected 0xA5, got 0x%h", $time, rx_data);

        #(CLK_PERIOD * 20);

        // Test 2: Send 0x3C
        $display("[%0t ns] Sending 0x3C...", $time);
        send_byte(8'h3C);

        @(posedge rx_done);
        if (rx_data === 8'h3C)
            $display("[%0t ns] SUCCESS: Received matching byte 0x%h", $time, rx_data);
        else
            $display("[%0t ns] ERROR: Expected 0x3C, got 0x%h", $time, rx_data);

        #(CLK_PERIOD * 50);
        $display("Simulation Finished.");
        $finish;
    end

endmodule