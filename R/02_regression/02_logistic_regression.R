################################################################################
# This script is teaches you basics of logistic regresion
# You will learn
# 1. How to fit a logistic regression model
# 2. How to logistic regression compares to random forest
#
# Read more: http://www.statmethods.net/advstats/glm.html
################################################################################

# Clear out your workspace whenever starting a new script. It's best practice
# to start with a clean slate so someone reviewing your script knows exactly
# what it does and what it doesn't do. 

rm(list=ls()) 

library(pROC)
library(randomForest)

load("data_derived/evaluate_function.RData") 

################################################################################
# Load data: 
################################################################################

# load full dataset
titanic <- read.csv("data_raw/titanic.csv")

# load our training and test sets from before
load("data_derived/titanic_test_training.RData")


################################################################################
# Build a simple model
################################################################################

# formula
f <- as.formula("Survived ~ Age + Sex + Class")

# basic logistic regression
fit <- glm(f, data=titanic_training, family=binomial())

str(fit)

# Out-of-sample fit - automatically gives probabilities
pred <- predict(fit, newdata=titanic_test)

logistic_roc <- roc(response=titanic_test$Survived == "Yes", 
                    predictor=pred)

plot(logistic_roc, main=paste("Logistic Regression, AUC =", 
                              round(logistic_roc$auc, 2)))

################################################################################
# Get a random forest model
################################################################################

fit_rf <- randomForest(f, data=titanic_training)

pred_rf <- predict(fit_rf, newdata=titanic_test, type="prob")

rf_roc <- roc(response=titanic_test$Survived == "Yes", 
              predictor=pred_rf[ , "Yes" ])

# compare RF to Logistic
plot(rf_roc)
lines(logistic_roc, col="red", lty=2)

legend("bottomright",
       legend=c(paste("Rand. Forest", round(rf_roc$auc, 2)),
                paste("Logistic", round(logistic_roc$auc, 2))),
       lty=c(1,2), col=c("black", "red"))

