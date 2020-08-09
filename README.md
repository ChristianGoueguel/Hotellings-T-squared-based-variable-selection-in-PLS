# Hotelling-T-squared-based-variable-selection-in-PLS
Exploring Hotelling-T² based variable selection in PLS for modeling high dimensional spectroscopic data.

One of the most common challenge encountered in the modeling of spectroscopic data, is to select a subset of variables (i.e. wavelengths) out of a large number of variables associated with the response variable. In fact, it is common for spectroscopic data to have a large number of variables relative to the number of observations. In such a situation, the selection of a smaller number of variables is crucial especially if we want to speed up the computation time, and gain in model’s stability and interpretability. Typically, variable selection methods are classified into two groups:

* Filter-based methods: the most relevant variables are selected as a preprocessing step independently of the prediction model.
* Wrapper-based methods: use the supervised learning approach.

Hence, any PLS-based variable selection is a wrapper method. Wrapper methods need some sort of criterion that relies solely on the characteristics of the data at hand.

https://towardsdatascience.com/hotelling-t²-based-variable-selection-in-partial-least-square-pls-165880272363
