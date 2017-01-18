/*
 * RandomizeMultipleArff.java
 *
 * Summary    : Performs the ML analysis on one arff file against a randomized number of instances of multiple arff files. 100 folds.
		Obtain the IG values of each feature in a subsampling method aproach. It generates 100 random subsets of the same number of samples from 
		the two classes and obtains the IG value of each feature against each subset and with the labels shuffled, for comparing the two distributions
		of IG values.
 *
 * Usage      : java -cp $WEKA_PATH RandomizeMultipleArff n_samples c1-label c2-label [<arff_file_1> .. <arff_file_n>]
 * 
 * Parameters : 
 *		n_samples: Number of samples of each class to substract per subset
 *              c1-label: Label of the first class
 *              c2-label: Label of the second class
 *              <arff_file_x> ARFF file where to extract the instances (all the files put in list will be used)
 *
 * Comments   : 
 *              All ARFF files shall have exactly the SAME ATTRIBUTES (number and name)
 *              Rows of the output are in the form of <attribute_name> <Normal/Shuffle> <ig_value>
 */

//for compiling use this command: javac -cp /home/juanluis/Desktop/Work/Clinical_paper/scripts:/projects_rg/Software/weka-3-6-3/weka.jar ./RandomizeMultipleArff.java 


import java.io.*;

import java.util.Random;
import java.util.Vector;
import java.util.Collections;
import java.util.Date;

import java.text.DecimalFormat;

import weka.core.Instances;
import weka.core.Instance;
import weka.core.Attribute;
import weka.core.converters.ConverterUtils.DataSource;
import weka.attributeSelection.InfoGainAttributeEval;
import weka.core.converters.ArffSaver;


public class RandomizeMultipleArff
{

  // Variables
  String m0label, m1label, olabel, wilcoxon;
  Instances tdata, ndata, alldata;
  Instances rtdata, rndata;
  int num_samples;

  /*
   * Constructor
   */
  public RandomizeMultipleArff
  (String[] args) throws Exception
  {
    Instances datap, dataf, dataAll;
    String gtlabel = "", gnlabel = "";

    num_samples = Integer.parseInt(args[1]);   
    m0label = args[2];
    m1label = args[3];
  //  olabel = "other";
    DataSource nsource = new DataSource(args[4]);
  //  DataSource tsource = new DataSource(args[4]);

    // Generate instances
    datap = nsource.getDataSet();
    datap.setClassIndex(datap.numAttributes() -1);
    ndata = new Instances(datap); ndata.setClassIndex(datap.numAttributes() -1); ndata.delete();
    
    dataf = nsource.getDataSet();
    dataf.setClassIndex(dataf.numAttributes() -1);
    tdata = new Instances(dataf); tdata.setClassIndex(dataf.numAttributes() -1); tdata.delete();
    
    dataAll = nsource.getDataSet();
    dataAll.setClassIndex(dataAll.numAttributes() -1);
    alldata = new Instances(dataAll); alldata.setClassIndex(dataAll.numAttributes() -1); alldata.delete();

    rndata = new Instances(ndata); 
    //rndata.delete();

    for (int i = 4; i < args.length; i ++) {

      Instances instances = (new DataSource(args[i])).getDataSet();

      for (int j = 0; j < instances.numInstances(); j++) {
        Instance inst = instances.instance(j);
        Instance newinst = new Instance(inst);

        if (inst.stringValue(instances.numAttributes() - 1).contains(m0label)) {
          ndata.add(new Instance(inst));
        }
        else{
          tdata.add(new Instance(inst));
        }
      alldata.add(new Instance(inst));         
      }
    }
  }

  public static void main(String[] args)
  {
    // Create class object and generate instances

    try {
      RandomizeMultipleArff rma = new RandomizeMultipleArff(args);
      
      int num_samples = rma.num_samples;
      Instances m0_random    = rma.ndata;
      Instances m1_random    = rma.tdata;

      Random random = new Random();
      InfoGainAttributeEval normal_eval = new InfoGainAttributeEval(), shuffle_eval = new InfoGainAttributeEval();
      
      for (int i = 0; i < 100; i++) {

        Instances normal = new Instances(rma.alldata); normal.delete();
        Instances shuffle  = new Instances(rma.alldata); shuffle.delete();

        random.setSeed(System.currentTimeMillis());
        m0_random.randomize(random);
        m1_random.randomize(random);

        for (int j = 0; j < num_samples/*rma.ndata.numInstances()*/; j++){ 

          normal.add(new Instance(m0_random.instance(j)));
          normal.add(new Instance(m1_random.instance(j)));
          shuffle.add(new Instance(m0_random.instance(j)));
          shuffle.add(new Instance(m1_random.instance(j)));
        }

        //shuffle the classes
        String [] classes = new String[num_samples*2];
        for (int j = 0; j < shuffle.numInstances(); j++) {
          Instance inst = shuffle.instance(j);
          String cl = inst.stringValue(inst.numAttributes() - 1);
          classes[j] = cl;
        }
        
        Random aleat = new Random();
        aleat.setSeed(System.currentTimeMillis());
        int max = classes.length;
        boolean[] bools = new boolean[num_samples*2];
        
        int k = 0;  

        while(k < shuffle.numInstances()){
            int limit = aleat.nextInt(max);
            if (!bools[limit]){
              Instance inst = shuffle.instance(k);
              inst.setClassValue(classes[limit]);
              k++;
              bools[limit] = true;
            }
        }

        normal_eval.buildEvaluator(normal);
        shuffle_eval.buildEvaluator(shuffle);

        for (int j = 0; j < normal.numAttributes() - 1; j++) {
          double normval = normal_eval.evaluateAttribute(j);
          double shuffval = shuffle_eval.evaluateAttribute(j);
          System.out.println(normal.attribute(j).name() + "\t" + "Normal" + "\t" + normval);
          System.out.println(shuffle.attribute(j).name() + "\t" + "Shuffle" + "\t" + shuffval);
        }
      }


    }
    catch (Exception e) {
      System.err.println("[" + (new Date()).toString() + "] " + e.getMessage() + "\n");
    }
  }
}
