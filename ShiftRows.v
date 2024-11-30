module ShiftRows (
    input [127:0] state_in,  // 입력 행렬 (128비트, 4x4 구조)
    output [127:0] state_out // 출력 행렬 (ShiftRows 적용된 128비트, 4x4 구조)
);

    // 0번째 행: 이동 없음
    assign state_out[127:120] = state_in[127:120]; // (0,0) 그대로 유지
    assign state_out[119:112] = state_in[87:80];   // (1,0) -> (0,1)
    assign state_out[111:104] = state_in[47:40];   // (2,0) -> (0,2)
    assign state_out[103:96]  = state_in[7:0];     // (3,0) -> (0,3)

    // 1번째 행: 왼쪽으로 1칸 이동
    assign state_out[95:88]   = state_in[95:88];   // (0,1) 그대로 유지
    assign state_out[87:80]   = state_in[55:48];   // (1,1) -> (1,2)
    assign state_out[79:72]   = state_in[15:8];    // (2,1) -> (1,3)
    assign state_out[71:64]   = state_in[103:96];  // (3,1) -> (1,0)

    // 2번째 행: 왼쪽으로 2칸 이동
    assign state_out[63:56]   = state_in[63:56];   // (0,2) 그대로 유지
    assign state_out[55:48]   = state_in[23:16];   // (1,2) -> (2,3)
    assign state_out[47:40]   = state_in[111:104]; // (2,2) -> (2,0)
    assign state_out[39:32]   = state_in[71:64];   // (3,2) -> (2,1)

    // 3번째 행: 왼쪽으로 3칸 이동
    assign state_out[31:24]   = state_in[31:24];   // (0,3) 그대로 유지
    assign state_out[23:16]   = state_in[119:112]; // (1,3) -> (3,0)
    assign state_out[15:8]    = state_in[79:72];   // (2,3) -> (3,1)
    assign state_out[7:0]     = state_in[39:32];   // (3,3) -> (3,2)

endmodule