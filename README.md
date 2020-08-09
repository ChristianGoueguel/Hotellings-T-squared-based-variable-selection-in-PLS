# Hotelling-T-squared-based-variable-selection-in-PLS
**Exploring Hotelling-T² based variable selection in PLS for modeling high dimensional spectroscopic data.**

One of the most common challenge encountered in the modeling of spectroscopic data, is to select a subset of variables (i.e. wavelengths) out of a large number of variables associated with the response variable. In fact, it is common for spectroscopic data to have a large number of variables relative to the number of observations. In such a situation, the selection of a smaller number of variables is crucial especially if we want to speed up the computation time, and gain in model’s stability and interpretability. Typically, variable selection methods are classified into two groups:

* Filter-based methods: the most relevant variables are selected as a preprocessing step independently of the prediction model.
* Wrapper-based methods: use the supervised learning approach. Hence, any PLS-based variable selection is a wrapper method. Wrapper methods need some sort of criterion that relies solely on the characteristics of the data at hand.

For illustrative purposes, let's consider a regression problem for which the relation between the response variable **y** (*n* × 1) and the predictor matrix **X** (*n* × *p*) is assumed to be explained by the linear model **_y_** = ***β*** **X**, where ***β*** (*p* × 1) is the regression coefficients. Our objective is to find some columns subsets of **X** with satisfactorily predictive power for **_y_**, using Hotelling-T² based variable selection.

![plsr calibration plot with variable selection ouliers removed](https://user-images.githubusercontent.com/59129468/89723760-5b7fa500-d9c8-11ea-99d7-a55dccd2d83d.png)

https://towardsdatascience.com/hotelling-t²-based-variable-selection-in-partial-least-square-pls-165880272363
