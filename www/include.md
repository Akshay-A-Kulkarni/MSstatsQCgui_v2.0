<body style=font-size: 5rem;">
<br><br>

<div style="font-size:1.7rem;">
<code>MSstatsQC</code> is an open-source R package and Shiny web application for statistical analysis and monitoring of quality control and system suitability testing (SST) samples produced by spectrometry-based proteomic experiments. Our framework termed <code>MSstatsQC</code> is available through <a href="www.msstats.org/msstatsqc">www.msstats.org/msstatsqc</a>.
<br><br>

</div>  

#### **Metrics and experimental workflows you can monitor**   

<div style="font-size:1.7rem;">
MSstatsQC uses statistical and machine learning methods to monitor the instrument performance by tracking metrics such as total peak area, retention time and full width at half maximum (FWHM) and peak assymetry. It can import and analyze any metric of interest if they were provided based on the required input format.  

MSstatsQC is available for quality control data from SRM, DDA and DIA experiments.
<br><br>

</div>

#### **MSstatsQC Modules**  

1. Module 1: individual experiments 
   Module analyzes QC data where a guide set is not available and uses unsupervised learning methods (isolation forests) for anomaly detection.   
   
2. Module 2: longitudinal tracking
   Module analyzes longitudinal QC data where a guide set is available and uses supervised learning methods (random forests) and statistical process control for suboptimality detection.   
   
3. Module 3: complex QC
   Module analyzes longitudinal pXn reference QC samples where a guide set is available and uses supervised learning methods (random forests) and statistical process control for suboptimality detection.  
   

### Installation of MSstatsQC R/Bioconductor package

To install the R/Bioconductor package version, start R and enter:
```
if (!requireNamespace("BiocManager", quietly=TRUE))
    install.packages("BiocManager")
BiocManager::install("MSstatsQC")
```

</body>