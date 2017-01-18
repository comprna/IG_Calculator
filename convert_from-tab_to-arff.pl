# convert_from-tab_to-arff.pl
#
# Summary    : Convert TAB-separated file to ARFF file for Weka analysis
#              http://www.cs.waikato.ac.nz/~ml/weka/arff.html
#
# Usage      : perl convert_from-tab_to-arff_vGen.pl <input-file> <c1-class> <c2-class>
#
# Parameters : 
#              <input-file> TAB-separated file where rows are features and columns are instances
#              <c1-class> Name of the first class
#              <c2-class> Name of the second class
# 
# Comments   : Column headers must be present and are used to label the instances
#              Class names cannot contain the characters '@', '%' or ','. An error will be thrown
#              'null' and 'NA' values are treated as missing values '?'
#              ',' characters in the feature names (row names in the TAB-separated files) will be replaced by '#'
use strict;

# 1. Declare and define variables
my $number_of_instances    = 0;  # Number of total instances
my $number_of_c1_instances = 0;  # Number of instances assigned to c1-class
my $number_of_c2_instances = 0;  # Number of instances assigned to c2-class
my $number_of_features     = 0;  # Number of total features
my @instances = ();              # Labels for instances
my @features  = ();              # Labels for features
my %values;                      # Values for each pair instance/feature

# 2. Parse command line
#    Exit (100) if command line is ill-formed
#    Exit (101) if input file does not exist
#    Exit (102) if input file is not readable
#    Exit (103) if class names contain '@' or '%' characters
print STDERR "[", scalar(localtime()), "] Bad syntax - Usage : perl convert_from-tab_to-arff_vGen.pl <input-file> <c1-class> <c2-class>\n" and exit 100 if (scalar(@ARGV) != 3);
print STDERR "[", scalar(localtime()), "] File $ARGV[0] does not exist\n" and exit 101 if (!-e $ARGV[0]);
print STDERR "[", scalar(localtime()), "] File $ARGV[0] is not readable\n" and exit 102 if (!-r $ARGV[0]);
print STDERR "[", scalar(localtime()), "] Class names cannot contain \'\@\', \'\%\' or \',\' characters\n" and exit(103) if (($ARGV[1] =~ m/\@|\%|\,/) or ($ARGV[2] =~ m/\@|\%|\,/));

# 3. Parse file
#    - Retrieve labels for instances
#    - Calculate number of instances and number of features
print STDERR "[", scalar(localtime()), "] Parsing file $ARGV[0]...\n";
open(TABSEP, " < $ARGV[0]");
my $headers = <TABSEP>; chomp($headers);
@instances = split "\t", $headers;
$number_of_instances = scalar(@instances);

for (my $i = 0; $i < scalar(@instances); $i++) {
  if ($instances[$i] =~ m/$ARGV[1]/){
    $number_of_c1_instances++;    
  }
  else{
    $number_of_c2_instances++;  
  }
}
print STDERR  "Number of instances class1: $number_of_c1_instances\n";
print STDERR  "Number of instances class2: $number_of_c2_instances\n";
close(TABSEP);

# 4. Parse file
#    - Extract values
#    Exit (104) if input file is ill-formed
open(TABSEP, " < $ARGV[0]");
<TABSEP>;
while(<TABSEP>) {
  chomp;

  my ($feature, @feature_values) = split;
  $feature =~ s/\,/#/g;
  
  for (my $i = 0; $i < scalar(@feature_values); $i++) {
    my $val = $feature_values[$i];
    if ($val eq 'NA') { $val = '?'; }
    elsif ($val eq 'null') {$val = '?';}
    elsif ($val !~ /^([+-]?)(?=\d|\.\d)\d*(\.\d*)?([Ee]([+-]?\d+))?$/) { print STDERR "[", scalar(localtime()), "] File $ARGV[0] cannot be converted. $val is not a valid value\n"; exit(104); }
    $values{$instances[$i]}{$feature} = $val;
  }

  $features[$number_of_features] = $feature;
  $number_of_features++;
}
print STDERR  "Number of features: $number_of_features\n";

close(TABSEP);

# 5. Print ARFF header comments
print STDOUT "% File : $ARGV[0]\n";
print STDOUT "% Number of instances : $number_of_instances\n";
#print STDOUT "% Number of instances assigned to $ARGV[1] class : $number_of_c1_instances\n";
#print STDOUT "% Number of instances assigned to $ARGV[2] class : $number_of_c2_instances\n";
print STDOUT "% Number of features : $number_of_features\n";

# Print ARFF header
print STDOUT "\@RELATION $ARGV[0]\n\n";
for (my $i = 0; $i < $number_of_features; $i++) {
  print STDOUT "\@ATTRIBUTE $features[$i] NUMERIC\n";
}
print STDOUT "\@ATTRIBUTE class {$ARGV[1],$ARGV[2]}\n\n";

# Print ARFF data
print STDOUT "\@DATA\n";
for (my $i = 0; $i < scalar(@instances); $i++) {
  my $instance = $instances[$i];
  print STDOUT $values{$instance}{$features[0]};
  for (my $j = 1; $j < $number_of_features; $j++) {
    print STDOUT ",", $values{$instance}{$features[$j]};
  }
  if ($instance =~ m/$ARGV[1]/) { print ",$ARGV[1]\n"; }
  else { print ",$ARGV[2]\n"; }
}
print STDERR "[", scalar(localtime()), "] File $ARGV[0] converted successfully\n";
