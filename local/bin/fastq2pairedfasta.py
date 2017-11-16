import os.path
import itertools
import argparse
import re

#- Chunyu Zhao 20171016 for igram1 ecoli cross assembly

class FastqRead(object):
    def __init__(self, read):
        self.desc, self.seq, self.qual = read
    
    def __repr__(self):
        return self.desc + "\n" + self.seq + "\n+\n" + self.qual + "\n"

def _grouper(iterable, n):
    "Collect data into fixed-length chunks or blocks"
    # grouper('ABCDEFG', 3) --> ABC DEF
    args = [iter(iterable)] * n
    return zip(*args)

def parse_fastq(f):
    for desc, seq, _, qual in _grouper(f, 4):
        desc = desc.rstrip()[1:]
        seq = seq.rstrip()
        qual = qual.rstrip()
        yield desc, seq,qual


def main(argv=None):

    p = argparse.ArgumentParser()

    p.add_argument(
        "--forward-reads", required=True,
        type=argparse.FileType("r"),
        help="FASTQ file of forward reads")

    p.add_argument(
        "--reverse-reads", required=False,
        type=argparse.FileType("r"),
        help="FASTQ file of reverse reads")

    p.add_argument(
        "--output-dir", required=True,
        help="Path to output directory")

    args = p.parse_args(argv)

    # input
    I1 = args.forward_reads.name
    I2 = args.reverse_reads.name

    # output
    I1_new = os.path.join(args.output_dir, re.sub(".fastq", ".fasta", os.path.basename(I1)))
    I2_new = os.path.join(args.output_dir, re.sub(".fastq", ".fasta", os.path.basename(I2)))

    # do the thing
    I1_handle = open(I1)
    I2_handle = open(I2)    
    fwds = (FastqRead(x) for x in parse_fastq(I1_handle))
    revs = (FastqRead(x) for x in parse_fastq(I2_handle))

    with open(I1_new, "w") as I1_out:
        with open(I2_new,"w") as I2_out:
            for fwd, rev in zip(fwds, revs):
                if fwd.desc.split(" ")[0] == rev.desc.split(" ")[0]:
                    I1_out.write(">%s\n%s\n" % (fwd.desc, fwd.seq))
                    I2_out.write(">%s\n%s\n" % (rev.desc, rev.seq))
                else:
                    print("error for ", fwd.desc, rev.desc)
                    sys.exit(0)

    I1_handle.close()
    I2_handle.close()


if __name__ == '__main__':
    main()
