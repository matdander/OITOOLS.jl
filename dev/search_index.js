var documenterSearchIndex = {"docs":
[{"location":"examples/#Examples-1","page":"Examples","title":"Examples","text":"","category":"section"},{"location":"examples/#","page":"Examples","title":"Examples","text":"We provide several example files in the demos/ subfolder:","category":"page"},{"location":"examples/#","page":"Examples","title":"Examples","text":"exampleimageand_model.jl    : given OIFITS data and a model image, compute the chi2, and plot the interferometric observables\nexamplelimbdarkening_fit.jl : given OIFITS data, do model-fitting (uniform disc, limb-darkened disc)\nexamplesatlasfit.jl         : model OIFITS data using a SATLAS model (open-source stellar atmosphere model code)\nexamplenestedsampling_fit.jl: use Bayesian model selection via nested sampling to compare limb-darkening laws\nexamplebootstrapfit.jl      : use the boostrap method to estimate error bars\nexamplenpoitarget_filter.jl : how to select only a given target within an OIFITS, and filter bad SNR data\nexamplefakedatahourangle.jl : simulate observations from target image and Hour Angle, write OIFITS data to file\nexamplefakedatadatabased.jl : simulate observations from target image and already existing OIFITS\nexampleimagereconstruction_dft.jl  : gradient-based image reconstruction using the exact DFT\nexampleimagereconstruction_nfft.jl : gradient-based image reconstruction using fast yet accurate NFFT\nexampleimagereconstruction_lcurve.jl : l-curve method to determine the regularization factor\nexampleimagereconstruction_epll.jl  : gradient-based image reconstruction using machine-learned priors (work in progress)\nexampleimagereconstruction_multitemporal.jl : gradient-based image reconstruction for time-variable images, with temporal regularization\nexampleimagereconstruction_multiwavelength.jl : (upcoming) gradient-based image reconstruction for spectrally dependent images, with transpectral regularization\nexample_oifitslib.jl                  : (upcoming) an interface to John Young's OIFITSLIB utilities (oimerge, oifilter, oicheck)","category":"page"},{"location":"install/#Manual-Installation-1","page":"Manual Installation","title":"Manual Installation","text":"","category":"section"},{"location":"install/#","page":"Manual Installation","title":"Manual Installation","text":"From a fresh Julia >1.1 installation, use the package manager (] key) then do:","category":"page"},{"location":"install/#","page":"Manual Installation","title":"Manual Installation","text":"add PyCall PyPlot LaTeXStrings FITSIO Libdl NLopt NFFT SpecialFunctions NearestNeighbors https://github.com/fabienbaron/OIFITS.jl#t4 https://github.com/emmt/ArrayTools.jl.git https://github.com/emmt/LazyAlgebra.jl.git https://github.com/emmt/OptimPackNextGen.jl.git https://github.com/fabienbaron/OITOOLS.jl.git","category":"page"},{"location":"install/#","page":"Manual Installation","title":"Manual Installation","text":"info: Info\n","category":"page"},{"location":"install/#","page":"Manual Installation","title":"Manual Installation","text":"OITOOLS uses the OIFITS, NFFT, SpecialFunctions and NearestNeighbors packages. For model fitting, NLopt (derivative-free local and global optimizers) and Multinest (model selection) are used. DNest4 is likely to replace Multinest soon. For image reconstruction, we use OptimPackNextGen.","category":"page"},{"location":"#OITOOLS-framework-1","page":"OITOOLS framework","title":"OITOOLS framework","text":"","category":"section"},{"location":"#","page":"OITOOLS framework","title":"OITOOLS framework","text":"This is the documentation for OITOOLS, a Julia package for optical interferometry. The sources are here.","category":"page"},{"location":"#","page":"OITOOLS framework","title":"OITOOLS framework","text":"warning: Warning\n","category":"page"},{"location":"#","page":"OITOOLS framework","title":"OITOOLS framework","text":"OITOOLS is in heavy development.","category":"page"},{"location":"#Contents-1","page":"OITOOLS framework","title":"Contents","text":"","category":"section"},{"location":"#","page":"OITOOLS framework","title":"OITOOLS framework","text":"Pages = [\"install.md\", \"examples.md\"]","category":"page"},{"location":"#Index-1","page":"OITOOLS framework","title":"Index","text":"","category":"section"},{"location":"#","page":"OITOOLS framework","title":"OITOOLS framework","text":"","category":"page"}]
}
