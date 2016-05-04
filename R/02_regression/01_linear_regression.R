################################################################################
# This script is teaches you basics of linear regresion
# You will learn
# 1. How to fit a regression model
# 2. How to diagnose the error term
# 3. How to interpret coefficients & other output
# 4. How to use RMSE to evaluate out-of-sample fit
################################################################################

# Clear out your workspace whenever starting a new script. It's best practice
# to start with a clean slate so someone reviewing your script knows exactly
# what it does and what it doesn't do. 

rm(list=ls()) 

# I recommend loading libraries at the top of the file so you can quickly see
# its dependencies

library(MASS) # we're using data and stepwise regression from MASS

################################################################################
# Load your data and inspect it
################################################################################

data(cats)

str(cats)

# Data contains two numeric variables and one categorical variable

pairs(cats)


################################################################################
# For now, focus on the mechanics, not training/test
################################################################################


# make a formula
f <- as.formula("Bwt ~ Hwt + Sex")

# Linear regression with two variables
fit <- lm(f, data=cats)

# Diagnostic plots of our model.
# Hit return several times. We'll go through the following plots
#
# Residuals vs Fitted: This should be a cloud. No correlation.
# Normal Q-Q: Our points should follow the diagonal line
# Scale-location: also a cloud
# Residuals vs. Levarage: good for detecting outliers
plot(fit)


# Summary of results
summary(fit)


# You can extract various objects with built in functions

coefficients(fit) # coefficients

confint(fit, level=0.95) # 95% confidence intervals

fitted(fit) # fitted values

fit$fitted.values # also, fitted values

residuals(fit) # fit error

fit$residuals # also, fit error


################################################################################
# Example: predicting mpg 
################################################################################

# load data and inspect

auto <- read.csv("data_raw/auto_mpg.csv")

str(auto)

pairs(auto[ , 1:6 ]) #  last 3 variables are identifiers

# partition data into training and test sets
test <- sample(1:nrow(auto), 50)

auto_training <- auto[ -test , ]

auto_test <- auto[ test , ]


# fit a preliminary model
f <- as.formula("mpg ~ cylinders + displacement + 
                horsepower + weight + acceleration")

fit <- lm(f, data = auto_training)

summary(fit)

plot(fit)

prediction <- predict(fit, newdata=auto_test)

# plotting predicted vs actual values, I see a non-linear correlation...
plot(prediction, auto_test$mpg, xlab="Fitted", ylab="Actual")


# Let's add some non-linear terms!
# Use I() in your formula to do transformations
f2 <- as.formula("mpg ~ cylinders + displacement + horsepower + weight + 
                 acceleration + I(cylinders^2) + I(displacement^2) + 
                 I(horsepower^2) + I(displacement^2)")

fit2 <- lm(f2, data=auto_training)

summary(fit2)

plot(fit2)

prediction2 <- predict(fit2, newdata=auto_test)

plot(prediction2, auto_test$mpg, xlab="Actual", ylab="Fitted")

# getting better...

auto_training$gpm <- auto_training$mpg ^ (-1)

auto_test$gpm <- auto_test$mpg ^ (-1)

f3 <- as.formula("gpm ~ cylinders + displacement + horsepower + weight + 
                 acceleration + I(cylinders^2) + I(displacement^2) + 
                 I(horsepower^2) + I(displacement^2)")


fit3 <- lm(f3, data = auto_training)

summary(fit3)

plot(fit3)

prediction3 <- predict(fit3, newdata=auto_test)

plot(prediction3, auto_test$gpm)

hist(auto_test$gpm - prediction3, breaks=15)

shapiro.test(auto_test$gpm - prediction3)

# Let's use stepwise regression to select variables

step <- stepAIC(fit3, direction="both")

summary(step)

plot(step)

prediction_step <- predict(step, newdata=auto_test)

plot(prediction_step, auto_test$gpm, xlab="Fitted", ylab="Actual")

# overall, which one does best? We're going to use root mean squared error

rmse1 <- sqrt(mean((prediction  - auto_test$mpg)^2))

rmse2 <- sqrt(mean((prediction2  - auto_test$mpg)^2))

rmse3 <- sqrt(mean((prediction3  - auto_test$gpm)^2))

rmse_step <- sqrt(mean((prediction_step  - auto_test$gpm)^2))


################################################################################
# Exercise: do on your own
################################################################################

# Did you know that random forest and svm can also do regression?

# 1. Load the randomForest and e1071 libraries

# 2. Use f2, our kitchen sink model as your formula

# 3. Fit an svm with the formula from step 2. Don't set type, svm will figure it out
#    You can type help(svm) to see what its default behavior is...

# 4. Fit a random forest model with the formula from step 2.

# 5. Predict using our svm and random forest models.

# 6. Calculate the RMSE for these prediction values

# 7. Which model performs the best?


################################################################################
# Exercise answers
################################################################################

# Did you know that random forest and svm can also do regression?

# 1. Load the randomForest and e1071 libraries
library(e1071)
library(randomForest)

# 2. Use f2, our kitchen sink model as your formula

# 3. Fit an svm with the formula from step 2. Don't set type, svm will figure it out
#    You can type help(svm) to see what its default behavior is...
fit_svm <- svm(f2, data=auto_training)

# 4. Fit a random forest model with the formula from step 2.
fit_rf <- randomForest(f2, data=auto_training)

# 5. Predict using our svm and random forest models.
p_svm <- predict(fit_svm, newdata=auto_test)

p_rf <- predict(fit_rf, newdata=auto_test)

# 6. Calculate the RMSE for these prediction values
rmse_svm <- sqrt(mean((p_svm - auto_test$mpg)^2))

rmse_rf <- sqrt(mean((p_rf - auto_test$mpg)^2))

# 7. Which model performs the best?

rmse1

rmse2

rmse_step

rmse_svm

rmse_rf
