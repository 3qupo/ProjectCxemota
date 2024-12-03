// cd C:\iverilog\runnerProject
// iverilog -o ./compiled ./src/runner.v
// vvp ./compiled

module runner (
    input clk,
    input rst,  // Сброс
    output reg [7:0] leds,  // Вывод на светодиоды (диагностика)
    output reg [6:0] seg1, // Первый семисегментник
    output reg [6:0] seg2, // Второй семисегментник
    output reg [6:0] seg3  // Третий семисегментник
);

// Генератор случайных чисел (LFSR)
reg [7:0] lfsr = 8'b10111001; // Инициализация LFSR
wire feedback = lfsr[7] ^ lfsr[5] ^ lfsr[4] ^ lfsr[3]; // Полином

// Счетчик для разделения тактов
reg [19:0] clk_div = 0;
wire slow_clk = clk_div[19]; // Медленный тактовый сигнал

// Регистр для случайных чисел
reg [11:0] random_number; // Три цифры случайного числа (по 4 бита каждая)

// Логика отображения числа на семисегментники
always @(posedge slow_clk or posedge rst) begin
    if (rst) begin
        lfsr <= 8'b10111001; // Сброс LFSR
        random_number <= 12'b0; // Сброс числа
    end else begin
        // Обновление LFSR
        lfsr <= {lfsr[6:0], feedback};

        // Генерация нового случайного числа
        random_number <= {lfsr[3:0], lfsr[7:4], lfsr[3:0]};
    end
end

// Декодер для семисегментников
always @* begin
    leds = lfsr; // Для диагностики на светодиодах

    seg1 = decode_digit(random_number[3:0]);   // Первая цифра
    seg2 = decode_digit(random_number[7:4]);   // Вторая цифра
    seg3 = decode_digit(random_number[11:8]);  // Третья цифра
end

// Функция декодирования цифр для семисегментника
function [6:0] decode_digit(input [3:0] digit);
    case (digit)
        4'd0: decode_digit = 7'b1000000;
        4'd1: decode_digit = 7'b1111001;
        4'd2: decode_digit = 7'b0100100;
        4'd3: decode_digit = 7'b0110000;
        4'd4: decode_digit = 7'b0011001;
        4'd5: decode_digit = 7'b0010010;
        4'd6: decode_digit = 7'b0000010;
        4'd7: decode_digit = 7'b1111000;
        4'd8: decode_digit = 7'b0000000;
        4'd9: decode_digit = 7'b0010000;
        default: decode_digit = 7'b1111111; // Пусто
    endcase
endfunction

// Делитель частоты
always @(posedge clk) begin
    clk_div <= clk_div + 1;
end

endmodule
