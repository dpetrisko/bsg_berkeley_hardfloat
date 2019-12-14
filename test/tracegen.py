import argparse


TR_SEND = 1
TR_RECV = 2
TR_DONE = 4

#typedef enum logic [4:0]
#{
#  e_op_fadd    = 5'b00000
#  ,e_op_fsub   = 5'b00001
#  ,e_op_fmul   = 5'b00010
#  ,e_op_fmin   = 5'b00011
#  ,e_op_fmax   = 5'b00100
#  ,e_op_fmadd  = 5'b00101
#  ,e_op_fmsub  = 5'b00110
#  ,e_op_fnmsub = 5'b00111
#  ,e_op_fnmadd = 5'b01000
#  ,e_op_i2f    = 5'b01001
#  ,e_op_iu2f   = 5'b01010
#  ,e_op_fsgnj  = 5'b01011
#  ,e_op_fsgnjn = 5'b01100
#  ,e_op_fsgnjx = 5'b01101
#  ,e_op_feq    = 5'b01110
#  ,e_op_flt    = 5'b01111
#  ,e_op_fle    = 5'b10000
#  ,e_op_fclass = 5'b10001
#  ,e_op_f2i    = 5'b10010
#  ,e_op_f2iu   = 5'b10011
#  ,e_op_pass   = 5'b11111
#} bsg_fp_op_e;

op_map = {"fadd": 0, "fsub": 1, "fmul" 2, "fmadd": 5}

def gen_case(filename, op):
    with open(filename) as f:
        lines = f.read().splitlines()

        for i, line in enumerate(lines):
            words = line.split()
            if len(words) == 4:
                op1 = int(words[0], 16)
                op2 = int(words[1], 16)
                op3 = 0
                res = int(words[2], 16)
                exc = int(words[3], 16)
            else:
                op1 = int(words[0], 16)
                op2 = int(words[1], 16)
                op3 = int(words[2], 16)
                res = int(words[3], 16)
                exc = int(words[4], 16)

            fnc = op_map[op]
            ipr = 1  # Double
            opr = 1  # Double
            rm = 0   # RNE

            tr_op = TR_SEND

            # NV -- suppress result
            if exc & 0b10000:
                res = 0
            # 64b NaN -- suppress result
            if (res & 0x7FFFFFFFFFFFFFFF) > 0x7FF0000000000000:
                res = 0

            print(
                "{:04b}_{:064b}_{:064b}_{:064b}_{:03b}_{:01b}_{:01b}_{:05b}".format(
                    tr_op, op1, op2, op3, rm, ipr, opr, fnc
                )
            )

            tr_op = TR_RECV

            print("{:04b}_{:064b}_{:05b}_{:0133b}".format(tr_op, res, exc, 0))

        tr_op = TR_DONE
        print("{:04b}_{:0202b}".format(tr_op, 0))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("case")
    parser.add_argument("op")

    args = parser.parse_args()

    gen_case(args.case, args.op)


if __name__ == "__main__":
    main()
