// cd C:\iverilog\runnerProject
// iverilog -o ./compiled ./src/runner.v
// vvp ./compiled

module random_display (
    input wire clk,          // Входной тактовый сигнал
    output wire gnd_1,       // Общий катод для первого разряда
    output wire gnd_2,       // Общий катод для второго разряда
    output wire gnd_3,       // Общий катод для третьего разряда
    output wire gnd_4,       // Общий катод для четвертого разряда
    output reg [7:0] leds    // Выходы для сегментов (a-g и точка)
);

// Регистры для LFSR генератора случайных чисел
reg [31:0] lfsr = 32'hABCD1234;  // Начальное значение
wire feedback = lfsr[31] ^ lfsr[21] ^ lfsr[1] ^ lfsr[0];

// Регистры для хранения чисел каждого разряда
reg [3:0] digit1 = 4'd0;
reg [3:0] digit2 = 4'd0;
reg [3:0] digit3 = 4'd0;
reg [3:0] digit4 = 4'd0;

// Регистры для мультиплексирования разрядов
reg [1:0] digit_select = 2'b00;
reg [31:0] refresh_counter = 32'd0;
reg [31:0] update_counter = 32'd0;

// Массив с кодировкой цифр для семисегментного индикатора
// Формат: {dp,g,f,e,d,c,b,a}, где 0 - сегмент горит
reg [7:0] seven_seg [0:9];

initial begin
    // Инициализация кодировки цифр
    seven_seg[0] = 8'b01001000;  // 0
    seven_seg[1] = 8'b11110100;  // 1
    seven_seg[2] = 8'b00011010;  // 2
    seven_seg[3] = 8'b10010000;  // 3
    seven_seg[4] = 8'b10101100;  // 4
    seven_seg[5] = 8'b10000001;  // 5
    seven_seg[6] = 8'b00001001;  // 6
    seven_seg[7] = 8'b11010100;  // 7
    seven_seg[8] = 8'b00001000;  // 8
    seven_seg[9] = 8'b10000000;  // 9
end

// Управление общими катодами (активный низкий уровень)
reg [3:0] digit_enable;
assign gnd_1 = digit_enable[0];
assign gnd_2 = digit_enable[1];
assign gnd_3 = digit_enable[2];
assign gnd_4 = digit_enable[3];

// Генерация случайных чисел и обновление разрядов
always @(posedge clk) begin
    // Счетчик для обновления случайных чисел (примерно раз в секунду)
    update_counter <= update_counter + 1;
    if (update_counter >= 27_000_000) begin  // Для тактовой частоты 27 МГц
        update_counter <= 0;
        
        // Обновление LFSR
        lfsr <= {lfsr[30:0], feedback};
        
        // Генерация новых случайных чисел для каждого разряда
        digit1 <= lfsr[3:0] % 10;
        digit2 <= lfsr[7:4] % 10;
        digit3 <= lfsr[11:8] % 10;
        digit4 <= lfsr[15:12] % 10;
    end

    // Мультиплексирование разрядов
    refresh_counter <= refresh_counter + 1;
    if (refresh_counter >= 13_500) begin  // Частота обновления ~2кГц
        refresh_counter <= 0;
        digit_select <= digit_select + 1;
        
        case(digit_select)
            2'b00: begin
                digit_enable <= 4'b1110;  // Активируем первый разряд
                leds <= seven_seg[digit1];
            end
            2'b01: begin
                digit_enable <= 4'b1101;  // Активируем второй разряд
                leds <= seven_seg[digit2];
            end
            2'b10: begin
                digit_enable <= 4'b1011;  // Активируем третий разряд
                leds <= seven_seg[digit3];
            end
            2'b11: begin
                digit_enable <= 4'b0111;  // Активируем четвертый разряд
                leds <= seven_seg[digit4];
            end
        endcase
    end
end

endmodule