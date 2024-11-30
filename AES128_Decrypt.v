module AES128_Decrypt (
    input [127:0] ciphertext,      // 128비트 암호문
    input [1407:0] round_keys,     // 암호화 모듈에서 생성된 11개의 128비트 라운드 키 (직렬로 저장)
    output [127:0] plaintext       // 복호화 결과로 나오는 128비트 평문
);

    wire [127:0] state [0:10]; // 각 라운드에서의 상태를 저장하는 128비트 레지스터 배열

    // 초기 라운드 (AddRoundKey)
    AddRoundKey add_initial_round(
        .state_in(ciphertext),             // 암호문 입력
        .round_key(round_keys[1407:1280]), // 마지막 라운드 키
        .state_out(state[10])             // 첫 번째 상태 출력
    );

    // 주요 9번 라운드
    generate
        genvar r;
        for (r = 10; r > 0; r = r - 1) begin : main_rounds
            wire [127:0] invshiftrows_out, invsubbytes_out, invmixcolumns_out;

            // InvShiftRows: 행을 오른쪽으로 순환 이동
            InvShiftRows invshiftrows(
                .state_in(state[r]),
                .state_out(invshiftrows_out)
            );

            // InvSubBytes: 비선형 역변환 수행
            InvSubBytes invsubbytes(
                .state_in(invshiftrows_out),
                .state_out(invsubbytes_out)
            );

            // AddRoundKey: 현재 라운드 키를 상태와 XOR 연산
            AddRoundKey add_round_key(
                .state_in(invsubbytes_out),
                .round_key(round_keys[r*128-1:(r-1)*128]),
                .state_out(invmixcolumns_out)
            );

            // InvMixColumns: 열을 역변환하여 데이터 퍼뜨림
            InvMixColumns invmixcolumns(
                .state_in(invmixcolumns_out),
                .state_out(state[r-1])
            );
        end
    endgenerate

    // 마지막 라운드 (InvShiftRows, InvSubBytes, AddRoundKey)
    wire [127:0] invshiftrows_final, invsubbytes_final;

    // InvShiftRows: 마지막 라운드에서 행을 오른쪽으로 순환 이동
    InvShiftRows invshiftrows_final_round(
        .state_in(state[1]),
        .state_out(invshiftrows_final)
    );

    // InvSubBytes: 마지막 라운드에서 비선형 역변환 수행
    InvSubBytes invsubbytes_final_round(
        .state_in(invshiftrows_final),
        .state_out(invsubbytes_final)
    );

    // AddRoundKey: 마지막 라운드 키를 적용하여 평문 생성
    AddRoundKey add_final_round_key(
        .state_in(invsubbytes_final),
        .round_key(round_keys[127:0]),
        .state_out(plaintext)
    );

endmodule