module runner_lab
(
    output [5:0] led,               // 6 светодиодов, управляемых состояниями бита mosi_d
    input rstn,                     // cброс (активный низкий). Если rstn = 0, модуль переходит в начальное состояние
    input sys_clk,                  // cистемный тактовый сигнал, используемый для синхронизации всех процессов
    input cs,                       // cигнал выбора устройства. Если cs = 0, происходит активная передача данных
    input mosi,                     // данные, передаваемые от мастера SPI
    input sclk                      // тактовый сигнал, формируемый приёмником во время передачи данных
);

parameter reg_width = 8;                                                   // ширина регистра для хранения данных, равна 8
parameter counter_width = $clog2(reg_width);                               // ширина счётчика, автоматически вычисляется как логарифм от reg_width log_{2}8 = 3 
parameter reset = 0;                                                       // cброс внутренних регистров                                           
parameter idle = 1;                                                        // ожидание активного сигнала cs
parameter load = 2;                                                        // подготовка регистра для приёма данных
parameter transact1 = 3;                                                   // приём данных с линии mosi и их сдвиг в регистре mosi_d
parameter transact2 = 4;                                                   // приём данных с линии mosi и их сдвиг в регистре mosi_d
parameter unload = 5;                                                      // завершение передачи данных

reg [reg_width-1:0] mosi_d;                          // регистр шириной 8 бит, используется для хранения принятых данных
reg [counter_width:0] count;                         // cчётчик битов, определяет количество оставшихся для приёма бит
reg [3:0] state;                                     // текущее состояние FSM, управляет переходами между этапами
reg [2:0] led_counter;                               // cчётчик для управления светодиодами   а надо?

initial
    begin
    led_counter <= 0;   
    mosi_d <= -1;
    state <= 0;
end

always @(state)
    begin
        case (state)
          reset:
          begin
            mosi_d <= -1;
            count <= 0;
          end
          idle:
          begin
            count <= 0;
          end
          load:
          begin
            mosi_d <= -1;
            count <= reg_width;
          end
          transact1:
          begin
            mosi_d <= {mosi_d[reg_width-2:0], mosi};
            count <= count-1;
          end
          transact2:
          begin
            mosi_d <= {mosi_d[reg_width-2:0], mosi};
            count <= count-1;
          end
          unload:
          begin
            count <= 0;
          end
          default:
          begin
            count <= 0;
          end
        endcase
  end


  always @(sys_clk)
  begin
  if (!cs)
  begin
  if (count == 0)
  begin
    state = load;
    state = transact1;
  end
  else
    case(state)
        transact1:
        state = transact2;
        transact2:
        state = transact1;
    endcase
  end
  else 
    state = idle;
  end

assign sclk = ( state == transact1 || state == transact2) ? sys_clk : 1'b0;

genvar i;
generate
  for (i = 0; i < 6; i = i + 1)
  begin
    assign led[i] = (rstn ? mosi_d[7 - i] : 1);
  end
endgenerate

endmodule