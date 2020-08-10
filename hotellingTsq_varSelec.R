#########################################
# Hotelling-T² based variable selection #
#########################################

# Data frame
pls_format <- data.frame(Ca = I(as.matrix(y)), spec = I(as.matrix(X)))

# T-squared PLS
n <- nrow(X)/2
Tsq_pls <- plsVarSel::T2_pls(ytr = pls_format$Ca[1:n], 
                             Xtr = pls_format$spec[1:n, ], 
                             yts = pls_format$Ca[-(1:n)], 
                             Xts = pls_format$spec[-(1:n), ], 
                             ncomp = ncomp, 
                             alpha = 0.01)

# Selected variables (as ind.T2 in T2_pls function)
X %<>% select(Tsq_pls$mv[[1]])

# Running PLSR with the new matrix X
source("plsr.R")
plot_9 <- plot_4
plot_10 <- plot_5
plot_11 <- plot_6
plot_12 <- plot_7
plot_13 <- plot_8


