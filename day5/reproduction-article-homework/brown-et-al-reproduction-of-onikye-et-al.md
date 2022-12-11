# Preface

In 2021 Brown et al published an article titled *A Reproduction of the Results
of Onyike et al. (2003)* in an Meta-Psychology that is free + open-access
and conducts open peer review. The Onikye et al. article they're referencing,
*Is obesity associated with major depression? Results from the Third National Health and Nutrition Examination Survey*
published in the American Journal of Epidemiology has been cited 1159+ times
on Google Scholar. 

Moreover, you can read in the About page of 
Meta-Psychology: 

> Prior to publication, all statistical analyses are reproduced by our
statistical reproduction team, which consists of the Statistical Editor and our
editorial assistant. This makes the article eligible for the reproducibility
badge.

# Homework

## Part 1: 

Please read the article by Brown et al (https://open.lnu.se/index.php/metapsychology/article/view/2071).

Abstract repeated here as a teaser: 

> Onyike et al. (2003) analyzed data from a large-scale US-American data set,
the Third National Health and Nutrition Examination Survey (NHANES-III), and
reported an association between obesity and major depression, especially among
people with severe obesity. Here, we report the results of a detailed
replication of Onyike et al.’s analyses. While we were able to reproduce the
majority of these authors’ descriptive statistics, this took a substantial
amount of time and effort, and we found several minor errors in the univariate
descriptive statistics reported in their Tables 1 and 2. We were able to
reproduce most of Onyike et al.’s bivariate findings regarding the relationship
between obesity and depression (Tables 3 and 4), albeit with some small
discrepancies (e.g., with respect to the magnitudes of standard errors). On the
other hand, we were unable to reproduce Table 5, containing Onyike et al.’s
findings with respect to the relationship between obesity and depression when
controlling for plausible confounding variables—arguably the paper’s most
important results—because some of the included predictor variables appear to be
either unavailable, or not coded in the way reported by Onyike et al., in the
public NHANES-III data sets. We discuss the implications of our findings for the
transparency of reporting and the reproducibility of published results.

## Part 2 

Please download and run their code which is freely, publicly accessible on 
OSFHOME, a file storage service provided by the [Open Science Framework](https://osf.io/) from 
the [Center for Open Science](https://www.cos.io/).

  - Brown et al's code+file repository: https://osf.io/j32yw/ 
  - Download their code+files (direct link): https://files.osf.io/v1/resources/j32yw/providers/osfstorage/?zip=
  
Note that in order to run their code, you will either want to a) make a new 
R project in the folder with their code on your computer, or b) open a new 
RStudio window, open up their .R file, and use `setwd('filepath/goes/here/')`
to make sure your R session can run their R code. 

## Part 3

Answer the following questions: 

  * Do you believe that the results Brown et al. have shared are more likely to
    be correct than those that Onikye et al published?  If so, why?  If not, why
    not?
    * What do you find compelling about their re-analysis and code?
    * What do you find lacking about their re-analysis and code?
  * How do you think the non-reproducibility of Onikye et al.'s article could
    have been avoided?
  * When, if at all, do you think articles should be required to share code and
    data?
    * What about in situations where the data relates to private or sensitive data? 
    * What about in situations where the subject matter is highly politically charged
      and there might be malicious actors who could see shared data and code as 
      additional surface area to attack? 
      
      
## An important aside

This isn't a class about stigma and health, but I think being in a Population
Health Science program, it's important to leave the breadcrumbs here for you to
do your own followup reading and learning.

Because the articles in this homework discuss body-weight and health, I want to
emphatically point out that this subject matter is not at all cut and dry. It's
important to acknowledge that:

  * Weight-based stigma is real and causes harm to health through
  multiple mechanisms including at least discrimination and health
  care practitioners' attitudes and behaviors:
    * https://ajph.aphapublications.org/doi/full/10.2105/AJPH.2009.159491
    * https://onlinelibrary.wiley.com/doi/full/10.1111/obr.12266 
  * The decision by health organizations to classify obesity as a "disease" is debated:
    * https://www.healthline.com/health/is-obesity-a-disease 
  * The language and terminology that we use can perpetuate stigma:
    * https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5051141/?report=classic
    * https://news.yale.edu/2012/07/12/choosing-words-wisely-when-talking-patients-about-their-weight 

If anything, what I hope you take away from this aside is that data do not speak
for themselves, but rather are subject to interpretation and leave room for
either the perpetuation or casting aside of pre-existing biases (See "Data Never Speak for Themselves"
from Nancy Krieger's article [*Structural Racism, Health Inequities, and the Two-Edged Sword of Data: Structural Problems Require Structural Solutions*](https://www.frontiersin.org/articles/10.3389/fpubh.2021.655447/full)). It's not
enough to engage with open-science practices and leverage sophisticated 
statistical analyses made possible in programs like R; instead, it's necessary to
combine advances in the state of the art in computing with advances in our 
conceptual frameworks to do science that can truly shift narratives in ways that 
benefit marginalized groups.