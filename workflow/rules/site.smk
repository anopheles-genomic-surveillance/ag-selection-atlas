rule build_site:
    input:
        "docs/_config.yml",
        "docs/_toc.yml",
        get_selection_atlas_site_pages,
        config = configpath,
    output:
        directory("docs/_build")
    log:    
        "logs/build-jupyter-book.log"
    shell:
        """
        jupyter-book build docs
        ln -sf docs/_build/html/index.html selection-atlas.html
        """

rule generate_toc:
    input:
        nb = f"{workflow.basedir}/notebooks/generate-toc.ipynb",
        cohorts_geojson = "build/final_cohorts.geojson",
        config = configpath,
        kernel=".kernel.set"
    output:
        nb = "build/notebooks/generate-toc.ipynb",
        toc = "docs/_toc.yml",
    log:
        "logs/generate_toc.log"
    shell:
        """
        papermill {input.nb} {output.nb} -k selection-atlas -f {input.config} 2> {log}
        """

rule home_page:
    input:
        nb = f"{workflow.basedir}/notebooks/home-page.ipynb",
        config = configpath,
        cohorts_geojson = "build/final_cohorts.geojson",
        kernel=".kernel.set"
    output:
        nb = "docs/home-page.ipynb"
    log:
        "logs/home_page.log"
    shell:
        """
        papermill {input.nb} {output.nb} -k selection-atlas 2> {log}
        """

rule country_pages:
    input:
        nb = f"{workflow.basedir}/notebooks/country-page.ipynb",
        config = configpath,
        cohorts_geojson = "build/final_cohorts.geojson",
        kernel=".kernel.set"
    output:
        nb = "build/notebooks/country/{country}.ipynb"
    log:
        "logs/country_pages/{country}.log"
    shell:
        """
        papermill {input.nb} {output.nb} -k selection-atlas -p country {wildcards.country} 2> {log}
        """

rule chromosome_pages:
    input:
        nb = f"{workflow.basedir}/notebooks/chromosome-page.ipynb",
        config = configpath,
        cohorts_geojson = "build/final_cohorts.geojson",
        signals = get_h12_signal_detection_csvs,
        kernel=".kernel.set"
    output:
        nb = "build/notebooks/genome/ag-{chrom}.ipynb"
    log:
        "logs/chromosome_pages/{chrom}.log"
    shell:
        """
        papermill {input.nb} {output.nb} -k selection-atlas -p contig {wildcards.chrom} 2> {log}
        """

rule cohort_pages:
    input:
        nb = f"{workflow.basedir}/notebooks/cohort-page.ipynb",
        cohorts_geojson = "build/final_cohorts.geojson",
        output_h12="build/notebooks/h12-gwss-{cohort}.ipynb",
        output_g123="build/notebooks/g123-gwss-{cohort}.ipynb",
        output_ihs="build/notebooks/ihs-gwss-{cohort}.ipynb",
        config = configpath,
        signals = expand("build/h12-signal-detection/{{cohort}}_{contig}.csv", contig=chromosomes),
        kernel=".kernel.set"
    output:
        nb = "build/notebooks/cohort/{cohort}.ipynb",
    log:
        "logs/cohort_pages/{cohort}.log"
    shell:
        """
        papermill {input.nb} {output.nb} -k selection-atlas -p cohort_id {wildcards.cohort} -f {input.config} 2> {log}
        """
