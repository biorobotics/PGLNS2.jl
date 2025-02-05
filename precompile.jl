using PackageCompiler
using Pkg
Pkg.activate(expanduser("~/GLNS_lazy_edge_eval.jl"))
using GLNS

create_sysimage(["GLNS"]; sysimage_path="GLNS.so",precompile_execution_file="precompilation_script.jl")
