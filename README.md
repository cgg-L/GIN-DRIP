# GIN-DRIP

The Genetics Informed Network-based Drug Repurposing via in silico Perturbation (GIN-DRIP) is a computational drug repurposing framework. Drug repurposing aims to find novel uses of existing approved drugs toward different diseases or conditions with the hope to accelerate the development process and lower the cost. 

GIN-DRIP integrates multimodal data of human genetics, tissue genomics, drug perturbation experiments and real-world electronic health records (EHRs) to prioritize drugs that worth further persuing. The framework is summarized and illustrated below:

![workflow](/image/workflow.png "This is a sample image.")  

The GIN-DRIP framework consists of four main components: disease-risk gene identification, disease signature construction, drug prioritization based on signature matching between disease and drug pertubation profiles, and EHR validation. 

In the following, we use type 2 diabetes (T2D) as an example disease to illustrate the steps/components/steps of running GIN-DRIP analysis.

## 1. iRIGs: identify disease risk genes

GIN-DRIP starts with the identification of high-confidence risk genes (HRGs) from GWAS loci, using [iRIGS](https://www.nature.com/articles/s41593-019-0382-7), a Bayesian integrative method that probabilistically predicts risk genes for each of the GWAS loci by integrating multi-omics data. The [code] of iRIGS can be downloaded 

### Running iRIGS:

1. Download and untar/unzip this file [source code of iRIGS](https://www.dropbox.com/s/i9jw5zimjd0wgqn/iRIGS_code.tar.gz?dl=0).
2. Enter folder "iRIGS_code" and type the following on linux platform for	help information.
```
Rscript	Gibbs.R	-h 
```

3. Usage:
```
Rscript Gibbs.R --SNP_file input.loci \
--weightFile input_features \
--res_path iRIGS_output \
--res_pref T2D \
--flank 1000000 \
--max_gene 20 
```

4.Explanation of arguments:

--SNP_file 

The file name of input GWAS loci. This file must include three columns: SNP, Chr, and Position.

--weightFile

The file name for input genomic features at gene-level. 

--flank 

An	integer	indicating	the	flanking region	(bp) for covering	candidate genes. 1000000 (i.e. 1Mb)	is recommended - this is equivalent to a 2Mb window centering around the lead SNP of each GWAS locus.

--res_path				

Directory for the ouput files. Optional; if not specified, "iRIGS_result"	will be used as	default.

--res_pref				

Prefix name for the output folder. Optional; if not specified, 	SNP_file name will be used as default.


We provide example [input loci](/example/input.loci) and [input features](/example/feature_file) to illustrate the format of the input files and to facilitate the runnning of iRIGS for T2D. 

The output folder include two intermediate files containing the genes extracted from the GWAS loci, the genomic features of these genes along with a composite weight (score) calculated from all features, and a final output file containing GWAS loci and the posterior probabilities of the genes being sampled/selected as the risk gene within each locus (see [example output of iRIGS](/example/iRIGS_output/)). 


## 2. Build genetics-informed disease signature

We construct a genetics-informed T2D signature equipped with genetic importance and up/down regulatory effects of T2D risk alleles on genes dysregulated/implicated in T2D.  

### 2a. Calculate gene importance scores (GIS) 

Beyond the HRGs, their interacting partners in the same pathways also have potential to serve as drug targets. In addition, there are loci that remain uncovered as the current T2D GWAS loci explain only a small portion of the T2D heritability. Therefore,  GIN-DRIP quantifies GIS for all genes based on the identified HRGs and Gene Ontology (GO)-derived network to prioritize genes at a genome-wide scale for T2D to facilitate drug repurposing,

Conceptually, genes that share more GO terms with HRGs are expected to receive higher genetic importance scores (GIS). We have included [code](/GIS/GIS.sh) for calculation GIS. 

The input file is a list of the first-rank gene (ranked by the posterior probability) representing each GWAS locus. The output file is a list of genes with GIS. 

The example [input](/GIS/example/input_hrg.txt) and [output files](/GIS/example/output_gis.txt) for GIS of T2D can be downloaded. 

```
bash GIS.sh ../example/iRIGS/output/T2D 
```

### 2b. Defining the sign (up/down) effects of risk genes

To infer the direction of regulatory effects (up/down) of T2D risk alleles on risk genes, we use the TWAS approach that combines T2D GWAS summary statistics and transcriptomic data of tissues relevant to T2D (pancreas, adipose, skeletal muscle, liver) from the GTEx project. The software to calcuate. 

TWAS of the five T2D relevant tissues for all available genes can be obtained from [here](https://). 

To summarize the tissue-level effects into an overall effect (direction) per gene, we use the following calculations: of the five T2D relevant tissues, if one or more tissues have P-value below 0.05, we averaged the TWAS Z-scores of the tissues with P-value  below 0.05; if none of the tissues’ P-value below 0.05, we averaged the TWAS Z-scores of all five tissues. If the summed TWAS Z-score is negative, the gene is considered being down-regulated in T2D, and conversely, being up-regulated in T2D.

The result of the above steps is a signed genetics-informed T2D-specific network, from which we can construct a T2D signature by selecting top important genes (defined as GIS>5) along with their signs. 

## 3. Prioritize drugs by aligning the disease signature to drug perturbation signatures

In this step, we score drugs for their potential of “reversing” the T2D signature by signature matching of the T2D signature to the transcriptional perturbation profiles of drugs from the L1000 database. Specificaly, a weighted Kolmogorov-Smirnov enrichment score (ES) is calculated for each assayed compound. A negative value of ES indicates therapeutic potential while a positive ES indicates exacerbation potential. A compound can have multiple ES values given multiple perturbation experiments varying by duration, doses and cell lines.  

The calculation task can be readily performed at the L1000 website with input of the up- and down-regulated gene lists derived from the signed disease signature. 

After you log into the [L1000 website](https://clue.io/) (you need to register an account if you haven't logged in before), click the "Tool" on the top task bar; on the drop-down menu, click Query". On the Query page, you can upload your list of up- and down-regulated genes (Entrez Gene IDs) in the box of Up-regulated genes and Down-regulated genes, respectively. Make sure to name your project and specify the Query parameters (first choose "Gene expression L1000", and then specify "Touchstone", "Individual Query", and "late"). After that, click "Submit" and wait for the job to be done. One will be notified via email once the job is completed and the output is available to download. 

We then extract the scores for FDA-approved drugs.

Additional filtering can be applied to further narrow down the candidate list for prioritization. Here, we consider a drug to to be more worth pursing if it further demonstrates robustness of reversal effects across experimental conditions, its best reversal score across experimental conditions ranks top compared to other drugs, and its structure is similar to existing T2D medicines. The [drug similarity metric](https://) is based on DrugSimDB. 

Telmisartan emerges as a top candidate after the comprehensive ranking method.
