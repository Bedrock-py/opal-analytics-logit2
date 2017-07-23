opal-analytics-logit2
=========================

## Installation

`pip install git+https://github.com/Bedrock-py/opal-analytics-logit2.git`

## Parameters Spec for Bedrock

```
self.parameters_spec = [
    { "name" : "Regression Formula", "attrname" : "formula", "value" : "", "type" : "input" },
    { "name" : "GLM family", "attrname" : "family", "value" : "binomial", "type" : "input" },
    { "name" : "Clustered Error Covariates", "attrname" : "clustered_rse" , "value" : "", "type" : "input"}
]
```

* `formula` A R-style formula for regression given as a string
* `family` Either `binomial` for logistic regression or `gaussian` for OLS
* `clustered_rse` Columns that should be clustered for robust standard error.  
  The format of the parameter is a comma delimited string `"column1,column2"`

## Requires a Matrix with the following files

* `matrix.csv` The full matrix with both endogenous and exogenous variables
* `features.txt` A list of column names for the matrix (one name per row)

## Outputs the following files

`matrix.csv` The coefficient table output from the GLM model
