# summarize PBAA results
# example:
# ruby pbaa_summary.rb <directory_of_fastq_files>


def fasta_to_hash(infile)
  f=File.open(infile,"r")
  return_hash = {}
  name = ""
  while line = f.gets do
    line.tr!("\u0000","")
    next if line == "\n"
    next if line =~ /^\=/
    if line =~ /^\>/
      name = line.chomp
      return_hash[name] = ""
    else
      return_hash[name] += line.chomp.upcase
    end
  end
  f.close
  return return_hash
end

indir = File.join(ARGV[0], "PBAA_results")

raise "PBAA results directory not found. Process aborted" unless File.exist? indir

ref_dir = []
Dir.chdir(indir) { ref_dir = Dir.glob("*/")}

ref_dir.each do |ref|
  outfile = File.join(indir, (ref[0..-2] + ".csv"))
  out = File.open(outfile, 'w')
  out.puts "guide_file,barcode,guide_sequence,cluster_number,read_count,uchime_score,uchime_left_parent,uchime_right_parent,cluster_freq,diversity,avg_quality,duplicate_parent,seq_length,filters"

  files = []
  Dir.chdir (File.join(indir, ref)) { files = Dir.glob("*passed_cluster_sequences.fasta")}

  files.each do |f|
    f =~ /Barcode(\d+)\_/
    bar = $1
    seqs = fasta_to_hash(File.join(indir, ref, f))
    seqs.keys.each do |k|
      out.print ref[0..-2] + "," + bar.to_s + ","
      info = k.split("\s")
      first = info.shift

      first =~ /guide\-(\w+)\_cluster\-(\d+)\_ReadCount\-(\d+)/

      out.print [$1.to_s, $2.to_s, $3.to_s].join(",") + ","

      info.each do |d|
        out.print d.split(":")[1].to_s + ","
      end
      out.print "\n"
    end
  end
  out.close
end

