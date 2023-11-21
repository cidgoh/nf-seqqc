include { SEQTK_SUBSEQ } from '../modules/nf-core/seqtk/subseq/main'

params.min_length = 0 // default value
params.max_length = Integer.MAX_VALUE // default value

process FILTER_ASSEMBLY_LENGTH {

    tag "${meta.id}"
    label 'process_medium'

    input:
    tuple val(meta), path(assembly)

    output:
    tuple val(meta), path('filtered_assembly.fasta'), emit: filtered_assembly

    script:
    """
    # Using awk to filter assembly based on length
    awk -v min_length=${params.min_length} -v max_length=${params.max_length} \\
        '/^>/ {if (n>=min_length && n<=max_length) print seq; seq=$0; n=0; next;} {seq=seq "\\n" \$0; n+=length(\$0);} \\
        END {if (n>=min_length && n<=max_length) print seq;}' \\
        ${assembly} > assembly_filtered.fasta

    # Now, use the seqtk_seq module to format the filtered assembly
    SEQTK_SEQ(assembly_filtered.fasta)
    """
}

