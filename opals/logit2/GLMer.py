
import subprocess
import os
from bedrock.analytics.utils import Algorithm
import pandas as pd
import logging
import statsmodels.api as sm
import csv
import rpy2
import rpy2.robjects as robjects
from rpy2.robjects import r, pandas2ri
from rpy2.robjects.packages import importr

def check_valid_formula(formula):
    # TODO: Look at `patsy` for helper function to validate more fully
    if (len(formula.split('~')) < 2):
        logging.error("Formula does not have ~")
        return False

class GLMer(Algorithm):
    def __init__(self):
        super(GLMer, self).__init__()
        self.parameters = []
        self.inputs = ['matrix.csv','features.txt']
        self.outputs = ['matrix.csv', 'summary.txt']
        self.name ='GLMer'
        self.type = 'Logit'
        self.description = 'Performs GLM with Random Effects analysis on the input dataset.'
        self.parameters_spec = [
            { "name" : "Regression Formula", "attrname" : "formula", "value" : "", "type" : "input" },
            { "name" : "GLM family", "attrname" : "family", "value" : "binomial", "type" : "input" }]

    def check_parameters(self):
        logging.error("Started check parms")
        super(GLMer, self).check_parameters()

        if(check_valid_formula(self.formula) == False):
            return False

        self.family = self.family.lower()

        if (self.family != "binomial" and self.family != "gaussian"):
            logging.error("GLM family {} not supported".format(self.family))
            return False

        return True

    def __build_df__(self, filepath):
        featuresPath = filepath['features.txt']['rootdir'] + 'features.txt'
        matrixPath = filepath['matrix.csv']['rootdir'] + 'matrix.csv'
        df = pd.read_csv(matrixPath, header=-1)
        featuresList = pd.read_csv(featuresPath, header=-1)

        df.columns = featuresList.T.values[0]

        return df

    def compute(self, filepath, **kwargs):
        df = self.__build_df__(filepath)

        pandas2ri.activate()
        rstan = importr("lme4")
        rdf = pandas2ri.py2ri(df)
        robjects.globalenv["rdf"] = rdf

        rglmString = 'output <- glmer({}, data = {}, family="{}")'.format(self.formula, "rdf", self.family)

        logging.error(rglmString)
        r(rglmString)
        summary_txt = r('s<-summary(output)')
        coef_table = r('data.frame(s$coefficients)')

        self.results = {'matrix.csv': list(csv.reader(coef_table.to_csv().split('\n'))), 'summary.txt': [str(summary_txt)]}
