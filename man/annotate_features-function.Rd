% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/annotate.R
\name{annotate_features}
\alias{annotate_features}
\title{Annotate Data}
\usage{
annotate_features(
  experiment,
  data_type = c("tss", "tsr", "tss_diff", "tsr_diff"),
  feature_type = c("gene", "transcript"),
  annotation_data = NULL,
  upstream = 1000,
  downstream = 100
)
}
\arguments{
\item{experiment}{TSRexploreR object with TSS GRanges}

\item{data_type}{Whether to annotate TSSs or TSRs}

\item{feature_type}{Annotate at the gene or transcript level}

\item{annotation_data}{Path to annotation file or loaded TxDb object}

\item{upstream}{Bases upstream of TSS for 'promoter' annotation}

\item{downstream}{Bases downstream of TSS for 'promoter' annotation}
}
\value{
TSRexploreR object with annotated features
}
\description{
Use the ChIPseeker package to annotate TSSs or TSRs relative to known genes or transcripts.
}
\details{
This function attempts to assign TSSs or TSRs to the nearest genomic feature.
Genomic annotation data can be provided as either a 'GTF' or 'GFF' file,
  or as a TxDb package from bioconductor.

'feature_type' allows to you link TSSs or TSRs to genes or transcripts.
Furthermore, the size of the promoter region can be defined using
  'upstream' and 'downstream', which are relative to the TSSs
  defined in your annotation data.
}
\examples{
TSSs <- system.file("extdata", "S288C_TSSs.RDS", package="TSRexploreR")
TSSs <- readRDS(TSSs)
tsre_exp <- tsr_explorer(TSSs)
tsre_exp <- format_counts(tsre_exp, data_type="tss")
annotation <- system.file("extdata", "S288C_Annotation.gtf", package="TSRexploreR")
tsre_exp <- annotate_features(
  tsre_exp, annotation_data=annotation,
  data_type="tss", feature_type="transcript"
)

}
