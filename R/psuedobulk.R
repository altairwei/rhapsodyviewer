#' Make psuedo-bulk RNA-Seq from scRNA-Seq.
#'
#' @param data_folders A vector of Rhapsody WTA results folder path.
#' @param normalization Normalization methods to apply. Available values
#'    are same as \code{Seurat::NormalizeData} plus "SCTransform".
#' @param method Psuedo-bulk method to apply. Available values
#'    are \code{avg} and \code{sum} .
#' @return A data.frame containing psuedo-bulk RNA-Seq expression data.
#'
#' @export
make_psuedo_bulk <- function(
  data_folders,
  normalization = "LogNormalize",
  method = "avg") {
  stopifnot(is.character(data_folders))
  names(data_folders) <- basename(data_folders)
  mat_list <- lapply(data_folders, function(base_dir) {
    expr_matrix <- read_rhapsody_wta(base_dir, TRUE)
    seurat_obj <- Seurat::CreateSeuratObject(
      counts = expr_matrix, project = basename(base_dir))
    seurat_obj$stim <- basename(base_dir)
    # Normalization
    if (normalization == "SCTransform") {
      seurat_obj <- Seurat::SCTransform(
        seurat_obj, do.scale = FALSE)
    } else {
      seurat_obj <- Seurat::NormalizeData(
        seurat_obj, normalization.method = normalization)
    }
    # Return normalized data
    Seurat::GetAssayData(seurat_obj)
  })

  .make_psuedo_bulk(mat_list, method)
}

.make_psuedo_bulk <- function(
  cell_gene_matrix_list,
  method = "avg") {
  stopifnot(!is.null(names(cell_gene_matrix_list)))

  method_to_apply <- switch(method,
    avg = Matrix::rowMeans,
    sum = Matrix::rowSums,
    Matrix::rowMeans
  )

  # A list of named vector which contains expression data
  expr_list <- lapply(cell_gene_matrix_list, function(mat) {
    # Gene average expression. (row = genes, col = cells)
    # `expm1` is used in Seurat::AverageExpression
    expr <- log1p(method_to_apply(expm1(mat)))
    stopifnot(expr >= 0L)

    expr
  })

  # Union of genes from all sample
  all_genes <- Reduce(union, lapply(expr_list, names))

  data_list <- lapply(expr_list, function(expr) {
    stopifnot(!is.null(names(expr)))

    # Fill NA with zero
    expr[setdiff(all_genes, names(expr))] <- 0
    stopifnot(length(all_genes) == length(expr))

    # Re-order expression data by gene names
    expr[all_genes]
  })

  df <- as.data.frame(
    data_list, row.names = all_genes, check.names = FALSE)

  df
}