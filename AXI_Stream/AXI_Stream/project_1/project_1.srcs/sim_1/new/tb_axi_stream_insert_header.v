`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/11 17:49:18
// Design Name: 
// Module Name: tb_axi_stream_insert_header
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


module tb_axi_stream_insert_header();
reg clk;
reg rst_n;
reg valid_in;
reg [31:0]  data_in;
reg [3:0]   keep_in;
reg         last_in;
wire        ready_in;
wire    valid_out;
wire [31:0]   data_out ;
wire [3:0]   keep_out ;
wire    last_out ;
reg     ready_out;
reg     valid_insert   ;
reg [31:0]    header_insert  ;
reg  [3:0]   keep_insert    ;
reg  [2:0]   byte_insert_cnt;
wire         ready_insert;

always #5 clk = ~clk;

initial
    begin
        clk = 1'b1;
        rst_n = 1'b0;
        valid_in = 1'b0;
        data_in = 1'b0;
        keep_in = 1'b0;
        last_in = 1'b0;
        ready_out = 1'b0;
        valid_insert = 1'b0;
        header_insert = 1'b0;
        keep_insert = 1'b0;
        byte_insert_cnt = 1'b0;
   
        #100
        rst_n = 1'b1;
        #200
        ready_out = 1'b1;
        
        #20
        valid_in = 1'b1;
        data_in = 32'hA0B0C0D0;
        keep_in = 4'b1111;
        
        valid_insert = 1'b1;   
        header_insert = 32'hF0E0D0C0;  
        keep_insert = 4'b0111;    
        byte_insert_cnt = 3'd3;
        #10
        valid_insert = 1'b0;   
        header_insert = 32'h0;  
        keep_insert = 4'b0;    
        byte_insert_cnt = 3'd0;

        wait(ready_in && valid_in)
        valid_in = 1'b0;
        data_in = 32'h0;
        keep_in = 4'b0;
        #50
        
        valid_in = 1'b1;
        data_in = 32'h10203040;
        keep_in = 4'b1111;
        #10
        wait(ready_in && valid_in)
        valid_in = 1'b0;
        data_in = 32'h0;
        keep_in = 4'b0;
        #50
        valid_in = 1'b1;
        data_in = 32'h50607080;
        keep_in = 4'b1111;
        last_in = 1'b1;
        #10
        wait(ready_in)
        valid_in = 1'b0;
        data_in = 32'h0;
        keep_in = 4'b0;
        last_in = 1'b0;
        #500
        
        valid_in = 1'b1;
        data_in = 32'hA0B0C0D0;
        keep_in = 4'b1111;
        
        valid_insert = 1'b1;   
        header_insert = 32'hF0E0D0C0;  
        keep_insert = 4'b0011;    
        byte_insert_cnt = 3'd2;
        #10
        valid_insert = 1'b0;   
        header_insert = 32'h0;  
        keep_insert = 4'b0;    
        byte_insert_cnt = 3'd0;

        wait(ready_in && valid_in)
        valid_in = 1'b0;
        data_in = 32'h0;
        keep_in = 4'b0;
        #50
        
        valid_in = 1'b1;
        data_in = 32'h10203040;
        keep_in = 4'b1111;
        #10
        wait(ready_in && valid_in)
        valid_in = 1'b0;
        data_in = 32'h0;
        keep_in = 4'b0;
        #50
        valid_in = 1'b1;
        data_in = 32'h50607080;
        keep_in = 4'b1110;
        last_in = 1'b1;
        #10
        wait(ready_in)
        valid_in = 1'b0;
        data_in = 32'h0;
        keep_in = 4'b0;
        last_in = 1'b0;
     end   

//always@(posedge clk)
//    if(!rst_n)begin
//        valid_insert <= 1'b1;
//        keep_insert <= 4'b0111;
//        header_insert <= 32'hF0E0D0C0;
//        byte_insert_cnt <= 3'd3;
//    end
//    else if(ready_insert)begin
//        valid_insert <= 1'b0;
//        keep_insert <= 1'b0;
//        header_insert <= 1'b0;
//        byte_insert_cnt <= 1'b0;
//    end
//    else    begin
//        valid_insert <= valid_insert;
//        keep_insert <= keep_insert;
//        header_insert <= header_insert;
//        byte_insert_cnt <= byte_insert_cnt;
//    end

//reg [4:0] cnt;

//always@(posedge clk)
//    if(!rst_n)begin
//        cnt <= 1'b0;
//        valid_in <= 1'b1;
//        data_in <= 32'hA0B0C0D0;
//    end
//    else if(ready_in)begin
//        cnt <= cnt + 1'b1;
//        valid_in <= 1'b0;
//        case(cnt)
//            0:
//                data_in <= 32'h10203040;
//            5:
//                data_in <= 32'h50607080;
//            10:
//                data_in <= 32'he0f0a0c0;
//            15:
//                data_in <= 32'h51617181;
//            default:data_in <= 32'h10203040;
//            endcase
//     end
//     else   begin
//        cnt <= cnt;
//        valid_in <= valid_in;
//        data_in <= data_in;
//     end
        


axi_stream_insert_header 
axi_stream_insert_header
(
.clk             (clk  )                         ,
.rst_n           (rst_n)                         ,
                 
                 
.valid_in        (valid_in)                         ,
.data_in         (data_in )         ,
.keep_in         (keep_in )    ,
.last_in         (last_in )                         ,
.ready_in       (ready_in)                         ,
                 
                 
. valid_out      (valid_out)                         ,
. data_out       (data_out )                  ,
. keep_out       (keep_out )                  ,
. last_out       (last_out )                         ,
.ready_out       (ready_out)                         ,
                 
                 
.valid_insert    (valid_insert   )                         ,
.header_insert   (header_insert  )         ,
.keep_insert     (keep_insert    )    , // 4'b0111
.byte_insert_cnt (byte_insert_cnt)       ,  // 3
. ready_insert   (ready_insert)
);


endmodule
