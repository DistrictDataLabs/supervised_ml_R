################################################################################
# This script is teaches you basics of decision trees and random forest
# You will learn
# 1. How to divide data into training and test sets
# 2. How to build a single classification tree
# 3. How to view and interpret some outputs from this classification tree
# 4. How to build random forests of classification trees
# 5. How to view and interpret some outputs from random forests
# 6. How to make predictions with both of these models
################################################################################

# Clear out your workspace whenever starting a new script. It's best practice
# to start with a clean slate so someone reviewing your script knows exactly
# what it does and what it doesn't do. 

rm(list=ls()) 

# I recommend loading libraries at the top of the file so you can quickly see
# its dependencies

library(rpart) # classification and regression trees (CART)
library(randomForest) # random forests of CARTs
library(pROC) # evaluation function from before

load("data_derived/evaluate_function.RData") # This is a modification of the 
                                             # evaluate function from the last 
                                             # module


################################################################################
# Load data, inspect it, and divide it into training and test sets
################################################################################

# load data
titanic <- read.csv("data_raw/titanic.csv")

# Inspect the data structure
str(titanic)

# Since we already plotted and explored this dataset, we'll skip it

# Get a training and test set
test_rows <- sample(1:nrow(titanic), floor(nrow(titanic) / 5))

titanic_test <- titanic[ test_rows , ]

titanic_training <- titanic[ -test_rows , ]

# let's save these for use in future modules
save(titanic_test, titanic_training, 
     file="data_derived/titanic_test_training.RData")

################################################################################
# Single tree classification with the rpart library
################################################################################

# define a formula for our model. 
# Formulas are how most classifiers in R are specified.
# They take the form y ~ x1 + x2 + ...
# Using a formula saves you typing and allows you to use the same specification
# with many different models
f <- as.formula("Survived ~ Age + Sex + Class")

# grow tree
# Note that method is explicitly set. Sometimes the algorithm will "guess" 
# the wrong method and treat our outcome as numeric, not categorical. So, we
# tell it exactly what we want
fit <- rpart(f, method="class", data=titanic_training)

# Hey! A new object! Let's look at its structure
str(fit)

# Lots of stuff in there...

# Show some preliminary results
printcp(fit)

# plot tree 
plot(fit, uniform=TRUE, 
     main="Classification Tree for Survival on the Titanic")
text(fit, use.n=TRUE, all=TRUE, cex=.7)

# you can make a prettier tree using rpart's post() function
# this is designed to write to file, but you can plot it to R's default device
# by setting filename = ''
post(fit, file="", title = "Classification Tree for Survived")

# you can prune the tree based on values of the cp table
# You'll want to prune to avoid overfitting on your training set
fit$cptable

# Let's choose 0.04 to prune (this may not be the best decision)
pfit<- prune(fit, cp=0.04)

# plot the pruned tree 
post(pfit, file = "", 
     title = "Pruned Classification Tree for Survived")


################################################################################
# Use our evaluation function to assess our tree on in-sample and out-of-sample
################################################################################

# This is the same data the model saw when it was training
training_pred <- predict(fit, newdata=titanic_training, type="class")

# this is our held-out data
test_pred <- predict(fit, newdata=titanic_test, type="class")

# We're going to save these all together as lists so we can add to them in a sec...
rpart_training_pred <- list(class_predictions=training_pred, 
                            eval=evaluate(actual = titanic_training$Survived, 
                                          predicted = training_pred))

rpart_test_pred <- list(class_predictions=test_pred, 
                        eval=evaluate(actual = titanic_test$Survived, 
                                      predicted = test_pred))

# first pass: how does in-sample compare with out-of-sample?
rpart_training_pred$eval$metrics$Yes

rpart_test_pred$eval$metrics$Yes

# let's compare this with our pruned tree
rpart_test_pruned <- predict(pfit, newdata=titanic_test, type="class")

rpart_test_pruned <- list(class_predictions = rpart_test_pruned,
                          eval=evaluate(actual = titanic_test$Survived, 
                                        predicted = rpart_test_pruned))


# we can get probabilities out too...
rpart_test_pred$prob_predictions <- predict(fit, newdata=titanic_test, type = "prob")

rpart_test_pred$roc <- roc(response=titanic_test$Survived == "Yes",
                           predictor=rpart_test_pred$prob_predictions[ , "Yes" ])

plot(rpart_test_pred$roc)

################################################################################
# Random Forests with the randomForest package
################################################################################

# Fit a random forest model
fit_rf <- randomForest(f, data=titanic_training)

str(fit_rf)

# random forest gives us its own in-sample confusion matrix
fit_rf$confusion

# it also gives us in-sample probabilities
head(fit_rf$votes)

