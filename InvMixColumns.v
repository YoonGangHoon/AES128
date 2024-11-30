module InvMixColumns (
    input [127:0] state_in,   // 128비트 입력 상태 (4x4 행렬로 처리)
    output reg [127:0] state_out // 128비트 출력 상태
);

    reg [7:0] state [0:3][0:3];        // 4x4 행렬 형태로 입력 상태 저장
    reg [7:0] mixed_state [0:3][0:3];  // 연산 결과를 저장하는 4x4 행렬
    integer i, j;

    // GF(2^8)에서 xtime 함수 (x를 2배 곱하는 연산)
    function [7:0] xtime;
        input [7:0] x;
        begin
            // x를 왼쪽으로 1비트 시프트하고, 최상위 비트가 1이면 다항식 0x1b를 XOR
            xtime = (x << 1) ^ ((x[7] == 1'b1) ? 8'h1b : 8'h00);
        end
    endfunction

    // GF(2^8)에서 Multiply 함수 (x와 y의 곱셈 수행)
    function [7:0] Multiply;
        input [7:0] x, y;
        reg [7:0] temp;
        reg [7:0] result;
        integer k;
        begin
            result = 8'h00; // 초기값 설정
            temp = x;       // x를 초기값으로 설정
            for (k = 0; k < 8; k = k + 1) begin
                if (y[0]) begin
                    // y의 최하위 비트가 1인 경우 현재 temp 값을 result에 XOR
                    result = result ^ temp;
                end
                // temp를 xtime 연산으로 2배 증가
                temp = xtime(temp);
                // y를 오른쪽으로 1비트 시프트
                y = y >> 1;
            end
            Multiply = result; // 연산 결과 반환
        end
    endfunction

    always @(*) begin
        // 입력 128비트를 4x4 행렬로 변환 (열 우선 순서)
        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                state[3-j][3-i] = state_in[(i*32 + j*8) +: 8];
            end
        end

        // InvMixColumns 연산 수행
        for (i = 0; i < 4; i = i + 1) begin
            mixed_state[0][i] = Multiply(state[0][i], 8'h0e) ^
                                Multiply(state[1][i], 8'h0b) ^
                                Multiply(state[2][i], 8'h0d) ^
                                Multiply(state[3][i], 8'h09);

            mixed_state[1][i] = Multiply(state[0][i], 8'h09) ^
                                Multiply(state[1][i], 8'h0e) ^
                                Multiply(state[2][i], 8'h0b) ^
                                Multiply(state[3][i], 8'h0d);

            mixed_state[2][i] = Multiply(state[0][i], 8'h0d) ^
                                Multiply(state[1][i], 8'h09) ^
                                Multiply(state[2][i], 8'h0e) ^
                                Multiply(state[3][i], 8'h0b);

            mixed_state[3][i] = Multiply(state[0][i], 8'h0b) ^
                                Multiply(state[1][i], 8'h0d) ^
                                Multiply(state[2][i], 8'h09) ^
                                Multiply(state[3][i], 8'h0e);
        end

        // 4x4 행렬을 다시 128비트로 변환 (열 우선 순서)
        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                state_out[(i*32 + j*8) +: 8] = mixed_state[3-j][3-i];
            end
        end
    end
endmodule