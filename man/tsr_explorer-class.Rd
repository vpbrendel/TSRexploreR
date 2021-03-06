% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/TSRexplore.R
\docType{class}
\name{tsr_explorer-class}
\alias{tsr_explorer-class}
\alias{tsr_explorer}
\title{TSRexploreR Class}
\usage{
tsr_explorer(
  TSSs = NA,
  TSRs = NA,
  sample_sheet = NULL,
  genome_annotation = NULL,
  genome_assembly = NULL
)
}
\arguments{
\item{TSSs}{Named list of TSS GRanges}

\item{TSRs}{Named list of TSR GRanges}

\item{sample_sheet}{Sample sheet}

\item{genome_annotation}{Genome annotation}

\item{genome_assembly}{Genome assembly}
}
\value{
A TSRexploreR object containing TSSs and/or TSRs
}
\description{
This function generates a new TSRexploreR object for
detailed analysis of transcription start sites (TSSs)
and TSS clusters, referred to here as transcription
start regions (TSRs).
}
\section{Slots}{

\describe{
\item{\code{experiment}}{Named lists containing GRanges of TSSs and/or TSRs}

\item{\code{counts}}{Named lists of TMM and CPM normalized TSSs and/or TSRs}

\item{\code{correlation}}{Named lists of correlation values for TSS and/or TSR sets}

\item{\code{diff_features}}{Differential features}

\item{\code{settings}}{Storage location for arguments used in various functions}

\item{\code{meta_data}}{Storage for meta_data (what metadata? qq)}
}}

\examples{
TSSs <- system.file("extdata", "S288C_TSSs.RDS", package="TSRexploreR")
TSSs <- readRDS(TSSs)
exp <- tsr_explorer(TSSs)

}
