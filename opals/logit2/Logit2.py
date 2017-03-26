
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
        self.parameters_spec = [{ "name" : "AnalysisStep", "attrname" : "step", "value" : 1, "type" : "input" , "step": 1, "max": 11, "min": 1}]

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
        cmd = ['Rscript',Rpath+'/logit2.R',newMatrixPath,self.step]

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