# get a summary with the print() function 
# (this makes no sense, I know)
print(fit_rf)

# We don't get nice tree plots like rpart since random forest is actually many
# (defaulting to 500) trees. 

# We *can*, however, see which variables are most important in prediction
importance(fit_rf)

# plot these
barplot(fit_rf$importance[ , 1 ], main="Importance of Variables in Random Forest")

# Let's evaluate out-of-sample random forest
prob_pred <- predict(fit_rf, newdata=titanic_test, type="prob")

class_pred <- predict(fit_rf, newdata=titanic_test, type="class")

# leaving class predictions blank for now. Let's choose a threshold...
rf_test_pred <- list(class_predictons=class_pred,
                     eval=evaluate(actual=titanic_test$Survived,
                                   predicted = class_pred),
                     prob_predictions=prob_pred,
                     roc=roc(response=titanic_test$Survived == "Yes",
                             predictor=prob_pred[ , "Yes" ]))

# you can shortcut the plotting of the ROC
plot(rf_test_pred$roc)

# let's compare it to rpart
lines(rpart_test_pred$roc, col="red", lty=2)

legend("bottomright",
       legend=c(paste("Random Forest, AUC:",  round(rf_test_pred$roc$auc, 3)),
                paste("Single Tree, AUC:", round(rpart_test_pred$roc$auc, 3))),
       lty=c(1,2), col=c("black", "red"))

# how about our metrics?
rf_test_pred$eval$metrics$Yes

rpart_test_pred$eval$metrics$Yes

################################################################################
# Exercises. Try these on your own.
#
# We're going to play with a variable with three classes
# We are predicting Species
################################################################################

data(iris)

str(iris)

# 1. Partition iris into training and test sets. Take about 20% (1/5) of the data
#    for a test set



# 2. Grow a single decision tree using rpart. Plot this tree


# 3. Train a random forest predictor. Instead of 500 trees use 100.
#    Hint: type help(randomForest) what does the ntree argument do?
#    Bonus: how many variables does each tree have? (mtry)
  

# 4. Make a barplot of variable importance. Which are most important?


# 5. Make classifications using random forest and your single tree. Evaluate them.
#    Which does better on our hold-out set?

# 6. Get probability predictions. Get a roc for each one. Look at AUC and plot



################################################################################
# Solutions to exercises below
################################################################################

# 1. Partition iris into training and test sets. Take about 20% (1/5) of the data
#    for a test set

test_rows <- sample(1:nrow(iris), size = floor(nrow(iris) / 5))

iris_training <- iris[ -test_rows , ]

iris_test <- iris[ test_rows , ]

# 2. Grow a single decision tree using rpart. Plot this tree

iris_f <- as.formula("Species ~ Petal.Length + Petal.Width + Sepal.Length + 
                     Sepal.Width")

iris_tree <- rpart(iris_f, data=iris_training)


# 3. Train a random forest predictor. Instead of 500 trees use 100.
#    Hint: type help(randomForest) what does the ntree argument do?
#    Bonus: how many variables does each tree have? (mtry)

iris_rf <- randomForest(iris_f, data=iris_training, ntree = 100)


# 4. Make a barplot of variable importance. Which are most important?
barplot(iris_rf$importance[ , 1 ])

# 5. Make classifications using random forest and your single tree. Evaluate them.
#    Which does better on our hold-out set?

pred_tree <- predict(iris_tree, newdata=iris_test, type="class")

pred_rf <- predict(iris_rf, newdata=iris_test, type="class")

evaluate(actual = iris_test$Species, predicted = pred_tree)

evaluate(actual = iris_test$Species, predicted = pred_rf)

# 6. Get probability predictions. Get a roc for each one. Look at AUC and plot

pred_tree_probs <- predict(iris_tree, newdata=iris_test, type="prob")

pred_rf_probs <- predict(iris_rf, newdata=iris_test, type="prob")

tree_rocs <- lapply(levels(iris$Species), function(x){
  
  result <- roc(iris_test$Species == x, pred_tree_probs[ , x ])
  
})

names(tree_rocs) <- levels(iris$Species)

rf_rocs <- lapply(levels(iris$Species), function(x){
  
  result <- roc(iris_test$Species == x, pred_rf_probs[ , x ])
  
})

names(rf_rocs) <- levels(iris$Species)

for(x in levels(iris$Species)){
  plot(tree_rocs[[ x ]], main=x)
  lines(rf_rocs[[ x ]], col="red", lty=2)
  legend("bottomright", 
         legend=c(paste("Tree AUC", round(tree_rocs[[ x ]]$auc, 2)),
                  paste("RF AUC", round(rf_rocs[[ x ]]$auc, 2))),
         col=c("black", "red"), lty=c(1,2))
}
