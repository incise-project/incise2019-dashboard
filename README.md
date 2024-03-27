# InCiSE 2019 Dashboard

This repository contains source code needed to produce an interactive
dashboard of the InCiSE 2019 results. You can see the live dashboard
[here](https://incise-project.github.io/incise2019-dashboard).

## About

From 2016 to 2019, the
[International Civil Service Effectiveness (InCiSE) project](https://www.bsg.ox.ac.uk/incise)
was a collaboration between the
[Blavatnik School of Government](https://www.bsg.ox.ac.uk) and the
[Institute for Government](http://instituteforgovernment.org.uk).
It was supported by the UK Civil Service (through the
[Cabinet Office](https://www.gov.uk/cabinetoffice)) and funded by the
[Open Society Foundations](https://www.opensocietyfoundations.org).

The Blavatnik School of Government is re-establishing the InCiSE project with
the aim of publishing a new edition of the InCiSE Index in 2024. To support
engagement with stakeholders the School is re-publishing the 2019 project
outputs (this dashboard, the
[Results Report](https://incise-project.github.io/incise2019-results/), and the
[Technical Report](https://incise-project.github.io/incise2019-techreport/))

## Citation

Please refer to and cite the original PDF publication:

> InCiSE Partners (2019) The International Civil Service Effectiveness (InCiSE)
> Index: Technical Report 2019, Oxford: Blavatnik School of Government,
> University of Oxford, https://www.bsg.ox.ac.uk/incise

## Copyright & licensing

The original report content and data are the joint copyright of the InCiSE
Partners - the Blavatnik School of Government (University of Oxford),
the Institute for Government, and the UK Civil Service (through the Cabinet
Office). The report content contained in this reproduction is released under
the [CC-BY-4.0](LICENSE) license.

New content included in this publication (i.e. content not included in the
original report) is the sole copyright of the Blavatnik School of Government,
University of Oxford and is also released under the [CC-BY-4.0](LICENSE).

The source code to process data and produce the report is released under the
[MIT License](LICENSE-CODE).

## Developer notes

This re-production of the report has been made in [Quarto](http://quarto.org)
with [R](https://r-project.org).

### Quarto publishing

The book is rendered and published to GitHub Pages using GitHub Actions.
Note computations are processed locally and
[frozen](https://quarto.org/docs/publishing/github-pages.html#freezing-computations)
by Quarto.
