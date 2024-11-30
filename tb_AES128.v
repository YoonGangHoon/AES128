`timescale 1ns/1ps

module tb_AES128;

    // 신호 정의
    reg CLK;                  // 클럭 신호
    reg nRST;                 // 리셋 신호 (비활성화-로우)
    reg ENCDEC;               // 암호화/복호화 선택 (0: 암호화, 1: 복호화)
    reg START;                // 시작 신호
    reg [127:0] KEY;          // 128비트 암호화 키
    reg [127:0] TEXTIN;       // 128비트 입력 데이터 (평문/암호문)
    wire DONE;                // 처리 완료 신호
    wire [127:0] TEXTOUT;     // 128비트 출력 데이터 (암호문/복호문)

    // AES Crypto Processor 모듈 인스턴스
    AES_Crypto_Processor uut (
        .CLK(CLK),        // 클럭 입력
        .nRST(nRST),      // 리셋 신호 입력
        .ENCDEC(ENCDEC),  // 암호화/복호화 선택 입력
        .START(START),    // 시작 신호 입력
        .KEY(KEY),        // 암호화 키 입력
        .TEXTIN(TEXTIN),  // 입력 데이터
        .DONE(DONE),      // 완료 신호 출력
        .TEXTOUT(TEXTOUT) // 출력 데이터
    );

    // 클럭 생성 (주기: 10ns, 주파수: 100MHz)
    always #5 CLK = ~CLK;

    initial begin
        // 시뮬레이션 결과 저장
        $dumpfile("aes_wave.vcd");
        $dumpvars(0, tb_AES128);

        // 초기화
        CLK = 0;                              // 클럭 초기화
        nRST = 0;                             // 리셋 활성화
        ENCDEC = 0;                           // 암호화 모드 설정
        START = 0;                            // 시작 신호 비활성화
        KEY = 128'h00000000000000000000000000000000; // 기본 키 설정
        TEXTIN = 128'h00000000000000000000000000000000; // 기본 입력 데이터 설정

        // 리셋 비활성화
        #10 nRST = 1;

        // 테스트 세트 1
        $display("Test Set 1");
        KEY = 128'h000102030405060708090a0b0c0d0e0f; // 테스트 키 1
        TEXTIN = 128'h00112233445566778899aabbccddeeff; // 테스트 평문 1
        $display("Plain text: %h", TEXTIN);

        // 암호화 테스트
        #10 START = 1; ENCDEC = 0; // 암호화 시작
        #10 START = 0; // 시작 신호 비활성화
        wait (DONE); // 완료 신호 대기
        #10 $display("Ciphertext: %h", TEXTOUT); // 암호문 출력

        // 복호화 테스트
        TEXTIN = TEXTOUT; // 암호문을 입력 데이터로 설정
        #10 START = 1; ENCDEC = 1; // 복호화 시작
        #10 START = 0; // 시작 신호 비활성화
        wait (DONE); // 완료 신호 대기
        #10 $display("Decrypted Text: %h", TEXTOUT); // 복호문 출력

        // 결과 검증
        if (TEXTOUT == 128'h00112233445566778899aabbccddeeff) begin
            $display("Test Set 1 Passed");
        end else begin
            $display("Test Set 1 Failed");
        end

        // 테스트 세트 2
        $display("\nTest Set 2");
        KEY = 128'h2b7e151628aed2a6abf7158809cf4f3c; // 테스트 키 2
        TEXTIN = 128'h6bc1bee22e409f96e93d7e117393172a; // 테스트 평문 2
        $display("Plain text: %h", TEXTIN);

        // 암호화 테스트
        #10 START = 1; ENCDEC = 0; // 암호화 시작
        #10 START = 0; // 시작 신호 비활성화
        wait (DONE); // 완료 신호 대기
        #10 $display("Ciphertext: %h", TEXTOUT); // 암호문 출력

        // 복호화 테스트
        TEXTIN = TEXTOUT; // 암호문을 입력 데이터로 설정
        #10 START = 1; ENCDEC = 1; // 복호화 시작
        #10 START = 0; // 시작 신호 비활성화
        wait (DONE); // 완료 신호 대기
        #10 $display("Decrypted Text: %h", TEXTOUT); // 복호문 출력

        // 결과 검증
        if (TEXTOUT == 128'h6bc1bee22e409f96e93d7e117393172a) begin
            $display("Test Set 2 Passed");
        end else begin
            $display("Test Set 2 Failed");
        end

        // 시뮬레이션 종료
        #100 $finish;
    end
endmodule