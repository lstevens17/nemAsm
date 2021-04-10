#!/usr/bin/env nextflow

// set up
nextflow.preview.dsl=2
date = new Date().format( 'yyyyMMdd' )

// collect parameters
params.strain = null 
params.reads = null
reads = Channel.fromPath(params.reads, checkIfExists: true)
params.outdir = "${params.strain}_reads2assembly"

// add test process
process calculate_read_stats {
    publishDir "${params.outdir}", mode: 'copy'
    conda '/lustre/scratch116/tol/teams/team301/users/ls30/miniconda3/envs/seqkit_env'
    
    input:
        path(reads)

    output:
        path "${reads}_seqkit_stats.tsv"

    script:
    """
    seqkit stats -a -T $reads >${reads}_seqkit_stats.tsv
    """
}

// specify workflow
workflow {
    calculate_read_stats(reads)
}