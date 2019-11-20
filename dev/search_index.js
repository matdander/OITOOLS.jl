var documenterSearchIndex = {"docs":
[{"location":"examples/intro/#Running-examples-1","page":"Running examples","title":"Running examples","text":"","category":"section"},{"location":"examples/intro/#","page":"Running examples","title":"Running examples","text":"We provide several example scripts to use OIFITS in the /demos/ folder. Data used by examples is located in the /demos/data folder. Examples are meant to be run from the /demos/ folder but can be easily modified to do otherwise.","category":"page"},{"location":"examples/intro/#","page":"Running examples","title":"Running examples","text":"demos/\n├── example_limb_darkening.jl\n├── example_image_and_model.jl\n├── data\n│   └── 2004-data1.oifits\n│   └── AlphaCenA.oifits\n...","category":"page"},{"location":"examples/plotting/#Plotting-OIFITS-data-1","page":"Plotting OIFITS data","title":"Plotting OIFITS data","text":"","category":"section"},{"location":"examples/plotting/#","page":"Plotting OIFITS data","title":"Plotting OIFITS data","text":"example_image_and_model.jl    : given OIFITS data and a model image, compute the chi2, and plot the interferometric observables\nexample_fancyplots.jl : colored plots","category":"page"},{"location":"examples/modeling/#Model-fitting-data-1","page":"Model fitting data","title":"Model fitting data","text":"","category":"section"},{"location":"examples/modeling/#Simple-model-fitting-1","page":"Model fitting data","title":"Simple model fitting","text":"","category":"section"},{"location":"examples/modeling/#","page":"Model fitting data","title":"Model fitting data","text":"example_limb_darkening_fit.jl : given OIFITS data, do model-fitting (uniform disc, limb-darkened disc) example_satlas_fit.jl         : model OIFITS data using a SATLAS model (open-source stellar atmosphere model code)","category":"page"},{"location":"examples/modeling/#Bootstrapping-errors-in-fits-1","page":"Model fitting data","title":"Bootstrapping errors in fits","text":"","category":"section"},{"location":"examples/modeling/#","page":"Model fitting data","title":"Model fitting data","text":"example_bootstrap_fit.jl      : use the boostrap method to estimate error bars","category":"page"},{"location":"examples/modeling/#Bayesian-model-selection-1","page":"Model fitting data","title":"Bayesian model selection","text":"","category":"section"},{"location":"examples/modeling/#","page":"Model fitting data","title":"Model fitting data","text":"example_nested_sampling_fit.jl: use Bayesian model selection via nested sampling to compare limb-darkening laws","category":"page"},{"location":"examples/simulating/#Simulating-observations-1","page":"Simulating observations","title":"Simulating observations","text":"","category":"section"},{"location":"examples/simulating/#Simulating-CHARA-observations-1","page":"Simulating observations","title":"Simulating CHARA observations","text":"","category":"section"},{"location":"examples/simulating/#","page":"Simulating observations","title":"Simulating observations","text":"example_chara_plan.jl: check if a target is in delay for given observation dates.","category":"page"},{"location":"examples/simulating/#Simulating-data-from-observation-dates-1","page":"Simulating observations","title":"Simulating data from observation dates","text":"","category":"section"},{"location":"examples/simulating/#","page":"Simulating observations","title":"Simulating observations","text":"example_fakedata_hourangle.jl: simulate observations from target image and Hour Angle, write OIFITS data to file","category":"page"},{"location":"examples/simulating/#Simulating-data-based-on-existing-dataset-1","page":"Simulating observations","title":"Simulating data based on existing dataset","text":"","category":"section"},{"location":"examples/simulating/#","page":"Simulating observations","title":"Simulating observations","text":"example_fakedata_databased.jl : simulate observations from target image and already existing OIFITS","category":"page"},{"location":"install/#Installation-1","page":"Installation","title":"Installation","text":"","category":"section"},{"location":"install/#","page":"Installation","title":"Installation","text":"From a fresh Julia >1.1 installation, use the package manager (] key) then do:","category":"page"},{"location":"install/#","page":"Installation","title":"Installation","text":"add PyCall PyPlot LaTeXStrings FITSIO Libdl NLopt NFFT SpecialFunctions NearestNeighbors https://github.com/fabienbaron/OIFITS.jl#t4 https://github.com/emmt/ArrayTools.jl.git https://github.com/emmt/LazyAlgebra.jl.git https://github.com/emmt/OptimPackNextGen.jl.git https://github.com/fabienbaron/OITOOLS.jl.git","category":"page"},{"location":"install/#","page":"Installation","title":"Installation","text":"info: Info\nOITOOLS uses the OIFITS, NFFT, SpecialFunctions and NearestNeighbors packages. For model fitting, NLopt (derivative-free local and global optimizers) and Multinest (model selection) are used. DNest4 is likely to replace Multinest soon. For image reconstruction, we use OptimPackNextGen written by Éric Thiébaut.","category":"page"},{"location":"#OITOOLS-framework-1","page":"Home","title":"OITOOLS framework","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"This is the documentation for OITOOLS, a Julia package for optical interferometry. The sources are here.","category":"page"},{"location":"#","page":"Home","title":"Home","text":"warning: Warning\nOITOOLS is still undergoing heavy development, and work on documentation is just starting.","category":"page"},{"location":"#Index-1","page":"Home","title":"Index","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"","category":"page"},{"location":"examples/reading/#Reading-OIFITS-files-1","page":"Reading OIFITS files","title":"Reading OIFITS files","text":"","category":"section"},{"location":"examples/reading/#Simple-files-1","page":"Reading OIFITS files","title":"Simple files","text":"","category":"section"},{"location":"examples/reading/#","page":"Reading OIFITS files","title":"Reading OIFITS files","text":"One target per file, reading all the data at once.","category":"page"},{"location":"examples/reading/#Filtering-imported-data-1","page":"Reading OIFITS files","title":"Filtering imported data","text":"","category":"section"},{"location":"examples/reading/#","page":"Reading OIFITS files","title":"Reading OIFITS files","text":"example_npoi_target_filter.jl : how to select only a given target within an OIFITS, and filter bad SNR data","category":"page"},{"location":"examples/reading/#Importing-polychromatic-or-time-variable-data-1","page":"Reading OIFITS files","title":"Importing polychromatic or time-variable data","text":"","category":"section"},{"location":"examples/imaging/#Imaging-1","page":"Imaging","title":"Imaging","text":"","category":"section"},{"location":"examples/imaging/#","page":"Imaging","title":"Imaging","text":"example_image_reconstruction_dft.jl  : gradient-based image reconstruction using the exact DFT\nexample_image_reconstruction_nfft.jl : gradient-based image reconstruction using fast yet accurate NFFT\nexample_image_reconstruction_lcurve.jl : l-curve method to determine the regularization factor\nexample_image_reconstruction_multitemporal.jl : gradient-based image reconstruction for time-variable images, with temporal regularization\nexample_image_reconstruction_multiwavelength.jl : (upcoming) gradient-based image reconstruction for spectrally dependent images, with transpectral regularization","category":"page"}]
}
