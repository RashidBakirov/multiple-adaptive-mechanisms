# Multiple Adaptive Mechanisms

Library of machine learning algoirhtms for predicting on streaming data with the implementation of multiple adaptive mechanisms paradigm.

Simple overview of use/purpose.

## Description

This is a collection of existing ML algorithms with multiple adaptive mechanisms, as well as code for the experiments of publications in this area, particularly for the paper ["Automated Adaptation Strategies for Stream Learning"](https://arxiv.org/abs/1812.10793). Currently, 4 batch versions of streaming algorithms Dynamic Weighted Majority [1], Paired Learner [2], Leveraged Bagging [3] and BLAST [4] are implemented. They are respectivelly referred to as bDWM, bPL, bLB and bBLAST, where "b" stands for "batch". 

## Getting Started

### Dependencies

* Matlab (R2020a was used in experiments).
* bLB requires Python 3.5+ and [scikit-multiflow](https://scikit-multiflow.github.io/) package including its dependencies.
* bBLAST requires Java (1.8 was used in experiments) and [MOA](https://moa.cms.waikato.ac.nz) library.
* Several other dependencies are included within the code and mentioned in the paper.

### Setup

* For bBLAST, you need to compile MOA with additional classes included in /code/bBLAST,

### Running experiments for "Automated Adaptation Strategies for Stream Learning"

* run run.sh with either "q" option for qsub based paralellisation or "b" option for mostly sequential execution (bLB makes use of Matlab parfor).

## Authors

[Rashid Bakirov](https://www.rashidbakirov.com/)

## Version History

* 0.3
    * Revision of the paper.
    * Added bLB and bBLAST.
    * Various fixes and optimisation.
* 0.2
    * Revision of the paper.
    * Various fixes and optimisation.
* 0.1
    * Initial release.


## License

License details pending.

## References
[1] Kolter, J. Z., & Maloof, M. A. (2007). Dynamic weighted majority: An ensemble method for drifting concepts. The Journal of Machine Learning Research, Volume 8, 2755–2790.

[2] Bach, S. H., & Maloof, M. A. (2008). Paired Learners for Concept Drift. 2008 Eighth IEEE International Conference on Data Mining, 23–32.

[3] Bifet, A., Holmes, G., & Pfahringer, B. (2010). Leveraging bagging for evolving data streams. Lecture Notes in Computer Science (Including Subseries Lecture Notes in Artificial Intelligence and Lecture Notes in Bioinformatics), 6321 LNAI(PART 1), 135–150.

[4] van Rijn, J. N., Holmes, G., Pfahringer, B., & Vanschoren, J. (2015). Having a Blast: Meta-Learning and Heterogeneous Ensembles for Data Streams. Data Mining (ICDM), 2015 IEEE International Conference On, 1003–1008.

