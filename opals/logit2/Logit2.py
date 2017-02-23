#****************************************************************
# Copyright (c) 2015, Georgia Tech Research Institute
# All rights reserved.
#
# This unpublished material is the property of the Georgia Tech
# Research Institute and is protected under copyright law.
# The methods and techniques described herein are considered
# trade secrets and/or confidential. Reproduction or distribution,
# in whole or in part, is forbidden except by the express written
# permission of the Georgia Tech Research Institute.
#****************************************************************/
import subprocess
from bedrock.analytics.utils import Algorithm 


class Logit2(Algorithm):
    def __init__(self):
        super(Logit2, self).__init__()
        self.parameters = ['']
        self.inputs = ['matrix.csv']
        self.outputs = ['matrix.csv']
        self.name ='Logit2'
        self.type = 'Logit'
        self.description = 'Performs Logit2 the input dataset.'
        self.parameters_spec = []

    def compute(self, filepath, **kwargs):
        path = filepath['matrix.csv']['rootdir'] + 'matrix.csv'


        path = '/home/tgoodyear/projects/ngss/opal-analytics-logit2/Rand2011PNAS_cooperation_data.csv'
        cmd = ['Rscript','logit2.R',path]
        x = subprocess.check_output(cmd, universal_newlines=True)
        tailStartChar = "Pr(>|z|)"
        tailStart = x.find("Pr(>|z|)") + len(tailStartChar) + 4
        tailEnd = x.find("---",tailStart)

        # Estimate Std. Error z value Pr(>|z|)
        resultHeader= ['Estimate','StdErr','zValue','Pr_z']
        resultTable = [row.split() for row in x[tailStart:tailEnd].replace("*","").split('\n')]
        result = resultHeader + resultTable

        # print resultTable
        # print tailStart, tailEnd

        self.results = {'matrix.csv': result}
