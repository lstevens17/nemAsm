#!/usr/bin/env nextflow

// set up
nextflow.preview.dsl=2
date = new Date().format( 'yyyyMMdd' )

// collect parameters
strain = Channel.of(params.strain)
reads = Channel.fromPath(params.reads, checkIfExists: true)
params.outdir = "${params.strain}_reads2assembly"

// calculate PacBio HiFi read stats
process calculate_read_stats {
    publishDir "${params.outdir}", mode: 'copy'
    conda '/lustre/scratch116/tol/teams/team301/users/ls30/miniconda3/envs/seqkit_env'
    
    input:
        tuple val(strain), path(reads)

    output:
        path "${strain}_read_statistics.tsv"

    script:
    """
    seqkit stats -a -T $reads >${strain}_read_statistics.tsv
    """
}

// generate preliminary wtdbg2 assembly
process prelim_wtdbg2_assembly {
    publishDir "${params.outdir}", mode: 'copy'
    conda '/lustre/scratch116/tol/teams/team301/users/ls30/miniconda3/envs/wtdbg2_env'
    
    input:
        tuple val(strain), path(reads)

    output:
        path "${strain}_wtdbg2_prelim.fa"

    script:
    """
    wtdbg2 -fo ${strain}_wtdbg2_prelim -t ${task.cpus} -x ccs -g 100m -i $reads
    wtpoa-cns -t ${task.cpus} -i ${strain}_wtdbg2_prelim.ctg.lay.gz -fo ${strain}_wtdbg2_prelim.fa
    """
}

// specify workflow
workflow {
    calculate_read_stats(strain.combine(reads))
    prelim_wtdbg2_assembly(strain.combine(reads))
}