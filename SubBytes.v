module SubBytes (
    input [127:0] state_in,       // 128비트 입력 상태
    output reg [127:0] state_out  // 128비트 출력 상태
);
    reg [7:0] sbox [0:255];       // AES S-Box 테이블
    integer i;

    // 초기화 블록: S-Box 테이블 값을 외부 파일에서 로드
    initial begin
        $readmemh("./data/sbox.mem", sbox); // sbox.mem 파일에서 16진수 값을 읽어와 S-Box 초기화
    end

    // 항상 블록: 입력 상태의 각 바이트를 S-Box를 통해 변환
    always @(*) begin
        for (i = 0; i < 16; i = i + 1) begin
            // 입력 바이트를 S-Box에서 변환하여 출력 상태에 저장
            state_out[(i*8) +: 8] = sbox[state_in[(i*8) +: 8]];
        end
    end

endmodule