################################################################################
# This script is teaches you basic model evaluation techniques
# You will learn
# 1. How to make confusion matrices for binary outcomes
# 2. How to calculate certain classification evaluation metrics
# 3. How to turn predicted probabilities into class assignments
# 4. Write a function to calculate metrics without having to copy code
################################################################################

# Clear out your workspace whenever starting a new script. It's best practice
# to start with a clean slate so someone reviewing your script knows exactly
# what it does and what it doesn't do. 

rm(list=ls()) 

# I recommend loading libraries at the top of the file so you can quickly see
# its dependencies

library(pROC)

################################################################################
# Load some datasets pertaining to survival on the Titanic
# This is a derivative of the Titanic data included with R
# type data(Titanic) or ??Titanic for more info on the original source
################################################################################

# Load source data. This is FYI for now, we won't use it in this module
titanic <- read.csv("data_raw/titanic.csv")

# inspect its structure: should be 2235 observations of 4 variables
str(titanic)

# Load some predictions made on a sample of the Titanic data
titanic_predictions <- read.csv("data_raw/titanic_predictions.csv")

str(titanic_predictions)

# This represents the actual value, predicted value, and predicted probabilities 
# for passengers' survival on the Titanic.

################################################################################
# Create a Confusion matrix for two-dimensional outcomes
#
#    | X' | Y' |
# ---|----|----|
#  X | TP | FN |
# ---|----|----|
#  Y | FP | TN |
#
# Above is the confusion matrix for outcome X, where X' is the predicted value
# For outcome Y, positives (P) and negatives (N) would be reversed.
################################################################################

# table() with two variables will make a two-way contingency table
confusion <- table(actual = titanic_predictions$actual,
                   prediction = titanic_predictions$prediction)

confusion

################################################################################
# Get basic counts for calculating our other metrics 
################################################################################

# "No" Predictions
no_counts <- list(tp=confusion[ 1 , 1 ],
                  fp=confusion[ 2 , 1 ],
                  fn=confusion[ 1 , 2 ],
                  tn=confusion[ 2 , 2 ])

# "Yes" Predictions - This is similar to No, but P and N are reversed
yes_counts <- list(tp=confusion[ 2 , 2 ],
                   fp=confusion[ 1 , 2 ],
                   fn=confusion[ 2 , 1 ],
                   tn=confusion[ 1 , 1 ])


# print confusion, yes_counts, and no_counts to the console.
# Be sure you understand
confusion

no_counts

yes_counts


################################################################################
# Calculate the following metrics for classifications of "Yes"
#
# Precision = TP / (TP + FP) - % of thigs we said are positive that are positive
# Recall or Sensitivity = TP / (TP + FN) - % of positives we said are positive
# Specificity = TN / (FP + TN) - % of negatives we said are negatives
# False Discovery Rate (FDR) = FP / (FP + TP) - % of things we said are positive
#                                               that are actually negative
################################################################################

precision <- yes_counts$tp / (yes_counts$tp + yes_counts$fp)

recall <- yes_counts$tp / (yes_counts$tp + yes_counts$fn)

specificity <- yes_counts$tn / (yes_counts$fp + yes_counts$tn)

fdr <- yes_counts$fp / (yes_counts$tp + yes_counts$fp)

################################################################################
# Often, classifiers can give you a probability or threshold of a class
# In fact, final assignments are often made based on P(class) >= 0.5
# Sometimes you may wish to tune the probability at which you make assignments.
# Let's do some metric calculations based on probabilities, not final assignments
################################################################################

# the roc() function from the pROC package can calculate some of these for us

yes_roc <- roc(response = titanic_predictions$actual == "Yes", # must be binary
               predictor = titanic_predictions$prob_Yes)

# examine the structure of this object
str(yes_roc)

# Plot the Receiver-operator curve (or ROC curve)
plot(1- yes_roc$specificities, # The x-axis is 1 - Specificity
     yes_roc$sensitivities, # The y-axis is Sensitivity (or Recall)
     xlab = "1 - Specificity", 
     ylab = "Sensitivity",
     main = "ROC for predictions of survival on the Titanic",
     type = "l")

# Random guesses would be a curve with slope of 1, running through the origin
lines(seq(0,1, by=0.1), seq(0,1,by=0.1), lty=2, col="red")


# The area under the ROC (or AUC) is usually a measure of goodness-of-fit
# AUC is calculated *before* choosing a threshold.
yes_roc$auc

