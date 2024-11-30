# 컴파일러와 주요 변수
IVERILOG = iverilog
VVP = vvp
TARGET = tb_AES128  # 테스트벤치 이름
SRC = \
    AES128_Decrypt.v \
    AES128_Encrypt.v \
    AES_Crypto_Processor.v \
    AddRoundKey.v \
    InvMixColumns.v \
    InvShiftRows.v \
    InvSubBytes.v \
    KeyExpansion.v \
    MixColumns.v \
    ShiftRows.v \
    SubBytes.v \
    tb_AES128.v

# 기본 목표
all: run

# 컴파일 단계
$(TARGET): $(SRC)
	$(IVERILOG) -o $(TARGET) $(SRC)

# 실행 단계
run: $(TARGET)
	$(VVP) $(TARGET)

# 청소(clean)
clean:
	rm -f $(TARGET) *.vcd