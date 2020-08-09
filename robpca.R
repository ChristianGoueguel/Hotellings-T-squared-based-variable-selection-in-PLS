######################################
#         ROBPCA modeling            #
######################################

# Model fitting
pca_mod <- spec_avg %>%
  select(-spectra, -Ca) %>%
  as.matrix() %>%
  rospca::robpca(k = 0,
                 kmax = 5,
                 alpha = 0.75,
                 h = NULL,
                 mcd = FALSE,
                 ndir = 5000,
                 skew = TRUE
                )

# Extracting explained variance
j = length(pca_mod$eigenvalues)
pca_eig <- matrix(nrow = 1, ncol = j)
for (i in 1:j) {
  pca_eig[, i] <- pca_mod[["eigenvalues"]][i] / sum(pca_mod[["eigenvalues"]])
}

# Scree plot
tibble(components = seq(1, j), variance = t(pca_eig * 100)) %>%
  ggplot() +
  geom_col(aes(x = components, y = variance), fill = "#17456E", colour = "black", position = "dodge") +
  geom_text(aes(x = components, y = variance, label = paste0(signif(variance, digits = 3), "%")), nudge_x = 0.1, nudge_y = 4) +
  geom_line(aes(x = components, y = variance), colour = "red") +
  geom_point(aes(x = components, y = variance), colour = "red") +
  ylim(0, 105) +
  labs(title = "Scree plot", subtitle = "Averaged spectra", x = "Principal Component", y = "Percent Variance Explained")

# Scores scatter plot
spec_avg %>%
  select(spectra, Ca) %>%
  cbind(., pca_mod[["scores"]]) %>%
  as_tibble() %>% 
  ggplot(aes(x = PC1, y = PC2, fill = Ca)) + 
  geom_point(size = 3, alpha = 1, shape = 21) + 
  stat_ellipse(geom = "path", type = "t", level = .95, colour = "darkred", size = .4) + 
  stat_ellipse(geom = "path", type = "t", level = .9975, colour = "darkgreen", size = .4) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black", size = .5) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "black", size = .5) +
  geom_rug(stat = "identity", size = 0.3, alpha = 1/2, colour = "#08306b", position = "jitter") +
  annotate("text", x = -.4e5, y = 63000, label = "95% conf. level", colour = "darkred", angle = 17) +
  annotate("text", x = -.5e5, y = 88000, label = "99% conf. level", colour = "darkgreen", angle = 15) +
  labs(x = "t1 [59.6%]", y = "t2 [24.8%]", fill = "Ca (%)") +
  theme(axis.title.x = element_text(face = "bold"), axis.title.y = element_text(face = "bold"))

# Outlier map
tbl_out <- spec_avg %>%
  select(spectra, Ca) %>%
  tibble(sd = pca_mod[["sd"]], od = pca_mod[["od"]], flag_sd = pca_mod$flag.sd, flag_od = pca_mod$flag.od, flag_all = pca_mod$flag.all)

cutoff_sd <- pca_mod[["cutoff.sd"]]
cutoff_od <- pca_mod[["cutoff.od"]]

tbl_out %>% 
  ggplot(aes(x = sd, y = od, fill = Ca)) +
  geom_point(size = 3, alpha = 1, shape = 21) +
  geom_hline(yintercept = cutoff_od, linetype = "dashed", color = "black", size = .5) +
  geom_vline(xintercept = cutoff_sd, linetype = "dashed", color = "black", size = .5) +
  geom_rug(stat = "identity", size = 0.3, alpha = 1/2, colour = "#08306b", position = "jitter") +
  labs(x = "Score distance (4 PCs)", y = "Orthogonal distance", fill = "Ca (%)") +
  theme(axis.title.x = element_text(face = "bold"), axis.title.y = element_text(face = "bold"))