# Let's add this to our chart, along with a legend
legend("bottomright",
       legend=c(paste("AUC =", round(yes_roc$auc, 2)),
                "Predictions", 
                "Random Guess"),
       lty=c(0,1,2), col=c("", "black", "red"))


################################################################################
# Examine the relationship between assigned classes and probabilities
################################################################################

# Recall the sensitivity (recall) and specificity of our assignments
recall

specificity

# What about those same figures for a probability threshold of about 0.5?

# our roc object contains thresholds, though they aren't exactly 0.5
check <- yes_roc$thresholds < 0.51 & yes_roc$thresholds > 0.49

yes_roc$sensitivities[ check ]

yes_roc$specificities[ check ]

# Same?

# Let's verify this independently...
titanic_predictions$prediction2 <- "No"

titanic_predictions$prediction2[ titanic_predictions$prob_Yes >= 0.5 ] <- "Yes"

titanic_predictions$prediction2 <- factor(titanic_predictions$prediction2,
                                          levels=levels(titanic_predictions$prediction))

confusion2 <- table(actual=titanic_predictions$actual,
                    prediction=titanic_predictions$prediction2)

confusion2

confusion

# Same? They should be.


################################################################################
# Exercises. Try these on your own.
################################################################################

# 1. Suppose we really want to minimize false positives. Create a confusion 
#    matrix for predictions of "Yes" where our probability threshold is >= 0.6
#    Assign this confusion matrix to an object called confusion_06


# 2. As above, calculate precision, recall (sensitivity), specificity, and FDR



# 3. Are you tired of copying code? Let's turn this into a function. Write a 
#    function called 'evaluate' that takes two vectors as input and calculates
#    the confusion matrix, and our 4 metrics for each outcome. I'll get you started

evaluate <- function(actual, predicted){
  
  #### YOUR CODE GOES HERE. FILL IN THE BLANKS
  
  
  
  # Return a list that contains the confusion matrix and statistics for 
  # EACH of our outcomes (for example "yes" and "no")
  
  
}



# 4. Test your function on titanic_predictions. Do you get the same answers?


################################################################################
# Answer to exercises below. Try yourself first, before reading on....
################################################################################

# 1. Suppose we really want to minimize false positives. Create a confusion 
#    matrix for predictions of "Yes" where our probability threshold is >= 0.6
#    Assign this confusion matrix to an object called confusion_06

titanic_predictions$prediction_06 <- "No"

titanic_predictions$prediction_06[ titanic_predictions$prob_Yes >= 0.6 ] <- "Yes"

confusion_06 <- table(actual=titanic_predictions$actual,
                      predicted=titanic_predictions$prediction_06)

confusion_06


# 2. As above, calculate precision, recall (sensitivity), specificity, and FDR

confusion_06[ 2 , 2 ] / sum(confusion_06[ , 2 ]) # precision

confusion_06[ 2 , 2 ] / sum(confusion_06[ 2 , ]) # recall

confusion_06[ 1 , 1 ] / sum(confusion_06[ 1 , ]) # sensitivity

confusion_06[ 1 , 2 ] / sum(confusion_06[ , 2 ]) # fdr


# 3. Are you tired of copying code? Let's turn this into a function. Write a 
#    function called 'evaluate' that takes two vectors as input and calculates
#    the confusion matrix, and our 4 metrics for each outcome. I'll get you started

evaluate <- function(actual, predicted){
  
  confusion <- table(actual=actual, predicted=predicted)
  
  class_levels <- rownames(confusion)
  
  metrics <- lapply(class_levels, function(x){
    y <- setdiff(class_levels, x) # get the other name
    
    tp <- confusion[ x , x ]
    fp <- confusion[ y , x ]
    tn <- confusion[ y , y ]
    fn <- confusion[ x , y ]
    
    precision <- tp / (tp + fp)
    recall <- tp / (tp + fn)
    specificity <- tn / (tn + fp)
    fdr <- 1 - precision
    
    list(precision = precision,
         recall = recall,
         specificity = specificity,
         fdr = fdr)
  })
  
  names(metrics) <- class_levels
  
  list(confusion=confusion, metrics=metrics)
  
}



# 4. Test your function on titanic_predictions. Do you get the same answers?

evaluate(actual = titanic_predictions$actual, 
         predicted = titanic_predictions$prediction)






