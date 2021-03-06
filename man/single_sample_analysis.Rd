% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/seurat.R
\name{single_sample_analysis}
\alias{single_sample_analysis}
\title{Perform single sample Seurat analysis}
\usage{
single_sample_analysis(
  object,
  mt_gene_file = NULL,
  cp_gene_file = NULL,
  dimensionality = 20
)
}
\arguments{
\item{object}{A Seurat object}

\item{mt_gene_file}{A file contains mitochondrial genes.}

\item{cp_gene_file}{A file contains chloroplast genes.}

\item{dimensionality}{Number of dimensions to use as input.}
}
\value{
A Seurat object
}
\description{
Perform single sample Seurat analysis
}
