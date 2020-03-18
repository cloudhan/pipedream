import os
import shutil
import random
import argparse

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("root")
    args = parser.parse_args()

    subdir = [d for d in os.listdir(args.root) if os.path.isdir(os.path.join(args.root, d)) and d != "train" and d!= "val"]

    for d in subdir:
        os.makedirs(os.path.join(args.root, "train", d), exist_ok=True)
        os.makedirs(os.path.join(args.root, "val", d), exist_ok=True)

        files = [f for f in os.listdir(os.path.join(args.root, d)) if os.path.isfile(os.path.join(args.root, d, f))]
        for f in files:
            if random.uniform(0.0, 1.0) < 0.8:
                shutil.move(os.path.join(args.root, d, f), os.path.join(args.root, "train", d, f))
            else:
                shutil.move(os.path.join(args.root, d, f), os.path.join(args.root, "val", d, f))
