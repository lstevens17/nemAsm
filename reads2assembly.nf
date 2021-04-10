#!/usr/bin/env nextflow

// set up
nextflow.preview.dsl=2
date = new Date().format( 'yyyyMMdd' )

// collect parameters
params.strain = null 
params.outdir = "${params.strain}_reads2assembly"

