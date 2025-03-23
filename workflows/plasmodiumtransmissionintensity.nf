/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
// include { paramsSummaryMap } from 'plugin/nf-schema'
// include { paramsSummaryMultiqc } from '../subworkflows/nf-core/utils_nfcore_pipeline'
// include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
// include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_plasmodiumdrugres_pipeline'

include { ESTIMATE_COI_NAIVE } from '../modules/local/estimate_coi_naive'
include { ALLELE_PER_LOCUS_SUMMARY } from '../modules/local/allele_per_locus_summary'
include { PER_LOCUS_POPGEN_SUMMARY } from '../modules/local/per_locus_popgen_summary'
include { DCIFER_WRAPPER } from '../modules/local/dcifer_wrapper'
include { RUN_MOIRE } from '../modules/local/run_moire'
include { COUNT_SAMPLES_BY_COI as COUNT_SAMPLES_BY_COI_naive } from '../modules/local/count_samples_by_coi'
include { COUNT_SAMPLES_BY_COI as COUNT_SAMPLES_BY_COI_tool } from '../modules/local/count_samples_by_coi'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow PLASMODIUMTRANSMISSIONINTENSITY {
    take:
    allele_table
    naive_coi_method

    main:

    // Run naive coi
    if (naive_coi_method == "NAIVE_INT_METHOD") {
        ESTIMATE_COI_NAIVE(allele_table, "integer_method", params.naive_coi_threshold)
        naive_coi_output = ESTIMATE_COI_NAIVE.out.coi_table
    } else if (naive_coi_method == "NAIVE_QUANTILE_METHOD") {
        ESTIMATE_COI_NAIVE(allele_table, "quantile_method", params.naive_coi_threshold)
        naive_coi_output = ESTIMATE_COI_NAIVE.out.coi_table
    } else {
        throw new IllegalArgumentException("Error: 'naive_coi_method' must be one of ${params.coi_method_options} Provided value: ${method}.")
    }
    COUNT_SAMPLES_BY_COI_naive(naive_coi_output, "naive")

    // Run additional tools.
    // TODO: In future this could be interoperable. e.g. MALECOT
    RUN_MOIRE(allele_table)
    COUNT_SAMPLES_BY_COI_tool(RUN_MOIRE.out.coi_summary, "MOIRE")

    // Estimate between-host relatedness
    DCIFER_WRAPPER(allele_table)

    // Per locus metrics
    ALLELE_PER_LOCUS_SUMMARY(allele_table)
    PER_LOCUS_POPGEN_SUMMARY(allele_table)

    //
    // Collate and save software versions
    //
    // softwareVersionsToYAML(ch_versions)
    //     .collectFile(
    //         storeDir: "${params.outdir}/pipeline_info",
    //         name: 'nf_core_' + 'pipeline_software_' + 'mqc_' + 'versions.yml',
    //         sort: true,
    //         newLine: true,
    //     )
    //     .set { ch_collated_versions }
}
