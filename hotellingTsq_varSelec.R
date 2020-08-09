#########################################
# Hotelling-T² based variable selection #
#########################################

library(plsVarSel)

pls_format <- data.frame(Ca = I(as.matrix(yTrain)), LIBS = I(as.matrix(XTrain)))

Tsq_pls <- T2_pls(ytr = pls_format$Ca[1:233], 
                  Xtr = pls_format$LIBS[1:233, ], 
                  yts = pls_format$Ca[-(1:233)], 
                  Xts = pls_format$LIBS[-(1:233), ], 
                  ncomp = 12, 
                  alpha = 0.01)

matplot(t(pls_format$LIBS), type = 'l', col=1, ylab='intensity')

points(Tsq_pls$mv[[1]], colMeans(pls_format$LIBS)[Tsq_pls$mv[[1]]], col=2, pch='x')

points(Tsq_pls$mv[[2]], colMeans(pls_format$LIBS)[Tsq_pls$mv[[2]]], col=3, pch='o')


XTrain_var <- XTrain %>% select(toto[[1]])

set.seed(0101)
pls_fit <- train(x = XTrain_var, 
                 y = yTrain,
                 method = "pls",
                 preProcess = c("center"),
                 metric = "RMSE", 
                 trControl = train_fit,
                 tuneLength = 15
)

library(Metrics)
percent_bias(actual = tmp_cal$reference, predicted = tmp_cal$predicted)
