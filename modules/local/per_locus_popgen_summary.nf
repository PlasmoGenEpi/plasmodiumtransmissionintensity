/*
 * STEP - PER_LOCUS_POPGEN_SUMMARY
 * Summarise total, unique, and singlet alleles called per locus
 */

process PER_LOCUS_POPGEN_SUMMARY {

    label 'process_single'

    input:
    path allele_table

    output:
    path ("per_locus_popgen_summary.tsv"), emit: per_locus_popgen_summary

    script:
    """
    Rscript ${projectDir}/bin/PGEcore/scripts/per_locus_popgen_summary_wrapper/per_locus_tajima_d_summary_wrapper.R \\
        --allele_table ${allele_table} 
    """
}
