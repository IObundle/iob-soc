import sys, string

f0 = open("boot_0.hex", "w");
f1 = open("boot_1.hex", "w");
f2 = open("boot_2.hex", "w");
f3 = open("boot_3.hex", "w");

main_file = open("boot.hex", "r");

text = main_file.readlines();

for line in text:
    if(line == "0\n"):
        f3.write("0\n");
        f2.write("0\n");
        f1.write("0\n");
        f0.write("0\n");
    else:
        f3.write(line[0:2] + '\n');
        f2.write(line[2:4] + '\n');
        f1.write(line[4:6] + '\n');
        f0.write(line[6:8] + '\n');




