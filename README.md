# IG_Calculator
Set of scripts for obtaining Infomration Gain values from a set of features

### 1. Convert to arff

For getting the IG values of our features, we are gonna use the library RWeka (https://cran.r-project.org/web/packages/RWeka/index.html). This library needs the arff format (http://www.cs.waikato.ac.nz/ml/weka/arff.html). The next script convert a tab separated psi file to arff. The user should specify the two classes (this classes should be in the name of the samples):

```
perl convert_from-tab_to-arff.pl psi_file.tab class1 class2 > psi_file.arff
```

Performs the ML analysis on one arff file against a randomized number of instances of multiple arff files. 100 folds.
		Obtain the IG values of each feature in a subsampling method aproach. It generates 100 random subsets of the same number of samples from 
		the two classes and obtains the IG value of each feature against each subset and with the labels shuffled, for comparing the two distributions
		of IG values.
    
### 2. Calculate the IG values

Obtain the IG values of each feature in a subsampling method aproach. It generates 100 random subsets of the same number of samples from the two classes and calculates the IG value of each feature against each subset and with the labels shuffled, for comparing the two distributions of IG values.  n_samples is the number of samples of each class to substract per subset:

```
java -cp $WEKA_PATH RandomizeMultipleArff n_samples class1 class2 [<arff_file_1> .. <arff_file_n>]
```
