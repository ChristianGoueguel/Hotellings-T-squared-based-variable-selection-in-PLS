######################################
# PLS-R modeling
######################################

train_fit <- trainControl(method = "repeatedcv",
                          number = 7,
                          repeats = 5,
                          search = "grid",
                          p = 0.8,
                          verboseIter = FALSE,
                          returnData = TRUE,
                          returnResamp = "final",
                          allowParallel = TRUE
)

XTrain <- spec_avg %>% select(-spectra, -Ca)
yTrain <- spec_avg$Ca %>% as.numeric()

set.seed(01)
pls_fit <- train(x = XTrain, 
                 y = yTrain,
                 method = "pls",
                 preProcess = c("center"),
                 metric = "RMSE", 
                 trControl = train_fit,
                 tuneLength = 15
)

pls_fit %>%
  ggplot(data = .,
         metric = "RMSE",
         plotType = "scatter",
         highlight = TRUE,
         output = "layered") + 
  theme(axis.title.x = element_text(face = "bold"),
        axis.title.y = element_text(face = "bold")
  ) +
  theme_bw(base_size = 14, 
           base_line_size = base_size / 22,
           base_rect_size = base_size / 15)

tibble(`Figure of merit` = c("RMSE","Rsquared","MAE"), 
       Calibration = c(getTrainPerf(pls_fit)[[1]], getTrainPerf(pls_fit)[[2]], getTrainPerf(pls_fit)[[3]])
) %>% print()

tmp_cal <- tibble(id = as.factor(spec_avg$spectra),
                  reference = yTrain,
                  predicted = predict(pls_fit),
                  residual = reference - predicted,
                  residual_std = residual / sd(residual),
                  out = abs(residual) > quantile(abs(residual), .9975)
)

cal_plot <- 
  tmp_cal %>%
  ggplot(aes(x = predicted, y = reference, colour = out, label = id)) +
  geom_point(size = 2, alpha = .7, show.legend = FALSE) +
  geom_abline(slope = 1, color = "black") +
  geom_smooth(method = "lm", color = "red", linetype = "dashed",size = .5, fill = "lightblue", se = TRUE, fullrange = FALSE, level = .95) +
  scale_color_viridis_d(end = .3, direction = 1) +
  #ggrepel::geom_label_repel(data = filter(tmp_cal, out == 1), show.legend = FALSE) +
  labs(x = "Predicted response", y = "Observed response") +
  theme(legend.position = "none", axis.title.x = element_text(face = "bold"), axis.title.y = element_text(face = "bold"))
ggExtra::ggMarginal(cal_plot, margins = "both", type = "histogram", col = "grey", fill = "orange")

residCal_plot <- 
  tmp_cal %>% 
  ggplot(aes(x = predicted, y = residual_std, colour = out, label = id)) +
  geom_point(size = 2, alpha = .7, show.legend = FALSE) +
  geom_hline(yintercept = 0, color = "black", linetype = "dashed") +
  geom_smooth(method = "loess", color = "red", linetype = "solid",size = .5, se = FALSE) +
  geom_rug(color = "blue", alpha = .5, sides = "l") +
  scale_color_viridis_d(end = .3, direction = 1) +
  #ggrepel::geom_label_repel(data = filter(tmp_cal, out == 1), show.legend = FALSE) +
  labs(x = "Predicted response", y = "Standardized residual") +
  theme(legend.position = "none", axis.title.x = element_text(face = "bold"), axis.title.y = element_text(face = "bold"))
ggExtra::ggMarginal(residCal_plot, margins = "y", type = "histogram", col = "grey", fill = "orange")


nb_LVs <- pls_fit$bestTune$ncomp
t_scores <- as_tibble(pls_fit$finalModel$scores[, 1:nb_LVs])
Err_matrix <- as_tibble(pls_fit$finalModel$residuals)

Q_residuals <- Err_matrix^2 %>%
  rowSums() %>% 
  as_tibble()

Tsq_hotelling <- (t_scores / apply(t_scores, 1, sd))^2 %>%
  rowSums() %>%
  as_tibble()

tmp_dist <- tibble(id = as.factor(spec_avg$spectra),
                   Q_resid = Q_residuals$value,
                   Tsq = Tsq_hotelling$value,
                   out = abs(Q_resid) > quantile(abs(Q_resid), .9975)
)

Tsq_upperlimit <- (nb_LVs*(ncol(XTrain)-1)) / (ncol(XTrain)-nb_LVs)*qf(p = .9975, df1 = nb_LVs, df2 = ncol(XTrain)-nb_LVs)

tmp_dist %>%
  ggplot(aes(x = Tsq, y = Q_resid, colour = out, label = id)) +
  geom_point(size = 2, alpha = .5, show.legend = FALSE) +
  geom_rug(color = "blue", alpha = .3) +
  ggrepel::geom_label_repel(data = filter(tmp_dist, out == 1), show.legend = FALSE) +
  # geom_point(data = filter(tmp_dist, Tsq >= Tsq_upperlimit), aes(x = Tsq, y = Q_resid, colour = "red", label = id)) +
  # ggrepel::geom_label_repel(data = filter(tmp_dist, Tsq >= qchisq(.9975, nb_LVs)), show.legend = FALSE) +
  geom_vline(xintercept = Tsq_upperlimit, linetype = 2) +
  geom_hline(yintercept = quantile(abs(tmp_dist$Q_resid), .9975), linetype = 2) +
  scale_color_viridis_d(end = .4, direction = -1) +
  labs(x = "Hotelling's T-squared", y = "Q residuals") +
  theme(legend.position = "none", axis.title.x = element_text(face = "bold"), axis.title.y = element_text(face = "bold"))

tmp_cal %>%
  ggqqplot(x = "residual_std", color = "red", size = 1) +
  labs(title = "Normal Q-Q plot") +
  theme_bw(base_size = 12, 
           base_rect_size = base_size / 15
  ) +
  theme(axis.title.x = element_text(face = "bold"),
        axis.title.y = element_text(face = "bold")
  )
