# batch process pbaa,guide sequences in the directory of the /guide.
# example command:
# ruby pbaa.rb <directory_of_fastq_files> <email>
# results in the folder PBAA_results

indir = ARGV[0]
if ARGV[1]
    email = ARGV[1]
else
    email = "moeser@med.unc.edu"
end

fastq_files = []

Dir.chdir(indir) {fastq_files = Dir.glob("*demux*fastq")}
guide_dir = File.join(indir, "guide")
raise "The directory for guide sequences not fouond. Process aborted." unless File.exist? guide_dir
guide_seq = []

Dir.chdir(guide_dir) {guide_seq = Dir.glob("*fasta")}
raise "No guide sequences found in the guide directory #{guide_dir}. Process aborted." unless guide_seq.size > 0

outdir = File.join(indir, "PBAA_results")
Dir.mkdir outdir unless File.directory? outdir

fastq_files_with_barcode = {}

fastq_files.each do |fastq|
    fastq =~ /demux\.(\d+)\-\-(\d+)/
    barcode1 = $1
    barcode2 = $2
    fastq_files_with_barcode[fastq] = [barcode1, barcode2]
end

guide_seq.each do |guide|
    guide_basename = File.basename(guide, ".fasta")
    guide_path = File.join(guide_dir, guide)
    outdir_guide = File.join(outdir, guide_basename)
    Dir.mkdir outdir_guide unless File.directory? outdir_guide
    fastq_files_with_barcode.each do |fastq, barcode|
        path = File.join(indir, fastq)
        outfile_path = File.join(outdir_guide, ("Barcode" + barcode.join("--")))
        print "Barcode #{barcode.join("--")}\t"
        print `sbatch --mail-type=FAIL --mail-user=#{email} --mem=40000 -t 280 --wrap=\"pbaa cluster #{guide_path} #{path} #{outfile_path}\"`
    end

end
