# PacBio SMRT sequencing PBAA workflow on Longleaf.

The three scripts follow up with  `lima --split-bam` process.

## bam2fastq.rb

Batch process the bam files using `bedtools bamtofastq`

Example:

```console
~$ ruby bam2fastq.rb <directory_of_bam_files>
```
After this process, bam files will be converted into fastq files with same file names in the same directory.

## fastq2fai.rb

Batch index the fastq files using `samtools faidx`

Example"

```console
~$ ruby fastq2fai.rb <directory_of_fastq_files>
```

After this process, an index fai file will be generated for each fastq file in the same directory.

## pbaa.rb

Batch process the sequences through `pbaa`

Guide sequences in the directory of the /guide. Each guide fasta file requires an index fai file with the same file basename.

Guide sequence fasta files can have more than one guide sequence in each file.

Default email is set as admin's email.

example command:

```console
~$ ruby pbaa.rb <directory_of_fastq_files> <email>
```

Results will be in the `/pbaa_results` directory in the input directory, separated by each guide sequence file in the `/guide` directory.

## pbaa_summary.rb

After the PBAA process, summarize the sequence tags in the `passed_cluster_sequences.fasta` files as `csv` file.

example command:

```console
~$ ruby pbaa_summary.rb <directory_of_fastq_files>
```

Summary `csv` files will found in the `/pbaa_results` directory.
