global HOMALG_PROJECT_PATH = dirname(@__DIR__)

"""
    HomalgProject.PKG_DIR

The directory in which to install bundled
[GAP](https://www.gap-system.org) packages from the github organization
[https://github.com/homalg-project/](https://github.com/homalg-project/).
It is equal to `joinpath(pathof(HomalgProject),"pkg")`.
"""
global PKG_DIR = joinpath(HOMALG_PROJECT_PATH, "pkg")

"""
    DownloadPackageFromHomalgProject(pkgname)

Clone the package named `pkgname` from the github organization
[https://github.com/homalg-project/](https://github.com/homalg-project/) to the subdirectory
[`HomalgProject.PKG_DIR`](@ref).
On success return `true` and on failure `false`.
"""
function DownloadPackageFromHomalgProject(pkgname)

    res = GAP.Globals.LoadPackage(julia_to_gap("PackageManager"), false)
    @assert res
    git = julia_to_gap("git")
    clone = julia_to_gap("clone")

    dir = joinpath(PKG_DIR, pkgname)

    if isdir(dir)
        return true
    end

    @info "Cloning into \"" * dir * "\""
    pkgname = julia_to_gap("https://github.com/homalg-project/" * pkgname)
    pkgname =
        GAP.Globals.PKGMAN_Exec(julia_to_gap("."), git, clone, pkgname, julia_to_gap(dir))

    if pkgname.code != 0
        @warn "Cloning failed:\n" * gap_to_julia(pkgname.output)
        return false
    end

    return true

end

export DownloadPackageFromHomalgProject

"""
    UpdatePackageFromHomalgProject(pkgname)

Update the package named `pkgname` located in the subdirectory
[`HomalgProject.PKG_DIR`](@ref) from the github organization
[https://github.com/homalg-project/](https://github.com/homalg-project/).
If the package directory does not exist locally then invoke
[`DownloadPackageFromHomalgProject`](@ref)(`pkgname`).
On success return `true` and on failure `false`.
"""
function UpdatePackageFromHomalgProject(pkgname)

    res = GAP.Globals.LoadPackage(julia_to_gap("PackageManager"), false)
    @assert res
    git = julia_to_gap("git")
    pull = julia_to_gap("pull")

    dir = joinpath(PKG_DIR, pkgname)

    if !isdir(dir)
        return DownloadPackageFromHomalgProject(pkgname)
    end

    @info "Updating \"" * dir * "\""
    pkgname =
        GAP.Globals.PKGMAN_Exec(julia_to_gap(dir), git, pull, julia_to_gap("--ff-only"))

    if pkgname.code != 0
        @warn "Updating failed:\n" * gap_to_julia(pkgname.output)
        return false
    end

    @info gap_to_julia(pkgname.output)
    return true

end

export UpdatePackageFromHomalgProject

"""
    RemovePackageFromHomalgProject(pkgname)

Delete the package named `pkgname` from the subdirectory
[`HomalgProject.PKG_DIR`](@ref).
On success return `true` and on failure `false`.
Removing a package and re-downloading it might be useful if udpating it fails.
"""
function RemovePackageFromHomalgProject(pkgname)

    res = GAP.Globals.LoadPackage(julia_to_gap("PackageManager"), false)
    @assert res
    rm = julia_to_gap("rm")
    opt = julia_to_gap("-rf")

    dir = joinpath(PKG_DIR, pkgname)

    if !isdir(dir)
        return false
    end

    @info "Removing \"" * dir * "\""
    pkgname = GAP.Globals.PKGMAN_Exec(julia_to_gap("."), rm, opt, julia_to_gap(dir))

    if pkgname.code != 0
        @warn "Remving failed:\n" * gap_to_julia(pkgname.output)
        return false
    end

    return true

end

export RemovePackageFromHomalgProject

##
global PACKAGES_BASED_ON_HOMALG = [
    "homalg_project",
    "OscarForHomalg",
    ##
    "alcove",
    "AlgebraicThomas",
    "ArangoDBInterface",
    "Blocks",
    "D-Modules",
    "LessGenerators",
    "LoopIntegrals",
    "MatroidGeneration",
    "NConvex",
    "ParallelizedIterators",
    "PrimaryDecomposition",
    "Sheaves",
]

