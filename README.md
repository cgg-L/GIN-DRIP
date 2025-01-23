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

The example [input](/GIS/example/iRIGS_output_T2D) and [output files](/GIS/example/output_gis) for GIS of T2D can be downloaded. 

```
bash GIS.sh iRIGS_output_T2D 
```

### 2b. Defining the sign (up/down) effects of risk genes

To infer the direction of regulatory effects (up/down) of T2D risk alleles on genes, we use the TWAS/PrediXcan approach to estimate the genetically-predicted gene expression and its association with T2D risk. Here, we leveraged the results from the study (PMID:32541925), which used S-PrediXcan along with European T2D GWAS summary statistics from more than 1 million individuals and reference eQTL summary statistics of all tissues from GTEx. We focus on the tissues known to be relevanat to T2D (pancreas, adipose, skeletal muscle, liver) and extracted the gene-tissue pairs considered significant (if they passed the P-value threshold of 1.93E-06) by the original paper for coding genes (see [here](/example/twas_t2d_5_tissues_coding genes)).

Of the signifcant genes, we observed that direction of association per gene with respect to T2D are consistent across the tissues for 99% of the significant genes, therefore, we summarize the tissue-level effects into an overall direction of effect by taking the sign of the average of the (PrediXcan) Z-scores.  

Finally, we construct a T2D signature based on the genetics-informed genes equipped with direction and importance scores. The T2D signautre is provided [here](/example/signature). 

## 3. Prioritize drugs by aligning the disease signature to drug perturbation signatures

In this step, we score drugs for their potential of “reversing” the T2D by signature matching of the T2D signature to the drug-perturbed gene expression profiles from the L1000 database. Specificaly, a weighted Kolmogorov-Smirnov enrichment score (ES) is calculated for each disease-drug pair. A negative value of ES indicates therapeutic potential while a positive ES indicates exacerbation potential. A compound can have multiple ES values given multiple perturbation experiments varying by duration, doses and cell types.  

The calculation can be carried out at the L1000 website with an input of the [up-](example/query_up) and [down-regulated gene sets](example/query_down) as derived from the signed T2D signature. 

After log into the [L1000 website](https://clue.io/) (suppose you have registered for an account), click the "Tool" on the top task bar; on the drop-down menu, click "Query". That will lead you to the Query page, where you can upload your list of up- and down-regulated genes (in Entrez Gene IDs) in the box of Up-regulated genes and Down-regulated genes, respectively. Make sure to name your project and specify the Query parameters (first choose "Gene expression L1000", and then specify "Touchstone", "Individual Query", and "late"). After that, click "Submit" and wait for the job to be done. One will be notified via email once the job is completed and the output (which is a folder) is available for download. 

We then extract from the output the repurposing scores for FDA-approved drugs and rank the drugs by the scores.

Additional filtering can be applied to further narrow down the candidate list for prioritization. Here, we consider a drug to to be more worth pursing if it further demonstrates robustness of reversal effects across experimental conditions, its best reversal score across experimental conditions ranks top compared to other drugs, and its structure is similar to existing T2D medicines. The [drug similarity metric](/database/DrugSimDB_v1_0_0.tab) is based on [DrugSimDB](https://academic.oup.com/bib/article/22/3/bbaa126/5864589). The ID's in the column 1 and column 2 refer to drug IDs as annotated in [drugBank](https://go.drugbank.com/). One can search for drug information in drugBank with an input of a drug ID (e.g., DB00966) or a drug name (e.g., Telmisartan).  


## Useful resources
The pre-computed weights of GTEx expression models can be downloaded from [PredictDB](https://predictdb.org/).
