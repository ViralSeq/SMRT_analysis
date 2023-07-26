# summarize PBAA results
# if a `csv` file exists in the target directory,
# it will try to abstract data from the `csv` file and annotate the barcoded sequences.
# example:
# ruby pbaa_summary.rb <directory_of_fastq_files>

require 'CSV'

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

raise "PBAA results directory not found. Process aborted." unless File.exist? indir

ref_dir = []
Dir.chdir(indir) { ref_dir = Dir.glob("*/")}

csv_file = []
Dir.chdir(ARGV[0]) { csv_file = Dir.glob("*.csv")}

if csv_file.empty?
  raise "CSV file not exist. Process aborted."
elsif csv_file.size > 1
  raise "multiple CSV files exist. Process aborted."
end

csv_file_path = File.join(ARGV[0], csv_file[0])

csv_lines = CSV.read(csv_file_path)

header = csv_lines[0].collect{ |n| n.upcase}

if !header.any? /barcode/i
  raise "Barcode field must be included in the CSV file. Barcode field not found. Process aborted."
elsif header.count("BARCODE") > 1
  raise "Multiple Barcode field exist. Process aborted."
end

barcode_position = header.index("BARCODE")
other_field_position = (0..(header.size - 1)).to_a - [barcode_position]

csv_hash = {}
csv_lines[1..-1].each do |line|
  next if line[barcode_position].nil?
  bar = line[barcode_position].to_s
  sequence_tag = ">"
  other_field_position.each do |of|
    sequence_tag += header[of].to_s + "-" + line[of].to_s + "\s"
  end
  sequence_tag += "BARCODE-" + line[barcode_position]
  csv_hash[bar] = sequence_tag
end

ref_dir.each do |ref|
  next if ref =~ /output/
  outfile = File.join(indir, (ref[0..-2] + ".csv"))
  outdir = File.join(indir, (ref[0..-2] + "_output"))
  out = File.open(outfile, 'w')
  out.puts "guide_file,barcode,guide_sequence,cluster_number,read_count,uchime_score,uchime_left_parent,uchime_right_parent,cluster_freq,diversity,avg_quality,duplicate_parent,seq_length,filters"
  Dir.mkdir outdir unless File.directory? outdir
  files = []
  Dir.chdir (File.join(indir, ref)) { files = Dir.glob("*passed_cluster_sequences.fasta")}

  files.each do |f|
    f =~ /Barcode(\d+)\_/
    bar = $1
    seqs = fasta_to_hash(File.join(indir, ref, f))
    out_fasta_file = File.open(File.join(outdir, "Barcode" + bar.to_s), "w")
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

      out_fasta_file.puts csv_hash[bar] + "\sCluster-" + $2.to_s + "\sReadCount-" + $3.to_s
      out_fasta_file.puts seqs[k]

    end
    out_fasta_file.close
  end
  out.close
end

puts "Done! Results can be found in #{indir}"
