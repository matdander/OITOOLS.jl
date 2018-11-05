using OITOOLS


#
#EXAMPLE 8
#Simulate an observation using an input image, given telescope parameters, and input hour angles

dates=[2018  3 5 10 13 56.7; 2018 3 5 10 15 56.7]
longitude=118.0570313111
ra=[20,57,59.44]
dec=46.4668258840408
lsts,hour_angles=hour_angle_calc(dates,longitude,ra)
lst_hours=floor.(lsts)
lstmin=floor.((lsts.-floor.(lsts)).*60)
lstsec=(((lsts.-floor.(lsts)).*60)-floor.(lstmin))*60
facility_config_file="./data/example_facility_config.txt"
obsv_config_file="./data/example_obs_config.txt"
combiner_config_file="./data/example_combiner_config.txt"
wave_config_file="./data/example_wave_config.txt"

image_file="./data/testmask.fits" #A 4.0 mas disk at 0.1 pix/mas in 64x64 grid
pixsize=0.1
out_file="!./data/test_ha_sim.oifits"
hour_angles=range(-1.07,stop=2.39,length=(38))
simulate_ha(facility_config_file,obsv_config_file,combiner_config_file,wave_config_file,hour_angles,dec,image_file,pixsize,out_file)

#Compare simulated data to impate

#display the image
fitsfile = "./data/testmask.fits";
pixsize = 0.101; # in mas/pixel
x_true = readfits(fitsfile); nx = (size(x_true))[1]; x_true=vec(x_true);
imdisp(x_true, pixscale = pixsize, tickinterval = 1.0, beamsize = 1.0, beamlocation = [0.85, 0.85])

#read the data file

oifitsfile = "./data/test_ha_sim.oifits";
data = (readoifits(oifitsfile))[1,1]; # data can be split by wavelength, time, etc.
uvplot(data);
v2plot(data,logplot=true);# Alternatively, one can do v2plot(data.v2_baseline,data.v2,data.v2_err,logplot=true);
t3phiplot(data);

# Setup Fourier transform via DFT
dft = setup_dft(data, nx, pixsize);
# This computes the complete chi2
f_chi2 = chi2_dft_f(x_true, dft, data);
# Compute |V|^2 observables and plot
cvis_model = image_to_cvis_dft(x_true, dft);
v2_model = cvis_to_v2(cvis_model, data.indx_v2);
v2plot_modelvsdata(data.v2_baseline,data.v2,data.v2_err, v2_model);

# NFFT method
ft = setup_nfft(data, nx, pixsize);
# This computes the complete chi2
f_chi2 = chi2_nfft_f(x_true, ft, data);
# Compute |V|^2 observables and plot
cvis_model = image_to_cvis_nfft(x_true, ft);
v2_model = cvis_to_v2(cvis_model, data.indx_v2);
v2plot_modelvsdata(data.v2_baseline,data.v2,data.v2_err, v2_model);