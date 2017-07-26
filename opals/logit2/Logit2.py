
import subprocess
import os
from bedrock.analytics.utils import Algorithm
import pandas as pd
import logging
import statsmodels.api as sm
import csv

def check_valid_formula(formula):
    # TODO: Look at `patsy` for helper function to validate more fully
    if (len(formula.split('~')) < 2):
        logging.error("Formula does not have ~")
        return False

class Logit2(Algorithm):
    def __init__(self):
        super(Logit2, self).__init__()
        self.parameters = []
        self.inputs = ['matrix.csv','features.txt']
        self.outputs = ['matrix.csv', 'summary.csv']
        self.name ='Logit2'
        self.type = 'Logit'
        self.description = 'Performs Logit2 analysis on the input dataset.'
        self.parameters_spec = [
            { "name" : "Regression Formula", "attrname" : "formula", "value" : "", "type" : "input" },
            { "name" : "GLM family", "attrname" : "family", "value" : "binomial", "type" : "input" },
            { "name" : "Clustered Error Covariates", "attrname" : "clustered_rse" , "value" : "", "type" : "input"}
        ]

    def check_parameters(self):
        logging.error("Started check parms")
        super(Logit2, self).check_parameters()

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

        f = sm.families.Binomial()

        if self.family == "binomial":
            f = sm.families.Binomial()
        elif self.family == "gaussian":
            f = sm.families.Gaussian()
        else:
            f = None

        glm = sm.GLM.from_formula(self.formula, df, family=f)

        if self.clustered_rse != "":
            clusters = self.clustered_rse.split(",")
        else:
            clusters = []

        if len(clusters) > 0:
            if len(clusters) > 2:
                clusters = clusters[0:2]

            groups = [df[c] for c in clusters]

            model = glm.fit(cov_type='cluster', cov_kwds={'groups':groups})
        else:
            model = glm.fit()

        summary = model.summary2()
        coef_table = summary.tables[1]
        logging.error(coef_table.to_csv())

        model_summary = [
            ["AIC",model.aic],
            ["deviance",model.deviance],
            ["peasron_chi2",model.pearson_chi2]
        ]

        self.results = {'matrix.csv': list(csv.reader(coef_table.to_csv().split('\n'))), 'summary.csv': model_summary}
