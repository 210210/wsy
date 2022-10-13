`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/10 11:19:51
// Design Name: 
// Module Name: axi_stream_insert_header
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
// 没有想到通用的方法，只写了位宽为32的，对于64bit、16bit等情况目前想到的
// 只有对不同的情况进行case

module axi_stream_insert_header #(
parameter DATA_WD = 32,
parameter DATA_BYTE_WD = DATA_WD / 8,
parameter BYTE_CNT_WD = $clog2(DATA_BYTE_WD)
) (
input clk,
input rst_n,

// AXI Stream input original data
input valid_in,
input [DATA_WD-1 : 0] data_in,
input [DATA_BYTE_WD-1 : 0] keep_in,
input last_in,
output ready_in,

// AXI Stream output with header inserted
output valid_out,
output [DATA_WD-1 : 0] data_out,
output [DATA_BYTE_WD-1 : 0] keep_out,
output last_out,
input ready_out,

// The header to be inserted to AXI Stream input
input valid_insert,
input [DATA_WD-1 : 0] header_insert,
input [DATA_BYTE_WD-1 : 0] keep_insert, // 4'b0111
input [BYTE_CNT_WD : 0] byte_insert_cnt,  // 3
output ready_insert
);

// header inserted
reg ready_insert_delay;
reg [DATA_WD-1 : 0] header_insert_delay;
reg [DATA_BYTE_WD-1 : 0] keep_insert_delay;
reg [3 : 0] byte_insert_cnt_delay;
wire    [6:0] Data_Bit;
assign  ready_insert = ready_insert_delay;
assign  Data_Bit = byte_insert_cnt_delay << 3; //  2*8=16

always@(posedge clk)
    if(!rst_n)
        ready_insert_delay <= 1'b1;
    else if(valid_insert && ready_insert_delay)
        ready_insert_delay <= 1'b0;
    else if(last_out)
        ready_insert_delay <= 1'b1;
    else
        ready_insert_delay <= ready_insert_delay;

always@(posedge clk)
    if(!rst_n)begin
        header_insert_delay <= 1'b0;
        keep_insert_delay <= 1'b0;
        byte_insert_cnt_delay <= 1'b0;
    end
    else if(valid_insert && ready_insert_delay)begin
        header_insert_delay <= header_insert;
        keep_insert_delay <= keep_insert;
        byte_insert_cnt_delay <= byte_insert_cnt;
    end    
    else    begin
        header_insert_delay <= header_insert_delay;
        keep_insert_delay <= keep_insert_delay;
        byte_insert_cnt_delay <= byte_insert_cnt_delay;
    end


// data
wire    [36:0] fifo_data_in;
wire    [36:0] fifo_data_out;
wire    full;
wire    empty;
wire    wr_en_in;
wire    rd_en_in;
//wire    ready_in_delay;
assign fifo_data_in = {last_in,keep_in,data_in};
assign ready_in = !full;
assign  wr_en_in = ready_in && valid_in;

fifo_generator_0 fifo_generator_0 (
  .clk(clk),      // input wire clk
  .srst(!rst_n),    // input wire srst
  .din(fifo_data_in),      // input wire [36 : 0] din
  .wr_en(wr_en_in),  // input wire wr_en
  .rd_en(rd_en_in),  // input wire rd_en
  .dout(fifo_data_out),    // output wire [36 : 0] dout
  .full(full),    // output wire full
  .empty(empty)  // output wire empty
);



// output
reg [DATA_WD-1 : 0] data_out_delay;
reg [DATA_WD-1 : 0] fifo_out_delay;
reg [DATA_WD-1 : 0] fifo_out_delay_a;
reg flag;


assign  data_out = data_out_delay;
assign  rd_en_in = !empty && ready_out;


always@(posedge clk)
    if(!rst_n)begin
        fifo_out_delay <= 1'b0;
        fifo_out_delay_a <= 1'b0;
    end
    else    begin
        fifo_out_delay <= fifo_data_out[31:0];
        fifo_out_delay_a <= fifo_out_delay;
    end

reg last_flag;
reg not_flag;


always @(posedge clk) 
    if(!rst_n) begin
        last_flag<='b0;
        not_flag<='b0;
    end
    else if(last_flag & ready_out & valid_out) begin
        last_flag<='b0;
        not_flag<='b1;
    end
    else if(fifo_data_out[36] & !not_flag)begin
        last_flag<='b1;
        not_flag<='b0;
    end
    else if(!last_flag & ready_out & valid_out) begin
        last_flag<='b0;
        not_flag<='b0;
    end

assign last_out=last_flag;
assign valid_out = !empty || last_flag;

always@(posedge clk)
    if(!rst_n)
        flag <= 1'b1;
    else if(last_out)
        flag <= 1'b1;
    else if(rd_en_in)
        flag <= 1'b0;
    else
        flag <= flag;

always@(*)
    if(!rst_n)begin
        data_out_delay <= 1'b0;
    end
    else if(rd_en_in)begin
        if(flag)
            case(byte_insert_cnt_delay)
                1:data_out_delay <= {header_insert_delay[7:0],fifo_data_out[31:8]};
                2:data_out_delay <= {header_insert_delay[15:0],fifo_data_out[31:16]};
                3:data_out_delay <= {header_insert_delay[23:0],fifo_data_out[31:24]};
                4:data_out_delay <= header_insert_delay[31:0];
                default:data_out_delay <= {header_insert_delay[7:0],fifo_data_out[31:8]};
            endcase
        else
            case(byte_insert_cnt_delay)
                1:data_out_delay <= {fifo_out_delay[7:0],fifo_data_out[31:8]};
                2:data_out_delay <= {fifo_out_delay[15:0],fifo_data_out[31:16]};
                3:data_out_delay <= {fifo_out_delay[23:0],fifo_data_out[31:24]};
                4:data_out_delay <= fifo_out_delay[31:0];
                default:data_out_delay <= {fifo_out_delay[7:0],fifo_data_out[31:8]};
            endcase
        end

reg [3:0] keep_out_temp;

assign keep_out = keep_out_temp;
                
always@(*)
    if(!rst_n)
        keep_out_temp <= 1'b0;
    else if(valid_out && ready_out && last_out)
        case(byte_insert_cnt_delay)
            1:
                keep_out_temp <= fifo_data_out[35:32] << 3;
            2:
                keep_out_temp <= fifo_data_out[35:32] << 2;
            3:
                keep_out_temp <= fifo_data_out[35:32] << 1;
            default:keep_out_temp <= fifo_data_out[35:32];
        endcase
    else if(valid_out && ready_out)
        keep_out_temp <= 4'b1111;
    else
        keep_out_temp <= 4'b0;

endmodule
