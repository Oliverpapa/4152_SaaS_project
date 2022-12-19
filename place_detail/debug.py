with open("CA_information.csv", "r") as f:
    f.readline()
    for line in f:
        if line.strip() == "": continue
        if len(line.strip().split(",")) < 3:
            print(line.strip())