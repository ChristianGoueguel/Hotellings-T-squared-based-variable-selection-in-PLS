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

X %<>% select(Tsq_pls$mv[[1]])
