# Draft 1: Prostate cancer transcriptomic data for biotrain


# Introduction to Prostate Cancer and TCGA Transcriptomic Data

Prostate cancer (PCa) is the most commonly diagnosed non-cutaneous malignancy and the second leading cause of cancer-related death among men in many parts of the world. It is a biologically heterogeneous disease, ranging from indolent tumors that may not require treatment to aggressive forms with a high risk of metastasis and mortality. Understanding the molecular landscape of prostate cancer is critical for improving diagnosis, risk stratification, and treatment strategies.

Advancements in high-throughput technologies have enabled comprehensive profiling of the transcriptome in cancer tissues. Transcriptomic data provide insights into gene expression changes that drive tumor progression, response to therapy, and clinical outcomes. These molecular features can be integrated with clinical variables to develop predictive models and guide personalized treatment.

## The Cancer Genome Atlas (TCGA)

The Cancer Genome Atlas (TCGA) is a landmark initiative launched by the National Cancer Institute (NCI) and the National Human Genome Research Institute (NHGRI) to systematically characterize the genomic and molecular alterations across more than 30 types of cancer. For prostate cancer, the TCGA-PRAD dataset includes extensive transcriptomic data (RNA-Seq) alongside detailed clinical annotations from patients with primary prostate adenocarcinoma. This resource enables integrative analyses to uncover clinically relevant biomarkers and molecular subtypes.

## Clinical Variables

The dataset includes several clinically relevant variables that are critical for understanding disease presentation and outcomes:

- **Age**: Age at diagnosis is a key demographic factor associated with disease incidence and progression.
- **Initial Weight**: Body weight at diagnosis may correlate with metabolic status and prognosis.
- **Histological Type**: Describes the microscopic characteristics of tumor cells; prostate adenocarcinoma is the most common histological subtype.
- **ISUP Grade Group**: A modern classification of histological characteristics, ranging from Grade Group 1 (least aggressive) to Grade Group 5 (most aggressive), used for prognostication.
- **Laterality**: Indicates whether the tumor affects one (unilateral) or both (bilateral) lobes of the prostate.
- **PSA (Prostate-Specific Antigen)**: A widely used biomarker for PCa diagnosis and monitoring; elevated levels may indicate tumor burden.
- **Targeted Molecular Therapy**: Refers to the administration of drugs that specifically target molecular pathways altered in cancer cells.
- **Radiation Therapy**: Indicates whether the patient received radiation as part of initial or adjuvant treatment.
- **Initial Pathologic Diagnosis Method**: Refers to the diagnostic technique used (e.g., needle biopsy, TURP, prostatectomy) for confirming prostate cancer.

Together, these variables and transcriptomic features allow the development of machine learning models to predict outcomes and inform clinical decision-making in prostate cancer management.


## About the Data

The transcriptomic and clinical data used in this project are available in the [`/data`](./data) folder of this repository.

As the focus of this module is on clustering and classification methods, we will work directly with a preprocessed version of the dataset. The data have already been downloaded, curated, and cleaned. This includes:

- Quality control and removal of outliers
- Consistent formatting of clinical variables (e.g., conversion to factors where appropriate)
- Selection of high-variance genes for dimensionality reduction

The following files are provided:

- **`feno.RDS`**: Contains all available clinical and phenotypic information for each patient in the dataset.
- **`exp.RDS`**: Gene expression matrix (RNA-Seq data) for all genes and all patients in the TCGA prostate cancer cohort.
- **`exp_top.RDS`**: A subset of the expression matrix, including only the top most variable genes across patients. This reduced dataset is useful for analyses that require fewer features, such as clustering or classification with limited computational resources.

These prepared files are ready to be used in downstream machine learning analyses.

## how this data was created?
You can visit [this page](https://rpubs.com/jbzt/914994) to learn more about how this dataset was downloaded and processed.
