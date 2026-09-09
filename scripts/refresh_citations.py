from semanticscholar import SemanticScholar
import pandas as pd
import click


@click.command('refresh_citations')
@click.argument('path_to_data', type=str)
def refresh_citations(path_to_data: str):
    """Refresh citation counts for studies in the given CSV file using the Semantic Scholar API.

    Args:
        path_to_data (str): Path to the CSV file containing study data.
    """
    # load studies
    data = pd.read_csv(path_to_data)
    implemented = data["Implemented"] == 1
    sch_key = "Semantic Scholar ID"
    # check for missing Semantic Scholar IDs
    if len(data.loc[implemented & data[sch_key].isna()]) > 0:
        print("WARNING: Semantic Scholar ID is NA for studies", data.loc[implemented & data[sch_key].isna()]["study-id"].tolist())
    # query Semantic Scholar for citation counts (implemented studies with non-NA Semantic Scholar IDs)
    sch = SemanticScholar()
    to_query = implemented & data[sch_key].notna()
    sch_ids = data.loc[to_query, sch_key].tolist()
    papers = sch.get_papers(
        sch_ids,
        fields=['title', 'authors', 'citationCount']
    )
    for paper in papers:
        authors = "" if len(paper.authors) == 0 else paper.authors[0].name
        print(paper.citationCount, "cites to", authors, paper.title)
    # add to dataset and rewrite to CSV
    citation_counts = [paper.citationCount for paper in papers]
    data["Semantic Scholar Citation Count"] = pd.Series(dtype='int')
    data.loc[to_query, "Semantic Scholar Citation Count"] = citation_counts
    data.to_csv(path_to_data, index=False)
    print("Wrote citations to", path_to_data)


if __name__ == '__main__':
    refresh_citations()
