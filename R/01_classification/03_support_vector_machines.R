################################################################################
# This script is teaches you basics of support vector machines (SVM)
# You will learn
# 1. How to use k-fold cross-validation as a better out-of-sample estimate
# 2. How to build a svm classification models
# 3. How to view and interpret some outputs from svm
# 4. Comparison of svm and random forest in terms of accuracy
################################################################################

# Clear out your workspace whenever starting a new script. It's best practice
# to start with a clean slate so someone reviewing your script knows exactly
# what it does and what it doesn't do. 

rm(list=ls()) 

# I recommend loading libraries at the top of the file so you can quickly see
# its dependencies

library(e1071)# has svm and other machine-learning algorithms
library(pROC) # evaluation function from before

load("data_derived/evaluate_function.RData") 

################################################################################
# Load data: 
################################################################################

# load full dataset
titanic <- read.csv("data_raw/titanic.csv")

# load our training and test sets from before
load("data_derived/titanic_test_training.RData")


################################################################################
# Build a simple SVM
################################################################################

# formula
f <- as.formula("Survived ~ Age + Sex + Class")

# basic SVM
fit <- svm(f, data=titanic_training, type="C-classification")

str(fit)

# In-sample fit
svm_in_sample <- evaluate(actual = titanic_training$Survived,
                          predicted = fit$fitted)

svm_in_sample$metrics$Yes

# Out-of-sample fit 
pred <- predict(fit, newdata=titanic_test)

svm_out_sample <- evaluate(actual = titanic_test$Survived,
                           predicted = pred)

svm_out_sample$metrics$Yes

################################################################################
# K-fold cross validation
#
# Sometimes your out-of-sample fit can be affected by the rows you sampled
# to be your training and test sets. A method to mitigate this is is called
# cross-validation. Here: you partition the data into k sets, build a model on
# k-1 sets and test on the kth set. You iteratively hold out which set is your
# test set and you get a distribution of performance measures.
################################################################################

# K-fold cross validation: Standard selections for k include 5, 10, 12

kFold <- function(data, k){
  
  # randomly sort the data
  data <- data[ sample(1:nrow(data), nrow(data)) , ]
  
  # get K batches of size "step"
  # Note, the last batch may be smaller than the others, depending on 
  # the size of your dataset
  step <- round(nrow(data) / k)
  
  batches <- seq(1, nrow(data), by = step)
  
  # divide the data into these batches
  result <- lapply(batches, function(x){
    data[ x:(min(nrow(data), x + step - 1)) , ]
  })
  
  result
  
}

# let's do 5 fold cross validataion
titanic_folds <- kFold(data = titanic, k = 5)

# let's fit svm models for cross validation and do evaluation
fit_cv <- lapply(1:length(titanic_folds), function(k){
  
  model <- svm(f, data=do.call(rbind, titanic_folds[ -k ]), type="C-classification")
  
  prediction <- predict(model, newdata=titanic_folds[[ k ]])
  
  evaluation <- evaluate(actual = titanic_folds[[ k ]]$Survived,
                         predicted = prediction)
  
  list(model = model, prediction = prediction, evaluation = evaluation)
})

# pull out precision
cv_yes_precision <- sapply(fit_cv, function(x) x$evaluation$metrics$Yes$precision)

summary(cv_yes_precision)

# pull out recall
cv_yes_recall <- sapply(fit_cv, function(x) x$evaluation$metrics$Yes$recall)

summary(cv_yes_recall)

# pull out the FDR
cv_yes_fdr <- sapply(fit_cv, function(x) x$evaluation$metrics$Yes$fdr)

summary(cv_yes_fdr)


################################################################################
# Exercises. Try these on your own.
#
# We're going to use 10-fold cross-validation to compare random forest and 
# svm predictions on the iris data
################################################################################

# load the dataset 
data(iris)

# 1. Inspect the structure of the data. Our outcome variable is "Species"



# 2. Partition data into 10 folds using the kFold function declared above.


# 3. Declare a formula to be used by svm and randomForest


# 4. Load the randomForest library if you haven't already done so



# 5. Use lapply to make a series of cross-validated models and evaluations like
#    we did above. Do this for random forest and for svm.



# 6. Look at your metrics. Which model do you think did better?



################################################################################
# Answers to exercises
################################################################################
# load the dataset 
data(iris)

# 1. Inspect the structure of the data. Our outcome variable is "Type"
str(iris)


# 2. Partition data into 10 folds using the kFold function declared above.
iris_folds <- kFold(data = iris, k = 10)


# 3. Declare a formula to be used by svm and randomForest
f <- as.formula("Species ~ Sepal.Length + Sepal.Width + Petal.Length + Petal.Width")


# 4. Load the randomForest library if you haven't already done so
library(randomForest)



# 5. Use lapply to make a series of cross-validated models and evaluations like
#    we did above. Do this for random forest and for svm.
svm_rf <- lapply(1:length(iris_folds), function(k){
  fit_svm <- svm(f, data=do.call(rbind, iris_folds[ -k ]), type="C-classification")
  fit_rf <- randomForest(f, data=do.call(rbind, iris_folds[ -k ]), type="class")
  p_svm <- predict(fit_svm, newdata=iris_folds[[ k ]])
  p_rf <- predict(fit_rf, newdata=iris_folds[[ k ]], type="class")
  eval_svm <- evaluate(actual = iris_folds[[ k ]]$Species,
                       predicted = p_svm)
  eval_rf <- evaluate(actual = iris_folds[[ k ]]$Species,
                      predicted = p_rf)
  list(eval_svm=eval_svm, eval_rf=eval_rf)
})



# 6. Look at your metrics. Which model do you think did better?
sapply(svm_rf, function(x){
  c(svm=x$eval_svm$metrics$versicolor$precision, 
    rf=x$eval_rf$metrics$versicolor$precision)
})

