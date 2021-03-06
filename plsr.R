######################################
#         PLS-R modeling             #
######################################

# Training parameters
train_fit <- caret::trainControl(method = "repeatedcv",
                                 number = 7,
                                 repeats = 5,
                                 search = "grid",
                                 p = 0.8,
                                 verboseIter = FALSE,
                                 returnData = TRUE,
                                 returnResamp = "final",
                                 allowParallel = TRUE
                                 )

# Training
set.seed(101)
pls_fit <- caret::train(x = X,
                        y = y,
                        method = "pls",
                        preProcess = c("center"),
                        metric = "RMSE", 
                        trControl = train_fit,
                        tuneLength = 20
                       )
plot_4 <- pls_fit %>%
  ggplot(data = .,
         metric = "RMSE",
         plotType = "scatter",
         highlight = TRUE,
         output = "layered"
        ) +
  theme(axis.title.x = element_text(face = "bold"), axis.title.y = element_text(face = "bold"))

# Learning curves
set.seed(101)
learn_data <- bind_cols(y, X) %>%
  caret::learning_curve_dat(dat = .,
                            outcome = "y",
                            proportion = (1:10)/10,
                            test_prop = 1/4,
                            verbose = FALSE,
                            method = "pls",
                            metric = "RMSE",
                            trControl = train_fit
                            )
plot_5 <- learn_data %>%
  ggplot(aes(x = Training_Size, y = RMSE, color = Data)) +
  geom_smooth(method = loess, span = .8) +
  labs(x = "Training set size", y = "RMSE") +
  theme(axis.title.x = element_text(face = "bold"), axis.title.y = element_text(face = "bold"))

# Training model performance
tibble(`Figure of merit` = c("RMSE","Rsquared","MAE"), 
       Calibration = c(getTrainPerf(pls_fit)[[1]], getTrainPerf(pls_fit)[[2]], getTrainPerf(pls_fit)[[3]])
      ) %>% print()

tmp_cal <- tibble(id = as.factor(spec_avg$spectra),
                  reference = y,
                  predicted = predict(pls_fit),
                  residual = reference - predicted,
                  residual_std = residual / sd(residual),
                  out = abs(residual) > quantile(abs(residual), .9975)
                 )

# Computing percent error
pct_mape <- Metrics::mape(actual = tmp_cal$reference, predicted = tmp_cal$predicted) * 100
pct_bias <- Metrics::percent_bias(actual = tmp_cal$reference, predicted = tmp_cal$predicted) * 100

# Observed vs. predicted plot
plot_6 <- tmp_cal %>%
  ggplot(aes(x = predicted, y = reference, colour = out, label = id)) +
  geom_point(size = 2, alpha = .7, show.legend = FALSE) +
  geom_abline(slope = 1, color = "black") +
  geom_smooth(method = "lm", color = "red", linetype = "dashed",size = .5, fill = "lightblue", se = TRUE, fullrange = FALSE, level = .95) +
  scale_color_viridis_d(end = .3, direction = 1) +
  ggrepel::geom_label_repel(data = filter(tmp_cal, out == 1), show.legend = FALSE) +
  labs(x = "Predicted response", y = "Observed response") +
  theme(legend.position = "none", axis.title.x = element_text(face = "bold"), axis.title.y = element_text(face = "bold"))
ggExtra::ggMarginal(plot_6, margins = "both", type = "histogram", col = "grey", fill = "orange")

# Residual plot
plot_7 <- tmp_cal %>% 
  ggplot(aes(x = predicted, y = residual_std, colour = out, label = id)) +
  geom_point(size = 2, alpha = .7, show.legend = FALSE) +
  geom_hline(yintercept = 0, color = "black", linetype = "dashed") +
  geom_smooth(method = "loess", color = "red", linetype = "solid",size = .5, se = FALSE) +
  geom_rug(color = "blue", alpha = .5, sides = "l") +
  scale_color_viridis_d(end = .3, direction = 1) +
  ggrepel::geom_label_repel(data = filter(tmp_cal, out == 1), show.legend = FALSE) +
  labs(x = "Predicted response", y = "Standardized residual") +
  theme(legend.position = "none", axis.title.x = element_text(face = "bold"), axis.title.y = element_text(face = "bold"))
ggExtra::ggMarginal(plot_7, margins = "y", type = "histogram", col = "grey", fill = "orange")

# Extracting data from the PLS model
ncomp <- pls_fit$bestTune$ncomp
t_scores <- as_tibble(pls_fit$finalModel$scores[, 1:ncomp])
Err_matrix <- as_tibble(pls_fit$finalModel$residuals)

# Computing Q residuals
Q_residuals <- Err_matrix^2 %>% rowSums() %>% as_tibble()

# Computing T-squared statistics
Tsq_hotelling <- (t_scores / apply(t_scores, 1, sd))^2 %>% rowSums() %>% as_tibble()

# Data frame
tmp_dist <- tibble(id = as.factor(spec_avg$spectra),
                   Q_resid = Q_residuals$value,
                   Tsq = Tsq_hotelling$value,
                   out = abs(Q_resid) > quantile(abs(Q_resid), .9975)
                  )

# Computing a cutoff value for the T-squared statistics
Tsq_cutoff <- (ncomp * (ncol(X) - 1)) / (ncol(X) - ncomp) * qf(p = .9975, df1 = ncomp, df2 = ncol(X) - ncomp)

# Q residuals vs. Hotelling T-squared plot
plot_8 <- tmp_dist %>%
  ggplot(aes(x = Tsq, y = Q_resid, colour = out, label = id)) +
  geom_point(size = 2, alpha = .5, show.legend = FALSE) +
  geom_rug(color = "blue", alpha = .3) +
  ggrepel::geom_label_repel(data = filter(tmp_dist, out == 1), show.legend = FALSE) +
  # geom_point(data = filter(tmp_dist, Tsq >= Tsq_cutoff), aes(x = Tsq, y = Q_resid, colour = "red", label = id)) +
  # ggrepel::geom_label_repel(data = filter(tmp_dist, Tsq >= Tsq_cutoff), show.legend = FALSE) +
  geom_vline(xintercept = Tsq_cutoff, linetype = 2) +
  geom_hline(yintercept = quantile(abs(tmp_dist$Q_resid), .9975), linetype = 2) +
  scale_color_viridis_d(end = .4, direction = -1) +
  labs(x = "Hotelling's T-squared", y = "Q residuals") +
  theme(legend.position = "none", axis.title.x = element_text(face = "bold"), axis.title.y = element_text(face = "bold"))


