load("data_raw/injury/injury.RData")

str(injury)

test_rows <- sample(1:nrow(injury), size = floor(nrow(injury) / 5))

injury_test <- injury[ test_rows , ]

injury_training <- injury[ -test_rows , ]

f_injury <- paste("mais3pl ~", 
                  paste(setdiff(names(injury), 
                                c("id", "mais", "mais3pl")), 
                        collapse = " + "))

f_injury <- as.formula(f_injury)

fit_injury <- rpart(f_injury, data = injury_training)

pfit_injury <- prune(fit_injury, cp = 0.04)
printcp(pfit_injury)
printcp(fit)
pfit_injury <- prune(fit_injury, cp = 0.01)
printcp(pfit_injury)
pfit_injury <- prune(fit_injury, cp = 0.02)
printcp(pfit_injury)

rpart_injury_pred <- predict(fit_injury, newdata = injury_test, type="class")

rpart_injury_eval <- evaluate(actual = injury_test$mais3pl,
                              predicted = rpart_injury_pred)

rpart_injury_eval$metrics$`TRUE`
