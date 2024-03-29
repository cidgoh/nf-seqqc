// import modules
include { SHOVILL } from '../../modules/nf-core/shovill'
include { RENAME_CTG as RENAME_CTG_SHOVILL; RENAME_CTG as RENAME_CTG_DRAGONFLYE } from '../../modules/local/rename_ctg'
// include {  } from '../../modules/local/rename_shovill'
include { DRAGONFLYE } from '../../modules/nf-core/dragonflye'

workflow WGS_ASSEMBLY {
    take: 
    reads

    main:
    if (params.mode=="nanopore"){
        reads | DRAGONFLYE
        RENAME_CTG_DRAGONFLYE(DRAGONFLYE.out.contigs, reads.map{ "fa" })

        contigs = RENAME_CTG_DRAGONFLYE.out
        corrections = []
        assembly_log = DRAGONFLYE.out.log
        raw_contigs = DRAGONFLYE.out.raw_contigs
        gfa = DRAGONFLYE.out.gfa
        dragonflye_info = DRAGONFLYE.out.txt
        versions = DRAGONFLYE.out.versions
    }
    else{
        reads.filter{ it[0].single_end == false } | SHOVILL
        
        // rename contig files
        RENAME_CTG_SHOVILL(SHOVILL.out.contigs, reads.map{ "fa" })

        contigs = RENAME_CTG_SHOVILL.out
        corrections = SHOVILL.out.corrections
        assembly_log = SHOVILL.out.log
        raw_contigs = SHOVILL.out.raw_contigs
        gfa = SHOVILL.out.gfa
        dragonflye_info = []
        versions = SHOVILL.out.versions
    }
    
    emit:
    ch_contigs = contigs
    ch_corrections = corrections
    ch_asembly_log = assembly_log
    ch_raw_contigs = raw_contigs
    ch_gfa = gfa
    ch_dragonflye_info = dragonflye_info
    ch_versions = versions
}