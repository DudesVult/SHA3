`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.02.2024 20:42:36
// Design Name: 
// Module Name: AXI_SHA_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module AXI_SHA_tb();
localparam WIDTH = 16;

logic ACLK;
logic ARESETn;
logic [3:0] USER;
logic [1:0] ID;
logic VALID;

logic TREADY;

logic [15:0] in_data;
logic how_to_last;

logic [15:0] out_data;
logic [4:0][4:0][63:0] D_out;
logic [7:0] i;

logic SHA_valid;
logic Mode;
logic [WIDTH-1:0] Mode_out;
logic Last;

logic Ready;

localparam FILE_IN   = "Copilot.bin";
localparam FILE_OUT      = "output.txt";

integer result;
integer file_in, file_out;
string  line_in, line_out;

int j;

wire   [0:4][0:4][63:0]  	Dout;

logic [(1600/WIDTH)-1:0][WIDTH-1:0] D_result;
logic [7:0] cnt;

logic [WIDTH-1:0] line;

int fd; // file descriptor

AXI_SHA AXI_SHA_i(.*);

always #5 ACLK = !ACLK;

// Начальные значения

initial begin

    ACLK = 1'b1;
    ARESETn = 1'b0;
    in_data = 16'd0;
    how_to_last = 1'b0;
    USER = 4'b0;		// Еще используется? Мб перенести ID сюда 
    ID = 2'd0;              // 0 - SHA3-224, 1 - SHA3-256, 2 - SHA3-384, 3 - SHA3-512
    SHA_valid = 1'b0;
	Mode = 1'b0;
	cnt = 8'b0;
    
    i = 8'b0;

    // Открытие файла и проверка 

    fd = $fopen("Copilot.bin","r");
    if (fd) $display("Success :%d", fd);
    else    $display("Error :%d", fd);
end

//// Хэш от 0

initial begin
    #50 ARESETn = 1'b1;
    USER = 4'd5;
//	 in_data = 16'd6; // 16'd0
//	 how_to_last = 1'b1;
//	 #50 SHA_valid = 1'b1;
//	 #50 SHA_valid = 1'b0;
end

//Чтение бинарного файла

always @(posedge(ACLK)) begin
    if (TREADY == 1'b1 && !$feof(fd)) begin
        if (!$feof(fd)) begin
            $fgets(line, fd);
            $display("line : %h", line, $time);
            in_data = line;
        end
        if ($feof(fd)) begin
            how_to_last = 1'b1;     // Добавить расчет last block заранее 
            #50                     // TODO: починить костыль
            SHA_valid = 1'b1;
            #20
            SHA_valid = 1'b0;
        end
    end
end


//// После расчета последнего сообщения переводит SHA в режим хранения
	
//always @(posedge ACLK) begin
//	if(Ready == 1'b1) begin
//	   SHA_valid = 1'b0;
//    end
//end

//// Не помню зачем добавил...

// initial begin
// 	forever begin
// 	#1;
// 	for (int i = 0; i<5; i++)
// 		for (int j = 0; j<5; j++)
// 			D_out[i][j] = revers_byte(Dout[i][j]);
// 	end
// end

//// Функция, которая будет ловить поток с АКС�? передатчика

//always @(posedge ACLK) begin
//    for(cnt = 0; cnt<(1600/WIDTH); cnt++) begin
//        if (Ready == 1'b1 && Last == 1'b0) begin
//            D_result [(WIDTH*cnt)-1:WIDTH*(cnt-1)] = Mode_out;
//            cnt = cnt + 1;
//        end
//        if (Ready == 1'b1 &&  Last == 1'b1) begin
//            D_result [(WIDTH*cnt)-1:WIDTH*(cnt-1)] = Mode_out;
//            cnt = cnt + 1;
//            $display("Result: %h", D_result);
//            #20 $stop;
//        end
//    end
//end
//

//// ������ ����

always @(posedge ACLK) begin
    if (Ready == 1'b1 && Last == 1'b0) begin
        cnt = cnt + 1;
        D_result [cnt-4] = Mode_out;
    end
    if (Ready == 1'b1 &&  Last == 1'b1) begin
        cnt = cnt + 1;
        D_result [cnt-4] = Mode_out;
        $display("Result: %h", D_result, $time);
        $display("Result: %h%h%h%h", D_result [0], D_result [1], D_result [2], D_result [3]);
        // print();
        #20 $stop;
    end
end
//

// ��������������� ��

//always @(posedge ACLK) begin
//	if (Ready == 1'b1 && Last == 1'b0) begin
//		D_result [(WIDTH*cnt)-1:WIDTH*(cnt-1)] = Mode_out;
//		cnt = cnt + 1;
//	end
//	if (Ready == 1'b1 &&  Last == 1'b1) begin
//		D_result [(WIDTH*cnt)-1:WIDTH*(cnt-1)] = Mode_out;
//		cnt = cnt + 1;
//		$display("Result: %h", D_result);
//		#20 $stop;
//	end
//end

// Переворачивайт порядок байт (может не понадобиться)

function logic [63:0] revers_byte(logic [63:0] data);
	logic [63:0] res;

	begin
		res = data;
		res = ((res<<32)  & 64'hFFFFFFFF00000000)|((res>>32) & 64'h00000000FFFFFFFF);
		res = ((res<<16)  & 64'hFFFF0000FFFF0000)|((res>>16) & 64'h0000FFFF0000FFFF);
		res = ((res<<8)   & 64'hFF00FF00FF00FF00)|((res>>8)  & 63'h00FF00FF00FF00FF);
		return res;
	end
endfunction  

// Функция для вывода правильного хэша в терминал

task print;
	file_out = $fopen(FILE_OUT, "w");
	$display("Hash from function: %h%h%h%h", revers_byte(Dout[0][0]), revers_byte(Dout[1][0]), revers_byte(Dout[2][0]), revers_byte(Dout[3][0]));
	$display("%h%h%h%h", revers_byte(Dout[4][0]), revers_byte(Dout[0][1]), revers_byte(Dout[1][1]), revers_byte(Dout[2][1]));
	$sformat(line_out, "%h%h%h%h", revers_byte(Dout[0][0]), revers_byte(Dout[1][0]), revers_byte(Dout[2][0]), revers_byte(Dout[3][0]));
	$fwrite(file_out, "%s\n", line_out);
	$fclose(file_out);
	# 10 $stop;
endtask
	
endmodule 