##
global PACKAGES_BASED_ON_CAP = [
    "CAP_project",
    ##
    "Algebroids",
    "CategoryConstructor",
    "CategoriesWithAmbientObjects",
    "CatReps",
    "FinSetsForCAP",
    "FinGSetsForCAP",
    "FunctorCategories",
    "GradedCategories",
    "HigherHomologicalAlgebra",
    "IntrinsicCategories",
    "IntrinsicModules",
    "InternalModules",
    "LazyCategories",
    "Locales",
    "QPA2",
    "SubcategoriesForCAP",
    "Toposes",
    "ZariskiFrames",
]

##
global PACKAGES_NEEDED = [
    ##
    "InfiniteLists",
]

"""
    HomalgProject.PACKAGES_TO_DOWNLOAD

List of packages which will be considered by
* [`DownloadAllPackagesFromHomalgProject`](@ref)()
* [`UpdateAllPackagesFromHomalgProject`](@ref)()
* [`RemoveAllPackagesFromHomalgProject`](@ref)()
"""
global PACKAGES_TO_DOWNLOAD = vcat(PACKAGES_BASED_ON_HOMALG, PACKAGES_BASED_ON_CAP, PACKAGES_NEEDED)

"""
    HomalgProject.PACKAGES_DEPRECATED

List of packages deprecated packages.
"""
global PACKAGES_DEPRECATED = [
    "BBGG",
    "Bicomplexes",
    "ComplexesCategories",
    "DerivedCategories",
    "FrobeniusCategories",
    "HomotopyCategories",
    "ModelCategories",
    "QuotientCategories",
    "StableCategories",
    "TriangulatedCategories",
]

"""
    DownloadAllPackagesFromHomalgProject()

Apply [`DownloadPackageFromHomalgProject`](@ref) to all packages
listed in [`PACKAGES_TO_DOWNLOAD`](@ref).
"""
function DownloadAllPackagesFromHomalgProject()

    for pkg in PACKAGES_TO_DOWNLOAD
        DownloadPackageFromHomalgProject(pkg)
    end

end

export DownloadAllPackagesFromHomalgProject

"""
    UpdateAllPackagesFromHomalgProject()

Apply [`UpdatePackageFromHomalgProject`](@ref) to all packages listed
in [`PACKAGES_TO_DOWNLOAD`](@ref).
"""
function UpdateAllPackagesFromHomalgProject()

    for pkg in PACKAGES_TO_DOWNLOAD
        UpdatePackageFromHomalgProject(pkg)
    end

end

export UpdateAllPackagesFromHomalgProject

"""
    RemoveAllPackagesFromHomalgProject()

Apply [`RemovePackageFromHomalgProject`](@ref) to all packages listed
in [`PACKAGES_TO_DOWNLOAD`](@ref).
"""
function RemoveAllPackagesFromHomalgProject()

    for pkg in PACKAGES_TO_DOWNLOAD
        RemovePackageFromHomalgProject(pkg)
    end

end

export RemoveAllPackagesFromHomalgProject

"""
    RemoveDeprecatedPackagesFromHomalgProject()

Apply [`RemovePackageFromHomalgProject`](@ref) to all packages listed
in [`PACKAGES_DEPRECATED`](@ref).
"""
function RemoveDeprecatedPackagesFromHomalgProject()

    for pkg in PACKAGES_DEPRECATED
        RemovePackageFromHomalgProject(pkg)
    end

end

export RemoveDeprecatedPackagesFromHomalgProject

"""
    HomalgProject.PACKAGES_TO_COMPILE

The list of all [GAP](https://www.gap-system.org) packages that will
downloaded (once) and installed by `GAP.Packages.install` when `using
Pkg; Pkg.build("HomalgProject")` is invoked.  The latter should be
called once `GAP.jl` gets updated.
"""
global PACKAGES_TO_COMPILE = [
    "Gauss",
    #"Browse", ## do not compile browse as it results into GAP raising the error "Error opening terminal: xterm-256color."
    "io",
    "grape",
    "digraphs",
    "ferret",
    "json",
    "orb",
]

global PACKAGES_DOWNLOADING_EXTERNAL_CODE = ["CddInterface", "NormalizInterface"]
