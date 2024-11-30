module AES_Crypto_Processor (
    input CLK,                 // 시스템 클럭
    input nRST,                // 활성화-로우 리셋 신호
    input ENCDEC,              // 0: 암호화, 1: 복호화
    input START,               // 시작 신호
    input [127:0] KEY,         // 128비트 암호화/복호화 키
    input [127:0] TEXTIN,      // 128비트 입력 데이터 (평문 또는 암호문)
    output reg DONE,           // 처리 완료 신호
    output reg [127:0] TEXTOUT // 128비트 출력 데이터 (암호문 또는 평문)
);
    // 내부 레지스터 및 와이어 정의
    reg [3:0] round;                  // 라운드 카운터
    reg [127:0] state;                // 현재 상태 (128비트 블록)
    wire [1407:0] round_keys;         // 라운드 키 (11개 라운드 동안 생성됨)
    wire [127:0] encrypt_out, decrypt_out; // 암호화 및 복호화 출력

    // 키 확장 모듈 연결
    KeyExpansion key_expansion (
        .Key(KEY),
        .SwappedRoundKey(round_keys)
    );

    // 암호화 모듈 연결
    AES128_Encrypt encryptor (
        .plaintext(state),
        .Key(KEY),
        .ciphertext(encrypt_out)
    );

    // 복호화 모듈 연결
    AES128_Decrypt decryptor (
        .ciphertext(state),
        .round_keys(round_keys),
        .plaintext(decrypt_out)
    );

    // 암호화 및 복호화를 위한 제어 로직
    always @(posedge CLK or negedge nRST) begin
        if (!nRST) begin
            // 리셋 신호가 활성화된 경우 초기화
            DONE <= 0;
            round <= 0;
            state <= 128'b0;
            TEXTOUT <= 128'b0;
        end else if (START && round == 0) begin
            // 시작 신호를 받으면 프로세스를 초기화
            DONE <= 0;
            state <= TEXTIN;
            round <= 1;
        end else if (round > 0 && round <= 10) begin
            // 암호화/복호화 라운드 진행
            if (ENCDEC == 0) begin
                // 암호화 모드
                state <= encrypt_out;
            end else begin
                // 복호화 모드
                state <= decrypt_out;
            end
            round <= round + 1;
        end else if (round == 11) begin
            // 처리 완료 후 결과 출력
            TEXTOUT <= state;
            DONE <= 1;
            round <= 0; // 다음 작업을 위해 라운드 카운터 초기화
        end else begin
            DONE <= 0; // 처리 중간 상태
        end
    end

endmodule