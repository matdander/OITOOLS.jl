
include("oitools.jl");
using MultiNest
oifitsfile = "AlphaCenA.oifits";
data = (readoifits(oifitsfile))[1,1];

function loglike_v2(cube::Vector{Cdouble}, context::Array{Float64, 1})
    nv2 = Int.((length(context)-1)/3)
    #v2_baseline = context[2:nv2+1];
    #v2 = context[nv2+2:2*nv2+1];
    #v2_err = context[2*nv2+2:end];
    diameter = cube[1]*context[1]+5.
    cube[1] = diameter
    return -0.5 * nv2 * log(2*pi) - 0.5*sum(log.(context[2*nv2+2:end])) - 0.5 * norm( (abs2.(visibility_ud(diameter,context[2:nv2+1]))-context[nv2+2:2*nv2+1])./context[2*nv2+2:end])^2
end

function dumper(physlive::Array{Cdouble, 2},posterior::Array{Cdouble, 2}, paramconstr::Array{Cdouble, 2},
    maxloglike::Cdouble,logz::Cdouble, inslogz::Cdouble, logzerr::Cdouble, context::Array{Cdouble,1})
    println(size(posterior, 1), " samples and logZ= ",logz, " +/- ", logzerr);
    println("Uniform disc size:", paramconstr);

    #	 paramConstr(4*nPar):
    #   paramConstr(1) to paramConstr(nPar)	     	= mean values of the parameters
    #   paramConstr(nPar+1) to paramConstr(2*nPar)    	= standard deviation of the parameters
    #   paramConstr(nPar*2+1) to paramConstr(3*nPar)  	= best-fit (maxlike) parameters
    #   paramConstr(nPar*4+1) to paramConstr(4*nPar)  	= MAP (maximum-a-posteriori) parameters

end

context = [10.0; data.v2_baseline;data.v2;data.v2_err]


nest = nested(loglike_v2, 1, "chains/eggbox_context_jl-",
    ins = true,  # do Nested Importance Sampling?
    mmodal = false, # do mode separation?
    ceff = false,  # run in constant efficiency mode?
    nlive = 1000,  # number of live points
    efr = 0.8,  # set the required efficiency
    tol = 10.,  # tol, defines the stopping criteria
    npar = 1,   # total no. of parameters including free & derived parameters
    nclspar = 1, # no. of parameters to do mode separation on
    updint = 1000, # after how many iterations feedback is required & the output files should be updated
                 # note: posterior files are updated & dumper routine is called after every updInt*10 iterations
    ztol = -1E90, # all the modes with logZ < Ztol are ignored
    maxmodes = 10, # expected max no. of modes (used only for memory allocation)
    wrap = false, # which parameters to have periodic boundary conditions?
    seed = -1, # random no. generator seed, if < 0 then take the seed from system clock
    fb = true, # need feedback on standard output?
    resume = false, # resume from a previous job?
    outfile = true, # write output files?
    initmpi = true, # initialize MPI routines?, relevant only if compiling with MPI
    logzero = nextfloat(-Inf), # points with loglike < logZero will be ignored by MultiNest
    maxiter = 0,
    dumper = dumper,
    context = context
)

# run MultiNest
@time run(nest)
