# AES128 Project

디지털설계 및 실험에서 진행한 AES128 프로젝트입니다.

## 개발 환경
1. macOS(M1)
2. icarus verilog 
3. gtkwave

## 설치 사항
1. brew install icarus-verilog
2. brew install gtkwave

## 사용 방법
1. git clone
2. 터미널에서 make 명령어 실행 (빌드 후 실행)
3. ./tb_AES128 명령어 실행 시 빌드 없이 실행
4. gtkwave aes_wave.vcd 명령어 실행 시 파형 확인 가능

## 제한 사항
1. M1 칩 이후의 macOS에서는 synthesis 제한적으로 가능(yosys 사용)
2. schemetic, power, timing 등은 확인 불가능(vivado 지원)
