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
import os
from bedrock.analytics.utils import Algorithm 


class Logit2(Algorithm):
    def __init__(self):
        super(Logit2, self).__init__()
        self.parameters = []
        self.inputs = ['matrix.csv','features.txt']
        self.outputs = ['matrix.csv']
        self.name ='Logit2'
        self.type = 'Logit'
        self.description = 'Performs Logit2 analysis on the input dataset.'
        self.parameters_spec = []

    def compute(self, filepath, **kwargs):
        
        # Add headers to csv
        featuresPath = filepath['features.txt']['rootdir'] + 'features.txt'
        matrixPath = filepath['matrix.csv']['rootdir'] + 'matrix.csv'
        newMatrixPath = filepath['matrix.csv']['rootdir'] + 'matrix_with_header.csv'
        features = ''
        with open(featuresPath,'r') as f:
            features = ','.join(f.read().splitlines())

        cmd = 'echo "{0}" | cat - {1} > {2}'.format(features,matrixPath,newMatrixPath)
        # print cmd
        x = subprocess.check_call(cmd, shell=True)


        # Run R script
        Rpath = os.path.dirname(os.path.abspath(__file__))
        cmd = ['Rscript',Rpath+'/logit2.R',newMatrixPath]

        # Parse output
        x = subprocess.check_output(cmd, universal_newlines=True)
        tailStartChar = "Pr(>|z|)"
        tailStart = x.find("Pr(>|z|)") + len(tailStartChar) + 4
        tailEnd = x.find("---",tailStart)
        resultHeader= [['','Estimate','StdErr','zValue','Pr_z']]
        resultTable = [row.split() for row in x[tailStart:tailEnd].replace("*","").strip().split('\n')]
        result = resultHeader + resultTable
        print result

        # print resultTable
        # print tailStart, tailEnd

        self.results = {'matrix.csv': result}
