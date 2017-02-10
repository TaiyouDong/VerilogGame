`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// Create Date:    17:11:22 01/05/2016 
// Design Name: 
// Module Name:    draw_demon1 
// Project Name: 	 Demon
/*

��ģ��Ϊ����ʵ�ֵ���Ҫģ�飬ʵ�ֵĹ����У�
1. Demon�ͱ���ͼƬ��ʱ����ʾ
2.С�����ƶ�ʱͼƬ�Ľ������
3.С��������Ծ�Ϳ����ٶȵĸı�
4.����ͼƬ���ϰ�����ƶ�
5.С�������ϰ������ײ���
6.��Ϸ����ͣ�����ù���
7.����ʱ������ӣ��ϰ����ƶ��ٶȼӿ�Ĺ���

ps����ģ�����ͼƬ�ĵ��ú���ʾ������ROMʵ��
*/

//////////////////////////////////////////////////////////////////////////////////
module draw_demon1(
	input clk,				//ϵͳ50mhzʱ���ź�
	input [9:0]h_count,	//��Ӧ��Ļ��ʾ�ĺ�����
	input [9:0]v_count,	//��Ӧ��Ļ��ʾ��������
	input video,
	input jump,				//С������Ծ����
	input clr,
	input reset,			//���ò���
	input shut,				//��ͣ����
	input clk_1ms, 		//��Ӧʱ��ģ�������ʱ���źţ�����ʱ����Ƶ�·
	input clk_5ms,
	input clk_01ms,
	input clk_100ms,
	input clk_10ms,
	output  reg red,
	output  reg green,
	output  reg blue
    );

reg [10:0]x,y;
reg collision,collision1;				//�ж���Ϸ�Ƿ����
parameter x1 = 120,x2 = 180;			//Demon�ĺ�����
parameter y1 = 270,y2 = 330;			//Demon�ĳ�ʼ������
parameter V0 = 82,delta = 1;			//Demon�ĳ�ʼ�ٶ����ڿ��еļ��ٶ�
parameter X_over = 120;
parameter Y_over = 130;					//����ͼƬ�ĺ�������
parameter Y_ground1 = 267,Y_ground2 = 310,Y_tree1 = 250,Y_tree2 = 268;//�������ϰ����������
integer V,count,diff,count1;			
integer ground,tree1,X_tree1,X_tree2,X_cloud1,X_cloud2,X_cloud3,Y_cloud1,Y_cloud2,Y_cloud3;

reg [10:0] Y, S,high_ground1,high_ground2,x_t1,y_t1,x_c1,x_c2,x_c3,y_c1,y_c2,y_c3,x_t2,y_t2,x_v,y_v;
reg [11:0] addr;
reg high,mode,draw_demon1,draw_demon2,in_ground1,in_ground2,in_tree1,in_tree2,in_cloud,in_cloud2,in_over;//in_cloud3;
wire [0:0] color1;
wire [0:0] color2;
wire [0:0] color_ground1,color_ground2,color_tree1,color_tree2,color_cloud,color_cloud2,color_over;//color_cloud3;
wire [15:0] show_ground1,show_ground2;
reg [14:0]show_over;
reg [15:0] show_tree1,show_tree2;
reg[12:0] show_cloud,show_cloud2;//show_cloud3;
reg clk_game;

initial begin
Y = y1;//YΪ�������ڵ�λ��
V = 0;
mode = 0;
count = 0;
draw_demon1 = 0;
ground = 0;
X_tree1 = 1200;
X_tree2 = 900;
collision = 0;
collision1 = 0;
Y_cloud1 = 50;X_cloud2 = 500;
Y_cloud1 = 110;X_cloud2 = 100;
diff = 60;
count = 0;
count1 = 0;
end


Demon1    Rom1(.clka(clk),.addra(addr),.douta(color1));						//DemonͼƬ1
Demon2    Rom2(.clka(clk),.addra(addr),.douta(color2));						//DemonͼƬ2������ͼƬ������ʾ�����ɶ�̬ͼ
ground 	 Rom3(.clka(clk),.addra(show_ground1),.douta(color_ground1));	//�����������ʾ
trees1 	 Rom5(.clka(clk),.addra(show_tree1),.douta(color_tree1));		//�ϰ���1��ʾ
clouds 	 Rom6(.clka(clk),.addra(show_cloud),.douta(color_cloud));		//��Ӱ�Ʋʵ���ʾ
trees2 	 Rom9(.clka(clk),.addra(show_tree2),.douta(color_tree2));		//�ϰ���2��ʾ
game_over Rom10(.clka(clk),.addra(show_over),.douta(color_over));			//��Ϸ����ͼƬ��ʾ

always@(posedge clk_100ms)begin//mode�����ж�С������������̬��mode == 1��ʾͼƬ1��mode == 2��ʾͼƬ2
	if(shut == 1 || collision1 == 1) //�ж���Ϸ�Ƿ��������ͣ
		mode = mode;
	else mode = ~mode;
end

always@(posedge clk_01ms)begin//clk_game������Ƶ����diff���ƣ�cllk_game���Ʊ������ƶ��ٶ�
	count = count + 1;
	if(count >= diff)begin
		count  = 0;
		clk_game = 1;
	end
	else begin
		clk_game = 0;
	end
end

always@(posedge clk_100ms)begin //diff����Ϸʱ������Ӷ����٣��Ӷ�ʹclk_gameƵ��Խ��Խ��
	count1 = count1 + 1;			  //ͨ����diff��difficult���ĸı����ı䱳�����ƶ��ٶȣ�����������Ϸ�Ѷ�
	if(reset == 1)begin
		diff = 60;
	end else
	if(count1 >= 50)begin
		count1 = 0;
		if(diff > 20)
			diff = diff - 4;
		else diff = diff;
	end
end

always@(posedge clk_game)begin//�������Ʊ����ƶ���ʱ�ӣ�clk_game�����Ʊ������ƶ��ٶ�
if(clr == 1)begin					//��������
		ground = 0;
		X_tree1 = 1200;
		X_tree2 = 900;
	end
else begin
	if(shut == 1 || collision1 == 1)begin   //�ж���Ϸ�Ƿ��������ͣ
		ground = ground;
	end else if(reset == 1)begin
		ground = 64;
	end
	else if(ground <= 576)						//groundΪ���Ʊ�����ʾ��ָ�룬groundΪ������ʾ�Ŀ�ʼλ��
		ground = ground + 1;
	else ground = 64;
	
	if(reset == 1)
		X_tree1 = 1200;
	else if(shut == 1 || collision1 == 1)begin		//�ж���Ϸ�Ƿ��������ͣ
		X_tree1 = X_tree1;
	end
	else if(X_tree1 > 0 )
		X_tree1 = X_tree1 -1;								//���������ϰ����ѭ���ƶ�
	else X_tree1 = 1200;
	
	 if(reset == 1)											//��λ����
		X_tree2 = 900;
	else if(shut == 1 || collision1 == 1)begin		//�ж���Ϸ�Ƿ��������ͣ
		X_tree2 = X_tree2;
	end
	else if(X_tree2 > 0 )
		X_tree2 = X_tree2 -1;
	else X_tree2 = 900;
	
	if(reset == 1)begin										//��λ����
		X_cloud1 = 800;
		X_cloud2 = 700;
	end else
	if(shut == 1 || collision1 == 1)begin				//�ж���Ϸ�Ƿ��������ͣ
		X_cloud1 = X_cloud1;
		X_cloud2 = X_cloud2;
		//X_cloud3 = X_cloud3;
	end 
	else begin
		if(X_cloud1 > 0 )
			X_cloud1 = X_cloud1 -1;							//�Ʋʵ�ѭ���ƶ�
		else X_cloud1 = 800;
		if(X_cloud2 > 0)
			X_cloud2 = X_cloud2 - 1;
		else X_cloud2 = 700;
		/*if(X_cloud3 > 0)
			X_cloud3 = X_cloud3 - 1;
		else X_cloud3 = 600;*/
	end
end
end

assign show_ground1 = (high_ground1*640 + (ground+h_count)%512);			//��ʾ�����ƶ���ָ�룬ROM������
assign show_ground2 = (high_ground2*640 + (ground+h_count)%512);


always@(*)begin 
if(h_count >= x1 && h_count < x2 && v_count >= Y && v_count < Y+60)begin//�ж��Ƿ�����ʾ������λ��
		y = v_count - Y;
		x = h_count - x1;
		addr = y * 60 + x;
		if(mode == 1 || high == 1)begin//ͨ��mode����draw_demon1��draw_demon2����������С��������ʾ
			draw_demon1 = 1;
			draw_demon2 = 0;
		end 
		else begin
			draw_demon2 = 1;
			draw_demon1 = 0;
		end
end
else begin
	draw_demon1 = 0;						//���������ʾ���������Ϊ0
	draw_demon2 = 0;
end

if(v_count >= Y_ground1 && v_count < Y_ground1+60 && h_count >= 1 && h_count <= 640)begin//�ж��Ƿ�����ʾ��1��λ��
	in_ground1 = 1;
	high_ground1 = v_count - Y_ground1;						
end
else begin
	in_ground1 = 0;
end


if(v_count >= Y_tree1 && v_count <Y_tree1+100 && h_count >= X_tree1 && h_count <= X_tree1+70 && h_count >= 1 && h_count <= 640)begin//�ж��Ƿ�����ʾ��1��λ��
	in_tree1= 1;
	x_t1 = h_count - X_tree1;
	y_t1 = v_count - Y_tree1;
	show_tree1   = (y_t1 * 70 + x_t1);		//ROM�������
end
else begin
	in_tree1 = 0;
end

if(v_count >= Y_tree2 && v_count <Y_tree2+60 && h_count >= X_tree2 && h_count <= X_tree2+70 && h_count >= 1 && h_count <= 640)begin//�ж��Ƿ�����ʾ��1��λ��
	in_tree2= 1;
	x_t2 = h_count - X_tree2;
	y_t2 = v_count - Y_tree2;
	show_tree2  = (y_t2 * 70 + x_t2);		//ROM�������
end
else begin
	in_tree2 = 0;
end

//�ж��Ƿ�����ʾ�Ʋʵ�λ��
if(v_count >= Y_cloud1 && v_count < Y_cloud1 +70 && h_count >= X_cloud1 && h_count < X_cloud1+100 && h_count >= 1 && h_count <= 640)begin
	in_cloud = 1;
	x_c1 = h_count - X_cloud1;
	y_c1 = v_count - Y_cloud1;
	show_cloud = (y_c1 * 100 + x_c1);		//ROM�������
end else
if(v_count >= Y_cloud2 && v_count < Y_cloud2 +70 && h_count >= X_cloud2 && h_count < X_cloud2+100 && h_count >= 1 && h_count <= 640)begin
	in_cloud = 1;
	x_c2 = h_count - X_cloud2;
	y_c2 = v_count - Y_cloud2;
	show_cloud = (y_c2 * 100 + x_c2);		//ROM�������
end
else begin
	in_cloud = 0;
end

//�ж��Ƿ�����ʾ���������λ��
if(v_count >= Y_over && v_count < Y_over+70 && h_count >= X_over && h_count < X_over+400)begin
	in_over = 1;
	x_v = h_count - X_over;
	y_v = v_count - Y_over;
	show_over = y_v * 400 + x_v;				//ROM�������
end
else in_over = 0;

red = 0;blue = 0;green = 0;					//vga��ʾ�ĳ�ʼ��
 
if(video == 1) begin
	red = 1;
	green = 1;
	blue = 1;
end


if(in_tree1 == 1)begin							//�������ʾ�������rgb��ֵ
	if(color_tree1[0] == 0)begin				//ROM���
		red =0;
		green =0;
		blue = 0;
	end 
end else if(in_tree2 == 1)begin
	if(color_tree2[0] == 0)begin
		red = 0;green = 0;blue= 0;
	end
end

if(draw_demon1 == 1 )begin							//�������ʾ�������rgb��ֵ
		if(color1[0] == 0)begin						//ROM���
				red = 0;
				green = 0;
				blue = 0;
		end
end else if(draw_demon2 == 1  )begin
			if(color2[0] == 0) begin
						red = 0;
						green = 0;
						blue =0;
					end
end

if(in_ground1 == 1)begin							//�������ʾ�������rgb��ֵ
	if(color_ground1[0] == 0)begin				//ROM���
		red = color_ground1[0];
		green = color_ground1[0];
		blue = color_ground1[0];
	end
end else if(in_ground2 == 1)begin
	if(color_ground2[0] == 0)begin
		red = color_ground2[0];
		green = color_ground2[0];
		blue = color_ground2[0];
	end
end

if(in_cloud == 1)begin							//�������ʾ�������rgb��ֵ
	if(color_cloud[0] ==0)begin				//ROM���
		red = 0;green = 0;blue = 0;
	end
end
//���С������ײ��ģ�飬ѡȡ�����������жϣ�����ѡȡС������5�����������ʶ��
if((x1+53 >= X_tree1 + 20) &&( x1 + 53 <= X_tree1 +53) &&( Y + 17 >= Y_tree1 + 14))
		collision1 = 1;
else if((Y +57 >= Y_tree1 + 14) && (x1 + 35 <= X_tree1 +53 )&& (x1 +35 >= X_tree1 + 20))
		collision1 = 1;
else if	((Y + 57>= Y_tree1 + 14) && (x1 + 19 <= X_tree1 +53 )&&( x1+ 19 >= X_tree1 + 20))
		collision1 = 1;
else if ((Y + 36>= Y_tree1 + 14) && (x1 + 8  <= X_tree1 +53 )&& (x1 +8  >= X_tree1 + 20))
	collision1 = 1;
else if(  (Y + 37 >= Y_tree1 + 14) && (x1 + 21 <= X_tree1 + 53) && (x1 + 21 >= X_tree1 + 20))
	collision1 = 1;
else if( (Y + 17 >= Y_tree2 + 7 ) && (x1 + 53 >= X_tree2 + 11) && (x1 + 53 <= X_tree2 + 57))
	collision1 = 1;
else if( (Y+57 >= Y_tree2 + 7) && (x1 + 35 >= X_tree2 + 11 ) && (x1 + 35 <= X_tree2 + 57))
	collision1 = 1;
else if( (Y+57 >= Y_tree2 + 7) && (x1 + 19 >= X_tree2 + 11 ) && (x1 + 19 <= X_tree2 + 57))
	collision1 = 1;
else if( (Y+36 >= Y_tree2 + 7) && (x1 + 8 >= X_tree2  + 11)  && (x1 + 8 <= X_tree2 + 57))
	collision1 = 1;
else if( (Y+37 >= Y_tree2 + 7) && (x1 + 21 >= X_tree2 + 11) && (x1 + 21 <= X_tree2 + 57))
	collision1 = 1;
else collision1 = 0;

if(collision1 == 1)begin		//�����Ϸ����������ʾ��game over��
	if(in_over == 1)begin
		red = color_over[0];
		blue = color_over[0];
		green = color_over[0];
	end
end

//����Ļ����Ϳ�ɺ�ɫ
if(((h_count >= 0 && h_count <= 64 )||(h_count >= 576 && h_count <= 640))&& v_count >= 0 && v_count <= 480 )begin
	red = 0;
	green = 0;
	blue = 0;
end


end



always@(posedge clk_5ms)begin//С����������ڿ��е�ʱ�����
if(clr == 1)begin				  //��λ���������
	V = 0;
	Y = y1;
end
else begin
	if(jump == 1)begin
		if(Y == y1)begin
			V = V0;
			high = 1;
		end
	end
	else if(Y == y1 && V == 0)
		high = 0;
		
		
	if(high == 1)begin
		if(reset == 1)begin
			V = 0;
			Y = y1;
		end else
		if(shut == 1 || collision1 == 1)begin		//�ж���Ϸ�Ƿ��������ͣ
			S = S;
			Y = Y;
			V = V;
		end 
		else if(V > -V0)begin
			S = (V0*V0 - V*V)/32;						//���ù�ʽ���С������λ�ú��ٶ�				
			Y = y1 - S;
			V = V - delta;
		end
		else begin
			V = 0;
			Y = y1;
		end
	end
end
end


endmodule
