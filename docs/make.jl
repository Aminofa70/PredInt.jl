using PredInt
using Documenter

DocMeta.setdocmeta!(PredInt, :DocTestSetup, :(using PredInt); recursive=true)

makedocs(;
    modules=[PredInt],
    authors="Aminofa70 <amin.alibakhshi@upm.es> and contributors",
    sitename="PredInt.jl",
    format=Documenter.HTML(;
        canonical="https://Aminofa70.github.io/PredInt.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Aminofa70/PredInt.jl",
    devbranch="main",
)
