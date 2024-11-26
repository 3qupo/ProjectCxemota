module runner
(
 	input clk,
 	input [7:0] b,
    output gnd_1,
 	output gnd_2,
 	output [7:0] leds
);

reg [20:0] counter=~0;
reg [7:0] counter_1 = 0;
reg [7:0] im_1 = 8'b00111101;
reg [7:0] im_2 = 8'b01001011;
reg [7:0] im = 0;
reg f = 1;
reg fi = 1;
reg pit =0;

assign gnd_1 = pit;
assign gnd_2 = !pit;
assign leds = ( pit ? im_2 : im_1 );

always @(posedge clk)
begin
 	counter <= counter + 1;
 if (!counter)
 	begin
 if((b[0]+b[1]+b[2]+b[3]+b[4]+b[5]+b[6]+b[7]==7)&&f)
begin
 f <= 0;
 			if (!b[7])
 			begin
fi <= !fi;
 			end
else
 			begin
if (fi) im_1 <= im_1^(~b);
else im_2 <= im_2^(~b);
 			end
 			im_1[7] <= fi;
im_2[7] <= !fi;
 		end
 		else f<=1;
 end
 if (counter_1 > 128)
 	begin
 		pit <= 0;
 end
 	else
 	begin
 		pit <= 1;
 	end
counter_1 <= counter_1 +1;
end

endmodule
