module AddRoundKey (
    input [127:0] state_in,     // 현재 상태 (128비트 입력)
    input [127:0] round_key,    // 라운드 키 (128비트)
    output [127:0] state_out    // 라운드 키가 적용된 출력 상태
);
    // 현재 상태와 라운드 키를 XOR 연산하여 새로운 상태를 생성
    assign state_out = state_in ^ round_key;
endmodule