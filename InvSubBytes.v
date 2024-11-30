module InvSubBytes (
    input [127:0] state_in,       // 128비트 입력 상태
    output reg [127:0] state_out  // 128비트 출력 상태
);

    reg [7:0] inv_sbox [0:255]; // AES 역 S-Box (256개의 8비트 값)
    integer i;

    // 초기화 블록: 역 S-Box 값을 메모리 파일에서 로드
    initial begin
        $readmemh("./data/inv_sbox.mem", inv_sbox); // inv_sbox.mem 파일에서 16진수 값을 로드
    end

    // 항상 블록: 입력 상태의 각 바이트를 역 S-Box를 통해 변환
    always @(*) begin
        for (i = 0; i < 16; i = i + 1) begin
            // 입력 바이트를 역 S-Box에서 찾아 출력 상태로 매핑
            state_out[(i*8) +: 8] = inv_sbox[state_in[(i*8) +: 8]];
        end
    end

endmodule