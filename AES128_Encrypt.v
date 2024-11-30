module AES128_Encrypt (
    input [127:0] plaintext,  // 128비트 평문 (암호화 대상)
    input [127:0] Key,        // 128비트 암호화 키
    output [127:0] ciphertext // 암호화 결과로 나오는 128비트 암호문
);

    wire [1407:0] round_keys; // 11개의 128비트 라운드 키를 직렬로 저장 (11 * 128 = 1408비트)
    wire [127:0] state [0:10]; // 각 라운드에서의 상태를 저장하는 128비트 레지스터 배열

    // 키 확장 모듈
    KeyExpansion key_expansion(
        .Key(Key),                  // 입력 키
        .SwappedRoundKey(round_keys) // 확장된 라운드 키
    );

    // 초기 라운드 (AddRoundKey)
    AddRoundKey add_initial_round(
        .state_in(plaintext),         // 초기 상태로 평문 입력
        .round_key(round_keys[127:0]), // 첫 번째 라운드 키
        .state_out(state[0])          // 첫 번째 상태 출력
    );

    // 주요 9번 라운드
    generate
        genvar r;
        for (r = 1; r < 10; r = r + 1) begin : main_rounds
            wire [127:0] subbytes_out, shiftrows_out, mixcolumns_out;

            // SubBytes: 비선형 변환 수행
            SubBytes subbytes(
                .state_in(state[r-1]),
                .state_out(subbytes_out)
            );

            // ShiftRows: 행을 왼쪽으로 순환 이동
            ShiftRows shiftrows(
                .state_in(subbytes_out),
                .state_out(shiftrows_out)
            );

            // MixColumns: 열 변환을 통해 데이터 확산
            MixColumns mixcolumns(
                .state_in(shiftrows_out),
                .state_out(mixcolumns_out)
            );

            // AddRoundKey: 현재 라운드 키를 상태와 XOR 연산
            AddRoundKey add_round_key(
                .state_in(mixcolumns_out),
                .round_key(round_keys[(r+1)*128-1:(r)*128]),
                .state_out(state[r])
            );
        end
    endgenerate

    // 마지막 라운드 (MixColumns 제외)
    wire [127:0] subbytes_final, shiftrows_final;

    // SubBytes: 마지막 라운드의 비선형 변환 수행
    SubBytes subbytes_final_round(
        .state_in(state[9]),
        .state_out(subbytes_final)
    );

    // ShiftRows: 마지막 라운드의 행을 왼쪽으로 순환 이동
    ShiftRows shiftrows_final_round(
        .state_in(subbytes_final),
        .state_out(shiftrows_final)
    );

    // AddRoundKey: 마지막 라운드 키 적용하여 암호문 생성
    AddRoundKey add_final_round_key(
        .state_in(shiftrows_final),
        .round_key(round_keys[1407:1280]),
        .state_out(ciphertext)
    );

endmodule