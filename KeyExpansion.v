module KeyExpansion (
    input [127:0] Key,               // 128비트 입력 키
    output reg [1407:0] SwappedRoundKey // 11개의 128비트 라운드 키 (1408비트)
);

    reg [31:0] temp;                // 임시 변수 (32비트 단위)
    reg [31:0] Rcon [0:10];         // Rcon 상수 (라운드 별로 사용)
    reg [7:0] sbox [0:255];         // S-box 테이블
    reg [1407:0] RoundKey;          // 확장된 라운드 키 저장
    integer i, j;                   // 반복문 인덱스 변수

    // S-box 테이블 초기화 (외부 파일에서 로드)
    initial begin
        $readmemh("./data/sbox.mem", sbox); // sbox.mem 파일에서 S-box 값을 로드
    end

    // Rcon 테이블 초기화 (외부 파일에서 로드)
    initial begin
        $readmemh("./data/rcon.mem", Rcon); // rcon.mem 파일에서 Rcon 값을 로드
    end

    always @(*) begin
        // 초기 키 복사 (128비트 입력 키를 RoundKey의 첫 4개 워드에 복사)
        for (i = 0; i < 4; i = i + 1) begin
            RoundKey[i*32 +: 32] = Key[(3-i)*32 +: 32]; // 입력 키를 역순으로 복사
        end

        // 라운드 키 확장 (44개의 워드 생성: 4개는 입력 키, 나머지는 확장)
        for (i = 4; i < 44; i = i + 1) begin
            temp = RoundKey[(i-1)*32 +: 32]; // 이전 워드 복사

            if (i % 4 == 0) begin
                // Rotate (32비트를 8비트 왼쪽 순환 이동)
                temp = {temp[23:0], temp[31:24]};

                // S-box 변환 (각 바이트를 S-box를 통해 변환)
                temp[31:24] = sbox[temp[31:24]];
                temp[23:16] = sbox[temp[23:16]];
                temp[15:8]  = sbox[temp[15:8]];
                temp[7:0]   = sbox[temp[7:0]];

                // Rcon 상수와 XOR 연산
                temp[31:24] = temp[31:24] ^ Rcon[i/4 - 1][31:24];
            end

            // RoundKey 갱신 (4번째 이전 워드와 XOR)
            RoundKey[i*32 +: 32] = RoundKey[(i-4)*32 +: 32] ^ temp;
        end

        // RoundKey를 역순으로 재배치 (AES 표준에 맞게 조정)
        for (i = 0; i < 11; i = i + 1) begin
            // 각 라운드의 RoundKey를 역순으로 정렬
            for (j = 0; j < 4; j = j + 1) begin
                SwappedRoundKey[i*128 + j*32 +: 32] = RoundKey[i*128 + (3-j)*32 +: 32];
            end
        end
    end
endmodule