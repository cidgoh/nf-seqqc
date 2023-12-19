include { SEQTK_SUBSEQ } from '../../modules/nf-core/seqtk/subseq/main'

// params.min_length = 0 // default value
// params.max_length = Integer.MAX_VALUE // default value

process FILTER_ASSEMBLY_LENGTH {

    tag "${meta.id}"
    label 'process_medium'

    input:
    tuple val(meta), path(assembly)

    output:
    tuple val(meta), path('filtered_assembly.fasta'), emit: filtered_assembly

    script:
    """
    #!/bin/bash
    awk -v min_length=${params.min_length} -v max_length=${params.max_length} \
        'BEGIN {FS="\\n"; RS=">"; ORS=""; min_filtered_length="inf"; max_filtered_length=0} \
        NR > 1 { \
            seq = substr(\$0, index(\$0, "\\n") + 1); \
            seq_length = length(seq) - gsub("\\n", "", seq); \
            if (seq_length >= min_length && seq_length <= max_length) { \
                print ">"\$0; \
                if (seq_length < min_filtered_length) {min_filtered_length = seq_length;} \
                if (seq_length > max_filtered_length) {max_filtered_length = seq_length;} \
            } \
        }' ${assembly} > filtered_assembly.fasta

    SEQTK_SEQ(filtered_assembly.fasta)
    """
}

