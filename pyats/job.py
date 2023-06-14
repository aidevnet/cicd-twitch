import os
import time

from pyats import aetest

# Needed for logic
from pyats.datastructures.logic import And, Not, Or
from genie.harness.main import gRun

def main():
    test_path = os.path.dirname(os.path.abspath(__file__))
    gRun(
        subsection_datafile=test_path+'/subsection_datafile.yaml',
        trigger_groups=And('nxos'),
    )