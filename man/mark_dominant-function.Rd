% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tss_metrics.R
\name{mark_dominant}
\alias{mark_dominant}
\title{Mark Dominant}
\usage{
mark_dominant(
  experiment,
  data_type = c("tss", "tsr"),
  threshold = NULL,
  use_normalized = FALSE,
  mark_per = "default"
)
}
\arguments{
\item{experiment}{TSRexploreR object with annotated TSSs/TSRs}

\item{data_type}{Either 'tss' or 'tsr'}

\item{threshold}{Read threshold for TSS/TSRs}

\item{use_normalized}{Whether to use normalized counts}

\item{mark_per}{By default marks dominant TSR per gene, and dominant TSS per TSR.
TSSs can also be set per as dominant TSS per 'gene'.}
}
\value{
tsr exlorer object with dominant status added to TSSs or TSRs.
}
\description{
Mark TSSs as dominant TSS per TSR or gene, or TSRs as dominant per gene.
}
\details{
This function marks which TSSs are dominant per TSR or gene,
  or which TSR is dominant per gene.
Analysis of dominant features may help to cut through the noise to get
  information such as the primary 5' UTR, sequence features associated with the
  the strongest TSS, and other related questions.

Setting a 'threshold' will only mark a TSS or TSR as dominant if their score
   is greater than or equal to the threshold.

'mark_per' controls the behavior of the function.
For TSSs 'default' will mark dominant TSS per TSR, and for TSRs the dominant
  TSR per gene is marked.
for TSSs, 'gene' can also be specified, which will mark the dominant TSS per gene.
}
\examples{
TSSs <- system.file("extdata", "S288C_TSSs.RDS", package="TSRexploreR")
TSSs <- readRDS(TSSs)
tsre_exp <- tsr_explorer(TSSs)
tsre_exp <- format_counts(tsre_exp, data_type="tss")
tsre_exp <- tss_clustering(tsre_exp)
tsre_exp <- associate_with_tsr(tsre_exp, sample_list=list(
  "S288C_WT_1"="S288C_WT_1", "S288C_WT_2"="S288C_WT_2", "S288C_WT_3"="S288C_WT_3",
  "S288C_D_1"="S288C_D_1", "S288C_D_2"="S288C_D_2", "S288C_D_3"="S288C_D_3"
))
tsre_exp <- mark_dominant(tsre_exp, data_type="tss")

}
\seealso{
\code{\link{associate_wth_tsr}} to associate TSSs with TSRs prior to marking
  dominant TSS per TSR.
}
