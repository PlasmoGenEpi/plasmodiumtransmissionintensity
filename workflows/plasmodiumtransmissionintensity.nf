/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
// include { paramsSummaryMap } from 'plugin/nf-schema'
// include { paramsSummaryMultiqc } from '../subworkflows/nf-core/utils_nfcore_pipeline'
// include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
// include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_plasmodiumdrugres_pipeline'

// include { EXTRACT_ALLELE_TABLE } from '../modules/local/extract_allele_table'
include { ESTIMATE_COI_NAIVE } from '../modules/local/estimate_coi_naive'
include { COUNT_SAMPLES_BY_COI } from '../modules/local/count_samples_by_coi'
include { RUN_MOIRE } from '../modules/local/run_moire'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow PLASMODIUMDRUGRES {
    take:
    allele_table

    main:


    ESTIMATE_COI_NAIVE(allele_table)
    TRANSLATE_LOCI_OF_INTEREST(allele_table, panel_info_bed_with_ref, loci_of_interest_bed, translate_loci_extra_args)

    // Estimate single locus allele prevalence
    ESTIMATE_ALLELE_PREVALENCE_NAIVE(TRANSLATE_LOCI_OF_INTEREST.out.collapsed_amino_acid_calls)

    // Estimate Multi Loci Allele Frequency 
    ESTIMATE_MLAF(mlaf_method, TRANSLATE_LOCI_OF_INTEREST.out.collapsed_amino_acid_calls, loci_groups)

    // Single locus allele frequency 
    if (slaf_method == 'from_mlaf') {
        ESTIMATE_SLAF(slaf_method, ESTIMATE_MLAF.out.mlaf_output)
    } else {
        ESTIMATE_SLAF(slaf_method, TRANSLATE_LOCI_OF_INTEREST.out.collapsed_amino_acid_calls)
    }

    // OUTPUT
    CREATE_OUTPUT(ESTIMATE_SLAF.out.slaf_output, ESTIMATE_ALLELE_PREVALENCE_NAIVE.out.allele_prevalence, ESTIMATE_MLAF.out.mlaf_output)


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

    emit:
    sl_summary = CREATE_OUTPUT.out.sl_summary
    ml_summary = CREATE_OUTPUT.out.ml_summary
    // versions = ch_versions // channel: [ path(versions.yml) ]
}


// 