// cd C:\iverilog\runnerProject
// iverilog -o ./compiled ./src/runner.v
// vvp ./compiled

module prng_display
(
    input wire clk,
    output wire gnd_1,
    output wire gnd_2,
    output wire gnd_3,
    output wire gnd_4,
    output reg [7:0] leds
);

// Генератор на основе сдвигового регистра
reg [15:0] lfsr = 16'h1234;
reg [31:0] timer = 0;
wire feedback = lfsr[15] ^ lfsr[14] ^ lfsr[12] ^ lfsr[3];

reg [7:0] segment_patterns [0:9];
reg [3:0] current_numbers [0:3];
reg [3:0] display_select = 4'b1110;
reg [15:0] display_counter = 0;

initial begin
    segment_patterns[0] = 8'b11111100;
    segment_patterns[1] = 8'b01100000;
    segment_patterns[2] = 8'b11011010;
    segment_patterns[3] = 8'b11110010;
    segment_patterns[4] = 8'b01100110;
    segment_patterns[5] = 8'b10110110;
    segment_patterns[6] = 8'b10111110;
    segment_patterns[7] = 8'b11100000;
    segment_patterns[8] = 8'b11111110;
    segment_patterns[9] = 8'b11110110;
    
    current_numbers[0] = 4'd0;
    current_numbers[1] = 4'd0;
    current_numbers[2] = 4'd0;
    current_numbers[3] = 4'd0;
end

assign gnd_1 = display_select[0];
assign gnd_2 = display_select[1];
assign gnd_3 = display_select[2];
assign gnd_4 = display_select[3];

always @(posedge clk) begin
    // Генерация новых чисел каждые ~3 секунды
    timer <= timer + 1;
    if (timer >= 27_000_000 * 3) begin  // При тактовой 27 МГц
        timer <= 0;
        lfsr <= {lfsr[14:0], feedback};
        current_numbers[0] <= lfsr[3:0] % 10;
        current_numbers[1] <= lfsr[7:4] % 10;
        current_numbers[2] <= lfsr[11:8] % 10;
        current_numbers[3] <= lfsr[15:12] % 10;
    end

    // Мультиплексирование дисплея
    display_counter <= display_counter + 1;
    case (display_counter[15:14])
        2'b00: begin
            display_select <= 4'b1110;
            leds <= segment_patterns[current_numbers[0]];
        end
        2'b01: begin
            display_select <= 4'b1101;
            leds <= segment_patterns[current_numbers[1]];
        end
        2'b10: begin
            display_select <= 4'b1011;
            leds <= segment_patterns[current_numbers[2]];
        end
        2'b11: begin
            display_select <= 4'b0111;
            leds <= segment_patterns[current_numbers[3]];
        end
    endcase
end

endmodule
