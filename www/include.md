<body style=font-size: 5rem;">
<br><br>
<div style="font-size:1.7rem;">
Statistical process control (SPC) is a general and well-established method of quality control (QC) which can be used to monitor and improve the quality of a process such as LC MS/MS.
<br><br>
 
</div>  


<div style="font-size:1.7rem;">
<code>MSstatsQC</code> is an open-source R package and Shiny web application for statistical analysis and monitoring of quality control and system suitability testing (SST) samples produced by spectrometry-based proteomic experiments. Our framework termed <code>MSstatsQC</code> is available through <a href="www.msstats.org/msstatsqc">www.msstats.org/msstatsqc</a>.
<br><br>

</div>  



<div style="font-size:1.7rem;">
It uses SPC tools to track metrics including total peak area, retention time, full width at half maximum (FWHM) and peak asymmetry for proteomic experiments. We introduce simultaneous and time weighted control charts and change point analysis to monitor mean and variability of metrics. Proposed longitudinal monitoring approach significantly improves the ability of real time monitoring, early detection and prevention of chromatographic and instrumental problems of mass spectrometric assays, thereby, reducing cost of control and failure.
<br><br>

</div>  


<div style="font-size:1.7rem;">
MSstatsQC is an R based package and a web-based software which provides longitudinal system suitability monitoring tools (control charts) for proteomic experiments.
<br><br>

</div>


#### **Metrics you can monitor**   

<div style="font-size:1.7rem;">
MSstatsQC uses control charts to monitor the instrument performance by tracking system suitability metrics including total peak area, retention time and full width at half maximum (FWHM) and peak assymetry. Additional metrics can also be analyzed by including them to the input file.
<br><br>

</div>


#### **Statistical functionalities**  

<div style="font-size:1.7rem;">
This framework includes simultaneous monitoring tools for mean and dispersion of suitability metrics and presents alternative methods of monitoring such as time weighted control charts to ensure that various types of process disturbances are detected effectively. Simultaneous control charts used in this framework can be classified into two groups: individual-moving range (XmR) control charts and mean and dispersion cumulative sum (CUSUM) control charts. To successfully identify the time of change, change point analysis is also included in this framework. Experiment specific control limits are provided with the control charts to distinguish between random noise and systematic error. MSstatsQC can also help user on decision making. Decision regions (red, yellow and blue) can be designed with 'Create Decision Rules' tab and results are available in 'Metric Summary' tab.
<br><br>

</div>

#### **Using MSstatsQC**  
The steps for generating results are as follows:

1. Import your SST/QC data
2. Determine the guide set to estimate metric mean and variance
3. Select specific precursor(s) or select all
4. Design decision rules
5. Run and generate control charts
6. Check with heatmaps, metric summary plots and change point analysis for better reasoning
7. Navigate results and download them for your reports


### Installation

To install this package, start R and enter:
```
if (!requireNamespace("BiocManager", quietly=TRUE))
    install.packages("BiocManager")
BiocManager::install("MSstatsQC")
```


Project team:
- Eralp Dogu, eralp.dogu@gmail.com
- Sara Taheri, mohammadtaheri.s@husky.neu.edu
- Olga Vitek, o.vitek@neu.edu


>Olga Vitek Lab  
College of Science    
College of Computer and Information Science     
360 Huntington Ave    
Boston, Massachusetts 02115

</body>