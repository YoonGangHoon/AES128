module MixColumns (
    input [127:0] state_in,       // 입력 상태 (128비트)
    output reg [127:0] state_out  // 출력 상태 (128비트)
);
    reg [7:0] state [0:3][0:3];        // 4x4 행렬로 변환된 입력 상태
    reg [7:0] mixed_state [0:3][0:3];  // 혼합 결과 저장
    reg [7:0] tmp, tm, t;              // 임시 변수
    integer i, j;

    // GF(2^8)에서 xtime 함수 (값을 2배 곱하는 연산)
    function [7:0] xtime;
        input [7:0] x;
        begin
            // x를 왼쪽으로 1비트 이동하고 최상위 비트가 1이면 다항식 0x1b를 XOR
            xtime = (x << 1) ^ ((x[7] == 1'b1) ? 8'h1b : 8'h00);
        end
    endfunction

    always @(*) begin
        // 입력을 4x4 행렬로 변환 (열 우선 순서)
        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                state[3-j][3-i] = state_in[(i*32 + j*8) +: 8];
            end
        end

        // MixColumns 연산 수행
        for (i = 0; i < 4; i = i + 1) begin
            t = state[0][i]; // 열의 첫 번째 값 저장
            tmp = state[0][i] ^ state[1][i] ^ state[2][i] ^ state[3][i]; // 열의 XOR 값 계산

            // 첫 번째 행의 계산
            tm = state[0][i] ^ state[1][i]; // 두 값의 XOR 계산
            tm = xtime(tm);                 // xtime 적용 (GF(2^8)에서 곱셈 수행)
            mixed_state[0][i] = state[0][i] ^ (tm ^ tmp); // 결과 저장

            // 두 번째 행의 계산
            tm = state[1][i] ^ state[2][i];
            tm = xtime(tm);
            mixed_state[1][i] = state[1][i] ^ (tm ^ tmp);

            // 세 번째 행의 계산
            tm = state[2][i] ^ state[3][i];
            tm = xtime(tm);
            mixed_state[2][i] = state[2][i] ^ (tm ^ tmp);

            // 네 번째 행의 계산
            tm = state[3][i] ^ t;          // t는 열의 첫 번째 값
            tm = xtime(tm);
            mixed_state[3][i] = state[3][i] ^ (tm ^ tmp);
        end
    
        // 결과를 128비트로 변환 (열 우선 순서)
        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                state_out[(i*32 + j*8) +: 8] = mixed_state[3-j][3-i];
            end
        end
    end
endmodule