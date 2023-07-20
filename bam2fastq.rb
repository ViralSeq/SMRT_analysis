# batch process the bam2fastq via bedtools. 
# example command:
# ruby bam2fastq.rb <directory_of_bam_files>

indir = ARGV[0]


bam_files = []

Dir.chdir(indir) {bam_files = Dir.glob("*demux*bam")}

bam_files.each do |bam|
    path = File.join(indir, bam)
    outfile = File.join(indir, File.basename(bam, ".bam"))
    outfile += ".fastq"

    puts `sbatch --mem=1000 -t 30 --wrap=\"bedtools bamtofastq -i #{path} -fq #{outfile}\"`
end
