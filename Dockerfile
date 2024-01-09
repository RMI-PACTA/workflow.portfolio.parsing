FROM rocker/r-ver:4.3.2

# set Docker image labels
LABEL org.opencontainers.image.source=https://github.com/RMI-PACTA/workflow.portfolio.parsing
LABEL org.opencontainers.image.description="Prepare portfolios to be processed by PACTA"
LABEL org.opencontainers.image.licenses=MIT
LABEL org.opencontainers.image.title=""
LABEL org.opencontainers.image.revision=""
LABEL org.opencontainers.image.version=""
LABEL org.opencontainers.image.vendor=""
LABEL org.opencontainers.image.base.name=""
LABEL org.opencontainers.image.ref.name=""
LABEL org.opencontainers.image.authors=""

# set frozen CRAN repo
ARG CRAN_REPO="https://packagemanager.posit.co/cran/__linux__/jammy/2023-10-30"
ARG R_HOME="/usr/local/lib/R"
RUN echo "options(repos = c(CRAN = '$CRAN_REPO'), pkg.sysreqs = FALSE)" >> "${R_HOME}/etc/Rprofile.site" 

# Install R dependencies
COPY DESCRIPTION /workflow.portfolio.parser/DESCRIPTION

# install pak, find dependencises from DESCRIPTION, and install them.
RUN Rscript -e "\
    install.packages('pak'); \
    deps <- pak::local_deps(root = '/workflow.portfolio.parser'); \
    pkg_deps <- deps[!deps[['direct']], 'ref']; \
    pak::pak(pkg_deps); \
    "

# copy in everything from this repo
COPY . /workflow.portfolio.parser

RUN Rscript -e "pak::pak('local::/workflow.portfolio.parser')" \
  && Rscript -e "remove.packages('pak')"

# set default run behavior
CMD ["Rscript", "-e", "logger::log_threshold(Sys.getenv('LOG_LEVEL', 'INFO'));workflow.portfolio.parsing::process_directory('/mnt/input')"]

# Don't run as root
RUN useradd -m portfolio-parser
USER portfolio-parser
WORKDIR /home/portfolio-parser
