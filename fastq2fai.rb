# batch process using samtools to generate .fai index file from fastq file
# example command:
# ruby fastq2fai.rb <directory_of_fastq_files>

indir = ARGV[0]


fastq_files = []

Dir.chdir(indir) {fastq_files = Dir.glob("*demux*fastq")}

fastq_files.each do |fastq|
    path = File.join(indir, fastq)

    print `sbatch --mem=1000 -t 30 --wrap=\"samtools faidx #{path}\"`
end
