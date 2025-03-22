/*
 * STEP - ALLELE_PER_LOCUS_SUMMARY
 * Summarise total, unique, and singlet alleles called per locus
 */

process ALLELE_PER_LOCUS_SUMMARY {

    label 'process_single'

    input:
    path allele_table

    output:
    path ("allele_summary_by_target.tsv"), emit: allele_summary_by_target

    script:
    """
    Rscript ${projectDir}/bin/PGEcore/scripts/allele_per_locus_summary/allele_per_locus_summary.R \\
        --allele_table ${allele_table} 
    """
}
